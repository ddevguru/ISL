"""Load sample ISL signs into database"""
from app import create_app, db
from models import Sign
import os

def load_signs():
    app = create_app(os.getenv('FLASK_ENV', 'development'))
    
    with app.app_context():
        print("Loading sample signs...")
        
        signs_data = [
            {
                'name': 'HELLO',
                'english_translation': 'Hello',
                'hindi_translation': 'नमस्ते',
                'category': 'Greetings',
                'difficulty_level': 'Easy',
                'description': 'Wave your hand near your face'
            },
            {
                'name': 'THANK_YOU',
                'english_translation': 'Thank You',
                'hindi_translation': 'धन्यवाद',
                'category': 'Greetings',
                'difficulty_level': 'Easy',
                'description': 'Bring hand to mouth, then extend outward'
            },
            {
                'name': 'YES',
                'english_translation': 'Yes',
                'hindi_translation': 'हाँ',
                'category': 'Common Words',
                'difficulty_level': 'Easy',
                'description': 'Nod with thumb up'
            },
            {
                'name': 'NO',
                'english_translation': 'No',
                'hindi_translation': 'नहीं',
                'category': 'Common Words',
                'difficulty_level': 'Easy',
                'description': 'Cross hands in front of body'
            },
            {
                'name': 'HOME',
                'english_translation': 'Home',
                'hindi_translation': 'घर',
                'category': 'Places',
                'difficulty_level': 'Easy',
                'description': 'Form roof shape with both hands'
            },
            {
                'name': 'GOOD',
                'english_translation': 'Good',
                'hindi_translation': 'अच्छा',
                'category': 'Adjectives',
                'difficulty_level': 'Easy',
                'description': 'Thumbs up gesture'
            },
            {
                'name': 'BAD',
                'english_translation': 'Bad',
                'hindi_translation': 'बुरा',
                'category': 'Adjectives',
                'difficulty_level': 'Easy',
                'description': 'Thumbs down gesture'
            },
            {
                'name': 'HELP',
                'english_translation': 'Help',
                'hindi_translation': 'मदद',
                'category': 'Verbs',
                'difficulty_level': 'Medium',
                'description': 'Fist on palm gesture'
            },
            {
                'name': 'LOVE',
                'english_translation': 'Love',
                'hindi_translation': 'प्यार',
                'category': 'Emotions',
                'difficulty_level': 'Medium',
                'description': 'Cross hands over heart'
            },
            {
                'name': 'FRIEND',
                'english_translation': 'Friend',
                'hindi_translation': 'दोस्त',
                'category': 'People',
                'difficulty_level': 'Medium',
                'description': 'Hook two fingers together'
            },
        ]
        
        for sign_data in signs_data:
            existing = Sign.query.filter_by(name=sign_data['name']).first()
            if not existing:
                sign = Sign(**sign_data)
                db.session.add(sign)
                print(f"  ✓ Added: {sign_data['name']}")
        
        db.session.commit()
        print("✅ Sample signs loaded!")

if __name__ == '__main__':
    load_signs()
