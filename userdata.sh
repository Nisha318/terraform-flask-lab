#!/bin/bash
# ============================================================
# userdata.sh - EC2 bootstrap script for GRC Flask Lab
# This runs automatically when the EC2 instance first boots
# ============================================================

# Update system packages
dnf update -y

# Install Python and pip
dnf install python3 python3-pip -y

# Create project directory
mkdir -p /home/ec2-user/flask-app
cd /home/ec2-user/flask-app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Flask
pip install flask

# Create the Flask application
cat > /home/ec2-user/flask-app/app.py << 'EOF'
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <html>
    <head><title>GRC Engineering Club</title></head>
    <body style="font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px;">
        <h1>GRC Engineering Club</h1>
        <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h2>Flask on EC2 Lab</h2>
            <p>If you can see this page, you have successfully:</p>
            <ul>
                <li>Provisioned an EC2 instance</li>
                <li>Configured security groups</li>
                <li>Installed Python and Flask</li>
                <li>Deployed a web application</li>
            </ul>
        </div>
    </body>
    </html>
    '''

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'grc-flask-lab'
    })

@app.route('/api/controls')
def controls():
    return jsonify({
        'framework': 'NIST 800-53',
        'controls': [
            {'id': 'AC-2', 'name': 'Account Management', 'status': 'Implemented'},
            {'id': 'SC-7', 'name': 'Boundary Protection', 'status': 'Implemented'},
            {'id': 'AU-2', 'name': 'Audit Events', 'status': 'Partial'}
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

# Set correct ownership
chown -R ec2-user:ec2-user /home/ec2-user/flask-app

# Create systemd service
cat > /etc/systemd/system/flask-app.service << 'EOF'
[Unit]
Description=GRC Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/flask-app
Environment="PATH=/home/ec2-user/flask-app/venv/bin"
ExecStart=/home/ec2-user/flask-app/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app