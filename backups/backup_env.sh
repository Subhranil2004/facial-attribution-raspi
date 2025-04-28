#!/bin/bash

# =========================
# 🛠️ CONFIGURATION SECTION
# =========================
BACKUP_DIR="./env-backup"   # Where to save backup
VENV_DIR=".venv"            # Your virtual environment name
PYTHON_BIN="python3"        # Python binary

# =========================
# 🎨 COLOR DEFINITIONS
# =========================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =========================
# 🚀 SCRIPT STARTS HERE
# =========================

echo -e "${BLUE}=== 🔥 Starting backup of environment ===${NC}"

# Check if venv exists
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}❌ Virtual environment '$VENV_DIR' not found. Aborting.${NC}"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}=== 📜 Freezing pip packages ===${NC}"
source $VENV_DIR/bin/activate
pip freeze > "$BACKUP_DIR/venv-requirements.txt"

# save system-site-packages
echo -e "${BLUE}=== 📦 Saving system site packages ===${NC}"

SITE_PACKAGES = $(python -c "import site; print('\n'.join(site.getsitepackages()))")
for path in $SITE_PACKAGES
do
	pip list --path "$path" >> "$BACKUP_DIR/system-site-packages.txt"
done



echo -e "${BLUE}=== 🌎 Saving environment variables ===${NC}"
printenv > "$BACKUP_DIR/environment-variables.txt"



# save python version
python --version > "$BACKUP_DIR/python-version.txt"

# save dependency tree
pipdeptree > "$BACKUP_DIR/dependency-tree.txt"

# Tar everything into a single file
echo -e "${BLUE}=== 📦 Packing backup into tar.gz ===${NC}"
tar -czvf env-backup.tar.gz "$BACKUP_DIR"
echo -e "${GREEN}✅ Backup created successfully: env-backup.tar.gz${NC}"
