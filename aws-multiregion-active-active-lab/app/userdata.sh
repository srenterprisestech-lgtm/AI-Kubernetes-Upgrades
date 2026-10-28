#!/bin/bash
set -euo pipefail

dnf install -y python3 python3-pip
python3 -m pip install --break-system-packages boto3

install -d -o root -g root -m 0755 /opt/active-active
cat > /opt/active-active/server.py <<'PYTHON_APP'
${app_source}
PYTHON_APP
cat > /opt/active-active/index.html <<'HTML_APP'
${index_source}
HTML_APP
chmod 0644 /opt/active-active/server.py /opt/active-active/index.html

cat > /etc/systemd/system/active-active.service <<'SERVICE'
[Unit]
Description=Active-active lab demo application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=nobody
Group=nobody
Environment="AWS_REGION=${region}"
Environment="TABLE_NAME=${table_name}"
ExecStart=/usr/bin/python3 /opt/active-active/server.py
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now active-active.service
