#!/usr/bin/env python
"""Script to load all sign language data into the database"""

import os
import sys
from pathlib import Path

def main():
    print("=" * 70)
    print("Sign Language Dataset Loader - 100+ Signs")
    print("=" * 70)

    try:
        from app import create_app, db
        from dataset_loader import DatasetLoader

        app = create_app(os.getenv('FLASK_ENV', 'development'))

        with app.app_context():
            print("\n[Step 1] Loading comprehensive sign language dataset...")
            loader = DatasetLoader()

            # Get dataset
            dataset = loader.load_sign_language_dataset()
            print(f"✓ Loaded {len(dataset)} signs from dataset")

            # Insert into database
            print("\n[Step 2] Inserting signs into database...")
            count, message = loader.insert_signs_into_db()
            print(f"✓ {message}")
            print(f"✓ {count} signs successfully added to database")

            # Display statistics
            print("\n[Step 3] Dataset Statistics:")
            stats = loader.get_dataset_statistics()

            print(f"\n  Total Signs: {stats['total_signs']}")
            print(f"\n  By Category:")
            for category, count in sorted(stats['categories'].items()):
                print(f"    • {category}: {count} signs")

            print(f"\n  By Difficulty Level:")
            for difficulty, count in sorted(stats['difficulty_distribution'].items()):
                print(f"    • {difficulty}: {count} signs")

            # Display sample signs
            print("\n[Step 4] Sample Signs from Each Category:")
            from models import Sign
            categories = db.session.query(Sign.category).distinct().all()

            for (cat,) in sorted(categories):
                if cat:
                    sample = Sign.query.filter_by(category=cat).first()
                    if sample:
                        print(f"\n  {cat}:")
                        print(f"    • {sample.name} ({sample.english_translation})")
                        print(f"      Hindi: {sample.hindi_translation}")
                        print(f"      Difficulty: {sample.difficulty_level}")

            print("\n" + "=" * 70)
            print("✓ Dataset Loading Complete!")
            print("=" * 70)
            print("\nYou can now:")
            print("  1. Test sign detection: POST /api/detection/detect-frame")
            print("  2. Browse signs: GET /api/detection/signs")
            print("  3. Search signs: GET /api/detection/signs?search=hello")
            print("  4. Filter by category: GET /api/detection/signs?category=Emotions")
            print("\nAPI is ready at http://localhost:5000")
            print("=" * 70)

    except Exception as e:
        print(f"\n✗ Error: {str(e)}")
        print("\nTroubleshooting:")
        print("  1. Ensure PostgreSQL is running")
        print("  2. Check DATABASE_URL in .env")
        print("  3. Run: python init_db.py")
        sys.exit(1)

if __name__ == '__main__':
    main()
