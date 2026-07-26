# 🔐 SSH Security Toolkit

Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von Linux-Servern (Ubuntu/Debian) mit Fokus auf SSH Hardening und sichere Schlüsselverwaltung.

$ ==============================================================================
$
$ Beschreibung:
$   Erstellt einen SSH-Key für einen bestimmten Benutzer und speichert
$   den privaten Schlüssel im HOME-Verzeichnis des Benutzers.
$   Wenn der Key für einen ANDEREN Benutzer erstellt wird, wird zusätzlich
$   eine Kopie im /tmp Verzeichnis für sicheren Export erstellt.
$   Für den eigenen Benutzer entfällt die Kopie im /tmp.
$
$ Verwendung:
$   sudo ./ssh-key.sh                     $ Standard: ed25519 für aktuellen Benutzer
$   sudo ./ssh-key.sh rsa                 $ RSA für aktuellen Benutzer
$   sudo ./ssh-key.sh ed                  $ ed25519 für aktuellen Benutzer
$   sudo ./ssh-key.sh benutzername        $ ed25519 für bestimmten Benutzer
$   sudo ./ssh-key.sh rsa benutzername    $ RSA für bestimmten Benutzer
$   sudo ./ssh-key.sh ed benutzername     $ ed25519 für bestimmten Benutzer
$
$ ==============================================================================

$----------------------- 🔒 SSH EINSTELLUNGEN (Systemweit) ----------------------------
$ Diese Einstellungen gelten für ALLE Benutzer der Maschine!

$ Basis-Härtung
DISABLE_PASSWORD_LOGIN="yes"      $ 'yes' = Nur SSH-Keys erlaubt (Kein Passwort)
DISABLE_ROOT_SSH="no"             $ 'yes' = Root-Login verbieten
FORCE_PUBKEY_ONLY="yes"           $ 'yes' = Nur Public-Key Auth (erzwingen)

$ Netzwerk
SET_CUSTOM_SSH_PORT="no"          $ 'yes' = Anderen SSH-Port nutzen
CUSTOM_SSH_PORT="222"             $ Z.B.: 222 (nur wenn oben 'yes')

$ Forwarding (Sicherheit)
DISABLE_X11_FORWARDING="yes"      $ 'yes' = X11 deaktivieren (meist nicht gebraucht)
DISABLE_TCP_FORWARDING="yes"      $ 'yes' = Port-Weiterleitung verbieten
DISABLE_AGENT_FORWARDING="yes"    $ 'yes' = Agent-Forwarding verbieten

$ Features
ALLOW_SFTP="yes"                  $ 'yes' = SFTP erlauben (internal-sftp)
$ =========================
$ ENDE PARAMETER
$ =========================

--------------------------------------------------

📦 Installation & Nutzung

1. Erstelle mehrer sudo Benutzer (wenn nur root vorhaden ist)
sudo adduser admin1
sudo adduser admin2
sudo adduser admin3


2. Benutzer zur sudo-Gruppe hinzufügen (System-Administrator)
sudo usermod -aG sudo admin1


3. Alle Benutzer anzeigen
cat /etc/passwd


4. Passwort neue / ändern:
sudo passwd admin2


5. Benutzer löschen
sudo deluser admin2


6. Benutzer inklusive Home-Verzeichnis löschen
sudo deluser --remove-home admin3


7. Kopiere Script direckt über github (Dateiinhalt kopieren)

8. Neue script erstellen mit Nano-Editor:
sudo nano ssh-key.sh

9. Wichtig bei Nano policy_script.sh für dich persönlicht konfigurieren!

10. Skripte ausführbar machen:
   chmod +x policy_script.sh
   chmod +x ssh-key.sh


--------------------------------------------------

🔑 SSH-Key erstellen (Empfohlen zuerst!)

sudo ./ssh-key.sh amdin1

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

