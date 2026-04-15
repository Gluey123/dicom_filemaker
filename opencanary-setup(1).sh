#!/bin/bash
# OpenCanary Setup Script — CPTC Tryout Out-of-Scope Monitoring
# Usage: sudo bash opencanary-setup.sh <device-name>
# Example: sudo bash opencanary-setup.sh ICU-BED-01

DEVICE_NAME=${1:-"OOS-DEVICE"}
LOGFILE="/var/log/opencanary.log"

echo "[*] Updating system..."
apt update -y

echo "[*] Installing dependencies..."
apt install python3-pip python3-dev libssl-dev libffi-dev -y

echo "[*] Installing OpenCanary..."
pip3 install opencanary --break-system-packages

echo "[*] Creating config directory..."
mkdir -p /etc/opencanaryd

echo "[*] Writing OpenCanary config..."
cat > /etc/opencanaryd/opencanary.conf << EOF
{
    "device.node_id": "${DEVICE_NAME}",
    "logger": {
        "class": "PyLogger",
        "kwargs": {
            "formatters": {
                "plain": {
                    "format": "%(message)s"
                }
            },
            "handlers": {
                "file": {
                    "class": "logging.FileHandler",
                    "filename": "${LOGFILE}"
                }
            }
        }
    },
    "portscan.enabled": true,
    "portscan.logfile": "${LOGFILE}",
    "portscan.synrate": 5,
    "portscan.nmaposrate": 5,
    "portscan.lorate": 3,
    "ftp.enabled": false,
    "http.enabled": false,
    "ssh.enabled": false,
    "telnet.enabled": false,
    "smb.enabled": false
}
EOF

echo "[*] Creating systemd service..."
cat > /etc/systemd/system/opencanary.service << EOF
[Unit]
Description=OpenCanary Honeypot Monitor
After=network.target

[Service]
ExecStart=/usr/local/bin/opencanaryd --dev
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Enabling and starting OpenCanary..."
systemctl daemon-reload
systemctl enable opencanary
systemctl start opencanary

echo ""
echo "[+] Done! OpenCanary is running on ${DEVICE_NAME}"
echo "[+] Logs will be saved to: ${LOGFILE}"
echo ""
echo "To check logs after the event run:"
echo "  cat ${LOGFILE} | python3 -m json.tool"
echo ""
echo "To see only scan attempts:"
echo "  grep 'portscan' ${LOGFILE}"
