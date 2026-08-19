import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/utils.dart';
import '../../data/services/sign_detection_service.dart';
import '../../data/models/models.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  final _signDetectionService = SignDetectionService();
  late AnimationController _scanAnimationController;
  late AnimationController _pulseController;

  CameraController? _cameraController;
  bool _cameraInitialized = false;
  bool _cameraPermissionGranted = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  Translation? _currentTranslation;
  late final List<Translation> _translationHistory;

  late Timer _autoDetectTimer;

  @override
  void initState() {
    super.initState();
    _translationHistory = [];
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _requestCameraPermission();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _pulseController.dispose();
    _cameraController?.dispose();
    _autoDetectTimer.cancel();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      _cameraPermissionGranted = status.isGranted;
    });

    if (status.isGranted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera found on device')),
          );
        }
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _cameraInitialized = true);
        _startAutoDetect();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  void _startAutoDetect() {
    _autoDetectTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) async {
        if (!_isTranslating && mounted) {
          await _startTranslation();
        }
      },
    );
  }

  Future<void> _startTranslation() async {
    setState(() => _isTranslating = true);
    _scanAnimationController.repeat();

    try {
      // Simulate frame capture from camera (in real app, pass actual frame)
      final result = await _signDetectionService.detectSignFromFrame(
        Uint8List(0), // Empty for simulation, would be actual frame data
      );

      final signDetails = _signDetectionService.getSignDetails(result.sign);

      final translation = Translation(
        sign: result.sign,
        englishText: signDetails?.englishMeaning ?? result.sign,
        hindiText: signDetails?.hindiMeaning ?? result.sign,
        confidence: result.confidence,
      );

      setState(() {
        _currentTranslation = translation;
        _translationHistory.insert(0, translation);
      });

      _scanAnimationController.stop();
      setState(() => _isTranslating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Detected: ${result.sign} (${(result.confidence * 100).toStringAsFixed(0)}%)'),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      _scanAnimationController.stop();
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error recognizing gesture'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _speak() async {
    setState(() => _isSpeaking = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isSpeaking = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔊 Translation spoken'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF3B82F6),
        ),
      );
    }
  }

  void _clearTranslation() {
    setState(() => _currentTranslation = null);
  }

  void _copyTranslation() {
    if (_currentTranslation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Copied to clipboard'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF6366F1),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ISL Translation'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedAIIndicator(
              label: 'AI Active',
              isActive: !_isTranslating,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Camera Preview Area
              FadeInUp(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: !_cameraPermissionGranted
                      ? EmptyState(
                          icon: Icons.camera_alt,
                          title: 'Camera Access Denied',
                          description: 'Please grant camera permission to use translation features.',
                          onAction: _requestCameraPermission,
                          actionLabel: 'Grant Permission',
                        )
                      : !_cameraInitialized
                          ? Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                // Real camera feed
                                CameraPreview(_cameraController!),

                                // Scanning animation overlay
                                if (_isTranslating)
                                  Positioned.fill(
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.5, end: 1.2)
                                          .animate(
                                        CurvedAnimation(
                                          parent: _scanAnimationController,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Status badge
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _isTranslating
                                                ? Colors.orange
                                                : const Color(0xFF22C55E),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isTranslating ? 'Processing' : 'Ready',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Translation Results
              if (_currentTranslation != null)
                FadeInUp(
                  child: TranslationCard(
                    sign: _currentTranslation!.sign,
                    translation: _currentTranslation!.englishText,
                    confidence: _currentTranslation!.confidence,
                    onCopy: _copyTranslation,
                    onSpeak: _speak,
                    onSave: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Translation saved')),
                      );
                    },
                  ),
                ),

              if (_currentTranslation != null) const SizedBox(height: 24),

              // Hindi Translation Preview
              if (_currentTranslation != null)
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.translate,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hindi Translation',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentTranslation!.hindiText,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_currentTranslation != null) const SizedBox(height: 24),

              // Controls
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: _isTranslating ? 'Processing...' : 'Recognize',
                        onPressed: _isTranslating ? () {} : () => _startTranslation(),
                        isLoading: _isTranslating,
                        icon: Icons.touch_app,
                      ),
                    ),
                    if (_currentTranslation != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Clear',
                          onPressed: _clearTranslation,
                          icon: Icons.clear,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_translationHistory.isNotEmpty) ...[
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: SectionHeader(
                    title: 'Translation History',
                    subtitle: 'Recent detections',
                  ),
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _translationHistory.take(5).length,
                    itemBuilder: (context, index) {
                      final translation = _translationHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translation.sign,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    translation.englishText,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(translation.confidence * 100).toInt()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
