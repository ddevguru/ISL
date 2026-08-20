from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, CallRequest, User
from datetime import datetime

call_bp = Blueprint("calls", __name__, url_prefix="/api/calls")
pending_offers = {}

@call_bp.route("/initiate", methods=["POST"])
@jwt_required()
def initiate_call():
    caller_id = get_jwt_identity()
    data = request.get_json()
    receiver_id = data.get("receiver_id")
    
    if not receiver_id:
        return jsonify({"error": "Receiver ID required"}), 400
    
    receiver = User.query.get(receiver_id)
    if not receiver or not receiver.is_online:
        return jsonify({"error": "Receiver not found"}), 400
    
    call = CallRequest(caller_id=caller_id, receiver_id=receiver_id, status="pending", call_type="video")
    db.session.add(call)
    db.session.commit()
    
    return jsonify({"call_id": call.id, "status": "pending", "receiver": receiver.to_dict()}), 200

@call_bp.route("/answer", methods=["POST"])
@jwt_required()
def answer_call():
    receiver_id = get_jwt_identity()
    data = request.get_json()
    call_id = data.get("call_id")
    call = CallRequest.query.get(call_id)
    
    if not call or call.receiver_id != receiver_id or call.status != "pending":
        return jsonify({"error": "Invalid call"}), 400
    
    call.status = "active"
    call.started_at = datetime.utcnow()
    db.session.commit()
    
    return jsonify({"call_id": call.id, "status": "active"}), 200

@call_bp.route("/end", methods=["POST"])
@jwt_required()
def end_call():
    user_id = get_jwt_identity()
    data = request.get_json()
    call_id = data.get("call_id")
    call = CallRequest.query.get(call_id)
    
    if not call:
        return jsonify({"error": "Call not found"}), 404
    
    call.status = "ended"
    call.ended_at = datetime.utcnow()
    if call.started_at:
        call.duration = int((call.ended_at - call.started_at).total_seconds())
    db.session.commit()
    
    return jsonify({"status": "ended", "duration": call.duration}), 200

@call_bp.route("/pending", methods=["GET"])
@jwt_required()
def get_pending_calls():
    user_id = get_jwt_identity()
    calls = CallRequest.query.filter(CallRequest.receiver_id == user_id, CallRequest.status == "pending").all()
    return jsonify({"calls": [c.to_dict() for c in calls]}), 200

@call_bp.route("/history", methods=["GET"])
@jwt_required()
def get_call_history():
    user_id = get_jwt_identity()
    limit = request.args.get("limit", 20, type=int)
    calls = CallRequest.query.filter((CallRequest.caller_id == user_id) | (CallRequest.receiver_id == user_id)).order_by(CallRequest.created_at.desc()).limit(limit).all()
    return jsonify({"history": [c.to_dict() for c in calls]}), 200

@call_bp.route("/send-offer", methods=["POST"])
@jwt_required()
def send_offer():
    data = request.get_json()
    call_id = data.get("call_id")
    offer = data.get("offer")
    if not offer or not call_id:
        return jsonify({"error": "Missing data"}), 400
    pending_offers[call_id] = {"offer": offer}
    return jsonify({"status": "sent"}), 200
