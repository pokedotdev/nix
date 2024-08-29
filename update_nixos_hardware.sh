#!/usr/bin/env bash

# Directory configuration
NIXOS_CONFIG_DIR="$(dirname "$(readlink -f "$0")")"
HARDWARE_CONFIG="$NIXOS_CONFIG_DIR/hardware-configuration.nix"
BACKUP_DIR="$NIXOS_CONFIG_DIR/backups"
LOG_FILE="$NIXOS_CONFIG_DIR/update_log.txt"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if we're in a git repository
is_git_repo() {
	git -C "$NIXOS_CONFIG_DIR" rev-parse --is-inside-work-tree &>/dev/null
}

# Function to commit changes
git_commit() {
	local message="$1"
	git -C "$NIXOS_CONFIG_DIR" add .
	git -C "$NIXOS_CONFIG_DIR" commit -m "$message"
}

# Create timestamp-based backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/hardware-configuration_$TIMESTAMP.nix"

log_message "Starting NixOS update and hardware-configuration.nix management"

# Create backup
cp "$HARDWARE_CONFIG" "$BACKUP_FILE"
log_message "Backup created: $BACKUP_FILE"

# Check if we're in a git repository
if is_git_repo; then
	log_message "Git repository detected"

	# Check for uncommitted changes
	if [[ -n $(git -C "$NIXOS_CONFIG_DIR" status -s) ]]; then
		log_message "Uncommitted changes detected"
		read -p "There are uncommitted changes. Do you want to commit them before updating? (y/n): " commit_response
		if [[ $commit_response =~ ^[Yy]$ ]]; then
			git_commit "Pre-update commit: $(date)"
			log_message "Uncommitted changes committed"
		else
			log_message "Proceeding with uncommitted changes"
		fi
	fi
else
	log_message "Not a Git repository. Version control operations will be skipped."
fi

# Update NixOS
log_message "Starting NixOS update"
sudo nixos-rebuild switch
if [ $? -eq 0 ]; then
	log_message "NixOS update completed successfully"
else
	log_message "Error during NixOS update"
	exit 1
fi

# Compare files
log_message "Comparing hardware configuration files"
diff "$HARDWARE_CONFIG" "$BACKUP_FILE" >"$NIXOS_CONFIG_DIR/hardware_changes.diff"

if [ -s "$NIXOS_CONFIG_DIR/hardware_changes.diff" ]; then
	log_message "Changes detected in hardware-configuration.nix"

	# Show changes
	echo "Changes detected in hardware-configuration.nix:"
	cat "$NIXOS_CONFIG_DIR/hardware_changes.diff"

	# Ask user if they want to keep the changes
	read -p "Do you want to keep these changes? (y/n): " response
	if [[ $response =~ ^[Yy]$ ]]; then
		log_message "Changes in hardware-configuration.nix kept"
		if is_git_repo; then
			git_commit "Update hardware-configuration.nix: $(date)"
			log_message "Changes committed to Git"
		fi
	else
		log_message "Reverting changes in hardware-configuration.nix"
		cp "$BACKUP_FILE" "$HARDWARE_CONFIG"
		if is_git_repo; then
			git_commit "Revert changes in hardware-configuration.nix: $(date)"
			log_message "Revert committed to Git"
		fi
	fi
else
	log_message "No changes detected in hardware-configuration.nix"
fi

# Clean up temporary files
rm "$NIXOS_CONFIG_DIR/hardware_changes.diff"

log_message "Update and management process completed"

echo "Process completed. Check the log at $LOG_FILE for more details."
