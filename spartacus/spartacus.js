#!/bin/bash

# === CONFIGURATION INITIALE ===
LOG_FILE="$HOME/spartacus-log.txt"
ERROR_LOG="$HOME/spartacus-error.log"
SECURE_DIR="$HOME/spartacus_secure/"
SPARTACUS_DIR="/mnt/c/Users/Administrateur/spartacus/"
REPO_GIT="https://github.com/kom5a/kom5a.git"
PYTHON_PATH="/usr/bin/python3"
API_KEY="NOUVELLE_CLE_API"
SUPABASE_URL="https://xyzcompany.supabase.co"
SUPABASE_KEY="SUPABASE_SECRET_KEY"
SECRET_CODE="KOM5A_2025"
GITHUB_TOKEN="GITHUB_SECRET_KEY"
VERCEL_TOKEN="VERCEL_SECRET_KEY"
DEBUG_MODE=true

# === FONCTIONS UTILITAIRES ===
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

error_log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a "$ERROR_LOG"
}

debug_log() {
    if [ "$DEBUG_MODE" = true ]; then
        echo "$(date +'%Y-%m-%d %H:%M:%S') - DEBUG: $1" | tee -a "$LOG_FILE"
    fi
}

retry_command() {
    local cmd="$1"
    local max_attempts=3
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if eval "$cmd"; then
            log "✅ Commande réussie : $cmd"
            return 0
        else
            attempt=$((attempt + 1))
            error_log "⚠ Échec de la commande ($attempt/$max_attempts) : $cmd"
            sleep 5
        fi
    done
    error_log "🚨 Échec définitif après $max_attempts tentatives : $cmd"
    return 1
}

self_update() {
    log "🔄 Vérification des mises à jour du script..."
    cd "$SPARTACUS_DIR" || { error_log "Dossier SPARTACUS introuvable !"; exit 1; }
    git fetch origin main
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
        log "🆕 Nouvelle version disponible. Mise à jour..."
        git reset --hard origin/main
        log "✅ Script mis à jour avec succès."
    fi
}

repair_system() {
    log "🔧 Vérification et réparation du système..."
    for cmd in node npm python3 git; do
        if ! command -v "$cmd" &> /dev/null; then
            log "🛠 Installation de $cmd..."
            sudo apt-get install -y "$cmd" || error_log "Échec de l'installation de $cmd"
        else
            log "✅ $cmd est installé."
        fi
    done
}

sync_git_repo() {
    log "🔄 Synchronisation avec GitHub..."
    cd "$SPARTACUS_DIR" || { error_log "Dossier SPARTACUS introuvable !"; exit 1; }
    retry_command "git pull origin main --rebase"
}

configure_environment() {
    log "⚙ Configuration des variables d'environnement..."
    export OPENAI_API_KEY="$API_KEY"
    export SUPABASE_URL="$SUPABASE_URL"
    export SUPABASE_KEY="$SUPABASE_KEY"
    export GITHUB_TOKEN="$GITHUB_TOKEN"
    export VERCEL_TOKEN="$VERCEL_TOKEN"
    log "✅ Variables configurées."
}

monitor_system() {
    log "👀 Mode surveillance activé..."
    tail -f "$ERROR_LOG" | while read line; do
        if echo "$line" | grep -q "ERROR"; then
            error_log "⚠ Erreur détectée, tentative de correction..."
            repair_system
        fi
    done
}

send_notification() {
    local message="$1"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" https://hooks.slack.com/services/XXXXXXXXX/YYYYYYYYY/ZZZZZZZZZZZZZZZZZZZZZZZZ
}

# === MENU INTERACTIF ===
while true; do
    clear
    echo "🔹 SPARTACUS - Le Maître du Digital 🔹"
    echo "---------------------------------------"
    echo "1) Vérifier et réparer le système"
    echo "2) Synchroniser le repo GitHub"
    echo "3) Mettre à jour les variables d’environnement"
    echo "4) Activer le monitoring en temps réel"
    echo "5) Quitter"
    echo "---------------------------------------"
    read -p "Votre choix : " CHOIX
    
    case $CHOIX in
        1) repair_system ;;
        2) sync_git_repo ;;
        3) configure_environment ;;
        4) monitor_system ;;
        5) exit 0 ;;
        *) echo "⛔ Choix invalide !" ;;
    esac
    sleep 2
done

