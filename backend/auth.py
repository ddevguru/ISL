from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from models import db, User
from datetime import datetime
import re
import logging

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

def validate_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password):
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    if not re.search(r'[A-Z]', password):
        return False, "Password must contain an uppercase letter"
    if not re.search(r'[0-9]', password):
        return False, "Password must contain a number"
    return True, "Password is valid"

@auth_bp.route('/signup', methods=['POST'])
def signup():
    print("\n" + "="*60)
    print("🔐 SIGNUP REQUEST RECEIVED")
    print("="*60)
    try:
        data = request.get_json()
        print(f"✓ Received JSON data: {data}")

        if not data:
            print("❌ No data provided")
            return jsonify({'error': 'No data provided'}), 400

        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        first_name = data.get('first_name', '')
        last_name = data.get('last_name', '')

        print(f"✓ Username: {username}")
        print(f"✓ Email: {email}")
        print(f"✓ First Name: {first_name}")

        if not all([username, email, password]):
            print("❌ Missing required fields")
            return jsonify({'error': 'Username, email, and password are required'}), 400

        if not validate_email(email):
            print("❌ Invalid email format")
            return jsonify({'error': 'Invalid email format'}), 400

        is_valid, message = validate_password(password)
        if not is_valid:
            print(f"❌ Password validation failed: {message}")
            return jsonify({'error': message}), 400

        existing_user = User.query.filter_by(username=username).first()
        if existing_user:
            print("❌ Username already exists")
            return jsonify({'error': 'Username already exists'}), 409

        existing_email = User.query.filter_by(email=email).first()
        if existing_email:
            print("❌ Email already exists")
            return jsonify({'error': 'Email already exists'}), 409

        print("✓ Validation passed, creating user...")
        user = User(
            username=username,
            email=email,
            first_name=first_name,
            last_name=last_name
        )
        user.set_password(password)

        db.session.add(user)
        db.session.commit()
        print(f"✓ User created with ID: {user.id}")

        access_token = create_access_token(identity=user.id)
        print(f"✓ Access token created")

        print("✅ SIGNUP SUCCESSFUL")
        print("="*60 + "\n")

        return jsonify({
            'message': 'User created successfully',
            'user': user.to_dict(),
            'access_token': access_token
        }), 201

    except Exception as e:
        print(f"❌ SIGNUP FAILED: {str(e)}")
        import traceback
        traceback.print_exc()
        print("="*60 + "\n")
        db.session.rollback()
        return jsonify({'error': f'Signup failed: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    print("\n" + "="*60)
    print("🔓 LOGIN REQUEST RECEIVED")
    print("="*60)
    try:
        data = request.get_json()
        print(f"✓ Received login data")

        if not data:
            print("❌ No data provided")
            return jsonify({'error': 'No data provided'}), 400

        username_or_email = data.get('username_or_email')
        password = data.get('password')

        print(f"✓ Username/Email: {username_or_email}")

        if not all([username_or_email, password]):
            print("❌ Missing username/email or password")
            return jsonify({'error': 'Username/Email and password are required'}), 400

        user = User.query.filter(
            (User.username == username_or_email) | (User.email == username_or_email)
        ).first()

        if not user or not user.check_password(password):
            print("❌ Invalid credentials")
            return jsonify({'error': 'Invalid username/email or password'}), 401

        if not user.is_active:
            print("❌ Account is inactive")
            return jsonify({'error': 'Account is inactive'}), 403

        # Update user status to online
        user.is_online = True
        user.updated_at = datetime.utcnow()
        db.session.commit()
        print(f"✓ User status updated to online")

        access_token = create_access_token(identity=user.id)
        print(f"✓ Access token created")

        print("✅ LOGIN SUCCESSFUL")
        print("="*60 + "\n")

        return jsonify({
            'message': 'Login successful',
            'user': user.to_dict(),
            'access_token': access_token
        }), 200

    except Exception as e:
        print(f"❌ LOGIN FAILED: {str(e)}")
        import traceback
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'Login failed: {str(e)}'}), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        if not user:
            return jsonify({'error': 'User not found'}), 404

        return jsonify({
            'user': user.to_dict()
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch profile: {str(e)}'}), 500

@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        if not user:
            return jsonify({'error': 'User not found'}), 404

        data = request.get_json()

        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'email' in data:
            new_email = data['email']
            if new_email != user.email and User.query.filter_by(email=new_email).first():
                return jsonify({'error': 'Email already in use'}), 409
            user.email = new_email
        if 'profile_picture' in data:
            user.profile_picture = data['profile_picture']

        user.updated_at = datetime.utcnow()
        db.session.commit()

        return jsonify({
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to update profile: {str(e)}'}), 500

@auth_bp.route('/change-password', methods=['POST'])
@jwt_required()
def change_password():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)

        if not user:
            return jsonify({'error': 'User not found'}), 404

        data = request.get_json()
        old_password = data.get('old_password')
        new_password = data.get('new_password')

        if not all([old_password, new_password]):
            return jsonify({'error': 'Old and new password are required'}), 400

        if not user.check_password(old_password):
            return jsonify({'error': 'Old password is incorrect'}), 401

        is_valid, message = validate_password(new_password)
        if not is_valid:
            return jsonify({'error': message}), 400

        user.set_password(new_password)
        db.session.commit()

        return jsonify({
            'message': 'Password changed successfully'
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to change password: {str(e)}'}), 500

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    return jsonify({
        'message': 'Logout successful'
    }), 200
