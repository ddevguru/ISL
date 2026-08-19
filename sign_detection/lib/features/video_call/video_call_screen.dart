import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/cards.dart';
import '../../data/services/sign_detection_service.dart';
import '../call_summary/call_summary_screen.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _signDetectionService = SignDetectionService();

  bool _isJoined = false;
  bool _isTranslationEnabled = false;
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _showChannelInput = true;

  late TextEditingController _channelController;
  late TextEditingController _userNameController;

  DateTime? _callStartTime;
  late Timer _durationTimer;
  String _callDuration = '00:00';

  String? _currentDetectedSign;
  late Timer _detectionTimer;

  @override
  void initState() {
    super.initState();
    _channelController = TextEditingController();
    _userNameController = TextEditingController(text: 'User123');
  }

  void _startCall() {
    if (_channelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter channel name')),
      );
      return;
    }

    setState(() {
      _showChannelInput = false;
      _isJoined = true;
    });

    _callStartTime = DateTime.now();
    _startCallTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Demo Call Started! (Mock video for now)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startCallTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final duration = DateTime.now().difference(_callStartTime!);
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        setState(() {
          _callDuration =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _stopCallTimer() {
    _durationTimer.cancel();
  }

  void _startSignDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isTranslationEnabled && mounted) {
        try {
          final result = await _signDetectionService.detectSignFromFrame(
            Uint8List(0),
          );
          setState(() => _currentDetectedSign = result.sign);
        } catch (e) {
          debugPrint('Sign detection error: $e');
        }
      }
    });
  }

  void _stopSignDetection() {
    if (_detectionTimer.isActive) {
      _detectionTimer.cancel();
    }
    setState(() => _currentDetectedSign = null);
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _stopCallTimer();
              _stopSignDetection();

              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const CallSummaryScreen(),
                  ),
                );
              }
            },
            child:
                const Text('End Call', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channelController.dispose();
    _userNameController.dispose();
    _stopCallTimer();
    _stopSignDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _showChannelInput
          ? _buildChannelSelectionScreen()
          : _buildCallScreen(),
    );
  }

  Widget _buildChannelSelectionScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.video_call,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo Video Call',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'With Live ISL Sign Detection!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: TextField(
                controller: _channelController,
                decoration: InputDecoration(
                  labelText: 'Channel Name',
                  hintText: 'e.g., isl-chat-1',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: _startCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Demo Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Features:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✅ Live ISL Sign Detection\n✅ English + Hindi Translation\n✅ Call Duration Timer\n✅ Mic, Camera, Speaker Controls',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallScreen() {
    return Stack(
      children: [
        // Main video area
        Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    // Mock remote participant
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.people_outline,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Demo Remote User',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),

                    // Translation overlay
                    if (_isTranslationEnabled && _currentDetectedSign != null)
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
                                        'ISL ON',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Live Translation',
                                      style: TextStyle(
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getSignTranslation(_currentDetectedSign!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Call duration
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _callDuration,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Control buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0),
                    Colors.white.withOpacity(0.95),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                        onPressed: () {
                          setState(() => _isMicEnabled = !_isMicEnabled);
                        },
                        isActive: _isMicEnabled,
                        label: 'Mic',
                      ),
                      _ControlButton(
                        icon: _isCameraEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        onPressed: () {
                          setState(() => _isCameraEnabled = !_isCameraEnabled);
                        },
                        isActive: _isCameraEnabled,
                        label: 'Camera',
                      ),
                      _ControlButton(
                        icon: _isSpeakerEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                        onPressed: () {
                          setState(() =>
                              _isSpeakerEnabled = !_isSpeakerEnabled);
                        },
                        isActive: _isSpeakerEnabled,
                        label: 'Speaker',
                      ),
                      _ControlButton(
                        icon: _isTranslationEnabled
                            ? Icons.translate
                            : Icons.translate_outlined,
                        onPressed: () {
                          setState(() =>
                              _isTranslationEnabled = !_isTranslationEnabled);
                          if (_isTranslationEnabled) {
                            _startSignDetection();
                          } else {
                            _stopSignDetection();
                          }
                        },
                        isActive: _isTranslationEnabled,
                        label: 'ISL',
                        color: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _endCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('End Call'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSignTranslation(String sign) {
    final signDetails = _signDetectionService.getSignDetails(sign);
    if (signDetails != null) {
      return '${signDetails.englishMeaning} (${signDetails.hindiMeaning})';
    }
    return sign;
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String label;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? (color ?? const Color(0xFF5B67CA)).withOpacity(0.15)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(32),
                border: isActive
                    ? Border.all(
                        color: color ?? const Color(0xFF5B67CA),
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isActive
                      ? (color ?? const Color(0xFF5B67CA))
                      : Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
