web: cd backend && gunicorn wsgi:app --timeout 120 --workers 4 --worker-class sync --access-logfile - --error-logfile -
release: cd backend && python init_db.py
