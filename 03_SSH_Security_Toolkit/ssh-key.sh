#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# ssh-key.sh — Generiert SSH-Keys für Admin-Benutzer
# Erstellt von Michael Schrot
# YouTube: https://www.youtube.com/@mschrot
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

# =========================
# KONFIGURATION (INTERN)
# =========================
# Farben für Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Temporäres Verzeichnis für sicheren Key-Export (nur für andere Benutzer)
TEMP_KEY_DIR="/tmp/secure_ssh_keys"

# =========================
# HILFSFUNKTIONEN
# =========================
print_error() { echo -e "${RED}❌ FEHLER:${NC} $1"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  WARNUNG:${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "\n${BLUE}==>${NC} $1"; }

show_usage() {
    echo "Verwendung:"
    echo "  sudo $0                     # Standard: ed25519 für aktuellen Benutzer"
    echo "  sudo $0 rsa                 # RSA für aktuellen Benutzer"
    echo "  sudo $0 ed                  # ed25519 für aktuellen Benutzer"
    echo "  sudo $0 benutzername        # ed25519 für bestimmten Benutzer"
    echo "  sudo $0 rsa benutzername    # RSA für bestimmten Benutzer"
    echo "  sudo $0 ed benutzername     # ed25519 für bestimmten Benutzer"
    echo ""
    echo "Optionen:"
    echo "  rsa  - Generiert RSA Schlüssel (4096 Bit)"
    echo "  ed   - Generiert ed25519 Schlüssel (empfohlen)"
}

cleanup_temp_dir() {
    if [[ -d "$TEMP_KEY_DIR" ]]; then
        rm -rf "$TEMP_KEY_DIR"
        print_info "Temporäres Verzeichnis bereinigt: $TEMP_KEY_DIR"
    fi
}

# =========================
# ARGUMENTE PARSEN
# =========================
KEY_TYPE=""
ADMIN_USER=""

# Prüfe ob Script als root ausgeführt wird
if [[ $EUID -ne 0 ]]; then
    print_error "Dieses Script muss mit sudo ausgeführt werden!"
    echo "    sudo $0"
    exit 1
fi

# Ermittle den sudo-Benutzer (für spätere Berechtigungen)
SUDO_CALLER="${SUDO_USER:-root}"

# Parse Argumente
if [[ $# -eq 0 ]]; then
    # Keine Argumente: Standard ed25519 für SUDO_USER
    KEY_TYPE="ed25519"
    ADMIN_USER="${SUDO_USER:-}"
elif [[ $# -eq 1 ]]; then
    # Ein Argument: entweder Schlüsseltyp oder Benutzername
    if [[ "$1" == "rsa" ]]; then
        KEY_TYPE="rsa"
        ADMIN_USER="${SUDO_USER:-}"
    elif [[ "$1" == "ed" ]]; then
        KEY_TYPE="ed25519"
        ADMIN_USER="${SUDO_USER:-}"
    else
        # Es wurde ein Benutzername übergeben
        KEY_TYPE="ed25519"
        ADMIN_USER="$1"
    fi
elif [[ $# -eq 2 ]]; then
    # Zwei Argumente: Schlüsseltyp und Benutzername
    if [[ "$1" == "rsa" ]]; then
        KEY_TYPE="rsa"
    elif [[ "$1" == "ed" ]]; then
        KEY_TYPE="ed25519"
    else
        print_error "Ungültiger Schlüsseltyp: $1 (verwende 'rsa' oder 'ed')"
        show_usage
        exit 1
    fi
    ADMIN_USER="$2"
else
    print_error "Zu viele Argumente!"
    show_usage
    exit 1
fi

# Prüfe ob ADMIN_USER gesetzt ist
if [[ -z "$ADMIN_USER" ]]; then
    print_error "Benutzer konnte nicht ermittelt werden. Bitte führe das Script mit sudo aus oder gib einen Benutzernamen an."
    show_usage
    exit 1
fi

# =========================
# BENUTZER PRÜFEN
# =========================
print_step "Prüfe Benutzer '$ADMIN_USER'"

# Prüfe ob Benutzer existiert
if ! id "$ADMIN_USER" >/dev/null 2>&1; then
    print_error "Benutzer '$ADMIN_USER' existiert nicht!"
    echo ""
    echo "Mögliche Lösungen:"
    echo "  1. Benutzer zuerst anlegen: adduser $ADMIN_USER"
    echo "  2. Einen existierenden Benutzer verwenden"
    echo "  3. Keinen Benutzernamen angeben (verwendet den sudo-ausführenden Benutzer)"
    echo ""
    exit 1
fi

print_success "Benutzer '$ADMIN_USER' gefunden"

# Prüfe ob Benutzer in sudo-Gruppe ist (nur Info)
if groups "$ADMIN_USER" | grep -q "\<sudo\>"; then
    print_info "Benutzer '$ADMIN_USER' ist in der sudo-Gruppe"
fi

# Prüfe ob es sich um den eigenen Benutzer handelt
IS_OWN_USER=false
if [[ "$ADMIN_USER" == "$SUDO_CALLER" ]]; then
    IS_OWN_USER=true
    print_info "SSH-Key wird für den eigenen Benutzer '$ADMIN_USER' erstellt"
    print_info "Es wird KEINE Kopie im /tmp Verzeichnis erstellt"
else
    print_info "SSH-Key wird für anderen Benutzer '$ADMIN_USER' erstellt"
    print_info "Eine Kopie wird im /tmp Verzeichnis für den Export bereitgestellt"
fi

# =========================
# KONFIGURATION
# =========================
# Schlüssellänge bei RSA (nur relevant wenn KEY_TYPE="rsa")
KEY_BITS="4096"
KEY_BASENAME="id_${KEY_TYPE}_${ADMIN_USER}"
USER_HOME="$(eval echo "~$ADMIN_USER")"
KEY_PRIV="$USER_HOME/.ssh/${KEY_BASENAME}"
KEY_PUB="$USER_HOME/.ssh/${KEY_BASENAME}.pub"
USER_SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$USER_SSH_DIR/authorized_keys"

# Temporäre Key-Kopie für Export (nur für andere Benutzer)
TEMP_USER_DIR="$TEMP_KEY_DIR/$ADMIN_USER"
TEMP_KEY_PRIV="$TEMP_USER_DIR/${KEY_BASENAME}"

# =========================
# TEMPORÄRES VERZEICHNIS VORBEREITEN (NUR FÜR ANDERE BENUTZER)
# =========================
if [[ "$IS_OWN_USER" == false ]]; then
    print_step "Bereite temporäres Verzeichnis für Key-Export vor"
    
    # Lösche altes temporäres Verzeichnis falls vorhanden
    if [[ -d "$TEMP_KEY_DIR" ]]; then
        rm -rf "$TEMP_KEY_DIR"
    fi
    
    # Erstelle neues temporäres Verzeichnis mit 755 Berechtigungen
    mkdir -p "$TEMP_USER_DIR"
    chmod 755 "$TEMP_KEY_DIR"
    chmod 750 "$TEMP_USER_DIR"
    
    # Gib dem sudo-caller Leseberechtigung (falls nicht root)
    if [[ "$SUDO_CALLER" != "root" ]]; then
        if command -v setfacl >/dev/null 2>&1; then
            setfacl -m "u:$SUDO_CALLER:rx" "$TEMP_KEY_DIR"
            setfacl -m "u:$SUDO_CALLER:rx" "$TEMP_USER_DIR"
            print_info "ACL Berechtigungen für Benutzer '$SUDO_CALLER' gesetzt"
        else
            chgrp -R "$SUDO_CALLER" "$TEMP_KEY_DIR" 2>/dev/null || true
            chmod 750 "$TEMP_USER_DIR"
            print_info "Gruppenberechtigungen für Benutzer '$SUDO_CALLER' gesetzt"
        fi
    fi
    
    print_success "Temporäres Verzeichnis erstellt: $TEMP_USER_DIR"
    print_info "Zugriff für root und sudo-Benutzer '$SUDO_CALLER'"
else
    print_step "Überspringe temporäres Verzeichnis (eigener Benutzer)"
fi

# =========================
# PASSPHRASE ABFRAGEN
# =========================
print_step "Passphrase für SSH-Key festlegen"
echo -e "${YELLOW}(WICHTIG: Der Benutzer benötigt diese Passphrase später!)${NC}"
echo ""

if [[ -z "${KEY_PASSPHRASE:-}" ]]; then
    echo "Bitte gib eine sichere Passphrase für den SSH-Key ein:"
    read -s -p "Passphrase: " KEY_PASSPHRASE
    echo
    read -s -p "Passphrase wiederholen: " KEY_PASSPHRASE2
    echo
    if [[ "$KEY_PASSPHRASE" != "$KEY_PASSPHRASE2" ]]; then
        print_error "Passphrasen stimmen nicht überein!"
        if [[ "$IS_OWN_USER" == false ]]; then
            cleanup_temp_dir
        fi
        exit 1
    fi
    if [[ -z "$KEY_PASSPHRASE" ]]; then
        print_warning "Keine Passphrase gesetzt! Das ist unsicher."
        read -p "Trotzdem fortfahren? (ja/nein): " -r continue_no_pass
        if [[ "$continue_no_pass" != "ja" ]]; then
            if [[ "$IS_OWN_USER" == false ]]; then
                cleanup_temp_dir
            fi
            exit 1
        fi
    fi
else
    print_warning "Passphrase wird aus Umgebungsvariable KEY_PASSPHRASE verwendet"
    if [[ "${#KEY_PASSPHRASE}" -lt 8 ]]; then
        print_error "Passphrase ist zu kurz (min. 8 Zeichen empfohlen)!"
        if [[ "$IS_OWN_USER" == false ]]; then
            cleanup_temp_dir
        fi
        exit 1
    fi
fi

# =========================
# PAKETE INSTALLIEREN
# =========================
print_step "Prüfe/Installiere benötigte Pakete"
apt-get update -qq
apt-get install -y openssh-client openssh-server >/dev/null 2>&1
print_success "Pakete sind installiert"

# =========================
# .ssh VERZEICHNIS VORBEREITEN
# =========================
print_step "Vorbereite .ssh Verzeichnis für Benutzer '$ADMIN_USER'"

# Erstelle .ssh Verzeichnis falls nötig
if [[ ! -d "$USER_SSH_DIR" ]]; then
    install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "$USER_SSH_DIR"
    print_info ".ssh Verzeichnis erstellt"
fi

# =========================
# SSH-KEY GENERIEREN
# =========================
print_step "Generiere SSH-Key (Typ: $KEY_TYPE)"

# Prüfe ob Keys bereits existieren
if [[ -f "$KEY_PRIV" || -f "$KEY_PUB" ]]; then
    print_warning "Key-Dateien existieren bereits:"
    echo "   Privat: $KEY_PRIV"
    echo "   Public: $KEY_PUB"
    read -p "Überschreiben? (ja/nein): " -r overwrite
    if [[ "$overwrite" != "ja" ]]; then
        print_error "Abgebrochen"
        if [[ "$IS_OWN_USER" == false ]]; then
            cleanup_temp_dir
        fi
        exit 1
    fi
    # Lösche alte Keys
    rm -f "$KEY_PRIV" "$KEY_PUB"
fi

# Generiere Key basierend auf Typ
KEY_COMMENT="${ADMIN_USER}@$(hostname)-$(date +%Y%m%d)"
if [[ "$KEY_TYPE" == "ed25519" ]]; then
    ssh-keygen -t ed25519 -a 100 -N "$KEY_PASSPHRASE" -C "$KEY_COMMENT" -f "$KEY_PRIV" >/dev/null 2>&1
elif [[ "$KEY_TYPE" == "rsa" ]]; then
    ssh-keygen -t rsa -b "$KEY_BITS" -N "$KEY_PASSPHRASE" -C "$KEY_COMMENT" -f "$KEY_PRIV" >/dev/null 2>&1
else
    print_error "Nicht unterstützter Key-Typ: $KEY_TYPE (verwende ed25519 oder rsa)"
    if [[ "$IS_OWN_USER" == false ]]; then
        cleanup_temp_dir
    fi
    exit 1
fi

# Setze korrekte Berechtigungen für die Keys
chown "$ADMIN_USER:$ADMIN_USER" "$KEY_PRIV" "$KEY_PUB"
chmod 600 "$KEY_PRIV"
chmod 644 "$KEY_PUB"

print_success "SSH-Key wurde generiert"
print_info "Privater Schlüssel: $KEY_PRIV"
print_info "Öffentlicher Schlüssel: $KEY_PUB"

# =========================
# KEY IN TEMP VERZEICHNIS KOPIEREN (NUR FÜR ANDERE BENUTZER)
# =========================
if [[ "$IS_OWN_USER" == false ]]; then
    print_step "Kopiere privaten Schlüssel ins temporäre Verzeichnis"
    
    # Kopiere privaten Schlüssel ins temporäre Verzeichnis
    cp "$KEY_PRIV" "$TEMP_KEY_PRIV"
    chmod 640 "$TEMP_KEY_PRIV"
    
    # Setze Berechtigungen für den sudo-caller
    if [[ "$SUDO_CALLER" != "root" ]]; then
        if command -v setfacl >/dev/null 2>&1; then
            setfacl -m "u:$SUDO_CALLER:r" "$TEMP_KEY_PRIV"
        else
            chgrp "$SUDO_CALLER" "$TEMP_KEY_PRIV" 2>/dev/null || true
        fi
    fi
    
    print_success "Privater Schlüssel wurde kopiert nach: $TEMP_KEY_PRIV"
    
    # Erstelle eine README Datei im Temp-Verzeichnis
    cat > "$TEMP_USER_DIR/README.txt" << EOF
SSH Key Export Informationen
============================
Benutzer: $ADMIN_USER
Schlüsseltyp: $KEY_TYPE
Erstellt am: $(date)
Server: $(hostname)
IP: $(hostname -I | awk '{print $1}')

Wichtige Hinweise:
1. Dieser private Schlüssel ist für root und $SUDO_CALLER zugänglich
2. Lade ihn sofort herunter und lösche ihn dann vom Server
3. Der private Schlüssel darf niemals weitergegeben werden
4. Die Passphrase wurde nicht gespeichert - merke sie dir gut!

Download mit SCP (von einem anderen Rechner):
  # Von Windows (PowerShell):
  scp $SUDO_CALLER@SERVER_IP:$TEMP_KEY_PRIV .
  
  # Von Linux/Mac:
  scp $SUDO_CALLER@SERVER_IP:$TEMP_KEY_PRIV ~/.ssh/${KEY_BASENAME}
  chmod 600 ~/.ssh/${KEY_BASENAME}

Nach dem Download vom Server löschen:
  sudo rm -rf $TEMP_KEY_DIR

Alternativ: Lösche nur diesen Benutzer-Ordner:
  sudo rm -rf $TEMP_USER_DIR
EOF
    
    chmod 644 "$TEMP_USER_DIR/README.txt"
    print_info "README.txt wurde erstellt: $TEMP_USER_DIR/README.txt"
else
    print_step "Überspringe Kopie ins temporäre Verzeichnis (eigener Benutzer)"
fi

# =========================
# AUTHORIZED_KEYS INSTALLIEREN
# =========================
print_step "Installiere öffentlichen Schlüssel für Benutzer '$ADMIN_USER'"

# Erstelle authorized_keys falls nötig
if [[ ! -f "$AUTHORIZED_KEYS" ]]; then
    touch "$AUTHORIZED_KEYS"
    chown "$ADMIN_USER:$ADMIN_USER" "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    print_info "authorized_keys Datei erstellt"
fi

# Füge öffentlichen Schlüssel hinzu (ohne Duplikate)
PUB_KEY_CONTENT="$(cat "$KEY_PUB")"
if grep -qxF "$PUB_KEY_CONTENT" "$AUTHORIZED_KEYS"; then
    print_warning "Öffentlicher Schlüssel existiert bereits in authorized_keys"
else
    echo "$PUB_KEY_CONTENT" >> "$AUTHORIZED_KEYS"
    print_success "Öffentlicher Schlüssel wurde installiert"
fi

# Setze korrekte Berechtigungen
chown -R "$ADMIN_USER:$ADMIN_USER" "$USER_SSH_DIR"
chmod 700 "$USER_SSH_DIR"
chmod 600 "$AUTHORIZED_KEYS"

# =========================
# ZUSÄTZLICHE SSH-KONFIGURATION
# =========================
print_step "Optimiere SSH-Konfiguration für Benutzer"

# Optional: Erstelle SSH-Client-Konfiguration für einfacheren Zugang
SSH_CONFIG="$USER_HOME/.ssh/config"
if [[ ! -f "$SSH_CONFIG" ]]; then
    cat > "$SSH_CONFIG" << EOF
# Automatisch generiert am $(date)
# Vereinfacht den SSH-Zugang mit diesem Key

Host $(hostname)
    HostName $(hostname -I | awk '{print $1}')
    User $ADMIN_USER
    IdentityFile ~/.ssh/${KEY_BASENAME}
    IdentitiesOnly yes
EOF
    chown "$ADMIN_USER:$ADMIN_USER" "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    print_info "SSH-Client-Konfiguration wurde erstellt: $SSH_CONFIG"
fi

# =========================
# AUSGABE & DOWNLOAD-INFO
# =========================
SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ SSH-KEY WURDE ERFOLGREICH GENERIERT!${NC}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📁 WICHTIGE PFADE:${NC}"
echo "   Privater Schlüssel:     ${KEY_PRIV}"
echo "   Öffentlicher Schlüssel: ${KEY_PUB}"
echo "   Installiert bei Benutzer: ${AUTHORIZED_KEYS}"
if [[ "$IS_OWN_USER" == false ]]; then
    echo "   Privater Schlüssel (TEMP): ${TEMP_KEY_PRIV}"
    echo "   Temporäres Verzeichnis:   ${TEMP_USER_DIR}"
fi
echo ""

if [[ "$IS_OWN_USER" == false ]]; then
    echo -e "${YELLOW}💻 DOWNLOAD DES PRIVATEN SCHLÜSSELS (empfohlen von /tmp):${NC}"
    echo ""
    echo "   🔹 VON WINDOWS (PowerShell oder CMD):"
    echo -e "      ${GREEN}scp ${SUDO_CALLER}@${SERVER_IP}:${TEMP_KEY_PRIV} .${NC}"
    echo ""
    echo "   🔹 VON LINUX/MAC:"
    echo -e "      ${GREEN}scp ${SUDO_CALLER}@${SERVER_IP}:${TEMP_KEY_PRIV} ~/.ssh/${KEY_BASENAME}${NC}"
    echo -e "      ${GREEN}chmod 600 ~/.ssh/${KEY_BASENAME}${NC}"
    echo ""
else
    echo -e "${YELLOW}💡 HINWEIS:${NC}"
    echo "   Da dies Ihr eigener Benutzer ist, wurde KEINE Kopie im /tmp Verzeichnis erstellt."
    echo "   Der private Schlüssel befindet sich nur in: ${KEY_PRIV}"
    echo ""
fi

echo -e "${YELLOW}🚀 SSH-LOGIN TESTEN:${NC}"
echo "   Von Windows:"
echo -e "   ${GREEN}ssh -i ${KEY_BASENAME} ${ADMIN_USER}@${SERVER_IP}${NC}"
echo ""
echo "   Von Linux/Mac:"
echo -e "   ${GREEN}ssh -i ~/.ssh/${KEY_BASENAME} ${ADMIN_USER}@${SERVER_IP}${NC}"
echo ""

if [[ "$IS_OWN_USER" == false ]]; then
    echo -e "${RED}⚠️  SICHERHEITSHINWEISE:${NC}"
    echo "   1. Der private Schlüssel liegt in: ${KEY_PRIV}"
    echo "   2. UND im temporären Verzeichnis: ${TEMP_KEY_PRIV}"
    echo "   3. Lade ihn SOFORT herunter (empfohlen aus /tmp):"
    echo -e "      ${GREEN}scp ${SUDO_CALLER}@${SERVER_IP}:${TEMP_KEY_PRIV} .${NC}"
    echo "   4. Lösche das temporäre Verzeichnis NACH dem Download:"
    echo -e "      ${GREEN}sudo rm -rf ${TEMP_KEY_DIR}${NC}"
    echo "   5. Optional: Lösche auch den privaten Schlüssel vom Benutzer:"
    echo -e "      ${GREEN}sudo rm ${KEY_PRIV}${NC}"
    echo "   6. Bewahre den privaten Schlüssel sicher auf (niemandem geben!)"
    echo -e "   7. Die Passphrase wurde ${YELLOW}NICHT${NC} gespeichert - merk sie dir!"
    echo ""
    echo -e "${YELLOW}📋 EXPORT-INFO:${NC}"
    echo "   Das temporäre Verzeichnis enthält eine README.txt mit weiteren Infos"
    echo "   Zugriff haben: root und sudo-Benutzer '${SUDO_CALLER}'"
    echo "   Temporärer Pfad: ${TEMP_KEY_DIR}"
else
    echo -e "${YELLOW}💡 TIPP:${NC}"
    echo "   Wenn Sie diesen Schlüssel auf einen anderen Rechner kopieren möchten:"
    echo -e "   ${GREEN}scp ${KEY_PRIV} benutzername@anderer-rechner:~/.ssh/${NC}"
    echo ""
fi

echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📺 Tutorials und Hilfe:${NC}"
echo -e "   🎬 YouTube: ${BLUE}https://www.youtube.com/@mschrot${NC}"
echo "   👍 Unterstütz mich gern mit einem Like und einem Abo!"
echo -e "   🐙 GitHub: ${BLUE}https://github.com/mschrot/${NC}"
echo ""
# =========================
# COPYRIGHT
# =========================
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║  © 2026 Michael Schrot (mschrot)                                          ║"
echo "║                                                                           ║"
echo "║  Lizenz: MIT                                                              ║"
echo "║  YouTube: https://www.youtube.com/@mschrot                                ║"
echo "║  GitHub:  https://github.com/mschrot                                      ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ "$IS_OWN_USER" == false ]]; then
    echo ""
    print_warning "Vergiss nicht, das temporäre Verzeichnis nach dem Download zu löschen!"
    echo "   sudo rm -rf ${TEMP_KEY_DIR}"
    echo ""
    echo -e "${GREEN}Jetzt kannst du auf das temporäre Verzeichnis zugreifen:${NC}"
    echo "   ls -la ${TEMP_KEY_DIR}/${ADMIN_USER}/"
    echo "   cat ${TEMP_USER_DIR}/README.txt"
    echo ""
fi