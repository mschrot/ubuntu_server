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

Benutzerverwaltung:
sudo adduser BENUTZERNAME
sudo usermod -aG sudo BENUTZERNAME
sudo deluser BENUTZERNAME
sudo deluser --remove-home BENUTZERNAME

Passwort:
passwd
sudo passwd BENUTZERNAME

--------------------------------------------------

📁 Ordner & Dateien

Ordner erstellen:
mkdir ORDNERNAME
mkdir ordner1 ordner2

Datei erstellen:
touch datei.txt
echo "Hallo Welt" > datei.txt

Löschen:
rmdir ordnername
rm -r ordnername (⚠️ mit Inhalt)
rm datei.txt

--------------------------------------------------

📂 Navigation

Aktueller Pfad:
pwd

Ordner wechseln:
cd ORDNERNAME
cd ..

Dateien anzeigen:
ls
ls -l
ls -la

--------------------------------------------------

🔎 Sudo-Admin prüfen

Alle Sudo-Benutzer zeigen:
getent group sudo

Admin-Rechte testen:
sudo whoami
(Ausgabe: root = ✅)

--------------------------------------------------

⚠️ Wichtige Hinweise

- BENUTZERNAME durch eigenen Namen ersetzen
- Bei sudo Befehlen Passwort eingeben
- rm -r löscht endgültig (kein Papierkorb)
- Keine Leerzeichen in Ordnernamen

--------------------------------------------------

🔒 Sicherheit

- Starke Passwörter verwenden
- Nur notwendige Benutzer anlegen
- Alte Benutzer regelmäßig löschen
- Sudo-Rechte nur vertrauenswürdigen Nutzern geben

--------------------------------------------------

🧪 Beispiel Workflow

1. Benutzer anlegen:
sudo adduser mschrot

2. Sudo-Rechte geben:
sudo usermod -aG sudo mschrot

3. Prüfen:
getent group sudo

4. Mit max einloggen:
su - mschrot

--------------------------------------------------

🛠️ Häufige Befehle

sudo whoami           # Prüft Admin-Rechte
pwd                   # Zeigt aktuellen Pfad
ls -la                # Zeigt alle Dateien
cd ..                 # Ein Ordner zurück
clear                 # Bildschirm leeren

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
