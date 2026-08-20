from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, User, CallRequest
from datetime import datetime
import logging

user_bp = Blueprint('user', __name__, url_prefix='/api/user')

@user_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    print(f"\n{'='*60}")
    print(f"📋 GET PROFILE: {user_id}")
    print(f"{'='*60}\n")

    try:
        user = User.query.get(user_id)

        if not user:
            print(f"❌ User not found: {user_id}")
            return jsonify({'error': 'User not found'}), 404

        print(f"✓ Retrieved profile for: {user.first_name} {user.last_name}")
        print(f"{'='*60}\n")

        return jsonify({
            'user': user.to_dict()
        }), 200
    except Exception as e:
        print(f"❌ Error retrieving profile: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': f'Failed to retrieve profile: {str(e)}'}), 500


@user_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    data = request.get_json()

    print(f"\n{'='*60}")
    print(f"✏️ UPDATE PROFILE: {user_id}")
    print(f"Data: {data}")
    print(f"{'='*60}\n")

    try:
        user = User.query.get(user_id)

        if not user:
            print(f"❌ User not found: {user_id}")
            return jsonify({'error': 'User not found'}), 404

        # Update allowed fields
        allowed_fields = ['first_name', 'last_name', 'bio', 'phone_number', 'country', 'language_preference']

        for field in allowed_fields:
            if field in data:
                setattr(user, field, data[field])
                print(f"✓ Updated {field}: {data[field]}")

        user.updated_at = datetime.utcnow()
        db.session.commit()

        print(f"✅ Profile updated successfully")
        print(f"{'='*60}\n")

        return jsonify({
            'message': 'Profile updated successfully',
            'user': user.to_dict()
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error updating profile: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': f'Failed to update profile: {str(e)}'}), 500


@user_bp.route('/status', methods=['PUT'])
@jwt_required()
def update_status():
    user_id = get_jwt_identity()
    data = request.get_json()
    is_online = data.get('is_online', False)

    print(f"\n{'='*60}")
    print(f"🔌 UPDATE STATUS: {user_id} -> {'Online' if is_online else 'Offline'}")
    print(f"{'='*60}\n")

    try:
        user = User.query.get(user_id)

        if not user:
            return jsonify({'error': 'User not found'}), 404

        user.is_online = is_online
        if not is_online:
            user.last_seen = datetime.utcnow()
        user.updated_at = datetime.utcnow()

        db.session.commit()

        print(f"✓ Status updated: {'Online' if is_online else 'Offline'}")
        print(f"{'='*60}\n")

        return jsonify({
            'message': 'Status updated',
            'is_online': user.is_online
        }), 200
    except Exception as e:
        db.session.rollback()
        print(f"❌ Error updating status: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': f'Failed to update status: {str(e)}'}), 500


@user_bp.route('/search', methods=['GET'])
@jwt_required()
def search_users():
    user_id = get_jwt_identity()
    query = request.args.get('q', '')
    limit = request.args.get('limit', 10, type=int)

    print(f"\n{'='*60}")
    print(f"🔍 SEARCH USERS: '{query}' (limit: {limit})")
    print(f"{'='*60}\n")

    try:
        if len(query) < 2:
            return jsonify({'users': []}), 200

        # Search by username, first_name, last_name, or email
        users = User.query.filter(
            (User.id != user_id) &
            (User.is_active == True) &
            (
                (User.username.ilike(f'%{query}%')) |
                (User.first_name.ilike(f'%{query}%')) |
                (User.last_name.ilike(f'%{query}%')) |
                (User.email.ilike(f'%{query}%'))
            )
        ).limit(limit).all()

        results = [user.to_dict() for user in users]
        print(f"✓ Found {len(results)} users")
        print(f"{'='*60}\n")

        return jsonify({'users': results}), 200
    except Exception as e:
        print(f"❌ Error searching users: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': f'Search failed: {str(e)}'}), 500


@user_bp.route('/online-users', methods=['GET'])
@jwt_required()
def get_online_users():
    user_id = get_jwt_identity()

    print(f"\n{'='*60}")
    print(f"👥 GET ONLINE USERS")
    print(f"{'='*60}\n")

    try:
        users = User.query.filter(
            (User.id != user_id) &
            (User.is_online == True) &
            (User.is_active == True)
        ).all()

        results = [user.to_dict() for user in users]
        print(f"✓ Found {len(results)} online users")
        print(f"{'='*60}\n")

        return jsonify({'users': results}), 200
    except Exception as e:
        print(f"❌ Error getting online users: {str(e)}")
        print(f"{'='*60}\n")
        return jsonify({'error': f'Failed to get online users: {str(e)}'}), 500
