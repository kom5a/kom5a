#!/bin/bash

# === CONFIGURATION INITIALE ===
LOG_FILE="$HOME/sparta-log.txt"
BACKUP_FILE="$HOME/sparta-backup.txt"
ERROR_LOG="$HOME/sparta-error.log"
SPARTA_DIR="/c/Users/Administrateur/spartacus/"
REPO_GIT="https://github.com/kom5a/kom5a.git"
PYTHON_PATH="/c/Users/Administrateur/AppData/Local/Programs/Python/Python311/"
API_KEY="NOUVELLE_CLE_API"

# Vérifier si le dossier SPARTA existe
if [ ! -d "$SPARTA_DIR" ]; then
    echo "🚨 Dossier SPARTA introuvable à $SPARTA_DIR ! Vérifiez l'emplacement." | tee -a $LOG_FILE
    exit 1
fi

# === LOGGING FUNCTION ===
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

error_log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a $ERROR_LOG
}

log "🚀 Démarrage du script d'automatisation SPARTA"

# === FIX API OPENAI ===
log "🔍 Vérification du quota OpenAI API..."
export OPENAI_API_KEY="$API_KEY"
echo 'export OPENAI_API_KEY="$API_KEY"' >> ~/.bashrc
source ~/.bashrc

python -c "import openai; print(openai.Model.list())" 2>&1 | tee -a $LOG_FILE || error_log "Problème avec OpenAI API"
if grep -q "insufficient_quota" $LOG_FILE; then
    error_log "🚨 Quota OpenAI insuffisant. Une nouvelle clé API est nécessaire."
fi

# === FIX PYTHON ===
log "🔍 Correction de Python et ajout au PATH..."
export PATH=$PATH:$PYTHON_PATH
echo 'export PATH=$PATH:$PYTHON_PATH' >> ~/.bashrc
source ~/.bashrc
python --version | tee -a $LOG_FILE || error_log "Python non détecté"
pip --version | tee -a $LOG_FILE || error_log "Pip non détecté"

# === FIX SSH ===
log "🔍 Vérification et relance du service SSH..."
sudo service ssh restart || error_log "Impossible de redémarrer SSH"
ssh -o StrictHostKeyChecking=no -p 2222 localhost | tee -a $LOG_FILE || error_log "Connexion SSH refusée"

# === FIX GIT & REPO ===
log "🔍 Synchronisation avec le repo GitHub..."
git config --global user.name "SPARTA"
git config --global user.email "sparta@kom5a.com"
cd "$SPARTA_DIR"
git pull origin main --rebase || error_log "Échec du rebase Git"
git add . || error_log "Erreur lors de l'ajout des fichiers Git"
git commit -m "Synchronisation avec le repo distant" || error_log "Échec du commit Git"
git push origin main || error_log "Échec du push Git"

# === FIX NEXT.JS & NPM ===
log "🔍 Installation de Next.js et correction des dépendances..."
npx create-next-app@latest kom5a --use-npm --force || error_log "Échec de l'installation Next.js"
cd kom5a
npm install tailwindcss postcss autoprefixer || error_log "Échec de l'installation de Tailwind"
npx tailwindcss init || error_log "Échec de l'initialisation de Tailwind"
npm run build | tee -a $LOG_FILE || error_log "Échec du build Next.js"

# === ACTIVER SPARTA ===
log "🚀 Activation de SPARTA en tâche de fond..."
nohup $SPARTA_DIR/monitor-sparta.sh > $SPARTA_DIR/sparta-log.txt 2>&1 & || error_log "Échec du démarrage de SPARTA"

# === SAUVEGARDE AUTOMATIQUE ===
log "💾 Sauvegarde automatique dans GitHub & Supabase..."
echo "Dernière sauvegarde: $(date)" >> $BACKUP_FILE
git add sparta-log.txt sparta-backup.txt || error_log "Échec de l'ajout des logs à Git"
git commit -m "Mise à jour SPARTA - $(date)" || error_log "Échec du commit des logs"
git push origin main || error_log "Échec du push des logs"

log "✅ SPARTA est actif et intégré dans le développement. Mission accomplie ! 🚀🔥"
