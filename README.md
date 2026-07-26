# 🔐 SSH Security Toolkit

Ein einfaches, aber leistungsstarkes Toolkit zur Absicherung von **Ubuntu- und Debian-Servern**. Das Projekt unterstützt dich dabei, SSH-Schlüssel sicher zu erstellen und deinen SSH-Server mit bewährten Sicherheitsmaßnahmen zu härten.

---

## ✨ Funktionen

* 🔑 Sichere SSH-Schlüssel (ed25519 oder RSA) erstellen
* 👤 SSH-Schlüssel für beliebige Benutzer generieren
* 🔒 Passwort-Login deaktivieren
* 🚫 Root-Login absichern oder deaktivieren
* 🔐 Public-Key-Authentifizierung erzwingen
* 🌐 Optionalen SSH-Port konfigurieren
* 🛡️ X11-, TCP- und Agent-Forwarding deaktivieren
* 📁 Optional SFTP aktivieren

---

# 📖 ssh-key.sh

Erstellt einen sicheren SSH-Schlüssel für den aktuellen oder einen beliebigen Benutzer.

### Unterstützte Befehle

```bash
# Standard (ed25519)
sudo ./ssh-key.sh

# RSA-Schlüssel
sudo ./ssh-key.sh rsa

# ed25519-Schlüssel
sudo ./ssh-key.sh ed

# Für bestimmten Benutzer
sudo ./ssh-key.sh benutzername

# RSA für bestimmten Benutzer
sudo ./ssh-key.sh rsa benutzername

# ed25519 für bestimmten Benutzer
sudo ./ssh-key.sh ed benutzername
```

### Besonderheiten

* Der private Schlüssel wird im Home-Verzeichnis des Benutzers gespeichert.
* Wird der Schlüssel für einen anderen Benutzer erstellt, erzeugt das Skript zusätzlich eine Kopie im `/tmp`-Verzeichnis für den sicheren Export.
* Für den aktuell angemeldeten Benutzer wird keine zusätzliche Kopie erstellt.

---

# 🛡️ policy_script.sh

Mit diesem Skript wird der SSH-Server sicher konfiguriert.

### Konfigurierbare Einstellungen

```bash
# Basis-Härtung
DISABLE_PASSWORD_LOGIN="yes"
DISABLE_ROOT_SSH="no"
FORCE_PUBKEY_ONLY="yes"

# Netzwerk
SET_CUSTOM_SSH_PORT="no"
CUSTOM_SSH_PORT="222"

# Forwarding
DISABLE_X11_FORWARDING="yes"
DISABLE_TCP_FORWARDING="yes"
DISABLE_AGENT_FORWARDING="yes"

# Features
ALLOW_SFTP="yes"
```

Alle Einstellungen befinden sich am Anfang der Datei und können vor der Ausführung angepasst werden.

---

# 📦 Installation

## 1. Administrator-Benutzer erstellen

```bash
sudo adduser admin1
sudo adduser admin2
sudo adduser admin3
```

## 2. Benutzer zur sudo-Gruppe hinzufügen

```bash
sudo usermod -aG sudo admin1
```

## 3. Alle Benutzer anzeigen

```bash
cat /etc/passwd
```

## 4. Passwort setzen oder ändern

```bash
sudo passwd admin2
```

## 5. Benutzer löschen

```bash
sudo deluser admin2
```

## 6. Benutzer inklusive Home-Verzeichnis löschen

```bash
sudo deluser --remove-home admin3
```

## 7. Skripte herunterladen

Lade beide Skripte aus diesem GitHub-Repository herunter.

## 8. Skriptdateien erstellen

```bash
sudo nano ssh-key.sh
sudo nano policy_script.sh
```

## 9. Konfiguration anpassen

Passe die Einstellungen in **policy_script.sh** an deine Umgebung und Sicherheitsanforderungen an.

## 10. Skripte ausführbar machen

```bash
chmod +x ssh-key.sh
chmod +x policy_script.sh
```

---

# 🚀 Verwendung

## 1️⃣ SSH-Schlüssel erstellen

```bash
sudo ./ssh-key.sh
```

Dadurch wird ein sicherer SSH-Schlüssel für deinen Benutzer erstellt.

---

## 2️⃣ SSH-Hardening anwenden

```bash
sudo ./policy_script.sh
```

> [!WARNING]
> **Wichtig:** Stelle sicher, dass du dich bereits erfolgreich per SSH-Schlüssel anmelden kannst. Andernfalls kannst du dich durch das Deaktivieren der Passwort-Anmeldung von deinem Server aussperren.

---

# 📂 Projektstruktur

```text
.
├── ssh-key.sh
├── policy_script.sh
└── README.md
```

---

# 📺 Credits

**Erstellt von:** Michael Schrot

**YouTube**
https://www.youtube.com/@mschrot

**GitHub**
https://github.com/mschrot

---

# ⭐ Support

Gefällt dir das Projekt?

* ⭐ Gib dem Repository einen Star.
* 👍 Like die Videos auf YouTube.
* 📢 Teile das Projekt mit anderen.

---

# 📜 Lizenz

Dieses Projekt steht zur freien Nutzung bereit.

Anpassungen, Verbesserungen und Pull Requests sind jederzeit willkommen.

---

# 💡 Empfehlung

Für maximale Sicherheit solltest du die Skripte in dieser Reihenfolge verwenden:

1. SSH-Schlüssel erstellen.
2. SSH-Anmeldung mit dem Schlüssel testen.
3. SSH-Hardening ausführen.

So stellst du sicher, dass du dich nicht versehentlich von deinem Server aussperrst.
