🚀 Ubuntu Mini Tutorial auf Ubuntu 22.04 / 24.04

Einfach diesen Text in eine .txt Datei kopieren und speichern ✅

--------------------------------------------------

📦 Features

- 👨 Benutzerverwaltung (erstellen, löschen, sudo)
- 🔑 Passwortänderung
- 📁 Datei- & Ordnerverwaltung
- 📂 Navigation im Terminal
- 🛡️ Sudo-Rechte prüfen
- ⚡ Einfache & schnelle Befehle

--------------------------------------------------

🧰 Voraussetzungen

- Ubuntu 22.04 oder 24.04
- Root oder sudo Zugriff
- Terminal-Grundkenntnisse
- Keine zusätzliche Software nötig

--------------------------------------------------

🔥 Wichtige Befehle

Benutzer erstellen:

sudo adduser BENUTZERNAME

Benutzer zu sudo hinzufügen:

sudo usermod -aG sudo BENUTZERNAME

Admin-Rechte prüfen:

sudo whoami

Alle Sudo-Benutzer zeigen:

getent group sudo

--------------------------------------------------

🔑 Passwort ändern

Eigenes Passwort:

passwd

Passwort für anderen Benutzer:

sudo passwd BENUTZERNAME

--------------------------------------------------

❌ Benutzer löschen

Nur Benutzer:

sudo deluser BENUTZERNAME

Mit Home-Ordner:

sudo deluser --remove-home BENUTZERNAME

--------------------------------------------------

📁 Ordner erstellen

Einzelner Ordner:

mkdir ORDNERNAME

Mehrere Ordner:

mkdir ordner1 ordner2

--------------------------------------------------

📄 Datei erstellen

Leere Datei:

touch datei.txt

Text in Datei schreiben:

echo "Hallo Welt" > datei.txt

--------------------------------------------------

❌ Löschen

Leeren Ordner löschen:

rmdir ordnername

Ordner mit Inhalt löschen (⚠️ vorsichtig!):

rm -r ordnername

Datei löschen:

rm datei.txt

--------------------------------------------------

📂 Navigation

Aktuelles Verzeichnis anzeigen:

pwd

Ordner wechseln:

cd ORDNERNAME

Einen Ordner zurück:

cd ..

Dateien anzeigen:

ls

Mit Details:

ls -l

Mit versteckten Dateien:

ls -la

--------------------------------------------------

🧪 Beispiel Workflow

1. Benutzer anlegen:

sudo adduser max

2. Sudo-Rechte geben:

sudo usermod -aG sudo max

3. Prüfen:

getent group sudo

4. Zu max wechseln:

su - max

--------------------------------------------------

🛠️ Häufige Befehle (Übersicht)

sudo whoami           # Prüft Admin-Rechte

pwd                   # Zeigt aktuellen Pfad

ls -la                # Zeigt alle Dateien an

cd ..                 # Ein Ordner zurück

clear                 # Bildschirm leeren

--------------------------------------------------

⚠️ Wichtige Hinweise

- BENUTZERNAME durch eigenen Namen ersetzen
- Bei sudo Befehlen Passwort eingeben
- rm -r löscht endgültig (kein Papierkorb)
- Keine Leerzeichen in Ordnernamen verwenden

--------------------------------------------------

🔒 Sicherheit

- Starke Passwörter verwenden
- Nur notwendige Benutzer anlegen
- Alte Benutzer regelmäßig löschen
- Sudo-Rechte nur vertrauenswürdigen Nutzern geben

--------------------------------------------------

🔗 Links

Ubuntu Docs:
https://help.ubuntu.com

Linux Terminal Guide:
https://ubuntu.com/tutorials/command-line-for-beginners

YouTube Tutorials:
https://www.youtube.com/@mschrot

--------------------------------------------------

📌 Credits

Erstellt von Michael Schrot

--------------------------------------------------

❤️ Support

⭐ Repo liken & teilen
