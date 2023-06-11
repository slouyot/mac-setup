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
# - Canon MX925 drivers + IJ Scan Utility
# - Brewlet: https://github.com/zkokaja/Brewlet
#

# Reminder to connect to Mac App Store
read -p "Are you connected to the Mac App Store (yes/no)? " response
if test "$response" = "no"; then
	echo "Please sign in and come back!"
	exit
fi

echo "Starting bootstrapping"

# Add hombrew to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Check if we are running on an Apple Silicon chipset and install Rosetta 2
if [ "$(uname -m)" = "arm64" ]; then
    echo "Running on ARM, installing Rosetta 2..."
    sudo softwareupdate --install-rosetta
else
    echo "No Rosetta 2 needed here."
fi

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
#    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update homebrew recipes
brew update

# Install apps with Brew
brew bundle --file ./Brewfile.newMac 

# Start Brew autoupdate with upgrade
#echo "Starts Brew autoupdate..."
#brew autoupdate start --upgrade
echo "**** Start a Brew upgrade once script is finished ****"

# Create folder structure
echo "Creating folder structure..."
[[ ! -d ~/Projects ]] && mkdir ~/Projects
[[ ! -d ~/Pictures/Screenshots ]] && mkdir ~/Pictures/Screenshots

# Configure shell
echo "Configuring shell..."
cp ./zshrc.newMac ~/.zshrc
chmod 600 ~/.zshrc

# Configure system settings
echo "Configuring macOS..."

# Enable dock auto-hide and reduce delay
defaults write com.apple.dock "autohide" -bool "true"
defaults write com.apple.dock "autohide-time-modifier" -float "0"

# Show Bluetooth, Volume icon in menu bar - Deprecated on macOS 12 Monterey
#defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/Volume.menu"

# Show battery percentage in menu bar - Deprecated on macOS 12 Monterey
#defaults write com.apple.menuextra.battery ShowPercent YES

# Apply format for date & time in menu bar
defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\""

# Customize Finder
defaults write com.apple.finder "ShowPathbar" -bool "true"
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"

# Set up default folder for screenshots
defaults write com.apple.screencapture "location" -string "~/Pictures/Screenshots"

# Enforce TextEdit saving format to TXT (no rich text)
defaults write com.apple.TextEdit "RichText" -bool "false"

# Cisco Webex - prevent from starting at launch
defaults write com.cisco.webexmeetingsapp "PTLaunchAtLogin" -float "0"

# Spotify - prevent from starting at launch
defaults write com.spotify.client "AutoStartSettingIsHidden" -float "0"

# Restart processes
killall Dock
killall Finder
killall SystemUIServer
killall TextEdit

echo "Bootstrapping complete"
