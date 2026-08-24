import cv2
import numpy as np
from pathlib import Path
import tempfile
import os
from datetime import datetime

class VideoProcessor:
    def __init__(self):
        self.detector = None
        self.frame_buffer = []
        self.detections = []

    def _get_detector(self):
        """Lazy initialization of detector"""
        if self.detector is None:
            from sign_detector import ISLSignDetector
            self.detector = ISLSignDetector()
        return self.detector

    def process_video_file(self, video_path, output_path=None, min_confidence=0.5):
        try:
            detector = self._get_detector()
            cap = cv2.VideoCapture(video_path)

            if not cap.isOpened():
                return None, "Failed to open video"

            fps = cap.get(cv2.CAP_PROP_FPS)
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

            if output_path:
                fourcc = cv2.VideoWriter_fourcc(*'mp4v')
                out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
            else:
                out = None

            detections = []
            frame_number = 0

            while cap.isOpened():
                ret, frame = cap.read()

                if not ret:
                    break

                sign, confidence, face_res, annotated_frame = detector.process_video_frame(
                    frame, min_confidence
                )

                if sign and confidence >= min_confidence:
                    detections.append({
                        'frame': frame_number,
                        'timestamp': frame_number / fps,
                        'sign': sign,
                        'confidence': float(confidence),
                        'face_detected': face_res.get('face_detected', False),
                        'expression': face_res.get('expression', 'Unknown')
                    })

                if out:
                    if sign and confidence >= min_confidence:
                        cv2.putText(
                            annotated_frame,
                            f'{sign} ({confidence:.2f})',
                            (10, 30),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1,
                            (0, 255, 0),
                            2
                        )
                    out.write(annotated_frame)

                frame_number += 1

            cap.release()
            if out:
                out.release()

            return {
                'total_frames': frame_count,
                'fps': fps,
                'duration': frame_count / fps,
                'detections': detections,
                'output_path': output_path
            }, None

        except Exception as e:
            return None, str(e)

    def process_camera_frame(self, frame, min_confidence=0.5):
        try:
            detector = self._get_detector()
            sign, confidence, face_res, annotated_frame = detector.process_video_frame(
                frame, min_confidence
            )

            result = {
                'sign': sign,
                'confidence': float(confidence) if confidence else 0.0,
                'frame': annotated_frame,
                'timestamp': datetime.utcnow().isoformat(),
                'face_detected': face_res.get('face_detected', False),
                'face_bbox': face_res.get('face_bbox'),
                'expression': face_res.get('expression', 'Unknown'),
                'facial_patterns': face_res.get('facial_patterns', {})
            }

            if sign and confidence >= min_confidence:
                self.detections.append(result)

            return result

        except Exception as e:
            return {'error': str(e)}

    def get_real_time_stream_processor(self):
        def process_stream(video_source=0):
            cap = cv2.VideoCapture(video_source)

            if not cap.isOpened():
                yield {'error': 'Failed to open camera'}
                return

            while cap.isOpened():
                ret, frame = cap.read()

                if not ret:
                    break

                result = self.process_camera_frame(frame, min_confidence=0.5)

                if 'error' not in result:
                    _, buffer = cv2.imencode('.jpg', result['frame'])
                    frame_bytes = buffer.tobytes()

                    yield {
                        'frame': frame_bytes,
                        'sign': result['sign'],
                        'confidence': result['confidence'],
                        'timestamp': result['timestamp'],
                        'face_detected': result.get('face_detected', False),
                        'expression': result.get('expression', 'Unknown')
                    }

            cap.release()

        return process_stream

    def extract_frames_from_video(self, video_path, num_frames=5):
        try:
            cap = cv2.VideoCapture(video_path)

            if not cap.isOpened():
                return None, "Failed to open video"

            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            frame_indices = np.linspace(0, total_frames - 1, num_frames, dtype=int)

            frames = []

            for idx in frame_indices:
                cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
                ret, frame = cap.read()

                if ret:
                    frames.append(frame)

            cap.release()

            return frames, None

        except Exception as e:
            return None, str(e)

    def get_detections(self):
        return self.detections

    def clear_detections(self):
        self.detections = []

    def save_detection_frame(self, frame, detection_info, save_path):
        try:
            os.makedirs(save_path, exist_ok=True)

            timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S_%f')
            filename = f"detection_{detection_info['sign']}_{timestamp}.jpg"
            filepath = os.path.join(save_path, filename)

            cv2.imwrite(filepath, frame)

            return filepath, None

        except Exception as e:
            return None, str(e)

    def overlay_translation(self, frame, sign, confidence, translation):
        try:
            h, w, c = frame.shape

            cv2.rectangle(frame, (0, 0), (w, 100), (0, 0, 0), -1)

            cv2.putText(
                frame,
                f'Sign: {sign}',
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                1,
                (0, 255, 0),
                2
            )

            cv2.putText(
                frame,
                f'Confidence: {confidence:.2f}',
                (10, 60),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (0, 255, 255),
                2
            )

            cv2.putText(
                frame,
                f'Translation: {translation}',
                (10, 90),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (255, 0, 0),
                2
            )

            return frame

        except Exception as e:
            print(f"Error overlaying translation: {e}")
            return frame

    def resize_frame(self, frame, width=None, height=None):
        h, w = frame.shape[:2]

        if width and not height:
            ratio = width / w
            height = int(h * ratio)
        elif height and not width:
            ratio = height / h
            width = int(w * ratio)
        elif not width and not height:
            return frame

        resized = cv2.resize(frame, (width, height))
        return resized
