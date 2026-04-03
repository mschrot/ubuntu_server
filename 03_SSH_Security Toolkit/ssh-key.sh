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
#
# Verwendung:
#   sudo ./ssh-key.sh
#
# ==============================================================================

# =========================
# KONFIGURATION (HIER ANPASSEN!)
# =========================
# Wähle den Schlüsseltyp: ed25519 (empfohlen) oder rsa
KEY_TYPE="ed25519"

# Schlüssellänge bei RSA (nur relevant wenn KEY_TYPE="rsa")
KEY_BITS="4096"

# =========================
# KONFIGURATION (INTERN)
# =========================
# Farben für Ausgaben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =========================
# HILFSFUNKTIONEN
# =========================
print_error() { echo -e "${RED}❌ FEHLER:${NC} $1"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  WARNUNG:${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "\n${BLUE}==>${NC} $1"; }

# =========================
# PRÜFUNGEN
# =========================
if [[ $EUID -ne 0 ]]; then
    print_error "Dieses Script muss mit sudo ausgeführt werden!"
    echo "    sudo $0"
    exit 1
fi

# Setze Default-Werte
ADMIN_USER="${ADMIN_USER:-$SUDO_USER}"
if [[ -z "$ADMIN_USER" ]]; then
    print_error "ADMIN_USER konnte nicht ermittelt werden. Bitte setze ihn manuell:"
    echo "    sudo ADMIN_USER=username ./$0"
    exit 1
fi

# Prüfe ob Benutzer existiert
if ! id "$ADMIN_USER" >/dev/null 2>&1; then
    print_error "Benutzer '$ADMIN_USER' existiert nicht!"
    echo "   Möchtest du ihn anlegen? (ja/nein)"
    read -r create_user
    if [[ "$create_user" == "ja" ]]; then
        adduser "$ADMIN_USER"
        usermod -aG sudo "$ADMIN_USER"
        print_success "Benutzer '$ADMIN_USER' wurde erstellt"
    else
        exit 1
    fi
fi

# SSH-Key Konfiguration (Umgebungsvariablen überschreiben Konfiguration)
KEY_TYPE="${KEY_TYPE:-$KEY_TYPE}"
KEY_BITS="${KEY_BITS:-$KEY_BITS}"
KEY_BASENAME="id_${KEY_TYPE}_${ADMIN_USER}"
USER_HOME="$(eval echo "~$ADMIN_USER")"
KEY_PRIV="$USER_HOME/.ssh/${KEY_BASENAME}"
KEY_PUB="$USER_HOME/.ssh/${KEY_BASENAME}.pub"
USER_SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$USER_SSH_DIR/authorized_keys"

# =========================
# PASSPHRASE ABFRAGEN
# =========================
print_step "Passphrase für SSH-Key festlegen"
if [[ -z "${KEY_PASSPHRASE:-}" ]]; then
    echo "Bitte gib eine sichere Passphrase für den SSH-Key ein:"
    read -s -p "Passphrase: " KEY_PASSPHRASE
    echo
    read -s -p "Passphrase wiederholen: " KEY_PASSPHRASE2
    echo
    if [[ "$KEY_PASSPHRASE" != "$KEY_PASSPHRASE2" ]]; then
        print_error "Passphrasen stimmen nicht überein!"
        exit 1
    fi
    if [[ -z "$KEY_PASSPHRASE" ]]; then
        print_warning "Keine Passphrase gesetzt! Das ist unsicher."
        read -p "Trotzdem fortfahren? (ja/nein): " -r continue_no_pass
        if [[ "$continue_no_pass" != "ja" ]]; then
            exit 1
        fi
    fi
else
    print_warning "Passphrase wird aus Umgebungsvariable KEY_PASSPHRASE verwendet"
    if [[ "${#KEY_PASSPHRASE}" -lt 8 ]]; then
        print_error "Passphrase ist zu kurz (min. 8 Zeichen empfohlen)!"
        exit 1
    fi
fi

# =========================
# PAKETE INSTALLIEREN
# =========================
print_step "Prüfe/Installiere benötigte Pakete"
apt-get update -qq
apt-get install -y openssh-client openssh-server >/dev/null
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
        exit 1
    fi
    # Lösche alte Keys
    rm -f "$KEY_PRIV" "$KEY_PUB"
fi

# Generiere Key basierend auf Typ
KEY_COMMENT="${ADMIN_USER}@$(hostname)-$(date +%Y%m%d)"
if [[ "$KEY_TYPE" == "ed25519" ]]; then
    ssh-keygen -t ed25519 -a 100 -N "$KEY_PASSPHRASE" -C "$KEY_COMMENT" -f "$KEY_PRIV" >/dev/null
elif [[ "$KEY_TYPE" == "rsa" ]]; then
    ssh-keygen -t rsa -b "$KEY_BITS" -N "$KEY_PASSPHRASE" -C "$KEY_COMMENT" -f "$KEY_PRIV" >/dev/null
else
    print_error "Nicht unterstützter Key-Typ: $KEY_TYPE (verwende ed25519 oder rsa)"
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
CURRENT_USER="${SUDO_USER:-$USER}"  # Der Benutzer, der sudo ausgeführt hat

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ SSH-KEY WURDE ERFOLGREICH GENERIERT!${NC}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📁 WICHTIGE PFADE:${NC}"
echo "   Privater Schlüssel:  ${KEY_PRIV}"
echo "   Öffentlicher Schlüssel: ${KEY_PUB}"
echo "   Installiert bei Benutzer: ${AUTHORIZED_KEYS}"
echo ""
echo -e "${YELLOW}💻 DOWNLOAD AUF WINDOWS (vom Server):${NC}"
echo "   Öffne PowerShell oder CMD und führe aus:"
echo ""
echo -e "   ${GREEN}scp ${ADMIN_USER}@${SERVER_IP}:\"${KEY_PRIV}\" .${NC}"
echo ""
echo -e "${YELLOW}🔧 DOWNLOAD AUF LINUX/MAC:${NC}"
echo -e "   ${GREEN}scp ${ADMIN_USER}@${SERVER_IP}:${KEY_PRIV} ~/.ssh/${KEY_BASENAME}${NC}"
echo "   chmod 600 ~/.ssh/${KEY_BASENAME}"
echo ""
echo -e "${YELLOW}🚀 SSH-LOGIN TESTEN:${NC}"
echo "   Von Windows:"
echo -e "   ${GREEN}ssh -i ${KEY_BASENAME} ${ADMIN_USER}@${SERVER_IP}${NC}"
echo ""
echo "   Von Linux/Mac:"
echo -e "   ${GREEN}ssh -i ~/.ssh/${KEY_BASENAME} ${ADMIN_USER}@${SERVER_IP}${NC}"
echo ""
echo -e "${RED}⚠️  SICHERHEITSHINWEISE:${NC}"
echo "   1. Der private Schlüssel liegt in: ${KEY_PRIV}"
echo "   2. Lade ihn SOFORT herunter:"
echo -e "      ${GREEN}scp ${ADMIN_USER}@${SERVER_IP}:${KEY_PRIV} .${NC}"
echo "   3. Lösche ihn dann vom Server (optional):"
echo -e "      ${GREEN}sudo rm ${KEY_PRIV}${NC}"
echo "   4. Bewahre den privaten Schlüssel sicher auf (niemandem geben!)"
echo "   5. Die Passphrase wurde ${YELLOW}NICHT${NC} gespeichert - merk sie dir!"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}📺 Tutorials und Hilfe:${NC}"
echo -e "   🎬 YouTube: ${BLUE}https://www.youtube.com/@mschrot${NC}"
echo "   👍 Unterstütz mich gern mit einem Like und einem Abo!"
echo -e "   🐙 GitHub: ${BLUE}https://github.com/mschrot/${NC}"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"