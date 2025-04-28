#!/bin/bash

# =========================
# 🛠️ CONFIGURATION SECTION
# =========================
BACKUP_DIR="./env-backup"       # Directory where backup files are
VENV_DIR="myenv"                # Name of your virtual environment
PYTHON_BIN="python3"            # Python binary
SYSTEM_PACKAGES=("python3-opencv" "libatlas-base-dev" "libjasper-dev" "libqtgui4" "libqt4-test")  # System packages needed
EXPECTED_PYTHON_VERSION="3.9"   # Expected python version from old setup (adjust if needed)

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

echo -e "${BLUE}=== 🔍 Detecting System Info ===${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${YELLOW}System:${NC} $PRETTY_NAME"
fi

if [ -f /proc/device-tree/model ]; then
    MODEL=$(tr -d '\0' </proc/device-tree/model)
    echo -e "${YELLOW}Device:${NC} $MODEL"
fi

echo -e "${BLUE}=== 🧪 Checking Python Version ===${NC}"
INSTALLED_PYTHON_VERSION=$($PYTHON_BIN -c 'import platform; print(platform.python_version())')

if [[ $INSTALLED_PYTHON_VERSION == $EXPECTED_PYTHON_VERSION* ]]; then
    echo -e "${GREEN}✅ Python version $INSTALLED_PYTHON_VERSION matches expected $EXPECTED_PYTHON_VERSION${NC}"
else
    echo -e "${RED}⚠️ Python version mismatch! Installed: $INSTALLED_PYTHON_VERSION, Expected: $EXPECTED_PYTHON_VERSION${NC}"
    echo -e "${YELLOW}Proceeding anyway, but watch for package issues.${NC}"
fi

echo -e "${BLUE}=== 🧰 Installing missing system packages ===${NC}"
for pkg in "${SYSTEM_PACKAGES[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $pkg already installed.${NC}"
    else
        echo -e "${YELLOW}📦 Installing $pkg...${NC}"
        sudo apt-get update
        sudo apt-get install -y "$pkg"
    fi
done

echo -e "${BLUE}=== 🏗️  Creating Virtual Environment ($VENV_DIR) ===${NC}"
$PYTHON_BIN -m venv --system-site-packages $VENV_DIR

echo -e "${BLUE}=== 🔥 Activating Virtual Environment ===${NC}"
source $VENV_DIR/bin/activate

echo -e "${BLUE}=== 🚀 Upgrading pip ===${NC}"
pip install --upgrade pip

echo -e "${BLUE}=== 📜 Installing Python packages from backup ===${NC}"
pip install --no-cache-dir -r $BACKUP_DIR/venv-requirements.txt

echo -e "${BLUE}=== 🌎 Restoring Environment Variables (Temporary Session) ===${NC}"
if [ -f "$BACKUP_DIR/environment-variables.txt" ]; then
    set -o allexport
    source "$BACKUP_DIR/environment-variables.txt"
    set +o allexport
    echo -e "${GREEN}✅ Environment variables loaded.${NC}"
else
    echo -e "${RED}⚠️ No environment variables file found.${NC}"
fi

echo -e "${BLUE}=== 📋 Installing System Site Packages from Backup ===${NC}"
if [ -f "$BACKUP_DIR/system-site-packages.txt" ]; then
    while IFS= read -r package; do
        echo -e "${YELLOW}📦 Installing system site package: $package...${NC}"
        pip install --no-cache-dir "$package"
    done < "$BACKUP_DIR/system-site-packages.txt"
    echo -e "${GREEN}✅ System site packages restored.${NC}"
else
    echo -e "${RED}⚠️ No system-site-packages.txt file found.${NC}"
fi

echo -e "${BLUE}=== 📋 Verifying Installed Python Packages ===${NC}"
pip list

echo -e "${GREEN}=== 🎉 Environment recreation completed successfully! ===${NC}"
echo ""
echo -e "${YELLOW}🔔 REMINDER:${NC}"
echo "- Run ${BLUE}source $VENV_DIR/bin/activate${NC} before using your environment."
echo "- If you face system lib issues, manually install missing apt packages."
