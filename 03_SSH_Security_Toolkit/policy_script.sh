#!/usr/bin/env bash
set -euo pipefail

# Erstellt von Michael Schrot
# YouTube: https://www.youtube.com/@mschrot
#
# ==============================================================================
# policy_script.sh — SSH Hardening + optional Passwordless sudo (Ubuntu/Debian)
#
# Speichern:        nano policy_script.sh
# Ausführbar:       chmod +x policy_script.sh
# Starten (sudo):   sudo ./policy_script.sh
#
# Was es macht:
#  1) Schreibt eine harte Override-Datei:
#     /etc/ssh/sshd_config.d/99-hardening.conf
#     (wirkt als "last one wins", also überschreibt frühere Einstellungen)
#  2) Optional: richtet sudo ohne Passwort per sudoers drop-in ein
#
# WICHTIG:
#  - Vor dem Ausführen sicherstellen, dass du bereits per SSH-Key reinkommst,
#    sonst kannst du dich aussperren.
#  - Passwortloses sudo ist ein großes Risiko. Nur aktivieren, wenn du weißt warum.
# ==============================================================================

# =========================
# PARAMETER (HIER ANPASSEN)
# =========================

#----------------------- 🔐 SUDO EINSTELLUNGEN (Benutzerspezifisch) --------------------
PASSWORDLESS_SUDO="no"            # 'yes' = Sudo ohne Passwort (RISIKO!)
PASSWORDLESS_SUDO_USER="ubuntu"   # Welcher User darf NOPASSWD nutzen
# ⚠️ ACHTUNG: Nur aktivieren wenn nötig! Jeder Prozess kann dann Root werden.
#--------------------------------------------------------------------------------------


#----------------------- 🔒 SSH EINSTELLUNGEN (Systemweit) ----------------------------
# Diese Einstellungen gelten für ALLE Benutzer der Maschine!

# Basis-Härtung
DISABLE_PASSWORD_LOGIN="yes"      # 'yes' = Nur SSH-Keys erlaubt (Kein Passwort)
DISABLE_ROOT_SSH="yes"            # 'yes' = Root-Login verbieten
FORCE_PUBKEY_ONLY="yes"           # 'yes' = Nur Public-Key Auth (erzwingen)

# Netzwerk
SET_CUSTOM_SSH_PORT="no"          # 'yes' = Anderen SSH-Port nutzen
CUSTOM_SSH_PORT="2222"            # Z.B.: 2222 (nur wenn oben 'yes')

# Forwarding (Sicherheit)
DISABLE_X11_FORWARDING="yes"      # 'yes' = X11 deaktivieren (meist nicht gebraucht)
DISABLE_TCP_FORWARDING="no"       # 'yes' = Port-Weiterleitung verbieten
DISABLE_AGENT_FORWARDING="yes"    # 'yes' = Agent-Forwarding verbieten

# Features
ALLOW_SFTP="yes"                  # 'yes' = SFTP erlauben (internal-sftp)
# =========================
# ENDE PARAMETER
# =========================

HARDENING_FILE="/etc/ssh/sshd_config.d/99-hardening.conf"
SUDOERS_FILE="/etc/sudoers.d/99-${PASSWORDLESS_SUDO_USER}-nopasswd"

# =========================
# FARBEN für Ausgabe
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =========================
# PRÜFUNGEN VOR AUSFÜHRUNG
# =========================

if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}❌ FEHLER: Bitte als root ausführen (z.B. sudo $0)${NC}"
  exit 1
fi

if ! command -v sshd >/dev/null 2>&1; then
  echo -e "${RED}❌ FEHLER: sshd nicht gefunden. Ist openssh-server installiert?${NC}"
  echo "   Lösung: sudo apt update && sudo apt install openssh-server -y"
  exit 1
fi

if [[ "${DISABLE_PASSWORD_LOGIN}" == "yes" ]]; then
  echo -e "${YELLOW}⚠️  WICHTIG: Du deaktivierst Passwort-Login!${NC}"
  echo "   Stelle sicher, dass du bereits mit SSH-Key verbunden bist."
  echo "   Sonst kannst du dich aussperren!"
  echo ""
  read -p "   Weiter? (ja/nein): " -r confirmation
  if [[ ! "$confirmation" =~ ^[jJ](a|ah)?$ ]]; then
    echo -e "${RED}❌ Abgebrochen.${NC}"
    exit 1
  fi
fi

# =========================
# SUBsystem-KONFLIKT BESEITIGEN (AUTOMATISCH)
# =========================
echo ""
echo -e "${BLUE}==> Prüfe auf doppelte 'Subsystem sftp' Definition...${NC}"

if grep -E '^[[:space:]]*Subsystem[[:space:]]+sftp' /etc/ssh/sshd_config >/dev/null; then
  echo "     → Gefunden: Subsystem sftp in /etc/ssh/sshd_config"
  echo "     → Kommentiere diese Zeile aus (überschreiben mit #)"
  
  # Backup der originalen sshd_config
  cp -a /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"
  
  # Kommentiere alle 'Subsystem sftp' Zeilen aus
  sed -i 's/^[[:space:]]*Subsystem[[:space:]]\+sftp/#Subsystem sftp (auskommentiert durch policy_script.sh)/' /etc/ssh/sshd_config
  
  echo -e "     ${GREEN}✅ Subsystem Zeile auskommentiert${NC}"
else
  echo -e "     ${GREEN}✅ Kein Konflikt gefunden (Subsystem sftp nicht in Hauptdatei aktiv)${NC}"
fi

# =========================
# SSH Include-Verzeichnis prüfen
# =========================
echo ""
echo -e "${BLUE}==> Prüfe, ob sshd_config Include-Verzeichnis nutzt...${NC}"
if ! grep -Eq '^[[:space:]]*Include[[:space:]]+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
  echo -e "${YELLOW}⚠️  WARNUNG: /etc/ssh/sshd_config enthält kein Include für /etc/ssh/sshd_config.d/*.conf${NC}"
  echo "         Dann greift diese Hardening-Datei evtl. NICHT."
  echo ""
  read -p "   Trotzdem fortfahren? (ja/nein): " -r confirmation
  if [[ ! "$confirmation" =~ ^[jJ](a|ah)?$ ]]; then
    echo -e "${RED}❌ Abgebrochen.${NC}"
    exit 1
  fi
fi

# =========================
# SSH HÄRTUNG
# =========================

echo -e "${BLUE}==> Schreibe Hardening-Override: ${HARDENING_FILE}${NC}"
install -d -m 0755 /etc/ssh/sshd_config.d

if [[ -f "${HARDENING_FILE}" ]]; then
  cp -a "${HARDENING_FILE}" "${HARDENING_FILE}.bak.$(date +%Y%m%d%H%M%S)"
  echo "     → Backup erstellt."
fi

{
  echo "# Generated by policy_script.sh on $(date -Is)"
  echo "# This file is intended to override earlier sshd_config settings."
  echo

  if [[ "${DISABLE_PASSWORD_LOGIN}" == "yes" ]]; then
    echo "# Passwort-Login deaktivieren (nur noch SSH-Keys)"
    echo "PasswordAuthentication no"
    echo "KbdInteractiveAuthentication no"
    echo "ChallengeResponseAuthentication no"
    echo "UsePAM yes"
    echo
  fi

  if [[ "${FORCE_PUBKEY_ONLY}" == "yes" ]]; then
    echo "# Erzwinge Public-Key Authentifizierung"
    echo "PubkeyAuthentication yes"
    echo "AuthenticationMethods publickey"
    echo
  fi

  if [[ "${DISABLE_ROOT_SSH}" == "yes" ]]; then
    echo "# Root-Login verbieten"
    echo "PermitRootLogin no"
    echo
  fi

  if [[ "${SET_CUSTOM_SSH_PORT}" == "yes" ]]; then
    echo "# Custom SSH Port"
    echo "Port ${CUSTOM_SSH_PORT}"
    echo
  fi

  echo "# Allgemeines Hardening"
  echo "Protocol 2"
  echo "MaxAuthTries 3"
  echo "LoginGraceTime 30"
  echo "ClientAliveInterval 300"
  echo "ClientAliveCountMax 2"
  echo "PermitEmptyPasswords no"
  echo "PrintMotd no"
  echo "Compression no"
  echo

  echo "# Forwarding Einstellungen"
  if [[ "${DISABLE_X11_FORWARDING}" == "yes" ]]; then
    echo "X11Forwarding no"
  fi
  if [[ "${DISABLE_TCP_FORWARDING}" == "yes" ]]; then
    echo "AllowTcpForwarding no"
  fi
  if [[ "${DISABLE_AGENT_FORWARDING}" == "yes" ]]; then
    echo "AllowAgentForwarding no"
  fi
  echo

  if [[ "${ALLOW_SFTP}" == "yes" ]]; then
    echo "# SFTP mit internal-sftp (robust und sicher)"
    echo "Subsystem sftp internal-sftp"
    echo
  else
    echo "# SFTP komplett deaktivieren"
    echo "Subsystem sftp /bin/false"
    echo
  fi

  echo "# Kryptographie-Einstellungen (modern und sicher)"
  echo "HostKey /etc/ssh/ssh_host_ed25519_key"
  echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org"
  echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com"
  echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"

} > "${HARDENING_FILE}"

chmod 0644 "${HARDENING_FILE}"

# =========================
# TEST & RELOAD
# =========================

echo ""
echo -e "${BLUE}==> Teste sshd-Konfiguration...${NC}"
if sshd -t; then
  echo -e "     ${GREEN}✅ Konfiguration ist gültig${NC}"
else
  echo -e "${RED}❌ FEHLER: SSH-Konfiguration ist ungültig!${NC}"
  echo "   Stelle die originale Konfiguration wieder her:"
  echo "   sudo rm ${HARDENING_FILE}"
  exit 1
fi

echo -e "${BLUE}==> Reload/Restart ssh Service...${NC}"
if systemctl is-active --quiet ssh; then
  systemctl reload ssh || systemctl restart ssh
  echo -e "     ${GREEN}✅ SSH Service neu geladen${NC}"
elif systemctl is-active --quiet sshd; then
  systemctl reload sshd || systemctl restart sshd
  echo -e "     ${GREEN}✅ SSHD Service neu geladen${NC}"
else
  echo -e "${YELLOW}⚠️  WARNUNG: ssh/sshd Service nicht aktiv. Bitte manuell starten.${NC}"
fi

# =========================
# PASSWORDLESS SUDO
# =========================

echo ""
if [[ "${PASSWORDLESS_SUDO}" == "yes" ]]; then
  echo -e "${BLUE}==> Richte sudo ohne Passwort ein für User: ${PASSWORDLESS_SUDO_USER}${NC}"
  
  if ! getent passwd "${PASSWORDLESS_SUDO_USER}" >/dev/null; then
    echo -e "${RED}❌ FEHLER: User '${PASSWORDLESS_SUDO_USER}' existiert nicht.${NC}"
    exit 1
  fi
  
  if ! id -nG "${PASSWORDLESS_SUDO_USER}" 2>/dev/null | grep -qw "sudo"; then
    echo -e "${YELLOW}⚠️  WARNUNG: User '${PASSWORDLESS_SUDO_USER}' ist nicht in der sudo-Gruppe!${NC}"
    echo "         NOPASSWD wird dann keine Wirkung haben."
    read -p "   Trotzdem fortfahren? (ja/nein): " -r confirmation
    if [[ ! "$confirmation" =~ ^[jJ](a|ah)?$ ]]; then
      echo -e "${RED}❌ Abgebrochen.${NC}"
      exit 1
    fi
  fi
  
  echo -e "${YELLOW}⚠️  SICHERHEITSWARNUNG: Du aktivierst passwordloses Sudo für ${PASSWORDLESS_SUDO_USER}!${NC}"
  echo "   Das ist ein hohes Sicherheitsrisiko!"
  read -p "   Wirklich aktivieren? (ja/nein): " -r confirmation
  if [[ ! "$confirmation" =~ ^[jJ](a|ah)?$ ]]; then
    echo -e "${RED}❌ Passwordless Sudo wurde abgelehnt.${NC}"
    PASSWORDLESS_SUDO="no"
  else
    {
      echo "# Generated by policy_script.sh on $(date -Is)"
      echo "# ⚠️  ACHTUNG: Dies erlaubt NOPASSWD sudo für ${PASSWORDLESS_SUDO_USER}"
      echo "${PASSWORDLESS_SUDO_USER} ALL=(ALL) NOPASSWD:ALL"
    } > "${SUDOERS_FILE}"
    
    chmod 0440 "${SUDOERS_FILE}"
    
    if visudo -cf "${SUDOERS_FILE}" >/dev/null 2>&1; then
      echo -e "     ${GREEN}✅ Passwordless Sudo aktiviert für: ${PASSWORDLESS_SUDO_USER}${NC}"
    else
      echo -e "${RED}❌ FEHLER: sudoers Syntax ist ungültig!${NC}"
      rm -f "${SUDOERS_FILE}"
      exit 1
    fi
  fi
fi

if [[ "${PASSWORDLESS_SUDO}" != "yes" ]]; then
  echo -e "${BLUE}==> Passwordless sudo: deaktiviert (PASSWORDLESS_SUDO=no)${NC}"
  if [[ -f "${SUDOERS_FILE}" ]]; then
    rm -f "${SUDOERS_FILE}"
    echo "     → Alte sudoers Datei entfernt"
  fi
fi

# =========================
# ABSCHLUSS
# =========================

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FERTIG! SSH Härtung wurde angewendet.${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📁 SSH Hardening Datei: ${HARDENING_FILE}"  # <- Korrigiert: HARDENING_FILE statt HARDINGEN_FILE
echo ""
echo -e "${RED}🔴 WICHTIG - TESTE VOR DEM AUSLOGGEN:${NC}"
echo "   1. Öffne ein NEUES Terminal"
echo "   2. Verbinde dich zum Server:"
if [[ "${SET_CUSTOM_SSH_PORT}" == "yes" ]]; then
  echo "      ssh -p ${CUSTOM_SSH_PORT} ${SUDO_USER:-$USER}@$(hostname -I | awk '{print $1}')"
else
  echo "      ssh ${SUDO_USER:-$USER}@$(hostname -I | awk '{print $1}')"
fi
echo "   3. Wenn die Verbindung funktioniert, kannst du das alte Terminal schließen"
echo ""
echo "📝 Nützliche Befehle:"
echo "   - SSH Konfiguration testen: sudo sshd -t"
echo "   - SSH Logs anzeigen: sudo journalctl -u ssh -f"
echo "   - Firewall Regeln prüfen: sudo ufw status"
echo ""
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