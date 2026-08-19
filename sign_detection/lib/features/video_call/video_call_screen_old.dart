import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';
import '../../core/widgets/utils.dart';
import '../call_summary/call_summary_screen.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isCallConnected = false;
  bool _isTranslationEnabled = false;
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isScreenSharing = false;

  late DateTime _callStartTime;

  String _getCallDuration() {
    if (!_isCallConnected) return '00:00';
    final duration = DateTime.now().difference(_callStartTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _showConnectingDialog);
  }

  void _showConnectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connecting...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Connecting to Rahul Kumar...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      setState(() {
        _isCallConnected = true;
        _callStartTime = DateTime.now();
      });
    });
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
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const CallSummaryScreen(),
                ),
              );
            },
            child: const Text('End Call', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main video area
          if (_isCallConnected)
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: Stack(
                        children: [
                          // Remote participant
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
                                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'RK',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Rahul Kumar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getCallDuration(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Translation overlay
                          if (_isTranslationEnabled)
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: FadeInDown(
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                            'Translation Active',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'HELLO',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Hello, how are you?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Confidence: 96%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Color(0xFF22C55E),
                                          ),
                                        ],
                                      ),
                                    ],
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
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text(
                    'Initializing call...',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

          // Local preview
          if (_isCallConnected)
            Positioned(
              bottom: 100,
              right: 16,
              child: FadeInUp(
                child: Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.black.withValues(alpha: 0.3),
                          size: 32,
                        ),
                      ),
                      if (!_isCameraEnabled)
                        Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Control buttons
          if (_isCallConnected)
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
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(
                            icon: _isMicEnabled
                                ? Icons.mic
                                : Icons.mic_off,
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
                              setState(() => _isSpeakerEnabled = !_isSpeakerEnabled);
                            },
                            isActive: _isSpeakerEnabled,
                            label: 'Speaker',
                          ),
                          _ControlButton(
                            icon: Icons.screen_share,
                            onPressed: () {
                              setState(() => _isScreenSharing = !_isScreenSharing);
                            },
                            isActive: _isScreenSharing,
                            label: 'Share',
                          ),
                          _ControlButton(
                            icon: _isTranslationEnabled
                                ? Icons.translate
                                : Icons.translate_outlined,
                            onPressed: () {
                              setState(() =>
                                  _isTranslationEnabled = !_isTranslationEnabled);
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
      ),
    );
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
                    ? (color ?? const Color(0xFF5B67CA)).withValues(alpha: 0.15)
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
                  color: isActive ? (color ?? const Color(0xFF5B67CA)) : Colors.grey[600],
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
