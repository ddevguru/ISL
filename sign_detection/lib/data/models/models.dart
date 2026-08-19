import 'package:uuid/uuid.dart';

// User Model
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final int signsLearned;
  final int practiceSessions;
  final int videoCalls;
  final double averageAccuracy;
  final int currentStreak;

  User({
    String? id,
    required this.name,
    required this.email,
    required this.role,
    this.signsLearned = 127,
    this.practiceSessions = 24,
    this.videoCalls = 18,
    this.averageAccuracy = 94.0,
    this.currentStreak = 7,
  }) : id = id ?? const Uuid().v4();
}

// Translation Model
class Translation {
  final String id;
  final String sign;
  final String englishText;
  final String hindiText;
  final double confidence;
  final DateTime timestamp;
  final String sessionId;

  Translation({
    String? id,
    required this.sign,
    required this.englishText,
    required this.hindiText,
    required this.confidence,
    DateTime? timestamp,
    String? sessionId,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        sessionId = sessionId ?? const Uuid().v4();
}

// Translation Session Model
class TranslationSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<Translation> translations;
  final String type;
  final double averageAccuracy;

  TranslationSession({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.translations,
    required this.type,
    required this.averageAccuracy,
  }) : id = id ?? const Uuid().v4();

  Duration get duration => endTime.difference(startTime);

  int get translationCount => translations.length;
}

// ISL Sign Model
class ISLSign {
  final String id;
  final String name;
  final String englishMeaning;
  final String hindiMeaning;
  final String category;
  final String description;
  final List<String> keywords;
  final bool isFavorite;

  ISLSign({
    String? id,
    required this.name,
    required this.englishMeaning,
    required this.hindiMeaning,
    required this.category,
    required this.description,
    required this.keywords,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();
}

// Video Call Model
class VideoCall {
  final String id;
  final String participantName;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int translationsCount;
  final double averageAccuracy;
  final bool translationEnabled;

  VideoCall({
    String? id,
    required this.participantName,
    required this.startTime,
    this.endTime,
    required this.status,
    this.translationsCount = 0,
    this.averageAccuracy = 0,
    this.translationEnabled = false,
  }) : id = id ?? const Uuid().v4();

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

// Gesture Recognition Result
class GestureResult {
  final String sign;
  final double confidence;
  final DateTime detectedAt;

  GestureResult({
    required this.sign,
    required this.confidence,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();
}

// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    DateTime? timestamp,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}

// Statistics Model
class Statistics {
  final int totalSigns;
  final int totalSessions;
  final int totalPracticeSessions;
  final double averageAccuracy;
  final int currentStreak;
  final int totalTranslations;

  Statistics({
    this.totalSigns = 127,
    this.totalSessions = 12,
    this.totalPracticeSessions = 24,
    this.averageAccuracy = 94.0,
    this.currentStreak = 7,
    this.totalTranslations = 456,
  });
}

// App Settings Model
class AppSettings {
  final bool darkMode;
  final bool highContrast;
  final double textScale;
  final bool reduceMotion;
  final bool captionsEnabled;
  final bool voiceOutputEnabled;
  final bool hapticFeedbackEnabled;
  final String preferredLanguage;
  final double translationSpeed;
  final double confidenceThreshold;
  final bool autoSpeak;

  AppSettings({
    this.darkMode = false,
    this.highContrast = false,
    this.textScale = 1.0,
    this.reduceMotion = false,
    this.captionsEnabled = true,
    this.voiceOutputEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.preferredLanguage = 'English',
    this.translationSpeed = 1.0,
    this.confidenceThreshold = 0.7,
    this.autoSpeak = true,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? highContrast,
    double? textScale,
    bool? reduceMotion,
    bool? captionsEnabled,
    bool? voiceOutputEnabled,
    bool? hapticFeedbackEnabled,
    String? preferredLanguage,
    double? translationSpeed,
    double? confidenceThreshold,
    bool? autoSpeak,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      highContrast: highContrast ?? this.highContrast,
      textScale: textScale ?? this.textScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      captionsEnabled: captionsEnabled ?? this.captionsEnabled,
      voiceOutputEnabled: voiceOutputEnabled ?? this.voiceOutputEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      translationSpeed: translationSpeed ?? this.translationSpeed,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      autoSpeak: autoSpeak ?? this.autoSpeak,
    );
  }
}
