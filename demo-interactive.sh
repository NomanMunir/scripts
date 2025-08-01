#!/bin/bash

#==============================================================================
# Interactive Software Selection Demo
# Demo script to showcase the new checkbox-style CLI interface
#==============================================================================

# Check if terminal supports colors
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1 && [[ $(tput colors) -ge 8 ]]; then
    # Colors for terminals that support them
    readonly GREEN="\033[32m"
    readonly CYAN="\033[36m"
    readonly RED="\033[31m"
    readonly YELLOW="\033[33m"
    readonly BLUE="\033[34m"
    readonly PURPLE="\033[35m"
    readonly WHITE="\033[37m"
    readonly BOLD="\033[1m"
    readonly DIM="\033[2m"
    readonly RESET="\033[0m"
else
    # No colors for terminals that don't support them
    readonly GREEN=""
    readonly CYAN=""
    readonly RED=""
    readonly YELLOW=""
    readonly BLUE=""
    readonly PURPLE=""
    readonly WHITE=""
    readonly BOLD=""
    readonly DIM=""
    readonly RESET=""
fi

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                    New Interactive Features Demo                     ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo

echo -e "${BOLD}${GREEN}🎯 New Interactive Software Selection Interface${RESET}"
echo
echo -e "${CYAN}Features:${RESET}"
echo -e "  ${GREEN}✓${RESET} Checkbox-style interface for multiple selections"
echo -e "  ${GREEN}✓${RESET} Category-based filtering (development, browsers, databases, etc.)"
echo -e "  ${GREEN}✓${RESET} Vim-style navigation (j/k) and arrow keys"
echo -e "  ${GREEN}✓${RESET} Visual progress indicators with descriptions"
echo -e "  ${GREEN}✓${RESET} Bulk operations (select all/none)"
echo -e "  ${GREEN}✓${RESET} Real-time selection counter"
echo

echo -e "${BOLD}${YELLOW}🎮 Navigation Controls:${RESET}"
echo -e "  ${YELLOW}↑/↓${RESET} or ${YELLOW}k/j${RESET}: Navigate through software list"
echo -e "  ${YELLOW}Space${RESET}: Toggle selection (✓/✗)"
echo -e "  ${YELLOW}Enter${RESET}: Confirm selections and proceed"
echo -e "  ${YELLOW}a${RESET}: Select all visible items"
echo -e "  ${YELLOW}n${RESET}: Deselect all items"
echo -e "  ${YELLOW}c${RESET}: Filter by category"
echo -e "  ${YELLOW}q${RESET}: Quit selection"
echo

echo -e "${BOLD}${PURPLE}📦 Available Software Categories:${RESET}"
echo -e "  ${BLUE}[development]${RESET} Git, VS Code, Docker, Node.js, Python, Rust, Go, Java"
echo -e "  ${GREEN}[browsers]${RESET} Chrome, Firefox, Microsoft Edge"
echo -e "  ${PURPLE}[databases]${RESET} MySQL/MariaDB, PostgreSQL, MongoDB, Redis"
echo -e "  ${CYAN}[multimedia]${RESET} VLC, GIMP, OBS Studio"
echo -e "  ${YELLOW}[communication]${RESET} Slack, Discord, Microsoft Teams"
echo -e "  ${WHITE}[utils]${RESET} htop, neofetch, tmux, Zsh + Oh My Zsh"
echo -e "  ${RED}[security]${RESET} UFW Firewall, Fail2Ban, SSH Server"
echo

echo -e "${BOLD}${CYAN}🚀 How to Use:${RESET}"
echo -e "1. Run the setup script: ${BOLD}sudo ./linux/setup-dev.sh${RESET}"
echo -e "2. Choose '🎯' or type 'interactive' when prompted"
echo -e "3. Use the interactive interface to select your software"
echo -e "4. Press Enter to confirm and start installation"
echo

echo -e "${BOLD}${GREEN}💡 Benefits over the old system:${RESET}"
echo -e "  ${GREEN}✓${RESET} No more going through each software one by one"
echo -e "  ${GREEN}✓${RESET} See all options at once with descriptions"
echo -e "  ${GREEN}✓${RESET} Filter by category to find what you need quickly"
echo -e "  ${GREEN}✓${RESET} Multiple selections in one go"
echo -e "  ${GREEN}✓${RESET} Modern, intuitive interface"
echo

echo -e "${YELLOW}Ready to try it? Run: ${BOLD}sudo ./linux/setup-dev.sh${RESET} and select the interactive option!"
