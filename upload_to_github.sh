#!/bin/bash

# ============================================================
#  PhishGuard XAI — GitHub Upload Script
#  Usage: bash upload_to_github.sh
# ============================================================

set -e  # Exit immediately on error

# ── Colors ──────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║   PhishGuard XAI — GitHub Upload Script   ║"
echo "  ╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Collect user info ────────────────────────────────
echo -e "${YELLOW}📋 Enter your GitHub details:${NC}"
echo ""

read -p "  GitHub Username       : " GITHUB_USERNAME
read -p "  Repository Name       : " REPO_NAME
read -p "  Commit message        [Initial commit: PhishGuard XAI]: " COMMIT_MSG
COMMIT_MSG=${COMMIT_MSG:-"Initial commit: PhishGuard XAI"}

echo ""
echo -e "${YELLOW}🔐 Authentication method:${NC}"
echo "   1) HTTPS  (will prompt for token/password)"
echo "   2) SSH    (uses your SSH key)"
read -p "  Choose [1 or 2]: " AUTH_CHOICE

if [ "$AUTH_CHOICE" == "2" ]; then
    REMOTE_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
else
    REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Username  : ${GREEN}${GITHUB_USERNAME}${NC}"
echo -e "  Repo      : ${GREEN}${REPO_NAME}${NC}"
echo -e "  Remote    : ${GREEN}${REMOTE_URL}${NC}"
echo -e "  Message   : ${GREEN}${COMMIT_MSG}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "  Proceed? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}  Aborted.${NC}"
    exit 1
fi

# ── Step 2: Locate the project folder ───────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

echo ""
echo -e "${YELLOW}📂 Project folder: ${GREEN}${PROJECT_DIR}${NC}"
cd "$PROJECT_DIR"

# ── Step 3: Check git is installed ──────────────────────────
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌  git is not installed. Install it first: https://git-scm.com${NC}"
    exit 1
fi

# ── Step 4: Init git if not already done ────────────────────
if [ ! -d ".git" ]; then
    echo -e "\n${YELLOW}⚙️  Initialising git repository...${NC}"
    git init
    echo -e "${GREEN}  ✔ git init done${NC}"
else
    echo -e "\n${YELLOW}⚙️  Git repo already exists — skipping init${NC}"
fi

# ── Step 5: Stage all files ──────────────────────────────────
echo -e "\n${YELLOW}📦 Staging files...${NC}"
git add .
echo -e "${GREEN}  ✔ All files staged${NC}"

# ── Step 6: Commit ──────────────────────────────────────────
echo -e "\n${YELLOW}💬 Creating commit...${NC}"
# Configure a default identity if none is set
git config user.email 2>/dev/null || git config user.email "you@example.com"
git config user.name  2>/dev/null || git config user.name  "$GITHUB_USERNAME"

git commit -m "$COMMIT_MSG"
echo -e "${GREEN}  ✔ Committed: \"${COMMIT_MSG}\"${NC}"

# ── Step 7: Rename branch to main ───────────────────────────
git branch -M main

# ── Step 8: Add remote (or update if it exists) ──────────────
echo -e "\n${YELLOW}🔗 Setting remote origin...${NC}"
if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REMOTE_URL"
    echo -e "${GREEN}  ✔ Remote updated${NC}"
else
    git remote add origin "$REMOTE_URL"
    echo -e "${GREEN}  ✔ Remote added${NC}"
fi

# ── Step 9: Push ─────────────────────────────────────────────
echo ""
echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
echo -e "   ${BLUE}(If prompted, enter your GitHub token as the password)${NC}"
echo ""

git push -u origin main

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Upload complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  🌐 View your repo at:"
echo -e "     ${BLUE}https://github.com/${GITHUB_USERNAME}/${REPO_NAME}${NC}"
echo ""
echo -e "  📌 Next steps:"
echo -e "     • Add a repo description and topics on GitHub"
echo -e "     • Star your own repo ⭐"
echo -e "     • Share the link!"
echo ""
