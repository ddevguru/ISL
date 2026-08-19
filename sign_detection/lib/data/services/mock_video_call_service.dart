import 'dart:async';
import '../models/models.dart';

enum CallStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  ended,
}

class MockVideoCallService {
  static final MockVideoCallService _instance = MockVideoCallService._internal();

  factory MockVideoCallService() {
    return _instance;
  }

  MockVideoCallService._internal();

  CallStatus _currentStatus = CallStatus.idle;
  late StreamController<CallStatus> _statusController;
  VideoCall? _currentCall;
  DateTime? _callStartTime;

  CallStatus get currentStatus => _currentStatus;
  VideoCall? get currentCall => _currentCall;
  Stream<CallStatus> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    _statusController = StreamController<CallStatus>.broadcast();
  }

  Future<void> startCall(String participantName) async {
    _updateStatus(CallStatus.connecting);
    await Future.delayed(const Duration(seconds: 2));

    _callStartTime = DateTime.now();
    _currentCall = VideoCall(
      participantName: participantName,
      startTime: _callStartTime!,
      status: 'connected',
      translationEnabled: false,
    );

    _updateStatus(CallStatus.connected);
  }

  Future<void> endCall() async {
    if (_currentCall != null) {
      final duration = DateTime.now().difference(_callStartTime ?? DateTime.now());
      _currentCall = _currentCall!.copyWith(
        endTime: DateTime.now(),
        status: 'completed',
      );
    }
    _updateStatus(CallStatus.ended);
  }

  Future<void> toggleTranslation(bool enabled) async {
    if (_currentCall != null) {
      _currentCall = _currentCall!.copyWith(translationEnabled: enabled);
    }
  }

  Future<void> simulateReconnecting() async {
    _updateStatus(CallStatus.reconnecting);
    await Future.delayed(const Duration(seconds: 2));
    _updateStatus(CallStatus.connected);
  }

  void _updateStatus(CallStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    _statusController.close();
  }
}

extension VideoCallExtension on VideoCall {
  VideoCall copyWith({
    String? id,
    String? participantName,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    int? translationsCount,
    double? averageAccuracy,
    bool? translationEnabled,
  }) {
    return VideoCall(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      translationsCount: translationsCount ?? this.translationsCount,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      translationEnabled: translationEnabled ?? this.translationEnabled,
    );
  }
}
