#!/usr/bin/env bash
# 
# Bootstrap script for setting up a new macOS machine
# Script for macOS Catalina (10.15)
# 
# This should be idempotent so it can be run multiple times.
#
# Some apps don't have a cask and so still need to be installed by hand. These
# include:
#
# - Adobe Lightroom Classic (install from Creative Cloud)
# - TamperMonkey scripts to enhance the FUT 20 Web App: https://github.com/Mardaneus86/futwebapp-tampermonkey
# - Logitech Options (bug with caskfile - report a bug!)
# - Canon MX925 drivers + IJ Scan Utility
# - Brewlet: https://github.com/zkokaja/Brewlet
#

echo "Starting bootstrapping"

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
#    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update homebrew recipes
brew update

# Install apps with Brew
brew bundle --file ~/Brewfile.newMac 

echo "Configuring macOS..."

# Enable dock auto-hide and reduce delay
defaults write com.apple.dock autohide -int 1
defaults write com.apple.dock autohide-time-modifier -int 0

# Show Bluetooth, Volume icon in menu bar
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/Volume.menu"

# Show battery percentage in menu bar
defaults write com.apple.menuextra.battery ShowPercent YES

# Apply format for date & time in menu bar
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"

# Restart processes
killall Dock
killall SystemUIServer

echo "Bootstrapping complete"