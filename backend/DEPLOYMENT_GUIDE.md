# Deployment Guide

## Pre-Deployment Checklist

### Security
- [ ] Change `SECRET_KEY` in `.env`
- [ ] Change `JWT_SECRET_KEY` in `.env`
- [ ] Set `FLASK_ENV=production`
- [ ] Configure strong PostgreSQL password
- [ ] Enable HTTPS/SSL certificate
- [ ] Set up firewall rules
- [ ] Configure CORS for specific origins

### Database
- [ ] PostgreSQL installed and running
- [ ] Database created and accessible
- [ ] Database user has proper permissions
- [ ] Backups configured
- [ ] Monitoring set up

### Application
- [ ] All dependencies in `requirements.txt`
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Dataset loaded into database
- [ ] ML models placed in `models/` directory
- [ ] Upload directories configured

### Infrastructure
- [ ] Server/VM provisioned
- [ ] Sufficient disk space (min 10GB)
- [ ] Sufficient RAM (min 2GB)
- [ ] Network connectivity verified
- [ ] DNS configured (if using domain)
- [ ] Load balancer configured (if needed)

## Deployment Methods

### Method 1: Docker Compose (Recommended for Production)

#### Prerequisites
- Docker 20.10+
- Docker Compose 1.29+

#### Steps

1. **Prepare Configuration**
```bash
cp .env.example .env
# Edit .env with production values
nano .env
```

2. **Build and Start Services**
```bash
docker-compose up -d
```

3. **Initialize Database**
```bash
docker-compose exec api python init_db.py
```

4. **Verify Services**
```bash
docker-compose ps
docker-compose logs -f api
```

5. **Test API**
```bash
curl http://localhost/health
curl http://localhost/api
```

#### Stopping Services
```bash
docker-compose down
```

#### Updating Application
```bash
git pull origin main
docker-compose build
docker-compose up -d
```

### Method 2: Manual Deployment with Gunicorn

#### Prerequisites
- Python 3.8+
- PostgreSQL 12+
- Redis (optional)
- Nginx or Apache

#### Steps

1. **Install Dependencies**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install gunicorn
```

2. **Configure Environment**
```bash
cp .env.example .env
# Edit with production values
source .env
```

3. **Initialize Database**
```bash
python init_db.py
```

4. **Start Gunicorn**
```bash
gunicorn -w 4 -b 127.0.0.1:5000 \
  --timeout 120 \
  --access-logfile /var/log/gunicorn_access.log \
  --error-logfile /var/log/gunicorn_error.log \
  'app:create_app()'
```

5. **Configure Nginx Reverse Proxy**

Create `/etc/nginx/sites-available/sign-detection`:
```nginx
upstream sign_api {
    server 127.0.0.1:5000;
}

server {
    listen 80;
    server_name your_domain.com;
    client_max_body_size 500M;

    location / {
        proxy_pass http://sign_api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/sign-detection \
    /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

6. **Create Systemd Service**

Create `/etc/systemd/system/sign-detection-api.service`:
```ini
[Unit]
Description=Sign Detection API
After=network.target

[Service]
Type=notify
User=www-data
WorkingDirectory=/opt/sign-detection/backend
Environment="PATH=/opt/sign-detection/backend/venv/bin"
ExecStart=/opt/sign-detection/backend/venv/bin/gunicorn \
    -w 4 -b 127.0.0.1:5000 \
    'app:create_app()'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable sign-detection-api
sudo systemctl start sign-detection-api
sudo systemctl status sign-detection-api
```

### Method 3: AWS Elastic Beanstalk

#### Prerequisites
- AWS account
- AWS CLI installed
- EB CLI installed

#### Steps

1. **Create `.ebextensions/01_flask.config`**
```yaml
option_settings:
  aws:elasticbeanstalk:container:python:
    WSGIPath: app:create_app()
  aws:elasticbeanstalk:application:environment:
    FLASK_ENV: production
    
commands:
  01_migrate:
    command: "source /var/app/venv/*/bin/activate && python init_db.py"
    leader_only: true
```

2. **Deploy**
```bash
eb init -p python-3.10 sign-detection-api
eb create sign-detection-prod --envvars \
  FLASK_ENV=production,SECRET_KEY=xxx,JWT_SECRET_KEY=xxx
eb deploy
```

### Method 4: Google Cloud Run

#### Prerequisites
- Google Cloud account
- Google Cloud CLI

#### Steps

1. **Create `cloudbuild.yaml`**
```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/sign-detection', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/sign-detection']
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args: ['run', '--filename=k8s/', '--image=gcr.io/$PROJECT_ID/sign-detection', '--location=us-central1']

images:
  - 'gcr.io/$PROJECT_ID/sign-detection'
```

2. **Deploy**
```bash
gcloud builds submit --config cloudbuild.yaml
gcloud run deploy sign-detection \
  --image gcr.io/$PROJECT_ID/sign-detection \
  --platform managed \
  --region us-central1 \
  --set-env-vars FLASK_ENV=production
```

## SSL/TLS Configuration

### Using Let's Encrypt with Certbot

1. **Install Certbot**
```bash
sudo apt-get install certbot python3-certbot-nginx
```

2. **Generate Certificate**
```bash
sudo certbot certonly --nginx -d your_domain.com
```

3. **Update Nginx Config**
```nginx
server {
    listen 443 ssl http2;
    server_name your_domain.com;

    ssl_certificate /etc/letsencrypt/live/your_domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your_domain.com/privkey.pem;

    # ... rest of config
}

server {
    listen 80;
    server_name your_domain.com;
    return 301 https://$server_name$request_uri;
}
```

4. **Auto-Renewal**
```bash
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

## Database Backup Strategy

### Automated Backups

1. **Daily Backup Script** (`backup_db.sh`)
```bash
#!/bin/bash
BACKUP_DIR="/backups/postgres"
DB_NAME="sign_detection"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

pg_dump -U postgres $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Keep only last 30 days
find $BACKUP_DIR -type f -mtime +30 -delete
```

2. **Cron Job**
```bash
crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /opt/sign-detection/backup_db.sh
```

3. **Cloud Backup (S3)**
```bash
#!/bin/bash
aws s3 cp /backups/postgres/ s3://your-bucket/backups/ --recursive
```

## Monitoring and Logging

### Application Monitoring

1. **Sentry for Error Tracking**
```python
# In app.py
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FlaskIntegration()]
)
```

2. **Prometheus Metrics**
```bash
pip install prometheus-flask-exporter
```

### Log Aggregation

**ELK Stack Setup**
```bash
docker-compose -f docker-compose.elk.yml up -d
```

### Health Monitoring

Configure monitoring for:
- API response time
- Database connection health
- Disk space usage
- Memory usage
- CPU usage
- Video processing queue

## Performance Optimization

### Database Optimization

1. **Create Indexes**
```sql
CREATE INDEX idx_user_history_timestamp ON user_history(detection_timestamp);
CREATE INDEX idx_user_history_user_id ON user_history(user_id);
CREATE INDEX idx_sign_name ON signs(name);
CREATE INDEX idx_sign_category ON signs(category);
```

2. **Enable Connection Pooling**
```python
# In config.py
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_size": 10,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
}
```

### Application Performance

1. **Enable Caching**
```python
# Install redis
pip install flask-caching

# Configure in app.py
cache = Cache(app, config={'CACHE_TYPE': 'redis'})
```

2. **Optimize Video Processing**
- Compress videos before upload
- Use GPU acceleration if available
- Implement async processing with Celery

3. **Rate Limiting**
```python
pip install Flask-Limiter

from flask_limiter import Limiter
limiter = Limiter(app, default_limits=["200 per day", "50 per hour"])
```

## Rollback Procedure

### If Deployment Fails

1. **Check Status**
```bash
docker-compose logs api
# or
sudo systemctl status sign-detection-api
```

2. **Rollback Docker**
```bash
docker-compose down
git revert HEAD
docker-compose up -d
```

3. **Rollback Manual**
```bash
git revert HEAD
sudo systemctl restart sign-detection-api
```

## Post-Deployment Verification

1. **API Health Check**
```bash
curl https://your_domain.com/health
```

2. **Database Connection**
```bash
curl https://your_domain.com/api
```

3. **User Registration Test**
```bash
curl -X POST https://your_domain.com/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"TestPass123"}'
```

4. **Sign Detection Test**
```bash
curl -X GET https://your_domain.com/api/detection/signs
```

## Maintenance

### Regular Tasks

**Weekly**
- Check logs for errors
- Monitor disk space
- Review performance metrics

**Monthly**
- Update dependencies
- Run database cleanup
- Review security logs

**Quarterly**
- Backup verification
- Load testing
- Security audit

### Update Process

1. **Development Testing**
```bash
git checkout develop
python -m pytest
```

2. **Staging Deployment**
```bash
docker-compose -f docker-compose.staging.yml up -d
```

3. **Production Deployment**
```bash
docker-compose pull
docker-compose up -d
```

## Scaling Strategies

### Horizontal Scaling

1. **Load Balancer Setup**
   - Multiple API instances behind load balancer
   - Session management with Redis

2. **Database Replication**
   - Primary-replica PostgreSQL setup
   - Read replicas for analytics

### Vertical Scaling

- Increase server resources (CPU, RAM)
- Optimize code for better performance
- Use GPU acceleration for ML models

## Disaster Recovery

### RTO/RPO Targets
- Recovery Time Objective (RTO): 1 hour
- Recovery Point Objective (RPO): 15 minutes

### Recovery Procedures

1. **Database Restoration**
```bash
# From backup
gunzip < backup_20240115_020000.sql.gz | psql sign_detection
```

2. **Application Recovery**
```bash
# Restore from git
git clone <repo>
docker-compose up -d
```

## Security Hardening

1. **SSL/TLS Setup** ✓
2. **Firewall Configuration**
   - Allow only HTTP/HTTPS
   - Restrict database access
   - Rate limiting enabled

3. **Regular Security Updates**
```bash
sudo apt-get update && sudo apt-get upgrade
pip install --upgrade pip
pip install -U -r requirements.txt
```

4. **Secrets Management**
   - Use environment variables
   - Rotate secrets regularly
   - Use AWS Secrets Manager or HashiCorp Vault

## Support and Troubleshooting

For deployment issues:
1. Check application logs
2. Review SETUP.md
3. Consult API_TESTING.md for API verification
4. Check system resources (disk, memory)
5. Verify database connectivity

---

**Deployment completed successfully!**

Your Sign Language Detection API is now running and ready for use.
