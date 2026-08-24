import json
import os
from pathlib import Path
from models import db, Sign
import random

class DatasetLoader:
    def __init__(self):
        self.datasets_path = Path('datasets')

    def load_sign_language_dataset(self):
        large_dataset = self._generate_comprehensive_dataset()
        return large_dataset

    def _generate_comprehensive_dataset(self):
        dataset = [
            # Greetings & Communication
            {'name': 'Hello', 'english_translation': 'Hello / Greetings', 'hindi_translation': 'नमस्ते', 'description': 'Waving hand gesture to greet someone', 'category': 'Greetings', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Goodbye', 'english_translation': 'Goodbye / Farewell', 'hindi_translation': 'अलविदा', 'description': 'Waving hand while moving it side to side', 'category': 'Greetings', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Welcome', 'english_translation': 'Welcome', 'hindi_translation': 'स्वागत है', 'description': 'Both hands open gesturing inward', 'category': 'Greetings', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Good Morning', 'english_translation': 'Good Morning', 'hindi_translation': 'सुप्रभात', 'description': 'Open hand to sky then greeting gesture', 'category': 'Greetings', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Good Night', 'english_translation': 'Good Night', 'hindi_translation': 'शुभ रात्रि', 'description': 'Hand to face like sleeping then wave', 'category': 'Greetings', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Responses & Affirmations
            {'name': 'Yes', 'english_translation': 'Yes / Affirmation', 'hindi_translation': 'हाँ', 'description': 'Nodding head or fist bouncing up and down', 'category': 'Response', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'No', 'english_translation': 'No / Denial', 'hindi_translation': 'नहीं', 'description': 'Shaking head side to side or crossed hands', 'category': 'Response', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Maybe', 'english_translation': 'Maybe / Perhaps', 'hindi_translation': 'शायद', 'description': 'Hand tilts side to side with uncertain expression', 'category': 'Response', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'OK', 'english_translation': 'OK / Agreed', 'hindi_translation': 'ठीक है', 'description': 'Thumb and finger circle with other fingers up', 'category': 'Response', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Agree', 'english_translation': 'Agree / Understand', 'hindi_translation': 'सहमत', 'description': 'Fist on chest then nod', 'category': 'Response', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Emotions
            {'name': 'Happy', 'english_translation': 'Happy / Joy', 'hindi_translation': 'खुश', 'description': 'Hands move up along face with smile', 'category': 'Emotions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sad', 'english_translation': 'Sad / Unhappy', 'hindi_translation': 'दुःख', 'description': 'Fingers trace down face with sad expression', 'category': 'Emotions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Angry', 'english_translation': 'Angry / Upset', 'hindi_translation': 'क्रोधित', 'description': 'Claw hands moving down face forcefully', 'category': 'Emotions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Scared', 'english_translation': 'Scared / Afraid', 'hindi_translation': 'डरा हुआ', 'description': 'Hands to chest with fearful expression', 'category': 'Emotions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Surprised', 'english_translation': 'Surprised / Shocked', 'hindi_translation': 'आश्चर्यचकित', 'description': 'Hands to mouth with wide eyes', 'category': 'Emotions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Love', 'english_translation': 'Love / Care', 'hindi_translation': 'प्यार', 'description': 'Both hands crossed on chest', 'category': 'Emotions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Tired', 'english_translation': 'Tired / Exhausted', 'hindi_translation': 'थका हुआ', 'description': 'Hands dropping from shoulders', 'category': 'Emotions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Confused', 'english_translation': 'Confused / Puzzled', 'hindi_translation': 'भ्रमित', 'description': 'Hand to head with tilted head', 'category': 'Emotions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Actions & Verbs
            {'name': 'Walk', 'english_translation': 'Walk / Move', 'hindi_translation': 'चलना', 'description': 'Two fingers walking on palm', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Run', 'english_translation': 'Run / Sprint', 'hindi_translation': 'दौड़ना', 'description': 'Arms bent at elbow moving back and forth quickly', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Jump', 'english_translation': 'Jump / Leap', 'hindi_translation': 'कूदना', 'description': 'Two fingers jumping upward', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sit', 'english_translation': 'Sit / Settle', 'hindi_translation': 'बैठना', 'description': 'Two fingers sit on other two fingers', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Stand', 'english_translation': 'Stand / Rise', 'hindi_translation': 'खड़ा होना', 'description': 'Two fingers standing on palm', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sleep', 'english_translation': 'Sleep / Rest', 'hindi_translation': 'सोना', 'description': 'Hands on cheek moving to palm as if sleeping', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Wake Up', 'english_translation': 'Wake Up / Awaken', 'hindi_translation': 'जागना', 'description': 'Eyes open gesture with both hands opening from sides', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Dance', 'english_translation': 'Dance / Move', 'hindi_translation': 'नृत्य', 'description': 'Both hands swaying side to side rhythmically', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Eat', 'english_translation': 'Eat / Consume', 'hindi_translation': 'खाना', 'description': 'Fingers to mouth repeatedly', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Drink', 'english_translation': 'Drink / Consume', 'hindi_translation': 'पीना', 'description': 'Hand in C shape to mouth as drinking', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Work', 'english_translation': 'Work / Labour', 'hindi_translation': 'काम', 'description': 'Both fists tapping together alternately', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Play', 'english_translation': 'Play / Fun', 'hindi_translation': 'खेलना', 'description': 'Both pinky fingers wiggling', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Read', 'english_translation': 'Read / Study', 'hindi_translation': 'पढ़ना', 'description': 'Open hand moving downward on palm', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Write', 'english_translation': 'Write / Pen', 'hindi_translation': 'लिखना', 'description': 'Finger gesture of writing on palm', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Listen', 'english_translation': 'Listen / Hear', 'hindi_translation': 'सुनना', 'description': 'Hand cupped behind ear', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Look', 'english_translation': 'Look / See', 'hindi_translation': 'देखना', 'description': 'Index and middle finger to eyes', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Help', 'english_translation': 'Help / Assist', 'hindi_translation': 'मदद', 'description': 'Hand under fist lifting up', 'category': 'Actions', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Give', 'english_translation': 'Give / Offer', 'hindi_translation': 'देना', 'description': 'Open hand moving forward', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Take', 'english_translation': 'Take / Accept', 'hindi_translation': 'लेना', 'description': 'Hand closing into fist as grasping', 'category': 'Actions', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},

            # Objects & Things
            {'name': 'Water', 'english_translation': 'Water / Drink', 'hindi_translation': 'पानी', 'description': 'W hand gesture to lips', 'category': 'Objects', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Food', 'english_translation': 'Food / Meal', 'hindi_translation': 'खाना', 'description': 'Open hand to mouth as eating', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'House', 'english_translation': 'House / Home', 'hindi_translation': 'घर', 'description': 'Hands form roof shape then lower', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Car', 'english_translation': 'Car / Vehicle', 'hindi_translation': 'कार', 'description': 'Hands stacked and moving forward', 'category': 'Objects', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Phone', 'english_translation': 'Phone / Telephone', 'hindi_translation': 'फोन', 'description': 'Hand in L shape to ear', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Book', 'english_translation': 'Book / Text', 'hindi_translation': 'किताब', 'description': 'Open hands like opening a book', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'School', 'english_translation': 'School / Academy', 'hindi_translation': 'स्कूल', 'description': 'Hands clapping together', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Money', 'english_translation': 'Money / Currency', 'hindi_translation': 'पैसा', 'description': 'Rubbing fingers together', 'category': 'Objects', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Clock', 'english_translation': 'Clock / Time', 'hindi_translation': 'घड़ी', 'description': 'Circular motion with index finger', 'category': 'Objects', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Doctor', 'english_translation': 'Doctor / Physician', 'hindi_translation': 'डॉक्टर', 'description': 'Hand to arm checking pulse', 'category': 'Objects', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Adjectives & Descriptions
            {'name': 'Good', 'english_translation': 'Good / Great', 'hindi_translation': 'अच्छा', 'description': 'Thumb up or hand on chin moving away', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Bad', 'english_translation': 'Bad / Evil', 'hindi_translation': 'बुरा', 'description': 'Hand to lips and turned down', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Beautiful', 'english_translation': 'Beautiful / Pretty', 'hindi_translation': 'सुंदर', 'description': 'Hand traces face then opens', 'category': 'Adjectives', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Ugly', 'english_translation': 'Ugly / Unattractive', 'hindi_translation': 'बदसूरत', 'description': 'Hand to face with disgusted expression', 'category': 'Adjectives', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Big', 'english_translation': 'Big / Large', 'hindi_translation': 'बड़ा', 'description': 'Both hands spread wide apart', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Small', 'english_translation': 'Small / Tiny', 'hindi_translation': 'छोटा', 'description': 'Hands close together indicating small', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Hot', 'english_translation': 'Hot / Warm', 'hindi_translation': 'गर्म', 'description': 'Hand away from mouth as hot', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Cold', 'english_translation': 'Cold / Freezing', 'hindi_translation': 'ठंडा', 'description': 'Shivering gesture with hands', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Strong', 'english_translation': 'Strong / Powerful', 'hindi_translation': 'मजबूत', 'description': 'Flexing biceps or fists clenched', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Weak', 'english_translation': 'Weak / Feeble', 'hindi_translation': 'कमजोर', 'description': 'Hands dropping down limp', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Fast', 'english_translation': 'Fast / Quick', 'hindi_translation': 'तेज', 'description': 'Hand moving quickly forward', 'category': 'Adjectives', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Slow', 'english_translation': 'Slow / Sluggish', 'hindi_translation': 'धीमा', 'description': 'Hand moving slowly forward', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Clean', 'english_translation': 'Clean / Neat', 'hindi_translation': 'साफ', 'description': 'Wiping motion across palm', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Dirty', 'english_translation': 'Dirty / Messy', 'hindi_translation': 'गंदा', 'description': 'Hand wiggling with disgusted look', 'category': 'Adjectives', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},

            # Family & Relationships
            {'name': 'Mother', 'english_translation': 'Mother / Mom', 'hindi_translation': 'माता', 'description': 'Thumb on chin, hand opens', 'category': 'Family', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Father', 'english_translation': 'Father / Dad', 'hindi_translation': 'पिता', 'description': 'Thumb on forehead, hand opens', 'category': 'Family', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sister', 'english_translation': 'Sister', 'hindi_translation': 'बहन', 'description': 'Pinky finger on cheek then hand opens', 'category': 'Family', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Brother', 'english_translation': 'Brother', 'hindi_translation': 'भाई', 'description': 'Index finger on temple then opens', 'category': 'Family', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Baby', 'english_translation': 'Baby / Infant', 'hindi_translation': 'बच्चा', 'description': 'Rocking motion as holding baby', 'category': 'Family', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Grandfather', 'english_translation': 'Grandfather', 'hindi_translation': 'दादा', 'description': 'Father sign then beard gesture', 'category': 'Family', 'difficulty_level': 'hard', 'dataset_source': 'ISL'},
            {'name': 'Grandmother', 'english_translation': 'Grandmother', 'hindi_translation': 'दादी', 'description': 'Mother sign then beard gesture', 'category': 'Family', 'difficulty_level': 'hard', 'dataset_source': 'ISL'},
            {'name': 'Husband', 'english_translation': 'Husband / Spouse', 'hindi_translation': 'पति', 'description': 'Male sign then marriage gesture', 'category': 'Family', 'difficulty_level': 'hard', 'dataset_source': 'ISL'},
            {'name': 'Wife', 'english_translation': 'Wife / Spouse', 'hindi_translation': 'पत्नी', 'description': 'Female sign then marriage gesture', 'category': 'Family', 'difficulty_level': 'hard', 'dataset_source': 'ISL'},
            {'name': 'Friend', 'english_translation': 'Friend / Companion', 'hindi_translation': 'मित्र', 'description': 'Two fingers linking together', 'category': 'Relationships', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Requests & Social
            {'name': 'Please', 'english_translation': 'Please / Request', 'hindi_translation': 'कृपया', 'description': 'Hand on chest in circular motion', 'category': 'Requests', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Thank You', 'english_translation': 'Thank You / Thanks', 'hindi_translation': 'धन्यवाद', 'description': 'Hand touching chest and moving forward', 'category': 'Requests', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sorry', 'english_translation': 'Sorry / Apology', 'hindi_translation': 'माफी', 'description': 'Hand on chest with sorry expression', 'category': 'Requests', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Excuse Me', 'english_translation': 'Excuse Me', 'hindi_translation': 'माफ कीजिए', 'description': 'Hand gesture seeking attention', 'category': 'Requests', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},

            # Education & Cognition
            {'name': 'Learn', 'english_translation': 'Learn / Study', 'hindi_translation': 'सीखना', 'description': 'Hand to head then to open palm', 'category': 'Education', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Understand', 'english_translation': 'Understand / Comprehend', 'hindi_translation': 'समझना', 'description': 'Pinching hand to head', 'category': 'Education', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Forget', 'english_translation': 'Forget / Neglect', 'hindi_translation': 'भूलना', 'description': 'Hand wiping across forehead', 'category': 'Education', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Remember', 'english_translation': 'Remember / Recall', 'hindi_translation': 'याद रखना', 'description': 'Finger to temple indicating thinking', 'category': 'Education', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Think', 'english_translation': 'Think / Ponder', 'hindi_translation': 'सोचना', 'description': 'Circular motion at temple', 'category': 'Education', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},

            # Time & Numbers
            {'name': 'Today', 'english_translation': 'Today / Now', 'hindi_translation': 'आज', 'description': 'Both hands down pointing to present', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Tomorrow', 'english_translation': 'Tomorrow', 'hindi_translation': 'कल', 'description': 'Thumb pointing forward indicating future', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Yesterday', 'english_translation': 'Yesterday', 'hindi_translation': 'कल', 'description': 'Thumb pointing backward indicating past', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Morning', 'english_translation': 'Morning / Dawn', 'hindi_translation': 'सुबह', 'description': 'Arm rising indicating sun coming up', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Evening', 'english_translation': 'Evening / Dusk', 'hindi_translation': 'शाम', 'description': 'Arm lowering indicating sun going down', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Night', 'english_translation': 'Night / Dark', 'hindi_translation': 'रात', 'description': 'Both hands moving over head in arc', 'category': 'Time', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'One', 'english_translation': 'One / Single', 'hindi_translation': 'एक', 'description': 'Index finger up', 'category': 'Numbers', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Two', 'english_translation': 'Two / Couple', 'hindi_translation': 'दो', 'description': 'Index and middle finger up', 'category': 'Numbers', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Three', 'english_translation': 'Three', 'hindi_translation': 'तीन', 'description': 'Three fingers up', 'category': 'Numbers', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Five', 'english_translation': 'Five / Hand', 'hindi_translation': 'पाँच', 'description': 'All five fingers spread', 'category': 'Numbers', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Ten', 'english_translation': 'Ten / Both Hands', 'hindi_translation': 'दस', 'description': 'Both hands with all fingers spread', 'category': 'Numbers', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},

            # Health & Body
            {'name': 'Pain', 'english_translation': 'Pain / Hurt', 'hindi_translation': 'दर्द', 'description': 'Fingers pointing inward at body area', 'category': 'Health', 'difficulty_level': 'easy', 'dataset_source': 'ISL'},
            {'name': 'Sick', 'english_translation': 'Sick / Ill', 'hindi_translation': 'बीमार', 'description': 'Hand to forehead and stomach', 'category': 'Health', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Health', 'english_translation': 'Health / Wellness', 'hindi_translation': 'स्वास्थ्य', 'description': 'Both hands on chest indicating strong', 'category': 'Health', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
            {'name': 'Hospital', 'english_translation': 'Hospital / Medical', 'hindi_translation': 'अस्पताल', 'description': 'Cross gesture with hands on arm', 'category': 'Health', 'difficulty_level': 'medium', 'dataset_source': 'ISL'},
        ]

        return dataset

    def generate_hand_landmarks(self, sign_name):
        """Generate simulated 2D hand skeleton points (21 landmarks) for visualization"""
        name = sign_name.upper()

        # Default open hand (HELLO) template normalized coordinates
        wrist = [0.5, 0.85]
        thumb = [[0.4, 0.8], [0.32, 0.74], [0.26, 0.7], [0.2, 0.68]]
        index = [[0.43, 0.6], [0.4, 0.48], [0.38, 0.39], [0.36, 0.3]]
        middle = [[0.5, 0.58], [0.5, 0.44], [0.5, 0.34], [0.5, 0.24]]
        ring = [[0.57, 0.6], [0.6, 0.48], [0.62, 0.39], [0.64, 0.3]]
        pinky = [[0.63, 0.64], [0.67, 0.55], [0.7, 0.48], [0.72, 0.41]]

        if name in ['GOOD', 'YES', 'AGREE', 'STRONG', 'HEALTH']:  # Thumbs Up
            thumb = [[0.4, 0.8], [0.34, 0.74], [0.32, 0.62], [0.32, 0.52]]
            index = [[0.43, 0.6], [0.44, 0.64], [0.43, 0.66], [0.44, 0.65]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name in ['BAD', 'WEAK', 'UGLY']:  # Thumbs Down
            thumb = [[0.4, 0.8], [0.34, 0.86], [0.32, 0.94], [0.32, 0.98]]
            index = [[0.43, 0.6], [0.44, 0.64], [0.43, 0.66], [0.44, 0.65]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name in ['PEACE', 'TWO', 'WALK', 'RUN', 'JUMP', 'DANCE', 'THREE']:  # Peace Sign
            thumb = [[0.4, 0.8], [0.36, 0.76], [0.38, 0.72], [0.42, 0.7]]
            index = [[0.43, 0.6], [0.38, 0.46], [0.34, 0.34], [0.3, 0.22]]
            middle = [[0.5, 0.58], [0.5, 0.44], [0.5, 0.32], [0.5, 0.2]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name in ['OK', 'UNDERSTAND', 'LISTEN']:  # OK Sign
            thumb = [[0.4, 0.8], [0.32, 0.76], [0.34, 0.68], [0.38, 0.62]]
            index = [[0.43, 0.6], [0.4, 0.54], [0.38, 0.58], [0.38, 0.62]]
            middle = [[0.5, 0.58], [0.5, 0.44], [0.5, 0.34], [0.5, 0.24]]
            ring = [[0.57, 0.6], [0.6, 0.48], [0.62, 0.39], [0.64, 0.3]]
            pinky = [[0.63, 0.64], [0.67, 0.55], [0.7, 0.48], [0.72, 0.41]]
        elif name in ['NO', 'ONE', 'THINK', 'LOOK', 'REMEMBER', 'FORGET', 'LEARN', 'WRITE', 'CLOCK']:  # Index point up
            thumb = [[0.4, 0.8], [0.36, 0.76], [0.38, 0.72], [0.42, 0.7]]
            index = [[0.43, 0.6], [0.4, 0.46], [0.38, 0.36], [0.36, 0.25]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name in ['LOVE', 'FRIEND', 'BEAUTIFUL', 'PHONE']:  # Love Sign
            thumb = [[0.4, 0.8], [0.32, 0.76], [0.24, 0.72], [0.18, 0.7]]
            index = [[0.43, 0.6], [0.4, 0.46], [0.38, 0.36], [0.36, 0.25]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.67, 0.54], [0.7, 0.47], [0.72, 0.4]]
        elif name in ['FIST', 'SORRY', 'ANGRY', 'SCARED', 'WORK', 'PAIN', 'SIT', 'COLD', 'DIRTY', 'BABY', 'SICK', 'TAKE', 'WATER', 'FOOD', 'CAR', 'MONEY', 'DOCTOR']:
            # Fist shape
            thumb = [[0.4, 0.8], [0.36, 0.76], [0.38, 0.72], [0.42, 0.7]]
            index = [[0.43, 0.6], [0.44, 0.64], [0.43, 0.66], [0.44, 0.65]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name == 'HELP':
            # Fist resting on palm (represented as fist here)
            thumb = [[0.4, 0.8], [0.36, 0.76], [0.38, 0.72], [0.42, 0.7]]
            index = [[0.43, 0.6], [0.44, 0.64], [0.43, 0.66], [0.44, 0.65]]
            middle = [[0.5, 0.58], [0.5, 0.62], [0.5, 0.64], [0.5, 0.63]]
            ring = [[0.57, 0.6], [0.56, 0.64], [0.57, 0.66], [0.56, 0.65]]
            pinky = [[0.63, 0.64], [0.62, 0.68], [0.63, 0.7], [0.62, 0.69]]
        elif name in ['HOME', 'HOUSE', 'SCHOOL', 'HOSPITAL']:
            # Tilted roof shape
            thumb = [[0.4, 0.8], [0.34, 0.76], [0.28, 0.72], [0.22, 0.7]]
            index = [[0.43, 0.6], [0.38, 0.52], [0.34, 0.45], [0.3, 0.38]]
            middle = [[0.5, 0.58], [0.46, 0.48], [0.42, 0.4], [0.38, 0.32]]
            ring = [[0.57, 0.6], [0.53, 0.52], [0.49, 0.45], [0.45, 0.38]]
            pinky = [[0.63, 0.64], [0.59, 0.58], [0.55, 0.52], [0.51, 0.46]]

        points = [wrist] + thumb + index + middle + ring + pinky
        return [{'x': p[0], 'y': p[1]} for p in points]

    def insert_signs_into_db(self):
        try:
            dataset = self.load_sign_language_dataset()

            for sign_data in dataset:
                existing = Sign.query.filter_by(name=sign_data['name']).first()

                if existing:
                    existing.keypoints_data = self.generate_hand_landmarks(sign_data['name'])
                    existing.english_translation = sign_data['english_translation']
                    existing.hindi_translation = sign_data.get('hindi_translation')
                    existing.description = sign_data.get('description')
                    existing.category = sign_data.get('category')
                    existing.difficulty_level = sign_data.get('difficulty_level')
                else:
                    sign = Sign(
                        name=sign_data['name'],
                        english_translation=sign_data['english_translation'],
                        hindi_translation=sign_data.get('hindi_translation'),
                        description=sign_data.get('description'),
                        category=sign_data.get('category'),
                        difficulty_level=sign_data.get('difficulty_level'),
                        dataset_source=sign_data.get('dataset_source'),
                        confidence_score=random.uniform(0.85, 0.99),
                        keypoints_data=self.generate_hand_landmarks(sign_data['name'])
                    )
                    db.session.add(sign)

            db.session.commit()
            return len(dataset), "Dataset loaded and updated successfully"

        except Exception as e:
            db.session.rollback()
            return 0, f"Error loading dataset: {str(e)}"

    def get_dataset_statistics(self):
        try:
            total_signs = Sign.query.count()
            categories = db.session.query(
                Sign.category,
                db.func.count(Sign.id).label('count')
            ).group_by(Sign.category).all()

            difficulty_distribution = db.session.query(
                Sign.difficulty_level,
                db.func.count(Sign.id).label('count')
            ).group_by(Sign.difficulty_level).all()

            return {
                'total_signs': total_signs,
                'categories': {cat: count for cat, count in categories},
                'difficulty_distribution': {diff: count for diff, count in difficulty_distribution}
            }

        except Exception as e:
            return {'error': str(e)}
