import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  Timer? _frameTimer;
  bool _isDetecting = false;
  String _detectedSign = 'No sign detected';
  double _confidence = 0.0;
  List<Map<String, dynamic>> _detectionHistory = [];
  
  // Face detection variables
  bool _faceDetected = false;
  Map<String, dynamic>? _faceBbox;
  String _expression = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        // Use front camera for self-signing and face detection
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
          _startDetectionTimer();
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startDetectionTimer() {
    _frameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) async {
      if (_isDetecting || _cameraController == null || !_cameraController!.value.isInitialized) {
        return;
      }

      setState(() => _isDetecting = true);

      try {
        // Capture frame as JPEG picture (robust & works on all devices without YUV corruptions)
        final imageFile = await _cameraController!.takePicture();
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Send to backend for detection
        await _detectSign(base64Image);
      } catch (e) {
        print('Frame capture/detection error: $e');
      } finally {
        if (mounted) {
          setState(() => _isDetecting = false);
        }
      }
    });
  }

  Future<void> _detectSign(String base64Image) async {
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
          'min_confidence': 0.2
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _detectedSign = data['sign'] ?? 'Unknown';
            _confidence = (data['confidence'] ?? 0.0).toDouble();
            
            _faceDetected = data['face_detected'] ?? false;
            _faceBbox = data['face_bbox'];
            _expression = data['expression'] ?? 'Unknown';

            if (_detectedSign != 'Unknown' && _confidence > 0.2) {
              // Add to history only if a valid sign is detected
              final existingIndex = _detectionHistory.indexWhere((h) => h['sign'] == _detectedSign);
              if (existingIndex != -1) {
                _detectionHistory.removeAt(existingIndex);
              }
              
              _detectionHistory.insert(0, {
                'sign': _detectedSign,
                'confidence': _confidence,
                'expression': _expression,
                'timestamp': DateTime.now(),
              });

              if (_detectionHistory.length > 10) {
                _detectionHistory.removeLast();
              }
            }
          });
        }
      }
    } catch (e) {
      print('Detection request error: $e');
    }
  }

  void _clearHistory() {
    setState(() {
      _detectionHistory.clear();
      _detectedSign = 'No sign detected';
      _confidence = 0.0;
      _faceDetected = false;
      _faceBbox = null;
      _expression = 'Unknown';
    });
  }

  String _getExpressionEmoji(String expression) {
    switch (expression.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'surprised':
        return '😲';
      case 'angry':
        return '😠';
      case 'wink left':
      case 'wink right':
        return '😜';
      case 'blink':
        return '😴';
      case 'neutral':
      default:
        return '😐';
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ISL Translation'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Camera Preview & Face Box Overlay
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  ),
                  if (_faceDetected && _faceBbox != null)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        
                        final boxX = _faceBbox!['x'] * w;
                        final boxY = _faceBbox!['y'] * h;
                        final boxW = _faceBbox!['w'] * w;
                        final boxH = _faceBbox!['h'] * h;
                        
                        return Positioned(
                          left: boxX,
                          top: boxY,
                          width: boxW,
                          height: boxH,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.green,
                                child: Text(
                                  _expression,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (_isDetecting)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Detection Result
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade100,
                      Colors.blue.shade100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Detected Sign',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _detectedSign,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _confidence,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _confidence > 0.7 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Expression Display
                    if (_faceDetected) ...[
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Face Expression: ',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            '${_getExpressionEmoji(_expression)} $_expression',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Toggle detection
                        if (_frameTimer != null && _frameTimer!.isActive) {
                          _frameTimer?.cancel();
                          setState(() {
                            _detectedSign = 'Detection paused';
                            _confidence = 0.0;
                          });
                        } else {
                          _startDetectionTimer();
                        }
                      },
                      icon: Icon(
                        _frameTimer != null && _frameTimer!.isActive
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        _frameTimer != null && _frameTimer!.isActive
                            ? 'Pause'
                            : 'Resume',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearHistory,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // History
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detection History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_detectionHistory.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('No detections yet'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _detectionHistory.length,
                      itemBuilder: (context, index) {
                        final item = _detectionHistory[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['sign'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%  •  ${item['expression']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${item['timestamp'].hour.toString().padLeft(2, '0')}:${item['timestamp'].minute.toString().padLeft(2, '0')}:${item['timestamp'].second.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
