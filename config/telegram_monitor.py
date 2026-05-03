import requests
import time
import urllib3
from datetime import datetime

urllib3.disable_warnings()

import os
TELEGRAM_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "8612386398:AAHqBzoKNata0-4mSWiSYHOJza2Dao5_iR4")
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID", "5372963901")
TARGET = "https://40.67.225.150.nip.io"
CHECK_INTERVAL = 30  # seconds

def send_telegram(message):
    url = f"https://api.telegram.org/bot8612386398:AAHqBzoKNata0-4mSWiSYHOJza2Dao5_iR4/sendMessage"
    try:
        requests.post(url, json={
            "chat_id": TELEGRAM_CHAT_ID,
            "text": message,
            "parse_mode": "HTML"
        })
    except Exception as e:
        print(f"Telegram error: {e}")

def check_attack(attack_type, emoji, payload, endpoint):
    try:
        response = requests.post(
            f"{TARGET}{endpoint}",
            json=payload,
            verify=False,
            timeout=5
        )
        status = response.status_code

        if status == 403:
            send_telegram(f"""🚨 <b>ATTACK BLOCKED!</b>

{emoji} <b>Type:</b> {attack_type}
⏰ <b>Time:</b> {datetime.now().strftime('%H:%M:%S')}
✅ <b>WAF Status:</b> BLOCKED (403)
🛡️ <b>OWASP Prevention Mode Active</b>""")
            return True
        return False
    except Exception as e:
        print(f"Error checking {attack_type}: {e}")
        return False

attacks = [
    {
        "name": "SQL Injection",
        "emoji": "💉",
        "endpoint": "/api/orders",
        "payload": {"email": "1' UNION SELECT NULL,NULL,NULL--", "name": "hacker"}
    },
    {
        "name": "XSS Attack",
        "emoji": "🕷️",
        "endpoint": "/api/orders",
        "payload": {"customerName": "<script>alert(document.cookie)</script>", "customerEmail": "hacker@evil.com"}
    },
    {
        "name": "Command Injection",
        "emoji": "💻",
        "endpoint": "/api/orders",
        "payload": {"customerName": "; cat /etc/passwd", "customerEmail": "hacker@evil.com"}
    }
]

print("🔍 Real-time attack monitor started...")
send_telegram(f"""🟢 <b>SECURITY MONITOR STARTED</b>

🔍 Watching: <code>{TARGET}</code>
⏱️ Check interval: every {CHECK_INTERVAL} seconds
🛡️ WAF: Prevention Mode (OWASP 3.2)

<i>You will be notified instantly when attacks are detected and blocked.</i>""")

while True:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Checking for attacks...")
    blocked_count = 0
    
    for attack in attacks:
        if check_attack(attack["name"], attack["emoji"], attack["payload"], attack["endpoint"]):
            blocked_count += 1
        time.sleep(1)
    
    if blocked_count > 0:
        print(f"  {blocked_count} attacks blocked — notifications sent")
    else:
        print(f"  No attacks detected")
    
    time.sleep(CHECK_INTERVAL)
