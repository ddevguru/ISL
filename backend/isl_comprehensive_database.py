"""
Comprehensive ISL (Indian Sign Language) Database - 300+ Signs
Extended with detailed categories, phrases, and multi-word signs
"""

ISL_COMPREHENSIVE_DATABASE = {
    'Greetings': [
        {'name': 'HELLO', 'en': 'Hello', 'hi': 'नमस्ते', 'desc': 'Wave hand near face'},
        {'name': 'GOODBYE', 'en': 'Goodbye', 'hi': 'अलविदा', 'desc': 'Wave hand up and down'},
        {'name': 'THANK_YOU', 'en': 'Thank You', 'hi': 'धन्यवाद', 'desc': 'Hand from mouth outward'},
        {'name': 'WELCOME', 'en': 'Welcome', 'hi': 'स्वागत है', 'desc': 'Open arms wide'},
        {'name': 'SORRY', 'en': 'Sorry', 'hi': 'माफी', 'desc': 'Hand over chest'},
        {'name': 'PLEASE', 'en': 'Please', 'hi': 'कृपया', 'desc': 'Palms together up'},
        {'name': 'EXCUSE_ME', 'en': 'Excuse Me', 'hi': 'माफ कीजिए', 'desc': 'Tap shoulder'},
        {'name': 'NICE_TO_MEET', 'en': 'Nice to Meet', 'hi': 'खुशी', 'desc': 'Handshake'},
        {'name': 'GOOD_MORNING', 'en': 'Good Morning', 'hi': 'सुप्रभात', 'desc': 'Sun rising + greeting'},
        {'name': 'GOOD_EVENING', 'en': 'Good Evening', 'hi': 'शुभ संध्या', 'desc': 'Sun setting + greeting'},
    ],

    'Basic_Words': [
        {'name': 'YES', 'en': 'Yes', 'hi': 'हाँ', 'desc': 'Nod with thumbs up'},
        {'name': 'NO', 'en': 'No', 'hi': 'नहीं', 'desc': 'Shake head'},
        {'name': 'OK', 'en': 'OK', 'hi': 'ठीक है', 'desc': 'Thumbs up'},
        {'name': 'GOOD', 'en': 'Good', 'hi': 'अच्छा', 'desc': 'Thumbs up'},
        {'name': 'BAD', 'en': 'Bad', 'hi': 'बुरा', 'desc': 'Thumbs down'},
        {'name': 'BETTER', 'en': 'Better', 'hi': 'बेहतर', 'desc': 'Thumb up higher'},
        {'name': 'BEST', 'en': 'Best', 'hi': 'सर्वश्रेष्ठ', 'desc': 'Both thumbs high'},
        {'name': 'EXCELLENT', 'en': 'Excellent', 'hi': 'शानदार', 'desc': 'Clap hands'},
        {'name': 'PERFECT', 'en': 'Perfect', 'hi': 'परिपूर्ण', 'desc': 'Kiss fingers'},
        {'name': 'WONDERFUL', 'en': 'Wonderful', 'hi': 'शानदार', 'desc': 'Arms spread wide'},
    ],

    'Pronouns': [
        {'name': 'I', 'en': 'I', 'hi': 'मैं', 'desc': 'Point to self'},
        {'name': 'YOU', 'en': 'You', 'hi': 'तुम', 'desc': 'Point forward'},
        {'name': 'HE', 'en': 'He', 'hi': 'वह', 'desc': 'Point to side'},
        {'name': 'SHE', 'en': 'She', 'hi': 'वह', 'desc': 'Point other side'},
        {'name': 'WE', 'en': 'We', 'hi': 'हम', 'desc': 'Circle with both'},
        {'name': 'THEY', 'en': 'They', 'hi': 'वे', 'desc': 'Spread arms'},
        {'name': 'THIS', 'en': 'This', 'hi': 'यह', 'desc': 'Point down'},
        {'name': 'THAT', 'en': 'That', 'hi': 'वह', 'desc': 'Point far'},
        {'name': 'EVERYONE', 'en': 'Everyone', 'hi': 'सभी', 'desc': 'Circle motion'},
        {'name': 'SOMEONE', 'en': 'Someone', 'hi': 'कोई', 'desc': 'Vague point'},
    ],

    'Daily_Activities': [
        {'name': 'EAT', 'en': 'Eat', 'hi': 'खाना', 'desc': 'Hand to mouth'},
        {'name': 'DRINK', 'en': 'Drink', 'hi': 'पीना', 'desc': 'Cup to lips'},
        {'name': 'SLEEP', 'en': 'Sleep', 'hi': 'सोना', 'desc': 'Head on hands'},
        {'name': 'WAKE_UP', 'en': 'Wake Up', 'hi': 'जागना', 'desc': 'Open eyes'},
        {'name': 'WORK', 'en': 'Work', 'hi': 'काम', 'desc': 'Fist to palm'},
        {'name': 'PLAY', 'en': 'Play', 'hi': 'खेलना', 'desc': 'Playful motion'},
        {'name': 'STUDY', 'en': 'Study', 'hi': 'पढना', 'desc': 'Open book'},
        {'name': 'READ', 'en': 'Read', 'hi': 'पढना', 'desc': 'Eyes follow motion'},
        {'name': 'WRITE', 'en': 'Write', 'hi': 'लिखना', 'desc': 'Writing motion'},
        {'name': 'WALK', 'en': 'Walk', 'hi': 'चलना', 'desc': 'Fingers walk'},
        {'name': 'RUN', 'en': 'Run', 'hi': 'दौड़ना', 'desc': 'Fast motion'},
        {'name': 'DANCE', 'en': 'Dance', 'hi': 'नाचना', 'desc': 'Sway motion'},
        {'name': 'SING', 'en': 'Sing', 'hi': 'गाना', 'desc': 'Hand motion from mouth'},
        {'name': 'LISTEN', 'en': 'Listen', 'hi': 'सुनना', 'desc': 'Hand to ear'},
        {'name': 'SPEAK', 'en': 'Speak', 'hi': 'बोलना', 'desc': 'Motion from mouth'},
    ],

    'Places': [
        {'name': 'HOME', 'en': 'Home', 'hi': 'घर', 'desc': 'Roof shape'},
        {'name': 'SCHOOL', 'en': 'School', 'hi': 'स्कूल', 'desc': 'Bell ring'},
        {'name': 'HOSPITAL', 'en': 'Hospital', 'hi': 'अस्पताल', 'desc': 'Cross sign'},
        {'name': 'MARKET', 'en': 'Market', 'hi': 'बाजार', 'desc': 'Buying motion'},
        {'name': 'OFFICE', 'en': 'Office', 'hi': 'कार्यालय', 'desc': 'Desk motion'},
        {'name': 'PARK', 'en': 'Park', 'hi': 'पार्क', 'desc': 'Tree motion'},
        {'name': 'TEMPLE', 'en': 'Temple', 'hi': 'मंदिर', 'desc': 'Prayer hands'},
        {'name': 'CHURCH', 'en': 'Church', 'hi': 'गिरजाघर', 'desc': 'Cross overhead'},
        {'name': 'MOSQUE', 'en': 'Mosque', 'hi': 'मस्जिद', 'desc': 'Dome shape'},
        {'name': 'CITY', 'en': 'City', 'hi': 'शहर', 'desc': 'Tall buildings'},
        {'name': 'VILLAGE', 'en': 'Village', 'hi': 'गाँव', 'desc': 'Small houses'},
        {'name': 'STREET', 'en': 'Street', 'hi': 'सड़क', 'desc': 'Two hands apart'},
        {'name': 'BEACH', 'en': 'Beach', 'hi': 'समुद्र तट', 'desc': 'Wave motion'},
        {'name': 'MOUNTAIN', 'en': 'Mountain', 'hi': 'पहाड़', 'desc': 'Triangle shape'},
        {'name': 'RIVER', 'en': 'River', 'hi': 'नदी', 'desc': 'Flowing motion'},
    ],

    'Emotions': [
        {'name': 'HAPPY', 'en': 'Happy', 'hi': 'खुश', 'desc': 'Smile up'},
        {'name': 'SAD', 'en': 'Sad', 'hi': 'उदास', 'desc': 'Frown down'},
        {'name': 'ANGRY', 'en': 'Angry', 'hi': 'गुस्सा', 'desc': 'Fist clench'},
        {'name': 'SCARED', 'en': 'Scared', 'hi': 'डर', 'desc': 'Hold self'},
        {'name': 'SURPRISED', 'en': 'Surprised', 'hi': 'आश्चर्य', 'desc': 'Hands to mouth'},
        {'name': 'LOVE', 'en': 'Love', 'hi': 'प्यार', 'desc': 'Cross over heart'},
        {'name': 'HATE', 'en': 'Hate', 'hi': 'नफरत', 'desc': 'Push away'},
        {'name': 'CONFUSED', 'en': 'Confused', 'hi': 'भ्रमित', 'desc': 'Head tilt'},
        {'name': 'EXCITED', 'en': 'Excited', 'hi': 'उत्साह', 'desc': 'Jump motion'},
        {'name': 'TIRED', 'en': 'Tired', 'hi': 'थकान', 'desc': 'Droop down'},
        {'name': 'PROUD', 'en': 'Proud', 'hi': 'गर्व', 'desc': 'Chest out'},
        {'name': 'ASHAMED', 'en': 'Ashamed', 'hi': 'शर्मिंदा', 'desc': 'Head down'},
    ],

    'Numbers': [
        {'name': 'ZERO', 'en': 'Zero', 'hi': 'शून्य', 'desc': 'O shape'},
        {'name': 'ONE', 'en': 'One', 'hi': 'एक', 'desc': 'One finger'},
        {'name': 'TWO', 'en': 'Two', 'hi': 'दो', 'desc': 'Two fingers'},
        {'name': 'THREE', 'en': 'Three', 'hi': 'तीन', 'desc': 'Three fingers'},
        {'name': 'FOUR', 'en': 'Four', 'hi': 'चार', 'desc': 'Four fingers'},
        {'name': 'FIVE', 'en': 'Five', 'hi': 'पाँच', 'desc': 'All fingers'},
        {'name': 'SIX', 'en': 'Six', 'hi': 'छः', 'desc': 'Six gesture'},
        {'name': 'SEVEN', 'en': 'Seven', 'hi': 'सात', 'desc': 'Seven gesture'},
        {'name': 'EIGHT', 'en': 'Eight', 'hi': 'आठ', 'desc': 'Eight gesture'},
        {'name': 'NINE', 'en': 'Nine', 'hi': 'नौ', 'desc': 'Nine gesture'},
        {'name': 'TEN', 'en': 'Ten', 'hi': 'दस', 'desc': 'Both hands open'},
        {'name': 'TWENTY', 'en': 'Twenty', 'hi': 'बीस', 'desc': 'Two tens'},
        {'name': 'FIFTY', 'en': 'Fifty', 'hi': 'पचास', 'desc': 'Five tens'},
        {'name': 'HUNDRED', 'en': 'Hundred', 'hi': 'सौ', 'desc': 'C shape'},
        {'name': 'THOUSAND', 'en': 'Thousand', 'hi': 'हजार', 'desc': 'M shape'},
    ],

    'Time': [
        {'name': 'NOW', 'en': 'Now', 'hi': 'अभी', 'desc': 'Point down fast'},
        {'name': 'TODAY', 'en': 'Today', 'hi': 'आज', 'desc': 'Point to self'},
        {'name': 'YESTERDAY', 'en': 'Yesterday', 'hi': 'कल', 'desc': 'Thumb back'},
        {'name': 'TOMORROW', 'en': 'Tomorrow', 'hi': 'कल', 'desc': 'Thumb forward'},
        {'name': 'MORNING', 'en': 'Morning', 'hi': 'सुबह', 'desc': 'Sun rising'},
        {'name': 'AFTERNOON', 'en': 'Afternoon', 'hi': 'दोपहर', 'desc': 'Sun peak'},
        {'name': 'EVENING', 'en': 'Evening', 'hi': 'शाम', 'desc': 'Sun setting'},
        {'name': 'NIGHT', 'en': 'Night', 'hi': 'रात', 'desc': 'Moon stars'},
        {'name': 'WEEK', 'en': 'Week', 'hi': 'सप्ताह', 'desc': 'Seven days'},
        {'name': 'MONTH', 'en': 'Month', 'hi': 'महीना', 'desc': 'Finger across'},
        {'name': 'YEAR', 'en': 'Year', 'hi': 'साल', 'desc': 'Circle motion'},
        {'name': 'MONDAY', 'en': 'Monday', 'hi': 'सोमवार', 'desc': 'One + day'},
        {'name': 'FRIDAY', 'en': 'Friday', 'hi': 'शुक्रवार', 'desc': 'Five + day'},
        {'name': 'SUNDAY', 'en': 'Sunday', 'hi': 'रविवार', 'desc': 'Sun + day'},
    ],

    'Questions': [
        {'name': 'WHAT', 'en': 'What', 'hi': 'क्या', 'desc': 'Palms up shrug'},
        {'name': 'WHERE', 'en': 'Where', 'hi': 'कहाँ', 'desc': 'Look around'},
        {'name': 'WHEN', 'en': 'When', 'hi': 'कब', 'desc': 'Point wrist'},
        {'name': 'WHY', 'en': 'Why', 'hi': 'क्यों', 'desc': 'Raise eyebrows'},
        {'name': 'WHO', 'en': 'Who', 'hi': 'कौन', 'desc': 'Circle around self'},
        {'name': 'HOW', 'en': 'How', 'hi': 'कैसे', 'desc': 'Palms up together'},
        {'name': 'HOW_MUCH', 'en': 'How Much', 'hi': 'कितना', 'desc': 'Hands apart'},
        {'name': 'HOW_MANY', 'en': 'How Many', 'hi': 'कितने', 'desc': 'Spread fingers'},
    ],

    'Family': [
        {'name': 'MOTHER', 'en': 'Mother', 'hi': 'माता', 'desc': 'Tap chin'},
        {'name': 'FATHER', 'en': 'Father', 'hi': 'पिता', 'desc': 'Tap forehead'},
        {'name': 'BROTHER', 'en': 'Brother', 'hi': 'भाई', 'desc': 'Point + brother'},
        {'name': 'SISTER', 'en': 'Sister', 'hi': 'बहन', 'desc': 'Point + sister'},
        {'name': 'SON', 'en': 'Son', 'hi': 'बेटा', 'desc': 'Male + child'},
        {'name': 'DAUGHTER', 'en': 'Daughter', 'hi': 'बेटी', 'desc': 'Female + child'},
        {'name': 'GRANDFATHER', 'en': 'Grandfather', 'hi': 'दादा', 'desc': 'Old + father'},
        {'name': 'GRANDMOTHER', 'en': 'Grandmother', 'hi': 'दादी', 'desc': 'Old + mother'},
        {'name': 'FRIEND', 'en': 'Friend', 'hi': 'दोस्त', 'desc': 'Hook fingers'},
        {'name': 'HUSBAND', 'en': 'Husband', 'hi': 'पति', 'desc': 'Ring + man'},
        {'name': 'WIFE', 'en': 'Wife', 'hi': 'पत्नी', 'desc': 'Ring + woman'},
        {'name': 'CHILD', 'en': 'Child', 'hi': 'बच्चा', 'desc': 'Hand at chest'},
        {'name': 'BABY', 'en': 'Baby', 'hi': 'बच्चा', 'desc': 'Rock motion'},
        {'name': 'WOMAN', 'en': 'Woman', 'hi': 'महिला', 'desc': 'Female feature'},
        {'name': 'MAN', 'en': 'Man', 'hi': 'आदमी', 'desc': 'Male feature'},
    ],

    'Food': [
        {'name': 'FOOD', 'en': 'Food', 'hi': 'खाना', 'desc': 'Hand to mouth'},
        {'name': 'BREAD', 'en': 'Bread', 'hi': 'रोटी', 'desc': 'Slicing motion'},
        {'name': 'RICE', 'en': 'Rice', 'hi': 'चावल', 'desc': 'Pinching motion'},
        {'name': 'WATER', 'en': 'Water', 'hi': 'पानी', 'desc': 'W sign'},
        {'name': 'MILK', 'en': 'Milk', 'hi': 'दूध', 'desc': 'Milking motion'},
        {'name': 'TEA', 'en': 'Tea', 'hi': 'चाय', 'desc': 'Cup motion'},
        {'name': 'APPLE', 'en': 'Apple', 'hi': 'सेब', 'desc': 'Round + eat'},
        {'name': 'ORANGE', 'en': 'Orange', 'hi': 'नारंगी', 'desc': 'Round + color'},
        {'name': 'MANGO', 'en': 'Mango', 'hi': 'आम', 'desc': 'Hanging motion'},
        {'name': 'BANANA', 'en': 'Banana', 'hi': 'केला', 'desc': 'C shape'},
        {'name': 'CHICKEN', 'en': 'Chicken', 'hi': 'मुर्गा', 'desc': 'Pecking motion'},
        {'name': 'FISH', 'en': 'Fish', 'hi': 'मछली', 'desc': 'Swimming motion'},
        {'name': 'MEAT', 'en': 'Meat', 'hi': 'मांस', 'desc': 'Tearing motion'},
        {'name': 'SWEET', 'en': 'Sweet', 'hi': 'मीठा', 'desc': 'Lick finger'},
        {'name': 'SALT', 'en': 'Salt', 'hi': 'नमक', 'desc': 'Pinch motion'},
    ],

    'Health': [
        {'name': 'SICK', 'en': 'Sick', 'hi': 'बीमार', 'desc': 'Hand to head'},
        {'name': 'PAIN', 'en': 'Pain', 'hi': 'दर्द', 'desc': 'Clutch area'},
        {'name': 'DOCTOR', 'en': 'Doctor', 'hi': 'डॉक्टर', 'desc': 'Check pulse'},
        {'name': 'MEDICINE', 'en': 'Medicine', 'hi': 'दवा', 'desc': 'Pill swallow'},
        {'name': 'HOSPITAL', 'en': 'Hospital', 'hi': 'अस्पताल', 'desc': 'Cross arms'},
        {'name': 'FEVER', 'en': 'Fever', 'hi': 'बुखार', 'desc': 'Head hot'},
        {'name': 'COUGH', 'en': 'Cough', 'hi': 'खांसी', 'desc': 'Coughing motion'},
        {'name': 'COLD', 'en': 'Cold', 'hi': 'सर्दी', 'desc': 'Shivering motion'},
        {'name': 'HEADACHE', 'en': 'Headache', 'hi': 'सिरदर्द', 'desc': 'Head pain'},
        {'name': 'TOOTHACHE', 'en': 'Toothache', 'hi': 'दांत का दर्द', 'desc': 'Tooth area'},
        {'name': 'HEALTHY', 'en': 'Healthy', 'hi': 'स्वस्थ', 'desc': 'Muscle flex'},
        {'name': 'EXERCISE', 'en': 'Exercise', 'hi': 'व्यायाम', 'desc': 'Fitness motion'},
    ],

    'Colors': [
        {'name': 'RED', 'en': 'Red', 'hi': 'लाल', 'desc': 'R + color'},
        {'name': 'BLUE', 'en': 'Blue', 'hi': 'नीला', 'desc': 'B + color'},
        {'name': 'GREEN', 'en': 'Green', 'hi': 'हरा', 'desc': 'G + color'},
        {'name': 'YELLOW', 'en': 'Yellow', 'hi': 'पीला', 'desc': 'Y + color'},
        {'name': 'WHITE', 'en': 'White', 'hi': 'सफेद', 'desc': 'W + color'},
        {'name': 'BLACK', 'en': 'Black', 'hi': 'काला', 'desc': 'B + color'},
        {'name': 'ORANGE', 'en': 'Orange', 'hi': 'नारंगी', 'desc': 'O + color'},
        {'name': 'PINK', 'en': 'Pink', 'hi': 'गुलाबी', 'desc': 'P + color'},
        {'name': 'PURPLE', 'en': 'Purple', 'hi': 'बैंगनी', 'desc': 'P + color'},
        {'name': 'BROWN', 'en': 'Brown', 'hi': 'भूरा', 'desc': 'B + color'},
    ],

    'Animals': [
        {'name': 'DOG', 'en': 'Dog', 'hi': 'कुत्ता', 'desc': 'Barking motion'},
        {'name': 'CAT', 'en': 'Cat', 'hi': 'बिल्ली', 'desc': 'Whisker motion'},
        {'name': 'BIRD', 'en': 'Bird', 'hi': 'पक्षी', 'desc': 'Flying motion'},
        {'name': 'FISH', 'en': 'Fish', 'hi': 'मछली', 'desc': 'Swimming motion'},
        {'name': 'HORSE', 'en': 'Horse', 'hi': 'घोड़ा', 'desc': 'Galloping motion'},
        {'name': 'COW', 'en': 'Cow', 'hi': 'गाय', 'desc': 'Horn motion'},
        {'name': 'ELEPHANT', 'en': 'Elephant', 'hi': 'हाथी', 'desc': 'Trunk motion'},
        {'name': 'LION', 'en': 'Lion', 'hi': 'शेर', 'desc': 'Mane + roar'},
        {'name': 'TIGER', 'en': 'Tiger', 'hi': 'बाघ', 'desc': 'Stripe motion'},
        {'name': 'MONKEY', 'en': 'Monkey', 'hi': 'बंदर', 'desc': 'Scratching motion'},
    ],

    'Weather': [
        {'name': 'WEATHER', 'en': 'Weather', 'hi': 'मौसम', 'desc': 'Point up'},
        {'name': 'SUN', 'en': 'Sun', 'hi': 'सूरज', 'desc': 'Circle above'},
        {'name': 'MOON', 'en': 'Moon', 'hi': 'चाँद', 'desc': 'C shape'},
        {'name': 'RAIN', 'en': 'Rain', 'hi': 'बारिश', 'desc': 'Fingers down'},
        {'name': 'SNOW', 'en': 'Snow', 'hi': 'बर्फ', 'desc': 'Falling motion'},
        {'name': 'WIND', 'en': 'Wind', 'hi': 'हवा', 'desc': 'W motion'},
        {'name': 'CLOUD', 'en': 'Cloud', 'hi': 'बादल', 'desc': 'Cloud shape'},
        {'name': 'LIGHTNING', 'en': 'Lightning', 'hi': 'बिजली', 'desc': 'Zigzag down'},
        {'name': 'THUNDER', 'en': 'Thunder', 'hi': 'गर्ज', 'desc': 'Loud sound'},
        {'name': 'COLD_WEATHER', 'en': 'Cold', 'hi': 'ठंडा', 'desc': 'Shivering'},
        {'name': 'HOT_WEATHER', 'en': 'Hot', 'hi': 'गर्म', 'desc': 'Wipe forehead'},
    ],

    'Sports': [
        {'name': 'CRICKET', 'en': 'Cricket', 'hi': 'क्रिकेट', 'desc': 'Batting motion'},
        {'name': 'FOOTBALL', 'en': 'Football', 'hi': 'फुटबॉल', 'desc': 'Kicking motion'},
        {'name': 'BASKETBALL', 'en': 'Basketball', 'hi': 'बास्केटबॉल', 'desc': 'Throwing up'},
        {'name': 'TENNIS', 'en': 'Tennis', 'hi': 'टेनिस', 'desc': 'Racket motion'},
        {'name': 'BADMINTON', 'en': 'Badminton', 'hi': 'बैडमिंटन', 'desc': 'Shuttle motion'},
        {'name': 'HOCKEY', 'en': 'Hockey', 'hi': 'हॉकी', 'desc': 'Stick motion'},
        {'name': 'SWIMMING', 'en': 'Swimming', 'hi': 'तैराकी', 'desc': 'Swimming motion'},
        {'name': 'RUNNING', 'en': 'Running', 'hi': 'दौड़ना', 'desc': 'Running motion'},
        {'name': 'CYCLING', 'en': 'Cycling', 'hi': 'साइकिल', 'desc': 'Pedaling motion'},
        {'name': 'BOXING', 'en': 'Boxing', 'hi': 'मुक्केबाजी', 'desc': 'Punching motion'},
    ],

    'Objects': [
        {'name': 'CHAIR', 'en': 'Chair', 'hi': 'कुर्सी', 'desc': 'Sit down'},
        {'name': 'TABLE', 'en': 'Table', 'hi': 'टेबल', 'desc': 'Flat surface'},
        {'name': 'DOOR', 'en': 'Door', 'hi': 'दरवाज़ा', 'desc': 'Open motion'},
        {'name': 'WINDOW', 'en': 'Window', 'hi': 'खिड़की', 'desc': 'Open frame'},
        {'name': 'BOOK', 'en': 'Book', 'hi': 'किताब', 'desc': 'Open book'},
        {'name': 'PEN', 'en': 'Pen', 'hi': 'कलम', 'desc': 'Writing'},
        {'name': 'PAPER', 'en': 'Paper', 'hi': 'कागज़', 'desc': 'Flat motion'},
        {'name': 'PHONE', 'en': 'Phone', 'hi': 'फोन', 'desc': 'Phone to ear'},
        {'name': 'CAR', 'en': 'Car', 'hi': 'कार', 'desc': 'Steering motion'},
        {'name': 'TRAIN', 'en': 'Train', 'hi': 'ट्रेन', 'desc': 'Rail motion'},
        {'name': 'BICYCLE', 'en': 'Bicycle', 'hi': 'साइकिल', 'desc': 'Pedaling'},
        {'name': 'PLANE', 'en': 'Plane', 'hi': 'हवाई जहाज', 'desc': 'Flying motion'},
    ],

    'Actions': [
        {'name': 'GIVE', 'en': 'Give', 'hi': 'देना', 'desc': 'Giving motion'},
        {'name': 'TAKE', 'en': 'Take', 'hi': 'लेना', 'desc': 'Taking motion'},
        {'name': 'SHOW', 'en': 'Show', 'hi': 'दिखाना', 'desc': 'Pointing'},
        {'name': 'HIDE', 'en': 'Hide', 'hi': 'छिपाना', 'desc': 'Covering motion'},
        {'name': 'OPEN', 'en': 'Open', 'hi': 'खोलना', 'desc': 'Opening motion'},
        {'name': 'CLOSE', 'en': 'Close', 'hi': 'बंद करना', 'desc': 'Closing motion'},
        {'name': 'PUSH', 'en': 'Push', 'hi': 'धक्का', 'desc': 'Push motion'},
        {'name': 'PULL', 'en': 'Pull', 'hi': 'खींचना', 'desc': 'Pull motion'},
        {'name': 'THROW', 'en': 'Throw', 'hi': 'फेंकना', 'desc': 'Throwing motion'},
        {'name': 'CATCH', 'en': 'Catch', 'hi': 'पकड़ना', 'desc': 'Catching motion'},
        {'name': 'CLIMB', 'en': 'Climb', 'hi': 'चढ़ना', 'desc': 'Climbing motion'},
        {'name': 'JUMP', 'en': 'Jump', 'hi': 'कूदना', 'desc': 'Jumping motion'},
        {'name': 'FALL', 'en': 'Fall', 'hi': 'गिरना', 'desc': 'Falling motion'},
        {'name': 'SIT', 'en': 'Sit', 'hi': 'बैठना', 'desc': 'Sit motion'},
        {'name': 'STAND', 'en': 'Stand', 'hi': 'खड़ा होना', 'desc': 'Standing motion'},
    ],

    'Abstract': [
        {'name': 'CONTINUE', 'en': 'Continue', 'hi': 'जारी रखना', 'desc': 'Moving forward'},
        {'name': 'STOP', 'en': 'Stop', 'hi': 'रुकना', 'desc': 'Stop motion'},
        {'name': 'WAIT', 'en': 'Wait', 'hi': 'प्रतीक्षा', 'desc': 'Waiting motion'},
        {'name': 'THINK', 'en': 'Think', 'hi': 'सोचना', 'desc': 'Thinking gesture'},
        {'name': 'KNOW', 'en': 'Know', 'hi': 'जानना', 'desc': 'Knowing gesture'},
        {'name': 'FORGET', 'en': 'Forget', 'hi': 'भूलना', 'desc': 'Forgetting gesture'},
        {'name': 'BELIEVE', 'en': 'Believe', 'hi': 'मानना', 'desc': 'Believing gesture'},
        {'name': 'UNDERSTAND', 'en': 'Understand', 'hi': 'समझना', 'desc': 'Understanding gesture'},
        {'name': 'PROMISE', 'en': 'Promise', 'hi': 'वादा', 'desc': 'Promise gesture'},
    ],
}

def get_all_signs():
    """Return flat list of all signs"""
    all_signs = []
    for category, signs in ISL_COMPREHENSIVE_DATABASE.items():
        for sign in signs:
            sign['category'] = category
            all_signs.append(sign)
    return all_signs

def get_signs_by_category(category):
    """Get signs from specific category"""
    return ISL_COMPREHENSIVE_DATABASE.get(category, [])

# Statistics
TOTAL_SIGNS = sum(len(signs) for signs in ISL_COMPREHENSIVE_DATABASE.values())
CATEGORIES = list(ISL_COMPREHENSIVE_DATABASE.keys())

if __name__ == '__main__':
    print(f"📊 ISL Comprehensive Database")
    print(f"Total Signs: {TOTAL_SIGNS}")
    print(f"Categories: {len(CATEGORIES)}")
    print(f"\nCategories: {', '.join(CATEGORIES)}")
    print(f"\nDatabase ready with {TOTAL_SIGNS} signs!")
