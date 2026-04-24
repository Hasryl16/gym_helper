import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import 'widgets/cue_banner.dart';
import 'widgets/form_score_hud.dart';
import 'widgets/rep_counter_hud.dart';
import 'widgets/skeleton_painter.dart';

/// Full-screen camera view with skeleton overlay and real-time HUDs.
class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  // Guard so that navigation to the summary screen only fires once, even if
  // the widget rebuilds while the session is in the summary state.
  bool _navigatedToSummary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  Future<void> _startSession() async {
    if (!mounted) return;
    final auth = context.read<AppAuthProvider>();
    final session = context.read<WorkoutSessionProvider>();
    final uid = auth.user?.uid;
    if (uid != null) {
      await session.startSession(uid);
    }
  }

  Future<bool> _onWillPop() async {
    final session = context.read<WorkoutSessionProvider>();
    if (session.sessionState == SessionState.active) {
      await session.stopSession();
    }
    return true;
  }

  Future<void> _handleStop() async {
    final session = context.read<WorkoutSessionProvider>();
    await session.stopSession();
    if (mounted) context.go(RouteNames.workoutSummary);
  }

  Future<void> _handleSwitchCamera() async {
    final session = context.read<WorkoutSessionProvider>();
    await session.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutSessionProvider>();
    final camera = session.cameraController;

    // Navigate to summary when session transitions to summary state.
    // The _navigatedToSummary guard ensures this fires at most once,
    // even across multiple rebuilds while the state is still summary.
    if (!_navigatedToSummary && session.sessionState == SessionState.summary) {
      _navigatedToSummary = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouteNames.workoutSummary);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final router = GoRouter.of(context);
          final canPop = await _onWillPop();
          if (canPop && mounted) router.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (camera != null && camera.value.isInitialized)
              _CameraPreviewFit(controller: camera)
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentPrimary,
                ),
              ),

            // Skeleton overlay
            if (session.currentPose != null && camera != null && camera.value.isInitialized)
              CustomPaint(
                painter: SkeletonPainter(
                  pose: session.currentPose!,
                  imageSize: Size(
                    camera.value.previewSize?.height ?? 1,
                    camera.value.previewSize?.width ?? 1,
                  ),
                  screenSize: MediaQuery.of(context).size,
                  isFrontCamera: session.isFrontCamera,
                ),
              ),

            // No pose detected indicator
            if (!session.poseDetected && session.sessionState == SessionState.active)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.jointWarn,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'No pose detected — move into frame',
                      style: TextStyle(
                        color: AppColors.jointWarn,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

            // Rep counter — top center
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: RepCounterHud(
                  count: session.repCount,
                  target: session.targetReps,
                ),
              ),
            ),

            // Form score — top right
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: FormScoreHud(score: session.formScore),
            ),

            // Cue banner — bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CueBanner(cue: session.activeCue),
            ),

            // Camera flip button — bottom left
            if (session.canSwitchCamera)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 20,
                child: GestureDetector(
                  onTap: session.isSwitchingCamera ? null : _handleSwitchCamera,
                  child: AnimatedOpacity(
                    opacity: session.isSwitchingCamera ? 0.4 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: session.isSwitchingCamera
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.flip_camera_android_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),

            // Stop FAB — bottom right
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              right: 20,
              child: GestureDetector(
                onTap: _handleStop,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.jointError,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.stop_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills available space with the camera preview, maintaining aspect ratio.
class _CameraPreviewFit extends StatelessWidget {
  const _CameraPreviewFit({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return const SizedBox.expand();

    // Camera preview size is rotated for portrait on Android
    final previewAspect = previewSize.width > previewSize.height
        ? previewSize.height / previewSize.width
        : previewSize.width / previewSize.height;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: 1,
        height: 1 / previewAspect,
        child: CameraPreview(controller),
      ),
    );
  }
}
