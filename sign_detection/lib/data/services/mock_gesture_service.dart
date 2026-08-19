import 'dart:async';
import '../models/models.dart';

class MockGestureRecognitionService {
  static final MockGestureRecognitionService _instance =
      MockGestureRecognitionService._internal();

  factory MockGestureRecognitionService() {
    return _instance;
  }

  MockGestureRecognitionService._internal();

  final List<String> mockGestures = [
    'HELLO',
    'THANK YOU',
    'YES',
    'NO',
    'HELP',
    'GOOD MORNING',
    'HOW ARE YOU',
    'PLEASE',
    'SORRY',
    'WELCOME',
    'DOCTOR',
    'HOSPITAL',
    'SCHOOL',
    'WORK',
    'HOME',
  ];

  Future<GestureResult> recognizeGesture() async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final gesture = mockGestures[DateTime.now().millisecond % mockGestures.length];
    final confidence = 0.85 + (DateTime.now().millisecond % 15) / 100.0;

    return GestureResult(
      sign: gesture,
      confidence: confidence,
    );
  }

  Stream<GestureResult> recognizeGesturesStream() async* {
    int count = 0;
    while (count < 10) {
      await Future.delayed(const Duration(seconds: 3));
      yield await recognizeGesture();
      count++;
    }
  }

  bool isAvailable() => true;
}
