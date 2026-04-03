# 🔐 SSH Security Toolkit

Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von Linux-Servern (Ubuntu/Debian) mit Fokus auf SSH Hardening und sichere Schlüsselverwaltung.

--------------------------------------------------

📦 Inhalt

Dieses Repository enthält zwei Skripte:

1. policy_script.sh
   → Härtet deine SSH-Konfiguration automatisch

   Features:
   - Deaktiviert Passwort-Login (nur SSH-Keys)
   - Verhindert Root-Login
   - Erzwingt Public-Key Authentifizierung
   - Setzt sichere Kryptographie (Ciphers, MACs, KEX)
   - Optional: Custom SSH-Port, Passwordless sudo (⚠️ Risiko!)
   - Automatische Validierung der SSH-Konfiguration
   - Backup bestehender Configs

2. ssh-key.sh
   → Erstellt sichere SSH-Schlüssel für Benutzer

   Features:
   - Unterstützt ed25519 (empfohlen) und rsa
   - Interaktive Passphrase-Erstellung
   - Automatische Einrichtung von .ssh Verzeichnis & authorized_keys
   - Optional: Benutzer automatisch erstellen
   - Erstellt SSH-Client-Konfiguration für einfachen Login

--------------------------------------------------

🚀 Installation & Nutzung

1. Repository klonen oder Dateien kopieren:
   git clone <your-repo-url>
   cd <repo>

2. Skripte ausführbar machen:
   chmod +x policy_script.sh
   chmod +x ssh-key.sh

--------------------------------------------------

🔑 SSH-Key erstellen (Empfohlen zuerst!)

sudo ./ssh-key.sh

👉 Erstellt einen sicheren SSH-Key für deinen Benutzer.

--------------------------------------------------

🛡️ SSH Hardening anwenden

sudo ./policy_script.sh

⚠️ WICHTIG:
- Stelle sicher, dass du dich bereits per SSH-Key verbinden kannst!
- Sonst sperrst du dich aus deinem Server aus.

--------------------------------------------------

📺 Credits

Erstellt von Michael Schrot

YouTube: https://www.youtube.com/@mschrot
GitHub: https://github.com/mschrot/

--------------------------------------------------

⭐ Support

Wenn dir das Projekt hilft:
- ⭐ Repo staren
- 👍 Video liken
- 📢 Teilen

--------------------------------------------------

📜 Lizenz

Dieses Projekt steht zur freien Nutzung bereit. Anpassungen und Verbesserungen sind willkommen.

--------------------------------------------------

💡 Tipp: Kombiniere beide Skripte für maximale Sicherheit – erst Keys erstellen, dann SSH härten!
