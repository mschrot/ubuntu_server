````md
# 🔐 SSH Security Toolkit

Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von Linux-Servern (Ubuntu/Debian) mit Fokus auf SSH-Hardening und sichere Schlüsselverwaltung.

---

## 📖 Beschreibung

Dieses Projekt besteht aus zwei Skripten:

- **ssh-key.sh** – erstellt sichere SSH-Schlüssel für Benutzer.
- **policy_script.sh** – härtet den SSH-Server und verbessert die Sicherheit.

### Funktionen

- 🔑 SSH-Schlüssel (ed25519 oder RSA) erstellen
- 👤 SSH-Schlüssel für beliebige Benutzer erzeugen
- 🔒 Passwort-Login deaktivieren
- 🚫 Root-Login sperren
- 🔐 Public-Key-Authentifizierung erzwingen
- 🌐 Optionalen SSH-Port konfigurieren
- ❌ X11-, TCP- und Agent-Forwarding deaktivieren
- 📁 Optional SFTP aktivieren

---

## ⚙️ Konfiguration

Die wichtigsten Einstellungen befinden sich am Anfang der Datei `policy_script.sh`.

```bash
#----------------------- 🔒 SSH EINSTELLUNGEN (Systemweit) ----------------------------

# Basis-Härtung
DISABLE_PASSWORD_LOGIN="yes"      # Nur SSH-Keys erlauben
DISABLE_ROOT_SSH="no"             # Root-Login verbieten
FORCE_PUBKEY_ONLY="yes"           # Nur Public-Key Authentifizierung

# Netzwerk
SET_CUSTOM_SSH_PORT="no"          # Eigenen SSH-Port verwenden
CUSTOM_SSH_PORT="222"

# Forwarding
DISABLE_X11_FORWARDING="yes"
DISABLE_TCP_FORWARDING="yes"
DISABLE_AGENT_FORWARDING="yes"

# Features
ALLOW_SFTP="yes"
```

---

## 🚀 Installation

### 1. Mehrere Administrator-Benutzer erstellen

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

### 4. Passwort setzen oder ändern

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

### 7. Skripte herunterladen

Kopiere den Inhalt der Skripte direkt von GitHub.

### 8. Neue Skriptdateien erstellen

```bash
sudo nano ssh-key.sh
sudo nano policy_script.sh
```

### 9. Skripte anpassen

Passe insbesondere die Konfigurationsparameter in `policy_script.sh` an deine Anforderungen an.

### 10. Skripte ausführbar machen

```bash
chmod +x ssh-key.sh
chmod +x policy_script.sh
```

---

# 🔑 SSH-Key erstellen (Empfohlen zuerst)

```bash
sudo ./ssh-key.sh
```

Dadurch wird ein sicherer SSH-Schlüssel für deinen Benutzer erstellt.

---

# 🛡️ SSH Hardening anwenden

```bash
sudo ./policy_script.sh
```

## ⚠️ Wichtiger Hinweis

Stelle sicher, dass du dich **bereits erfolgreich mit deinem SSH-Schlüssel anmelden kannst**, bevor du das Hardening aktivierst.

Andernfalls kannst du dich von deinem Server aussperren.

---

## 📺 Credits

Erstellt von **Michael Schrot**

**YouTube**

https://www.youtube.com/@mschrot

**GitHub**

https://github.com/mschrot

---

## ⭐ Support

Wenn dir dieses Projekt gefällt oder geholfen hat:

- ⭐ Repository mit einem Star unterstützen
- 👍 Video liken
- 📢 Projekt teilen

---

## 📜 Lizenz

Dieses Projekt steht frei zur Verfügung.

Verbesserungen, Erweiterungen und Pull Requests sind jederzeit willkommen.

---

## 💡 Tipp

Für maximale Sicherheit empfiehlt sich folgende Reihenfolge:

1. SSH-Schlüssel erstellen
2. Verbindung per SSH-Schlüssel testen
3. SSH-Hardening anwenden

So vermeidest du, dich versehentlich von deinem Server auszusperren.
````
