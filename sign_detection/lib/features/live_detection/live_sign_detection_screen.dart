import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/api_config.dart';
import '../../core/widgets/cards.dart';
import '../../data/services/sign_detection_service.dart';

class LiveSignDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LiveSignDetectionScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<LiveSignDetectionScreen> createState() =>
      _LiveSignDetectionScreenState();
}

class _LiveSignDetectionScreenState extends State<LiveSignDetectionScreen> {
  late CameraController _cameraController;
  late Timer _detectionTimer;

  bool _isCameraInitialized = false;
  bool _isDetectionEnabled = true;
  bool _isLoading = false;

  String? _currentDetectedSign;
  double _confidence = 0.0;
  List<String> _detectionHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      _showError('No camera found on this device');
      return;
    }

    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      await _cameraController.startImageStream(_processFrame);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startDetectionTimer();
      }
    } catch (e) {
      _showError('Camera error: $e');
    }
  }

  void _startDetectionTimer() {
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) async {
        if (_isDetectionEnabled && !_isLoading) {
          await _detectSign();
        }
      },
    );
  }

  Future<void> _processFrame(CameraImage image) async {
  }

  Future<void> _detectSign() async {
    if (!_isCameraInitialized || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final image = await _cameraController.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await ApiService.detectFrame(frameBase64: base64Image);

      if (mounted) {
        setState(() {
          _currentDetectedSign = response['sign'] ?? 'Unknown';
          _confidence = (response['confidence'] ?? 0.0).toDouble();

          if (_detectionHistory.length >= 10) {
            _detectionHistory.removeAt(0);
          }
          _detectionHistory.add(_currentDetectedSign!);
        });
      }
    } catch (e) {
      debugPrint('Detection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _toggleDetection() {
    setState(() => _isDetectionEnabled = !_isDetectionEnabled);
  }

  void _clearHistory() {
    setState(() {
      _detectionHistory.clear();
      _currentDetectedSign = null;
      _confidence = 0.0;
    });
  }

  @override
  void dispose() {
    _detectionTimer.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Sign Detection')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live Sign Detection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                CameraPreview(_cameraController),
                if (_isLoading)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (_currentDetectedSign != null && !_isLoading)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: FadeInDown(
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'DETECTING',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(_confidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentDetectedSign!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleDetection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDetectionEnabled
                                ? const Color(0xFF22C55E)
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            _isDetectionEnabled
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            _isDetectionEnabled ? 'Pause' : 'Resume',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _clearHistory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  if (_detectionHistory.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detection History',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _detectionHistory.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B67CA)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF5B67CA),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _detectionHistory[index],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5B67CA),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Sign Detection Info'),
        content: const Text(
          'This screen captures video frames and sends them to the backend for real-time ISL sign detection.\n\n'
          '📹 Position your hands in frame\n'
          '✋ Make clear signs\n'
          '⏱️ Processing speed depends on backend\n'
          '📊 Confidence score shown above\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
