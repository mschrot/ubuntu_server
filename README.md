```html
<h1 align="center">🔐 SSH Security Toolkit</h1>

<p align="center">
Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von Linux-Servern (Ubuntu/Debian)
mit Fokus auf SSH Hardening und sichere Schlüsselverwaltung.
</p>

<hr>

<h2>📖 Beschreibung</h2>

<pre>
# ==============================================================================
#
# Beschreibung:
#   Erstellt einen SSH-Key für einen bestimmten Benutzer und speichert
#   den privaten Schlüssel im HOME-Verzeichnis des Benutzers.
#   Wenn der Key für einen ANDEREN Benutzer erstellt wird, wird zusätzlich
#   eine Kopie im /tmp Verzeichnis für sicheren Export erstellt.
#   Für den eigenen Benutzer entfällt die Kopie im /tmp.
#
# Verwendung:
#   sudo ./ssh-key.sh                     # Standard: ed25519 für aktuellen Benutzer
#   sudo ./ssh-key.sh rsa                 # RSA für aktuellen Benutzer
#   sudo ./ssh-key.sh ed                  # ed25519 für aktuellen Benutzer
#   sudo ./ssh-key.sh benutzername        # ed25519 für bestimmten Benutzer
#   sudo ./ssh-key.sh rsa benutzername    # RSA für bestimmten Benutzer
#   sudo ./ssh-key.sh ed benutzername     # ed25519 für bestimmten Benutzer
#
# ==============================================================================
</pre>

<hr>

<h2>🔒 SSH Einstellungen (Systemweit)</h2>

<pre>
#----------------------- 🔒 SSH EINSTELLUNGEN (Systemweit) ----------------------------
# Diese Einstellungen gelten für ALLE Benutzer der Maschine!

# Basis-Härtung
DISABLE_PASSWORD_LOGIN="yes"      # 'yes' = Nur SSH-Keys erlaubt (Kein Passwort)
DISABLE_ROOT_SSH="no"             # 'yes' = Root-Login verbieten
FORCE_PUBKEY_ONLY="yes"           # 'yes' = Nur Public-Key Auth (erzwingen)

# Netzwerk
SET_CUSTOM_SSH_PORT="no"          # 'yes' = Anderen SSH-Port nutzen
CUSTOM_SSH_PORT="222"             # Z.B.: 222 (nur wenn oben 'yes')

# Forwarding (Sicherheit)
DISABLE_X11_FORWARDING="yes"      # 'yes' = X11 deaktivieren (meist nicht gebraucht)
DISABLE_TCP_FORWARDING="yes"      # 'yes' = Port-Weiterleitung verbieten
DISABLE_AGENT_FORWARDING="yes"    # 'yes' = Agent-Forwarding verbieten

# Features
ALLOW_SFTP="yes"                  # 'yes' = SFTP erlauben (internal-sftp)

# =========================
# ENDE PARAMETER
# =========================
</pre>

<hr>

<h2>📦 Installation &amp; Nutzung</h2>

<ol>
<li>
<b>Erstelle mehrere sudo-Benutzer (wenn nur Root vorhanden ist)</b>

<pre>sudo adduser admin1
sudo adduser admin2
sudo adduser admin3</pre>
</li>

<li>
<b>Benutzer zur sudo-Gruppe hinzufügen (System-Administrator)</b>

<pre>sudo usermod -aG sudo admin1</pre>
</li>

<li>
<b>Alle Benutzer anzeigen</b>

<pre>cat /etc/passwd</pre>
</li>

<li>
<b>Passwort neu setzen oder ändern</b>

<pre>sudo passwd admin2</pre>
</li>

<li>
<b>Benutzer löschen</b>

<pre>sudo deluser admin2</pre>
</li>

<li>
<b>Benutzer inklusive Home-Verzeichnis löschen</b>

<pre>sudo deluser --remove-home admin3</pre>
</li>

<li>
Kopiere die Skripte direkt von GitHub.
</li>

<li>
<b>Neue Skriptdateien erstellen</b>

<pre>sudo nano ssh-key.sh
sudo nano policy_script.sh</pre>
</li>

<li>
Konfiguriere <b>policy_script.sh</b> nach deinen Anforderungen.
</li>

<li>
<b>Skripte ausführbar machen</b>

<pre>chmod +x ssh-key.sh
chmod +x policy_script.sh</pre>
</li>
</ol>

<hr>

<h2>🔑 SSH-Key erstellen (Empfohlen zuerst)</h2>

<pre>sudo ./ssh-key.sh</pre>

<p>👉 Erstellt einen sicheren SSH-Key für deinen Benutzer.</p>

<hr>

<h2>🛡️ SSH Hardening anwenden</h2>

<pre>sudo ./policy_script.sh</pre>

<h3>⚠️ WICHTIG</h3>

<ul>
<li>Stelle sicher, dass du dich bereits per SSH-Key verbinden kannst.</li>
<li>Andernfalls kannst du dich von deinem Server aussperren.</li>
</ul>

<hr>

<h2>📺 Credits</h2>

<p>
Erstellt von <b>Michael Schrot</b>
</p>

<p>
<b>YouTube</b><br>
https://www.youtube.com/@mschrot
</p>

<p>
<b>GitHub</b><br>
https://github.com/mschrot
</p>

<hr>

<h2>⭐ Support</h2>

<p>Wenn dir das Projekt hilft:</p>

<ul>
<li>⭐ Repository mit einem Star unterstützen</li>
<li>👍 Video liken</li>
<li>📢 Projekt teilen</li>
</ul>

<hr>

<h2>📜 Lizenz</h2>

<p>
Dieses Projekt steht zur freien Nutzung bereit.
Anpassungen und Verbesserungen sind jederzeit willkommen.
</p>

<hr>

<h2>💡 Tipp</h2>

<p>
Kombiniere beide Skripte für maximale Sicherheit:
</p>

<ol>
<li>SSH-Key erstellen</li>
<li>SSH-Verbindung testen</li>
<li>SSH-Hardening anwenden</li>
</ol>
```
