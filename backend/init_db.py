#!/usr/bin/env python
import os
import sys
from pathlib import Path

def init_database():
    from app import create_app, db
    from dataset_loader import DatasetLoader

    print("=" * 60)
    print("Sign Language Detection - Database Initialization")
    print("=" * 60)

    try:
        app = create_app(os.getenv('FLASK_ENV', 'development'))

        with app.app_context():
            print("\n[1/3] Creating database tables...")
            db.create_all()
            print("✓ Database tables created successfully")

            print("\n[2/3] Loading sign language dataset...")
            loader = DatasetLoader()
            count, message = loader.insert_signs_into_db()
            print(f"✓ {message} ({count} signs loaded)")

            print("\n[3/3] Verifying dataset...")
            stats = loader.get_dataset_statistics()
            print(f"✓ Total signs in database: {stats['total_signs']}")
            print(f"✓ Categories: {len(stats['categories'])}")
            for category, count in stats['categories'].items():
                print(f"  - {category}: {count} signs")
            print(f"✓ Difficulty levels: {len(stats['difficulty_distribution'])}")
            for difficulty, count in stats['difficulty_distribution'].items():
                print(f"  - {difficulty}: {count} signs")

            print("\n" + "=" * 60)
            print("Database initialization completed successfully!")
            print("=" * 60)
            print("\nYou can now start the application with:")
            print("  python app.py")
            print("\nAPI will be available at:")
            print("  http://localhost:5000")
            print("\nAPI Documentation:")
            print("  GET http://localhost:5000/api")
            print("=" * 60)

    except Exception as e:
        print(f"\n✗ Error during initialization: {str(e)}")
        print("\nTroubleshooting:")
        print("1. Ensure PostgreSQL is running")
        print("2. Check DATABASE_URL in .env file")
        print("3. Verify .env file is configured correctly")
        print("4. Run: cp .env.example .env (if .env doesn't exist)")
        sys.exit(1)

def create_admin_user():
    from app import create_app, db
    from models import User

    print("\n" + "=" * 60)
    print("Creating Admin User")
    print("=" * 60)

    app = create_app()

    with app.app_context():
        existing_admin = User.query.filter_by(username='admin').first()
        if existing_admin:
            print("✓ Admin user already exists")
            return

        admin = User(
            username='admin',
            email='admin@signdetection.com',
            first_name='Admin',
            last_name='User'
        )
        admin.set_password('Admin@123')

        try:
            db.session.add(admin)
            db.session.commit()
            print("✓ Admin user created successfully")
            print("\nAdmin Credentials:")
            print("  Username: admin")
            print("  Email: admin@signdetection.com")
            print("  Password: Admin@123")
            print("\nIMPORTANT: Change the password after first login!")
        except Exception as e:
            db.session.rollback()
            print(f"✗ Error creating admin user: {str(e)}")

if __name__ == '__main__':
    init_database()

    try:
        response = input("\nWould you like to create an admin user? (y/n): ").strip().lower()
        if response == 'y':
            create_admin_user()
    except KeyboardInterrupt:
        print("\n\nInitialization cancelled by user")
