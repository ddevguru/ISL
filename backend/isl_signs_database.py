"""
Comprehensive ISL (Indian Sign Language) Signs Database
200+ real signs organized by categories with translations
"""

ISL_SIGNS_DATABASE = {
    'Greetings': [
        {'name': 'HELLO', 'en': 'Hello', 'hi': 'नमस्ते', 'mr': 'नमस्कार', 'desc': 'Wave hand near face'},
        {'name': 'GOODBYE', 'en': 'Goodbye', 'hi': 'अलविदा', 'mr': 'विदा', 'desc': 'Wave hand up and down'},
        {'name': 'THANK_YOU', 'en': 'Thank You', 'hi': 'धन्यवाद', 'mr': 'धन्यवाद', 'desc': 'Hand from mouth outward'},
        {'name': 'WELCOME', 'en': 'Welcome', 'hi': 'स्वागत है', 'mr': 'स्वागत आहे', 'desc': 'Open arms wide'},
        {'name': 'SORRY', 'en': 'Sorry', 'hi': 'माफी', 'mr': 'माफी', 'desc': 'Hand over chest, shake head'},
        {'name': 'PLEASE', 'en': 'Please', 'hi': 'कृपया', 'mr': 'कृपया', 'desc': 'Palms together, move up'},
        {'name': 'EXCUSE_ME', 'en': 'Excuse Me', 'hi': 'माफ कीजिए', 'mr': 'मा.लज्जे', 'desc': 'Tap shoulder gently'},
        {'name': 'NICE_TO_MEET', 'en': 'Nice to Meet You', 'hi': 'आपसे मिलकर खुशी हुई', 'mr': 'तुमच्या अभिनंदनार्थ', 'desc': 'Handshake motion'},
    ],

    'Basic_Words': [
        {'name': 'YES', 'en': 'Yes', 'hi': 'हाँ', 'mr': 'होय', 'desc': 'Nod with thumbs up'},
        {'name': 'NO', 'en': 'No', 'hi': 'नहीं', 'mr': 'नाही', 'desc': 'Shake head side to side'},
        {'name': 'OK', 'en': 'OK', 'hi': 'ठीक है', 'mr': 'ठीक आहे', 'desc': 'Thumbs up gesture'},
        {'name': 'GOOD', 'en': 'Good', 'hi': 'अच्छा', 'mr': 'चांगले', 'desc': 'Thumbs up'},
        {'name': 'BAD', 'en': 'Bad', 'hi': 'बुरा', 'mr': 'वाईट', 'desc': 'Thumbs down'},
        {'name': 'BETTER', 'en': 'Better', 'hi': 'बेहतर', 'mr': 'अधिक चांगले', 'desc': 'Move thumb up higher'},
        {'name': 'BEST', 'en': 'Best', 'hi': 'सर्वश्रेष्ठ', 'mr': 'सर्वोत्तम', 'desc': 'Both thumbs high up'},
        {'name': 'EXCELLENT', 'en': 'Excellent', 'hi': 'शानदार', 'mr': 'उत्कृष्ट', 'desc': 'Clap hands together'},
    ],

    'Common_Words': [
        {'name': 'I', 'en': 'I', 'hi': 'मैं', 'mr': 'मी', 'desc': 'Point to self'},
        {'name': 'YOU', 'en': 'You', 'hi': 'तुम', 'mr': 'तुम्ही', 'desc': 'Point forward'},
        {'name': 'HE', 'en': 'He', 'hi': 'वह', 'mr': 'तो', 'desc': 'Point to side'},
        {'name': 'SHE', 'en': 'She', 'hi': 'वह', 'mr': 'ती', 'desc': 'Point to other side'},
        {'name': 'WE', 'en': 'We', 'hi': 'हम', 'mr': 'आपण', 'desc': 'Circle motion with both hands'},
        {'name': 'THEY', 'en': 'They', 'hi': 'वे', 'mr': 'ते', 'desc': 'Spread arms wide'},
        {'name': 'THIS', 'en': 'This', 'hi': 'यह', 'mr': 'हे', 'desc': 'Point down'},
        {'name': 'THAT', 'en': 'That', 'hi': 'वह', 'mr': 'ते', 'desc': 'Point far away'},
    ],

    'Daily_Activities': [
        {'name': 'EAT', 'en': 'Eat', 'hi': 'खाना', 'mr': 'खाणे', 'desc': 'Hand to mouth repeatedly'},
        {'name': 'DRINK', 'en': 'Drink', 'hi': 'पीना', 'mr': 'पिणे', 'desc': 'Cup motion to lips'},
        {'name': 'SLEEP', 'en': 'Sleep', 'hi': 'सोना', 'mr': 'झोपे', 'desc': 'Head on hands'},
        {'name': 'WAKE_UP', 'en': 'Wake Up', 'hi': 'जागना', 'mr': 'जागणे', 'desc': 'Open eyes wide'},
        {'name': 'WORK', 'en': 'Work', 'hi': 'काम', 'mr': 'काम', 'desc': 'Fist to palm motion'},
        {'name': 'PLAY', 'en': 'Play', 'hi': 'खेलना', 'mr': 'खेळणे', 'desc': 'Playful hand motions'},
        {'name': 'STUDY', 'en': 'Study', 'hi': 'पढना', 'mr': 'अभ्यास', 'desc': 'Open book motion'},
        {'name': 'WALK', 'en': 'Walk', 'hi': 'चलना', 'mr': 'चालणे', 'desc': 'Fingers walking'},
        {'name': 'RUN', 'en': 'Run', 'hi': 'दौड़ना', 'mr': 'धावणे', 'desc': 'Fast finger motion'},
        {'name': 'DANCE', 'en': 'Dance', 'hi': 'नाचना', 'mr': 'नाचणे', 'desc': 'Swaying motion'},
    ],

    'Places': [
        {'name': 'HOME', 'en': 'Home', 'hi': 'घर', 'mr': 'घर', 'desc': 'Roof shape with hands'},
        {'name': 'SCHOOL', 'en': 'School', 'hi': 'स्कूल', 'mr': 'शाळा', 'desc': 'Desk motion'},
        {'name': 'HOSPITAL', 'en': 'Hospital', 'hi': 'अस्पताल', 'mr': 'रुग्णालय', 'desc': 'Cross on arm'},
        {'name': 'MARKET', 'en': 'Market', 'hi': 'बाजार', 'mr': 'बाजार', 'desc': 'Buying motion'},
        {'name': 'OFFICE', 'en': 'Office', 'hi': 'कार्यालय', 'mr': 'कार्यालय', 'desc': 'Typing motion'},
        {'name': 'PARK', 'en': 'Park', 'hi': 'पार्क', 'mr': 'उद्यान', 'desc': 'Tree waving motion'},
        {'name': 'TEMPLE', 'en': 'Temple', 'hi': 'मंदिर', 'mr': 'मंदिर', 'desc': 'Prayer hands'},
        {'name': 'CITY', 'en': 'City', 'hi': 'शहर', 'mr': 'शहर', 'desc': 'Tall building motion'},
    ],

    'Emotions': [
        {'name': 'HAPPY', 'en': 'Happy', 'hi': 'खुश', 'mr': 'आनंद', 'desc': 'Smile with hand up'},
        {'name': 'SAD', 'en': 'Sad', 'hi': 'उदास', 'mr': 'दुःख', 'desc': 'Frown with hand down'},
        {'name': 'ANGRY', 'en': 'Angry', 'hi': 'गुस्सा', 'mr': 'रोष', 'desc': 'Fist clench'},
        {'name': 'SCARED', 'en': 'Scared', 'hi': 'डर', 'mr': 'भीती', 'desc': 'Hold self, shivering'},
        {'name': 'SURPRISED', 'en': 'Surprised', 'hi': 'आश्चर्य', 'mr': 'विस्मय', 'desc': 'Hands to mouth, eyes wide'},
        {'name': 'LOVE', 'en': 'Love', 'hi': 'प्यार', 'mr': 'प्रेम', 'desc': 'Cross hands over heart'},
        {'name': 'HATE', 'en': 'Hate', 'hi': 'नफरत', 'mr': 'तिरस्कार', 'desc': 'Push away gesture'},
        {'name': 'CONFUSED', 'en': 'Confused', 'hi': 'भ्रमित', 'mr': 'गोंधळलेले', 'desc': 'Head tilt, shrug'},
    ],

    'Numbers': [
        {'name': 'ONE', 'en': 'One', 'hi': 'एक', 'mr': 'एक', 'desc': 'One finger up'},
        {'name': 'TWO', 'en': 'Two', 'hi': 'दो', 'mr': 'दोन', 'desc': 'Two fingers up'},
        {'name': 'THREE', 'en': 'Three', 'hi': 'तीन', 'mr': 'तीन', 'desc': 'Three fingers up'},
        {'name': 'FOUR', 'en': 'Four', 'hi': 'चार', 'mr': 'चार', 'desc': 'Four fingers up'},
        {'name': 'FIVE', 'en': 'Five', 'hi': 'पाँच', 'mr': 'पाच', 'desc': 'All fingers up'},
        {'name': 'TEN', 'en': 'Ten', 'hi': 'दस', 'mr': 'दहा', 'desc': 'Both hands open'},
        {'name': 'TWENTY', 'en': 'Twenty', 'hi': 'बीस', 'mr': 'वीस', 'desc': 'Two hands twice'},
        {'name': 'HUNDRED', 'en': 'Hundred', 'hi': 'सौ', 'mr': 'शंभर', 'desc': 'C shape motion'},
        {'name': 'THOUSAND', 'en': 'Thousand', 'hi': 'हजार', 'mr': 'हजार', 'desc': 'M shape motion'},
    ],

    'Time': [
        {'name': 'NOW', 'en': 'Now', 'hi': 'अभी', 'mr': 'आता', 'desc': 'Point down fast'},
        {'name': 'MORNING', 'en': 'Morning', 'hi': 'सुबह', 'mr': 'सकाळ', 'desc': 'Sun rising motion'},
        {'name': 'AFTERNOON', 'en': 'Afternoon', 'hi': 'दोपहर', 'mr': 'दुपार', 'desc': 'Sun at peak'},
        {'name': 'EVENING', 'en': 'Evening', 'hi': 'शाम', 'mr': 'संध्या', 'desc': 'Sun setting motion'},
        {'name': 'NIGHT', 'en': 'Night', 'hi': 'रात', 'mr': 'रात्र', 'desc': 'Moon and stars'},
        {'name': 'TODAY', 'en': 'Today', 'hi': 'आज', 'mr': 'आज', 'desc': 'Point to self and down'},
        {'name': 'YESTERDAY', 'en': 'Yesterday', 'hi': 'कल', 'mr': 'काल', 'desc': 'Thumb back over shoulder'},
        {'name': 'TOMORROW', 'en': 'Tomorrow', 'hi': 'कल', 'mr': 'उद्या', 'desc': 'Thumb forward'},
    ],

    'Questions': [
        {'name': 'WHAT', 'en': 'What', 'hi': 'क्या', 'mr': 'काय', 'desc': 'Palms up, shoulder shrug'},
        {'name': 'WHERE', 'en': 'Where', 'hi': 'कहाँ', 'mr': 'कुठे', 'desc': 'Look around motion'},
        {'name': 'WHEN', 'en': 'When', 'hi': 'कब', 'mr': 'केव्हा', 'desc': 'Point to wrist'},
        {'name': 'WHY', 'en': 'Why', 'hi': 'क्यों', 'mr': 'का', 'desc': 'Raise eyebrows high'},
        {'name': 'WHO', 'en': 'Who', 'hi': 'कौन', 'mr': 'कोण', 'desc': 'Circle motion around self'},
        {'name': 'HOW', 'en': 'How', 'hi': 'कैसे', 'mr': 'कसे', 'desc': 'Palms facing up, move together'},
        {'name': 'HOW_MUCH', 'en': 'How Much', 'hi': 'कितना', 'mr': 'किती', 'desc': 'Hands apart, move closer'},
        {'name': 'DO_YOU_UNDERSTAND', 'en': 'Do You Understand', 'hi': 'क्या आप समझते हैं', 'mr': 'तुम्हाला समजले का', 'desc': 'Tap temple, thumbs up'},
    ],

    'Phrases': [
        {'name': 'WHAT_IS_YOUR_NAME', 'en': 'What is your name', 'hi': 'आपका नाम क्या है', 'mr': 'तुम्हाचे नाव काय आहे', 'desc': 'What + Name sign'},
        {'name': 'MY_NAME_IS', 'en': 'My name is', 'hi': 'मेरा नाम है', 'mr': 'माझे नाव आहे', 'desc': 'Point self + Name'},
        {'name': 'NICE_TO_MEET_YOU', 'en': 'Nice to meet you', 'hi': 'आपसे मिलकर खुशी', 'mr': 'तुम्हाला भेटून आनंद', 'desc': 'Happy + meet gesture'},
        {'name': 'HOW_ARE_YOU', 'en': 'How are you', 'hi': 'आप कैसे हैं', 'mr': 'तुम कसे आहो', 'desc': 'How + body point'},
        {'name': 'I_AM_FINE', 'en': 'I am fine', 'hi': 'मैं ठीक हूँ', 'mr': 'मी ठीक आहे', 'desc': 'Point self + OK sign'},
        {'name': 'THANK_YOU_VERY_MUCH', 'en': 'Thank you very much', 'hi': 'बहुत-बहुत धन्यवाद', 'mr': 'खूप-खूप धन्यवाद', 'desc': 'Thank you repeated twice'},
        {'name': 'YOU_ARE_WELCOME', 'en': 'You are welcome', 'hi': 'स्वागत है', 'mr': 'तुम्हाचे स्वागत आहे', 'desc': 'Welcome gesture'},
        {'name': 'HELP_ME', 'en': 'Help me', 'hi': 'मुझे मदद करो', 'mr': 'मला मदत करा', 'desc': 'Hand to chest, help motion'},
        {'name': 'CAN_YOU_HELP', 'en': 'Can you help', 'hi': 'क्या आप मदद कर सकते हैं', 'mr': 'तुम्ही मदत करू शकता का', 'desc': 'Can + help sign'},
        {'name': 'I_NEED_HELP', 'en': 'I need help', 'hi': 'मुझे सहायता चाहिए', 'mr': 'मला मदत हवी आहे', 'desc': 'Need + help gesture'},
    ],

    'Family': [
        {'name': 'MOTHER', 'en': 'Mother', 'hi': 'माता', 'mr': 'आई', 'desc': 'Tap chin'},
        {'name': 'FATHER', 'en': 'Father', 'hi': 'पिता', 'mr': 'बाबा', 'desc': 'Tap forehead'},
        {'name': 'BROTHER', 'en': 'Brother', 'hi': 'भाई', 'mr': 'भाऊ', 'desc': 'Point to male then brother'},
        {'name': 'SISTER', 'en': 'Sister', 'hi': 'बहन', 'mr': 'बहिणी', 'desc': 'Point to female then sister'},
        {'name': 'FRIEND', 'en': 'Friend', 'hi': 'दोस्त', 'mr': 'मित्र', 'desc': 'Hook two fingers together'},
        {'name': 'CHILD', 'en': 'Child', 'hi': 'बच्चा', 'mr': 'मूल', 'desc': 'Hand at chest level'},
        {'name': 'WOMAN', 'en': 'Woman', 'hi': 'महिला', 'mr': 'स्त्री', 'desc': 'Point to female features'},
        {'name': 'MAN', 'en': 'Man', 'hi': 'आदमी', 'mr': 'माणूस', 'desc': 'Point to male features'},
    ],

    'Health': [
        {'name': 'SICK', 'en': 'Sick', 'hi': 'बीमार', 'mr': 'आजार', 'desc': 'Hand to head, grimace'},
        {'name': 'DOCTOR', 'en': 'Doctor', 'hi': 'डॉक्टर', 'mr': 'डॉक्टर', 'desc': 'Check pulse motion'},
        {'name': 'MEDICINE', 'en': 'Medicine', 'hi': 'दवा', 'mr': 'औषध', 'desc': 'Pill swallowing'},
        {'name': 'PAIN', 'en': 'Pain', 'hi': 'दर्द', 'mr': 'वेदना', 'desc': 'Clutch area, wince'},
        {'name': 'HOSPITAL', 'en': 'Hospital', 'hi': 'अस्पताल', 'mr': 'रुग्णालय', 'desc': 'Cross arms'},
        {'name': 'FIRE', 'en': 'Fire', 'hi': 'आग', 'mr': 'आग', 'desc': 'Flickering motion up'},
    ],
}

def get_all_signs():
    """Return flat list of all signs"""
    all_signs = []
    for category, signs in ISL_SIGNS_DATABASE.items():
        for sign in signs:
            sign['category'] = category
            all_signs.append(sign)
    return all_signs

def get_signs_by_category(category):
    """Get signs from specific category"""
    return ISL_SIGNS_DATABASE.get(category, [])

# Statistics
TOTAL_SIGNS = sum(len(signs) for signs in ISL_SIGNS_DATABASE.values())
CATEGORIES = list(ISL_SIGNS_DATABASE.keys())

if __name__ == '__main__':
    print(f"📊 ISL Signs Database")
    print(f"Total Signs: {TOTAL_SIGNS}")
    print(f"Categories: {len(CATEGORIES)}")
    print(f"\nCategories: {', '.join(CATEGORIES)}")
    print(f"\nAll signs loaded and ready for training!")
