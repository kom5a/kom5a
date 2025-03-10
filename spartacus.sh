#!/bin/bash

# === CONFIGURATION INITIALE ===
LOG_FILE="$HOME/spartacus-log.txt"
ERROR_LOG="$HOME/spartacus-error.log"
SPARTACUS_DIR="/mnt/c/Users/Administrateur/kom5a/spartacus/"
GITHUB_TOKEN="GITHUB_SECRET_KEY"
VERCEL_TOKEN="VERCEL_SECRET_KEY"
SUPABASE_URL="https://xyzcompany.supabase.co"
SUPABASE_KEY="SUPABASE_SECRET_KEY"
SECRET_CODE="KOM5A_2025"
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

# === FONCTION APPEL OPENAI ===
call_openai_api() {
    local prompt="$1"
    local response=$(curl -s https://api.openai.com/v1/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "model": "gpt-4",
            "messages": [{"role": "user", "content": "'"$prompt"'"}],
            "temperature": 0.7
        }')

    echo "🔹 Réponse OpenAI :"
    echo "$response" | jq '.choices[0].message.content'
}

# === SYNCHRONISATION & REPARATION ===
sync_git_repo() {
    log "🔄 Synchronisation avec GitHub..."
    cd "$SPARTACUS_DIR" || { error_log "Dossier SPARTACUS introuvable !"; exit 1; }
    git pull origin main --rebase
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

# === LANCEMENT DES SERVICES ===
start_services() {
    log "🚀 Démarrage des services : Supabase, Vercel et Docker..."
    supabase start || error_log "⚠ Erreur lors du démarrage de Supabase"
    vercel deploy || error_log "⚠ Erreur lors du déploiement sur Vercel"
    docker-compose up -d || error_log "⚠ Erreur lors du démarrage de Docker"
}

# === MODE SURVEILLANCE INTELLIGENTE ===
monitor_errors() {
    log "👀 Mode surveillance activé..."
    tail -f "$ERROR_LOG" | while read line; do
        if echo "$line" | grep -q "ERROR"; then
            error_log "⚠ Erreur détectée, tentative de correction..."
            call_openai_api "Comment corriger cette erreur : $line"
        fi
    done
}

# === INTERFACE UTILISATEUR ===
while true; do
    clear
    echo "🔹 SPARTACUS - Le Maître du Digital 🔹"
    echo "---------------------------------------"
    echo "1) Vérifier et réparer le système"
    echo "2) Synchroniser le repo GitHub"
    echo "3) Lancer les services (Supabase, Vercel, Docker)"
    echo "4) Activer le monitoring intelligent avec OpenAI"
    echo "5) Tester OpenAI"
    echo "6) Quitter"
    echo "---------------------------------------"
    read -p "Votre choix : " CHOIX
    
    case $CHOIX in
        1) repair_system ;;
        2) sync_git_repo ;;
        3) start_services ;;
        4) monitor_errors ;;
        5) 
            read -p "Entrez votre question pour OpenAI : " prompt
            call_openai_api "$prompt"
            ;;
        6) exit 0 ;;
        *) echo "⛔ Choix invalide !" ;;
    esac
    sleep 2
done

