import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
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
  bool _isDetecting = false;
  String _detectedSign = 'No sign detected';
  double _confidence = 0.0;
  List<Map<String, dynamic>> _detectionHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {});
          _startDetection();
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;

      _isDetecting = true;

      try {
        // Convert CameraImage to base64
        final bytes = await _convertCameraImage(image);
        final base64Image = base64Encode(bytes);

        // Send to backend for detection
        await _detectSign(base64Image);
      } catch (e) {
        print('Detection error: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<List<int>> _convertCameraImage(CameraImage image) async {
    final planes = image.planes;
    final buffer = planes[0].bytes;

    try {
      // Create image from raw bytes using a simpler method
      final image16 = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: buffer.buffer,
        format: img.Format.uint8,
      );

      return img.encodeJpg(image16);
    } catch (e) {
      print('Image conversion error: $e');
      // Fallback: just return the bytes as-is
      return buffer;
    }
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
        body: jsonEncode({'frame': base64Image}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _detectedSign = data['sign'] ?? 'Unknown';
            _confidence = (data['confidence'] ?? 0.0).toDouble();

            _detectionHistory.insert(0, {
              'sign': _detectedSign,
              'confidence': _confidence,
              'timestamp': DateTime.now(),
            });

            if (_detectionHistory.length > 10) {
              _detectionHistory.removeLast();
            }
          });
        }
      }
    } catch (e) {
      print('Detection request error: $e');
    }
  }

  void _captureFrame() async {
    try {
      final image = await _cameraController!.takePicture();
      print('Frame captured: ${image.path}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Frame captured! Processing...')),
      );
    } catch (e) {
      print('Error capturing frame: $e');
    }
  }

  void _clearHistory() {
    setState(() {
      _detectionHistory.clear();
      _detectedSign = 'No sign detected';
      _confidence = 0.0;
    });
  }

  @override
  void dispose() {
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
            // Camera Preview
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: CameraPreview(_cameraController!),
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
                      onPressed: _captureFrame,
                      icon: const Icon(Icons.camera),
                      label: const Text('Capture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    'Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${item['timestamp'].hour}:${item['timestamp'].minute}',
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
