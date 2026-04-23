import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../constants/exercise_rules.dart';

/// Wraps MLKit PoseDetector.
/// Converts CameraImage frames to InputImage, runs pose detection,
/// and applies EMA smoothing on landmark positions.
class PoseService {
  PoseService() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  late final PoseDetector _detector;

  // EMA smoothed landmark positions: landmarkType -> (x, y, z)
  final Map<PoseLandmarkType, _SmoothedPoint> _smoothed = {};

  bool _isClosed = false;

  /// Process a [CameraImage] from the camera plugin.
  /// Returns the detected [Pose] or null if no pose found.
  Future<Pose?> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (_isClosed) return null;

    final inputImage = _toInputImage(image, rotation);
    if (inputImage == null) return null;

    final poses = await _detector.processImage(inputImage);
    if (poses.isEmpty) return null;

    final pose = poses.first;
    return _applyEma(pose);
  }

  /// Convert [CameraImage] to [InputImage] for MLKit.
  /// Handles Android YUV420 → NV21 and iOS BGRA8888.
  InputImage? _toInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      if (Platform.isAndroid) {
        // Convert YUV420 planes to NV21 byte array
        final nv21 = _yuv420ToNv21(image);
        return InputImage.fromBytes(
          bytes: nv21,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      } else if (Platform.isIOS) {
        // iOS provides BGRA8888 directly
        final bytes = image.planes.first.bytes;
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Convert Android YUV_420_888 to NV21 byte array.
  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final ySize = image.width * image.height;
    final uvSize = image.width * image.height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane
    int nv21Index = 0;
    for (int row = 0; row < image.height; row++) {
      final rowOffset = row * yPlane.bytesPerRow;
      for (int col = 0; col < image.width; col++) {
        nv21[nv21Index++] = yPlane.bytes[rowOffset + col];
      }
    }

    // Interleave V and U planes for NV21 (V first)
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 2;
    for (int row = 0; row < image.height ~/ 2; row++) {
      for (int col = 0; col < image.width ~/ 2; col++) {
        final uvOffset = row * uvRowStride + col * uvPixelStride;
        nv21[nv21Index++] = vPlane.bytes[uvOffset]; // V
        nv21[nv21Index++] = uPlane.bytes[uvOffset]; // U
      }
    }

    return nv21;
  }

  /// Apply exponential moving average smoothing to landmark positions.
  Pose _applyEma(Pose pose) {
    const double alpha = ExerciseRules.emaAlpha;
    final smoothedLandmarks = <PoseLandmarkType, PoseLandmark>{};

    for (final entry in pose.landmarks.entries) {
      final type = entry.key;
      final raw = entry.value;

      if (_smoothed.containsKey(type)) {
        final prev = _smoothed[type]!;
        final sx = alpha * raw.x + (1 - alpha) * prev.x;
        final sy = alpha * raw.y + (1 - alpha) * prev.y;
        final sz = alpha * raw.z + (1 - alpha) * prev.z;
        _smoothed[type] = _SmoothedPoint(sx, sy, sz);
        smoothedLandmarks[type] = PoseLandmark(
          type: type,
          x: sx,
          y: sy,
          z: sz,
          likelihood: raw.likelihood,
        );
      } else {
        _smoothed[type] = _SmoothedPoint(raw.x, raw.y, raw.z);
        smoothedLandmarks[type] = raw;
      }
    }

    return Pose(landmarks: smoothedLandmarks);
  }

  /// Release the MLKit detector.
  Future<void> close() async {
    if (!_isClosed) {
      _isClosed = true;
      await _detector.close();
    }
  }
}

class _SmoothedPoint {
  const _SmoothedPoint(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}
