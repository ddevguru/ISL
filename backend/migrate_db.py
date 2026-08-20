#!/usr/bin/env python3
"""
Database migration script to add missing columns to existing tables
Run this once to update the database schema
"""
import os
from app import create_app, db
from sqlalchemy import text

app = create_app(os.getenv('FLASK_ENV', 'production'))

def migrate_users_table():
    """Add missing columns to users table"""
    with app.app_context():
        try:
            # List of columns to add with their definitions
            columns_to_add = [
                ('profile_picture', 'VARCHAR(255)'),
                ('bio', 'TEXT'),
                ('phone_number', 'VARCHAR(20)'),
                ('country', 'VARCHAR(100)'),
                ('language_preference', "VARCHAR(10) DEFAULT 'en'"),
                ('is_online', 'BOOLEAN DEFAULT FALSE'),
                ('last_seen', 'TIMESTAMP'),
                ('created_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'),
                ('updated_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'),
                ('is_active', 'BOOLEAN DEFAULT TRUE'),
            ]

            for col_name, col_type in columns_to_add:
                try:
                    # Try to add the column if it doesn't exist
                    query = f"""
                    ALTER TABLE users
                    ADD COLUMN IF NOT EXISTS {col_name} {col_type}
                    """
                    db.session.execute(text(query))
                    db.session.commit()
                    print(f"✓ Added column: {col_name}")
                except Exception as e:
                    print(f"⚠ Column {col_name} might already exist: {e}")
                    db.session.rollback()

            print("\n✅ Database migration complete!")

        except Exception as e:
            print(f"❌ Migration failed: {e}")
            db.session.rollback()

if __name__ == '__main__':
    print("🔄 Starting database migration...")
    migrate_users_table()
