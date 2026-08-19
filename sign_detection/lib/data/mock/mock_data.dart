import '../models/models.dart';

class MockDataRepository {
  static final MockDataRepository _instance = MockDataRepository._internal();

  factory MockDataRepository() {
    return _instance;
  }

  MockDataRepository._internal();

  // Mock user data
  final User currentUser = User(
    name: 'Aarav Sharma',
    email: 'aarav@example.com',
    role: 'ISL User',
    signsLearned: 127,
    practiceSessions: 24,
    videoCalls: 18,
    averageAccuracy: 94.0,
    currentStreak: 7,
  );

  // Mock ISL Signs
  List<ISLSign> getAllSigns() {
    return [
      ISLSign(
        name: 'HELLO',
        englishMeaning: 'Hello',
        hindiMeaning: 'नमस्ते',
        category: 'Greetings',
        description: 'A common greeting to say hello',
        keywords: ['greeting', 'hello', 'hi'],
      ),
      ISLSign(
        name: 'THANK YOU',
        englishMeaning: 'Thank you',
        hindiMeaning: 'धन्यवाद',
        category: 'Common Words',
        description: 'Expression of gratitude',
        keywords: ['thanks', 'gratitude'],
      ),
      ISLSign(
        name: 'YES',
        englishMeaning: 'Yes',
        hindiMeaning: 'हाँ',
        category: 'Common Words',
        description: 'Affirmative response',
        keywords: ['affirmative', 'positive'],
      ),
      ISLSign(
        name: 'NO',
        englishMeaning: 'No',
        hindiMeaning: 'नहीं',
        category: 'Common Words',
        description: 'Negative response',
        keywords: ['negative', 'refusal'],
      ),
      ISLSign(
        name: 'HELP',
        englishMeaning: 'Help',
        hindiMeaning: 'मदद',
        category: 'Emergency',
        description: 'Request for assistance',
        keywords: ['assist', 'aid', 'support'],
      ),
      ISLSign(
        name: 'GOOD MORNING',
        englishMeaning: 'Good Morning',
        hindiMeaning: 'सुप्रभात',
        category: 'Greetings',
        description: 'Morning greeting',
        keywords: ['morning', 'greeting'],
      ),
      ISLSign(
        name: 'HOW ARE YOU',
        englishMeaning: 'How are you?',
        hindiMeaning: 'आप कैसे हैं?',
        category: 'Greetings',
        description: 'Inquiry about wellbeing',
        keywords: ['wellbeing', 'health'],
      ),
      ISLSign(
        name: 'PLEASE',
        englishMeaning: 'Please',
        hindiMeaning: 'कृपया',
        category: 'Common Words',
        description: 'Polite request',
        keywords: ['polite', 'request'],
      ),
      ISLSign(
        name: 'SORRY',
        englishMeaning: 'Sorry',
        hindiMeaning: 'क्षमा करें',
        category: 'Common Words',
        description: 'Apology or regret',
        keywords: ['apology', 'regret'],
      ),
      ISLSign(
        name: 'WELCOME',
        englishMeaning: 'Welcome',
        hindiMeaning: 'स्वागत है',
        category: 'Greetings',
        description: 'Greeting of welcome',
        keywords: ['greet', 'welcome'],
      ),
      ISLSign(
        name: 'DOCTOR',
        englishMeaning: 'Doctor',
        hindiMeaning: 'डॉक्टर',
        category: 'Healthcare',
        description: 'Medical professional',
        keywords: ['medical', 'physician'],
      ),
      ISLSign(
        name: 'HOSPITAL',
        englishMeaning: 'Hospital',
        hindiMeaning: 'अस्पताल',
        category: 'Healthcare',
        description: 'Medical facility',
        keywords: ['health', 'facility'],
      ),
      ISLSign(
        name: 'SCHOOL',
        englishMeaning: 'School',
        hindiMeaning: 'स्कूल',
        category: 'Education',
        description: 'Educational institution',
        keywords: ['education', 'learning'],
      ),
      ISLSign(
        name: 'WORK',
        englishMeaning: 'Work',
        hindiMeaning: 'काम',
        category: 'Common Words',
        description: 'Employment or task',
        keywords: ['job', 'task', 'employment'],
      ),
      ISLSign(
        name: 'HOME',
        englishMeaning: 'Home',
        hindiMeaning: 'घर',
        category: 'Common Words',
        description: 'Place of residence',
        keywords: ['house', 'residence'],
      ),
      ISLSign(
        name: 'PHONE',
        englishMeaning: 'Phone',
        hindiMeaning: 'फोन',
        category: 'Technology',
        description: 'Communication device',
        keywords: ['device', 'call', 'communication'],
      ),
      ISLSign(
        name: 'COMPUTER',
        englishMeaning: 'Computer',
        hindiMeaning: 'कंप्यूटर',
        category: 'Technology',
        description: 'Computing device',
        keywords: ['technology', 'device'],
      ),
      ISLSign(
        name: 'WATER',
        englishMeaning: 'Water',
        hindiMeaning: 'पानी',
        category: 'Daily Conversation',
        description: 'Essential liquid',
        keywords: ['drink', 'liquid'],
      ),
      ISLSign(
        name: 'FOOD',
        englishMeaning: 'Food',
        hindiMeaning: 'खाना',
        category: 'Daily Conversation',
        description: 'Edible items',
        keywords: ['eat', 'meal'],
      ),
      ISLSign(
        name: 'LOVE',
        englishMeaning: 'Love',
        hindiMeaning: 'प्यार',
        category: 'Emotions',
        description: 'Deep affection',
        keywords: ['affection', 'care'],
      ),
    ];
  }

  List<ISLSign> getSignsByCategory(String category) {
    return getAllSigns().where((sign) => sign.category == category).toList();
  }

  List<String> getCategories() {
    final signs = getAllSigns();
    final categories = <String>{};
    for (var sign in signs) {
      categories.add(sign.category);
    }
    return categories.toList();
  }

  ISLSign? getSignByName(String name) {
    try {
      return getAllSigns().firstWhere((sign) => sign.name == name);
    } catch (e) {
      return null;
    }
  }

  // Mock translation sessions
  List<TranslationSession> getTranslationHistory() {
    return [
      TranslationSession(
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 52)),
        translations: [
          Translation(
            sign: 'HELLO',
            englishText: 'Hello',
            hindiText: 'नमस्ते',
            confidence: 0.96,
          ),
          Translation(
            sign: 'HOW ARE YOU',
            englishText: 'How are you?',
            hindiText: 'आप कैसे हैं?',
            confidence: 0.94,
          ),
          Translation(
            sign: 'THANK YOU',
            englishText: 'Thank you',
            hindiText: 'धन्यवाद',
            confidence: 0.95,
          ),
        ],
        type: 'Video Call',
        averageAccuracy: 0.95,
      ),
      TranslationSession(
        startTime: DateTime.now().subtract(const Duration(hours: 5)),
        endTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
        translations: [
          Translation(
            sign: 'GOOD MORNING',
            englishText: 'Good Morning',
            hindiText: 'सुप्रभात',
            confidence: 0.92,
          ),
          Translation(
            sign: 'HELP',
            englishText: 'Help',
            hindiText: 'मदद',
            confidence: 0.98,
          ),
        ],
        type: 'Live Translation',
        averageAccuracy: 0.95,
      ),
      TranslationSession(
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 35)),
        translations: [
          Translation(
            sign: 'PRACTICE',
            englishText: 'Practice',
            hindiText: 'अभ्यास',
            confidence: 0.96,
          ),
        ],
        type: 'Practice Session',
        averageAccuracy: 0.96,
      ),
    ];
  }

  // Mock video calls
  List<VideoCall> getCallHistory() {
    return [
      VideoCall(
        participantName: 'Rahul Kumar',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 52)),
        status: 'completed',
        translationsCount: 18,
        averageAccuracy: 0.94,
        translationEnabled: true,
      ),
      VideoCall(
        participantName: 'Priya Singh',
        startTime: DateTime.now().subtract(const Duration(hours: 5)),
        endTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        status: 'completed',
        translationsCount: 24,
        averageAccuracy: 0.92,
        translationEnabled: true,
      ),
      VideoCall(
        participantName: 'Amit Patel',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 45)),
        status: 'completed',
        translationsCount: 15,
        averageAccuracy: 0.95,
        translationEnabled: false,
      ),
    ];
  }

  // Mock notifications
  List<AppNotification> getNotifications() {
    return [
      AppNotification(
        title: 'Translation session completed',
        description: 'Your latest session achieved 94% accuracy.',
        type: 'success',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        title: 'Practice reminder',
        description: 'Continue your ISL practice today.',
        type: 'reminder',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        title: 'New sign category',
        description: 'Emergency signs have been added.',
        type: 'new',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Mock statistics
  Statistics getStatistics() {
    return Statistics(
      totalSigns: 127,
      totalSessions: 12,
      totalPracticeSessions: 24,
      averageAccuracy: 94.0,
      currentStreak: 7,
      totalTranslations: 456,
    );
  }
}
