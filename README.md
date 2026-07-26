````md
# 🔐 SSH Security Toolkit

Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von Linux-Servern (Ubuntu/Debian) mit Fokus auf SSH Hardening und sichere Schlüsselverwaltung.

---

## 📖 Beschreibung

```text
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
```

---

## 🔒 SSH-Einstellungen (Systemweit)

```bash
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
```

---

# 📦 Installation & Nutzung

### 1. Mehrere sudo-Benutzer erstellen (wenn nur Root vorhanden ist)

```bash
sudo adduser admin1
sudo adduser admin2
sudo adduser admin3
```

### 2. Benutzer zur sudo-Gruppe hinzufügen

```bash
sudo usermod -aG sudo admin1
```

### 3. Alle Benutzer anzeigen

```bash
cat /etc/passwd
```

### 4. Passwort neu setzen oder ändern

```bash
sudo passwd admin2
```

### 5. Benutzer löschen

```bash
sudo deluser admin2
```

### 6. Benutzer inklusive Home-Verzeichnis löschen

```bash
sudo deluser --remove-home admin3
```

### 7. Skripte von GitHub herunterladen

Kopiere den Inhalt der Skripte direkt aus diesem Repository.

### 8. Neue Skriptdateien erstellen

```bash
sudo nano ssh-key.sh
sudo nano policy_script.sh
```

### 9. Skripte konfigurieren

Passe insbesondere die Einstellungen in **policy_script.sh** an deine Umgebung an.

### 10. Skripte ausführbar machen

```bash
chmod +x ssh-key.sh
chmod +x policy_script.sh
```

---

# 🔑 SSH-Key erstellen (Empfohlen zuerst!)

```bash
sudo ./ssh-key.sh
```

👉 Erstellt einen sicheren SSH-Key für deinen Benutzer.

---

# 🛡️ SSH Hardening anwenden

```bash
sudo ./policy_script.sh
```

## ⚠️ WICHTIG

- Stelle sicher, dass du dich bereits per SSH-Key verbinden kannst.
- Andernfalls kannst du dich von deinem Server aussperren.

---

# 📺 Credits

Erstellt von **Michael Schrot**

**YouTube**

https://www.youtube.com/@mschrot

**GitHub**

https://github.com/mschrot/

---

# ⭐ Support

Wenn dir das Projekt hilft:

- ⭐ Repository mit einem Star unterstützen
- 👍 Video liken
- 📢 Projekt teilen

---

# 📜 Lizenz

Dieses Projekt steht zur freien Nutzung bereit.

Anpassungen und Verbesserungen sind jederzeit willkommen.

---

# 💡 Tipp

Kombiniere beide Skripte für maximale Sicherheit:

1. SSH-Key erstellen
2. SSH-Verbindung testen
3. SSH-Hardening anwenden
````
