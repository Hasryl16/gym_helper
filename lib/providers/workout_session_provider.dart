import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/models/exercise_type.dart';
import '../core/models/session_model.dart';
import '../core/services/angle_calculator.dart';
import '../core/services/form_analyzer.dart';
import '../core/services/pose_service.dart';
import '../core/services/rep_counter.dart';
import '../core/services/session_recorder.dart';
import '../core/services/firestore_service.dart';

enum SessionState {
  idle,
  positionCheck,
  active,
  finalizing,
  summary,
}

/// Owns the camera, pose detection, rep counting, and session recording.
/// Single-lifecycle provider — dispose to release all resources.
class WorkoutSessionProvider extends ChangeNotifier {
  WorkoutSessionProvider();

  // Core services
  CameraController? _cameraController;
  PoseService? _poseService;
  RepCounter? _repCounter;
  SessionRecorder? _sessionRecorder;
  final FirestoreService _firestoreService = FirestoreService();

  // State
  SessionState _sessionState = SessionState.idle;
  ExerciseType _exerciseType = ExerciseType.pushup;
  int _targetReps = 20;
  int _repCount = 0;
  double _formScore = 100.0;
  String? _activeCue;
  SessionModel? _lastSession;
  String? _savedSessionId;
  String? _errorMessage;
  bool _isBusy = false; // guard against concurrent frame processing
  Pose? _currentPose;

  // Getters
  SessionState get sessionState => _sessionState;
  ExerciseType get exerciseType => _exerciseType;
  int get targetReps => _targetReps;
  int get repCount => _repCount;
  double get formScore => _formScore;
  String? get activeCue => _activeCue;
  SessionModel? get lastSession => _lastSession;
  String? get savedSessionId => _savedSessionId;
  String? get errorMessage => _errorMessage;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized =>
      _cameraController?.value.isInitialized ?? false;
  Pose? get currentPose => _currentPose;
  bool get poseDetected => _currentPose != null;

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// Set exercise type and target reps before starting.
  void configureExercise(ExerciseType type, {int targetReps = 20}) {
    _exerciseType = type;
    _targetReps = targetReps;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Camera
  // ---------------------------------------------------------------------------

  /// Initialize the camera controller.
  Future<void> initCamera([List<CameraDescription>? cameras]) async {
    final availableCams = cameras ?? await availableCameras();

    if (availableCams.isEmpty) {
      _errorMessage = 'No camera available on this device.';
      notifyListeners();
      return;
    }

    // Prefer back camera
    final camera = availableCams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => availableCams.first,
    );

    try {
      // Dispose existing controller if any
      await _cameraController?.dispose();

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      _cameraController = controller;
      _poseService = PoseService();
      _sessionState = SessionState.positionCheck;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Camera initialization failed: $e';
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  /// Start recording a session.
  Future<void> startSession(String userId) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _repCounter = RepCounter();
    _sessionRecorder = SessionRecorder(
      userId: userId,
      exerciseType: _exerciseType,
    );
    _repCount = 0;
    _formScore = 100.0;
    _activeCue = null;
    _savedSessionId = null;
    _sessionState = SessionState.active;
    notifyListeners();

    // Start frame streaming
    await _cameraController!.startImageStream(_onFrame);
  }

  /// Stop recording and finalize the session.
  Future<void> stopSession({String? userId}) async {
    if (_sessionState != SessionState.active) return;
    _sessionState = SessionState.finalizing;
    notifyListeners();

    try {
      await _cameraController?.stopImageStream();
    } catch (_) {}

    _lastSession = _sessionRecorder?.finalize();
    _sessionState = SessionState.summary;
    notifyListeners();
  }

  /// Save last session to Firestore and return the session ID.
  Future<String?> saveSession() async {
    final session = _lastSession;
    if (session == null) return null;
    try {
      final id = await _firestoreService.createSession(session);
      _savedSessionId = id;
      notifyListeners();
      return id;
    } catch (e) {
      _errorMessage = 'Failed to save session: $e';
      notifyListeners();
      return null;
    }
  }

  /// Return to idle — ready for a new session.
  void resetSession() {
    _sessionState = SessionState.positionCheck;
    _repCount = 0;
    _formScore = 100.0;
    _activeCue = null;
    _lastSession = null;
    _savedSessionId = null;
    _currentPose = null;
    _repCounter?.reset();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Frame processing
  // ---------------------------------------------------------------------------

  void _onFrame(CameraImage image) {
    if (_isBusy || _sessionState != SessionState.active) return;
    _isBusy = true;

    final rotation = _getInputImageRotation();
    _poseService?.processFrame(image, rotation).then((pose) {
      if (pose == null) {
        _currentPose = null;
        _isBusy = false;
        return;
      }

      _currentPose = pose;
      final event = _repCounter!.processPose(pose);

      if (event == RepEvent.repCompleted) {
        _repCount = _repCounter!.repCount;

        // Analyze form for this rep
        final result = FormAnalyzer.analyzePushup(
          pose,
          _repCounter!.lastMinElbow,
        );

        // Get hip angle for recording
        final hipAngle = AngleCalculator.hipAverage(pose) ?? 180.0;

        _sessionRecorder!.recordRep(
          formScore: result.score,
          errors: result.errors,
          minElbowAngle: _repCounter!.lastMinElbow,
          maxElbowAngle: _repCounter!.lastMaxElbow,
          minHipAngle: hipAngle,
        );

        // Update running form score (rolling average)
        final totalReps = _sessionRecorder!.repCount;
        _formScore = ((_formScore * (totalReps - 1)) + result.score) / totalReps;
        _activeCue = result.activeCue;
      } else {
        // Continuous form feedback even between reps
        final check = FormAnalyzer.analyzePushup(
          pose,
          _repCounter!.lastMinElbow,
        );
        _activeCue = check.activeCue;
      }

      notifyListeners();
      _isBusy = false;

      // Auto-stop when target reached
      if (_repCount >= _targetReps) {
        stopSession();
      }
    }).catchError((_) {
      _isBusy = false;
    });
  }

  InputImageRotation _getInputImageRotation() {
    final sensorOrientation =
        _cameraController?.description.sensorOrientation ?? 0;
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    _poseService?.close();
    super.dispose();
  }
}
