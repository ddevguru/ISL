import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../core/widgets/hand_skeleton.dart';

class PracticeScreen extends StatefulWidget {
  final Map<String, dynamic> sign;

  const PracticeScreen({Key? key, required this.sign}) : super(key: key);

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  Timer? _frameTimer;
  bool _isDetecting = false;
  bool _success = false;
  double _confidence = 0.0;
  String _currentFeedback = 'Position your hand in front of the camera';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        final frontCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras![0],
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {});
          _startPracticeTimer();
        }
      }
    } catch (e) {
      setState(() => _currentFeedback = 'Camera error: $e');
    }
  }

  void _startPracticeTimer() {
    _frameTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) async {
      if (_isDetecting || _success || _cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }

      setState(() => _isDetecting = true);

      try {
        final imageFile = await _cameraController!.takePicture();
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        await _validateGesture(base64Image);
      } catch (e) {
        print('Practice frame capture error: $e');
      } finally {
        if (mounted) {
          setState(() => _isDetecting = false);
        }
      }
    });
  }

  Future<void> _validateGesture(String base64Image) async {
    try {
      final authService = context.read<AuthService>();

      final response = await http.post(
        Uri.parse(ApiConfig.detectFrameEndpoint),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
        body: jsonEncode({
          'frame': base64Image,
          'min_confidence': 0.4,
          'target_sign': widget.sign['name']
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detectedSign = data['sign'];
        final conf = (data['confidence'] ?? 0.0).toDouble();

        if (mounted) {
          if (detectedSign != null && detectedSign.toString().toUpperCase() == widget.sign['name'].toString().toUpperCase()) {
            // Target sign correctly detected!
            setState(() {
              _success = true;
              _confidence = conf;
              _currentFeedback = 'Excellent! Correct sign detected! 🎉';
            });
            
            _frameTimer?.cancel();
            await _recordProgress(true);
            
            // Auto close after 2.5 seconds
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) {
                Navigator.of(context).pop(true); // Return true to indicate success
              }
            });
          } else if (detectedSign != null && detectedSign != 'Unknown') {
            setState(() {
              _currentFeedback = 'Detected sign "$detectedSign". Keep trying to make "${widget.sign['name']}"!';
            });
          } else {
            setState(() {
              _currentFeedback = 'No hand shape detected. Align your hand with the template!';
            });
          }
        }
      }
    } catch (e) {
      print('Practice validation error: $e');
    }
  }

  Future<void> _recordProgress(bool correct) async {
    try {
      final authService = context.read<AuthService>();
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/learning/progress/${widget.sign['id']}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer ${authService.accessToken}',
        },
        body: jsonEncode({'correct': correct}),
      );
    } catch (e) {
      print('Error saving practice progress: $e');
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Practice: ${widget.sign['name']}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Practice: ${widget.sign['name']}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Target template and guide
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                HandSkeletonWidget(
                  keypoints: widget.sign['keypoints_data'],
                  width: 90,
                  height: 90,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice "${widget.sign['name']}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.sign['description'] ?? 'Perform the gesture shown on the left.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Camera View with Bounding overlay
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                
                // Feedback Overlay at bottom
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: ZoomIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: _success
                            ? Colors.green.withOpacity(0.9)
                            : Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentFeedback,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_success) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Confidence Score: ${(_confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Success Splash Celebration
                if (_success)
                  Positioned.fill(
                    child: Container(
                      color: Colors.green.withOpacity(0.3),
                      child: Center(
                        child: BounceInDown(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Loading Frame Processing Spinner
                if (_isDetecting && !_success)
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
