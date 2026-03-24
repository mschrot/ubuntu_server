#!/bin/bash

# Docker und Portainer Installationsskript für Ubuntu Server 24.04
# Ausführen mit: chmod +x install.sh && sudo ./install.sh

set -e  # Beenden bei Fehlern
set -u  # Beenden bei undefinierten Variablen

# Farben für die Ausgabe
ROT='\033[0;31m'
GRUEN='\033[0;32m'
GELB='\033[1;33m'
BLAU='\033[0;34m'
NC='\033[0m' # Keine Farbe

# Logging-Funktionen
log_info() {
    echo -e "${GRUEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${GELB}[WARNUNG]${NC} $1"
}

log_error() {
    echo -e "${ROT}[FEHLER]${NC} $1"
}

log_step() {
    echo -e "${BLAU}[SCHRITT]${NC} $1"
}

# Ermittle den echten Benutzer (auch wenn mit sudo ausgeführt)
if [[ $SUDO_USER ]]; then
    ECHTER_BENUTZER=$SUDO_USER
else
    ECHTER_BENUTZER=$(whoami)
fi

# Begrüßung
echo ""
echo "============================================"
echo -e "${BLAU}Docker und Portainer Installationsskript${NC}"
echo "============================================"
echo ""
log_info "Installation wird für Benutzer: $ECHTER_BENUTZER durchgeführt"
echo ""

# Systemaktualisierung
log_step "Aktualisiere Systempakete..."
apt update && apt upgrade -y

# Installiere Abhängigkeiten
log_step "Installiere benötigte Pakete..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    ufw \
    wget \
    git

# Entferne alte Docker-Versionen falls vorhanden
log_step "Entferne alte Docker-Versionen..."
apt remove -y docker docker-engine docker.io containerd runc || true

# Füge Dockers offiziellen GPG-Schlüssel hinzu
log_step "Füge Dockers offiziellen GPG-Schlüssel hinzu..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Füge Docker Repository hinzu
log_step "Füge Docker Repository hinzu..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Aktualisiere Paketindex erneut
apt update

# Installiere Docker Engine
log_step "Installiere Docker Engine..."
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Füge Benutzer zur Docker-Gruppe hinzu (falls nicht root)
if [[ "$ECHTER_BENUTZER" != "root" ]]; then
    log_step "Füge Benutzer $ECHTER_BENUTZER zur Docker-Gruppe hinzu..."
    usermod -aG docker $ECHTER_BENUTZER
    log_info "Benutzer wurde zur Docker-Gruppe hinzugefügt"
fi

# Aktiviere und starte Docker Dienst
log_step "Aktiviere und starte Docker Dienst..."
systemctl enable docker
systemctl start docker

# Warte kurz bis Docker bereit ist
sleep 3

# Überprüfe Docker Installation
log_step "Überprüfe Docker Installation..."
if docker --version > /dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version)
    log_info "Docker erfolgreich installiert: $DOCKER_VERSION"
else
    log_error "Docker Installation fehlgeschlagen!"
    exit 1
fi

# Überprüfe Docker Compose
if docker compose version > /dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version)
    log_info "Docker Compose erfolgreich installiert: $COMPOSE_VERSION"
fi

# Konfiguriere UFW Firewall falls aktiv
if ufw status | grep -q "active"; then
    log_step "Konfiguriere UFW Firewall..."
    
    # Erstelle Backup der aktuellen Regeln
    ufw status numbered > /tmp/ufw_backup.txt 2>/dev/null || true
    
    # Füge benötigte Ports hinzu
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow 8000/tcp comment 'Portainer Agent'
    ufw allow 9000/tcp comment 'Portainer HTTP'
    ufw allow 9443/tcp comment 'Portainer HTTPS'
    
    log_info "UFW Regeln wurden hinzugefügt"
    ufw status verbose
fi

# Erstelle Docker Volume für Portainer
log_step "Erstelle Docker Volume für Portainer..."
docker volume create portainer_data || true

# Installiere Portainer Community Edition
log_step "Installiere Portainer Community Edition..."
docker run -d \
    --name=portainer \
    --restart=always \
    -p 8000:8000 \
    -p 9000:9000 \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest

# Warte bis Portainer startet
sleep 5

# Überprüfe ob Portainer läuft
if docker ps | grep -q portainer; then
    log_info "Portainer wurde erfolgreich installiert!"
else
    log_error "Portainer Installation fehlgeschlagen!"
    exit 1
fi

# Ermittle Server-IP-Adresse
SERVER_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
if [[ -z "$SERVER_IP" ]]; then
    SERVER_IP="localhost"
fi

# Docker Compose Beispiel erstellen
log_step "Erstelle Beispiel Docker Compose Datei..."
cat > /home/$ECHTER_BENUTZER/docker-compose-example.yml << EOF
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx-example
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    ports:
      - "9000:9000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: unless-stopped

volumes:
  portainer_data:
    external: true
EOF

chown $ECHTER_BENUTZER:$ECHTER_BENUTZER /home/$ECHTER_BENUTZER/docker-compose-example.yml 2>/dev/null || true

# Erstelle einfache Test-Webseite
mkdir -p /home/$ECHTER_BENUTZER/html 2>/dev/null || true
cat > /home/$ECHTER_BENUTZER/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Docker Testseite</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #0db7ed; }
        .container { max-width: 600px; margin: 0 auto; }
        .success { color: green; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Docker & Portainer erfolgreich installiert! 🎉</h1>
        <p>Diese Seite wird von einem Docker Container bereitgestellt.</p>
        <p class="success">✅ Installation erfolgreich abgeschlossen</p>
        <p>Zugriff auf Portainer: <strong>https://$SERVER_IP:9443</strong></p>
    </div>
</body>
</html>
EOF

chown -R $ECHTER_BENUTZER:$ECHTER_BENUTZER /home/$ECHTER_BENUTZER/html 2>/dev/null || true

# Starte Beispiel Container (optional)
log_step "Starte Beispiel Nginx Container..."
docker run -d \
    --name=nginx-example \
    --restart=unless-stopped \
    -p 8080:80 \
    -v /home/$ECHTER_BENUTZER/html:/usr/share/nginx/html \
    nginx:latest || true

# Abschlussbildschirm
echo ""
echo "============================================"
echo -e "${GRUEN}✅ Installation erfolgreich abgeschlossen!${NC}"
echo "============================================"
echo ""
echo -e "${BLAU}📦 Docker Informationen:${NC}"
echo "  Version: $(docker --version)"
echo "  Compose: $(docker compose version)"
echo "  Container Status:"
docker ps --format "  table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo -e "${BLAU}🌐 Portainer Zugang:${NC}"
echo "  HTTPS: https://${SERVER_IP}:9443"
echo "  HTTP:  http://${SERVER_IP}:9000"
echo "  Agent: http://${SERVER_IP}:8000"
echo ""
echo -e "${BLAU}📝 Wichtige Hinweise:${NC}"
if [[ "$ECHTER_BENUTZER" != "root" ]]; then
    echo "  1️⃣ Abmelden und erneut anmelden für Docker Gruppenrechte:"
    echo "     exit  # Ausloggen und neu verbinden"
    echo "     oder: newgrp docker"
fi
echo "  2️⃣ Portainer im Browser öffnen und Admin-Konto erstellen"
echo "  3️⃣ Firewall-Regeln wurden bei aktiver UFW konfiguriert"
echo "  4️⃣ Beispiel Nginx Container läuft auf Port 8080"
echo ""
echo -e "${BLAU}🔧 Nützliche Befehle:${NC}"
echo "  docker ps                    # Laufende Container anzeigen"
echo "  docker logs portainer        # Portainer Logs anzeigen"
echo "  docker stop nginx-example    # Beispiel Container stoppen"
echo "  docker compose -f docker-compose-example.yml up -d  # Beispiel starten"
echo ""
echo -e "${BLAU}📂 Erstellte Dateien:${NC}"
echo "  /home/$ECHTER_BENUTZER/docker-compose-example.yml  # Docker Compose Beispiel"
echo "  /home/$ECHTER_BENUTZER/html/                        # Beispiel Webseite"
echo ""
echo -e "${GELB}⚠️  Sicherheitshinweise:${NC}"
echo "  • Ändern Sie das Standard-Passwort für Portainer"
echo "  • Aktivieren Sie HTTPS für Produktivumgebungen"
echo "  • Konfigurieren Sie regelmäßige Backups"
echo ""
echo "============================================"
echo -e "${GRUEN}Viel Erfolg mit Docker und Portainer!${NC}"
echo "============================================"