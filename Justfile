# This is a Justfile to setup my custom apps
# and fine tune some settings. I was initially
# created to be used with a Project Bluefin, 
# a fedora Silverblue based distro

set unstable

# List of files that shold be installed
user_apps := "
	com.nextcloud.desktopclient.nextcloud
	org.keepassxc.KeePassXC
	md.obsidian.Obsidian
	org.inkscape.Inkscape
	org.libreoffice.LibreOffice
	be.alexandervanhee.gradia
	com.jgraph.drawio.desktop
	im.riot.Riot
	nl.hjdskes.gcolor3
	org.gitfourchette.gitfourchette
	net.ankiweb.Anki
"

wallpapers_repo := "https://github.com/elementary/wallpapers.git"
wallpapers_dir  := "$HOME/.local/share/backgrounds"

# default
default:
	just --list

# install flatpaks
install-apps:
	@echo "#### Flatpak App Installer ###"
	@for app in {{ replace(replace(user_apps, "\n", " "), "  ", " ") }}; do just install-app "$app"; done
	@echo "#### Installation finished ###"


# Download nice wallpapers from ElementaryOS
install-wallpapers:
	#!/usr/bin/env bash
	set -euo pipefail
	dest="{{ wallpapers_dir }}"
	mkdir -p "$dest"
	if [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
		echo "✓ Wallpapers folder is not empty, skipping."
		exit 0
	fi
	echo "### Downloading Wallpapers ###"
	tmp=$(mktemp -d)
	trap "rm -rf $tmp" EXIT
	echo "→ Cloning repository..."
	git clone --depth=1 {{ wallpapers_repo }} "$tmp/wallpapers"
	echo "→ Moving wallpapers to $dest..."
	mv "$tmp/wallpapers/backgrounds/"* "$dest/"
	echo "✓ Wallpapers installed to $dest"


# Check if a flatpak app is installed
[private]
[no-exit-message]
is-installed app:
    @flatpak list --app --columns=application | grep -q "^{{app}}$"


# Install a single app if not already installed
[private]
install-app app:
    @if just is-installed {{app}}; then \
        echo "✓ {{app}} is already installed, skipping."; \
    else \
        echo "→ Installing {{app}}..."; \
        flatpak install --assumeyes flathub {{app}} && \
        echo "✓ {{app}} installed successfully." || \
        echo "✗ Failed to install {{app}}."; \
    fi

