import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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
        model: PoseDetectionModel.base,
      ),
    );
  }

  late final PoseDetector _detector;

  // EMA smoothed landmark positions: landmarkType -> (x, y, z)
  final Map<PoseLandmarkType, _SmoothedPoint> _smoothed = {};

  int _frameCount = 0;
  bool _errorLogged = false;

  bool _isClosed = false;

  /// Process a [CameraImage] from the camera plugin.
  /// Returns the detected [Pose] or null if no pose found.
  Future<Pose?> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (_isClosed) return null;

    final inputImage = _toInputImage(image, rotation);

    _frameCount++;
    if (_frameCount % 90 == 1) {
      debugPrint('[PoseService] frame=$_frameCount '
          'fmt=${image.format.raw} '
          'planes=${image.planes.length} '
          'size=${image.width}x${image.height} '
          'yStride=${image.planes[0].bytesPerRow} '
          'yLen=${image.planes[0].bytes.length} '
          '${image.planes.length > 2 ? "uvStride=${image.planes[1].bytesPerRow} vLen=${image.planes[2].bytes.length}" : ""} '
          'pixelStrides=${image.planes.map((p) => p.bytesPerPixel).toList()} '
          'rotation=$rotation '
          'inputImageNull=${inputImage == null}');
    }

    if (inputImage == null) return null;

    final poses = await _detector.processImage(inputImage);

    if (_frameCount % 90 == 1) {
      debugPrint('[PoseService] poses detected: ${poses.length}');
    }

    if (poses.isEmpty) return null;

    return _applyEma(poses.first);
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
    } catch (e, stack) {
      if (!_errorLogged) {
        _errorLogged = true;
        debugPrint('[PoseService] _toInputImage EXCEPTION: $e\n$stack');
      }
      return null;
    }
  }

  /// Convert Android YUV_420_888 to NV21 byte array.
  /// Handles both interleaved (pixelStride=2) and planar (pixelStride=1) UV.
  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width = image.width;
    final height = image.height;
    final ySize = width * height;
    final uvSize = width * height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane — respect row stride (may have padding)
    int outIdx = 0;
    for (int row = 0; row < height; row++) {
      final srcOffset = row * yPlane.bytesPerRow;
      nv21.setRange(outIdx, outIdx + width, yPlane.bytes, srcOffset);
      outIdx += width;
    }

    // Build interleaved VU plane for NV21
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final uvRowStride = uPlane.bytesPerRow;

    if (uvPixelStride == 2) {
      // Already interleaved (most devices): U and V share the same buffer
      // offset by 1 byte.  Copy V-plane bytes which already contain VUVU...
      // Some devices (e.g. Xiaomi vayu) report the V buffer 1 byte short of
      // the last full row — clamp to avoid RangeError on the last iteration.
      for (int row = 0; row < height ~/ 2; row++) {
        final srcOffset = row * uvRowStride;
        final copyLen = (vPlane.bytes.length - srcOffset).clamp(0, width);
        if (copyLen > 0) nv21.setRange(outIdx, outIdx + copyLen, vPlane.bytes, srcOffset);
        outIdx += width;
      }
    } else {
      // Planar (pixelStride == 1): U and V are separate buffers, interleave manually.
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          final uvOffset = row * uvRowStride + col;
          nv21[outIdx++] = vPlane.bytes[uvOffset]; // V
          nv21[outIdx++] = uPlane.bytes[uvOffset]; // U
        }
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
