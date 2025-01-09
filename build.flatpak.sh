#!/bin/bash
# Script to build, test, and package a Flatpak
# Author: josejp2424
# Get the current user's home directory dynamically
USER_HOME=$(eval echo ~$SUDO_USER) # Get the home directory of the user running the script
# Path configuration
REPO_PATH="$USER_HOME/.local/share/flatpak/repo"        # Repository path for the current user
CONFIG_PATH="$USER_HOME/midori-flatpak/flathub.json" # Path to the JSON configuration file
OUTPUT_PATH="$USER_HOME/midori-flatpak/io.astian.midori.flatpak" # Output path for the .flatpak file
BUILD_DIR="$USER_HOME/midori-flatpak/build"            # Temporary build directory
# Function to install appstream and additional dependencies depending on the distro
install_appstream() {
    DISTRO=$(lsb_release -si 2>/dev/null || echo "unknown")

    case "$DISTRO" in
        "Ubuntu" | "Debian" | "devuan")
            echo "Detected Debian/Ubuntu-based system. Installing appstream and required dependencies..."
            sudo apt update
            sudo apt install -y appstream gir1.2-appstream libappstream-glib-dev appstream-util appstream-generator
            ;;
        "Fedora")
            echo "Detected Fedora. Installing appstream and required dependencies..."
            sudo dnf install -y appstream appstream-glib appstream-generator
            ;;
        "openSUSE")
            echo "Detected openSUSE. Installing appstream and required dependencies..."
            sudo zypper install -y appstream appstream-glib appstream-generator
            ;;
        "Arch" | "Manjaro")
            echo "Detected Arch-based system. Installing appstream and required dependencies..."
            sudo pacman -Syu --noconfirm appstream appstream-glib appstream-generator
            ;;
        "Slackware")
            echo "Detected Slackware. Installing appstream and required dependencies..."
            echo "Please manually install appstream and related packages on Slackware."
            exit 1
            ;;
        *)
            echo "Unknown distribution. Cannot install appstream automatically."
            exit 1
            ;;
    esac
}
# Check if appstream is installed
if ! command -v appstream &>/dev/null; then
    echo "appstream is not installed. Trying to install it..."
    install_appstream
else
    echo "appstream is already installed."
fi
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: The configuration file does not exist at $CONFIG_PATH"
    exit 1
fi
if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi
# Add the Flathub repository if it does not exist
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Install the required Flatpak runtimes and SDK
echo "Installing necessary Flatpak runtimes and SDK..."
flatpak install --user -y flathub org.freedesktop.Platform//24.08
flatpak install --user -y flathub org.freedesktop.Sdk//24.08
# Build the application
echo "Building the application with flatpak-builder..."
flatpak-builder --repo="$REPO_PATH" --force-clean "$BUILD_DIR" "$CONFIG_PATH" \
    --install-deps-from=flathub --ccache
if [ $? -ne 0 ]; then
    echo "Error: Build failed with flatpak-builder."
    exit 1
fi
# Generate the .flatpak file
echo "Generating the .flatpak file..."
flatpak build-bundle "$REPO_PATH" "$OUTPUT_PATH" io.astian.midori --runtime-repo=https://dl.flathub.org/repo/

if [ $? -eq 0 ]; then
    echo "The .flatpak file was successfully created at $OUTPUT_PATH"
else
    echo "Error: Could not generate the .flatpak file"
    exit 1
fi
# Install and test the application locally
echo "Installing and testing the application..."
flatpak install --user -y "$REPO_PATH" io.astian.midori
if [ $? -eq 0 ]; then
    echo "Application installed successfully. Running it now..."
    flatpak run io.astian.midori
else
    echo "Error: Could not install the application."
    exit 1
fi
echo "Process completed successfully."
