import json
from pathlib import Path
from typing import Dict, List, Tuple

class TranslationService:
    def __init__(self):
        self.translations = self._load_translations()
        self.sign_to_words = self._build_sign_to_words_map()

    def _load_translations(self) -> Dict:
        try:
            labels_file = Path('models/sign_labels.json')
            if labels_file.exists():
                with open(labels_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load translations: {e}")
        return self._get_default_translations()

    def _get_default_translations(self) -> Dict:
        return {
            '0': {'english': 'Hello', 'hindi': 'नमस्ते', 'words': ['hello', 'greetings', 'hi']},
            '1': {'english': 'Thank You', 'hindi': 'धन्यवाद', 'words': ['thank', 'thanks', 'appreciate']},
            '2': {'english': 'Yes', 'hindi': 'हाँ', 'words': ['yes', 'yeah', 'affirmative']},
            '3': {'english': 'No', 'hindi': 'नहीं', 'words': ['no', 'nope', 'negative']},
            '4': {'english': 'Water', 'hindi': 'पानी', 'words': ['water', 'drink', 'liquid']},
            '5': {'english': 'Food', 'hindi': 'खाना', 'words': ['food', 'eat', 'meal']},
            '6': {'english': 'Good', 'hindi': 'अच्छा', 'words': ['good', 'great', 'excellent']},
            '7': {'english': 'Bad', 'hindi': 'बुरा', 'words': ['bad', 'poor', 'terrible']},
            '8': {'english': 'Help', 'hindi': 'मदद', 'words': ['help', 'assist', 'aid']},
            '9': {'english': 'Please', 'hindi': 'कृपया', 'words': ['please', 'request', 'ask']},
        }

    def _build_sign_to_words_map(self) -> Dict[str, List[str]]:
        sign_map = {}
        for sign_id, trans in self.translations.items():
            english = trans.get('english', '')
            words = trans.get('words', [english.lower()])
            sign_map[english.lower()] = {
                'english': english,
                'hindi': trans.get('hindi', ''),
                'variations': words
            }
        return sign_map

    def translate_sign(self, sign_name: str, target_language: str = 'english') -> str:
        """Translate a single sign to target language"""
        sign_lower = sign_name.lower()

        for sign_id, trans in self.translations.items():
            if trans.get('english', '').lower() == sign_lower:
                return trans.get(target_language, sign_name)

        for sign_lower_map, trans_map in self.sign_to_words.items():
            if sign_lower_map == sign_lower:
                return trans_map.get(target_language, sign_name)

        return sign_name

    def build_sentence(self, signs: List[str], target_language: str = 'english') -> str:
        """Build a sentence from detected signs"""
        translations = []

        for sign in signs:
            trans = self.translate_sign(sign, target_language)
            if trans:
                translations.append(trans)

        if target_language == 'hindi':
            return ' '.join(translations)
        else:
            return ' '.join(translations)

    def detect_paragraph_signs(self, detected_signs: List[Dict]) -> Dict:
        """Process multiple detected signs and build a paragraph"""
        unique_signs = []
        seen = set()

        for detection in detected_signs:
            sign = detection.get('sign')
            if sign and sign.lower() not in seen:
                unique_signs.append(sign)
                seen.add(sign.lower())

        english_paragraph = self.build_sentence(unique_signs, 'english')
        hindi_paragraph = self.build_sentence(unique_signs, 'hindi')

        return {
            'signs': unique_signs,
            'english_paragraph': english_paragraph,
            'hindi_paragraph': hindi_paragraph,
            'total_signs': len(unique_signs),
            'total_detections': len(detected_signs)
        }

    def get_sign_details(self, sign_name: str) -> Dict:
        """Get detailed information about a sign including translations"""
        sign_lower = sign_name.lower()

        for sign_id, trans in self.translations.items():
            if trans.get('english', '').lower() == sign_lower:
                return {
                    'id': sign_id,
                    'english': trans.get('english'),
                    'hindi': trans.get('hindi'),
                    'variations': trans.get('words', []),
                    'confidence': 0.0
                }

        return {
            'english': sign_name,
            'hindi': sign_name,
            'variations': [sign_name.lower()],
            'confidence': 0.0
        }

    def get_all_signs(self) -> List[Dict]:
        """Get all available signs with translations"""
        signs = []
        for sign_id, trans in self.translations.items():
            signs.append({
                'id': sign_id,
                'english': trans.get('english'),
                'hindi': trans.get('hindi'),
                'variations': trans.get('words', [])
            })
        return signs

    def fuzzy_match_sign(self, input_text: str) -> Tuple[str, float]:
        """Find closest matching sign for input text"""
        from difflib import SequenceMatcher

        input_lower = input_text.lower().strip()
        best_match = None
        best_ratio = 0.0

        for sign_lower_map, trans_map in self.sign_to_words.items():
            ratio = SequenceMatcher(None, input_lower, sign_lower_map).ratio()
            if ratio > best_ratio:
                best_ratio = ratio
                best_match = trans_map.get('english')

        return (best_match, best_ratio) if best_match else (input_text, 0.0)

    def expand_abbreviations(self, text: str) -> str:
        """Expand common abbreviations in sign language"""
        expansions = {
            'u': 'you',
            'r': 'are',
            'ur': 'your',
            'b4': 'before',
            '2': 'to',
            'c': 'see',
            '4u': 'for you'
        }

        words = text.split()
        expanded = []

        for word in words:
            expanded.append(expansions.get(word.lower(), word))

        return ' '.join(expanded)

    def validate_sign_sequence(self, signs: List[str]) -> Dict:
        """Validate if a sequence of signs makes sense"""
        analysis = {
            'valid_signs': [],
            'invalid_signs': [],
            'confidence': 0.0,
            'suggestions': []
        }

        for sign in signs:
            details = self.get_sign_details(sign)
            if details and details.get('english') != sign:
                analysis['valid_signs'].append(details)
            else:
                closest, ratio = self.fuzzy_match_sign(sign)
                if ratio > 0.7:
                    analysis['suggestions'].append({
                        'original': sign,
                        'suggested': closest,
                        'confidence': ratio
                    })
                    analysis['valid_signs'].append(self.get_sign_details(closest))
                else:
                    analysis['invalid_signs'].append(sign)

        analysis['confidence'] = len(analysis['valid_signs']) / max(len(signs), 1)

        return analysis
