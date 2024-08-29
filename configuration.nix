# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
	imports = [
		./hardware-configuration.nix
	];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "machine"; # Define your hostname.
	# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	# Set your time zone.
	time.timeZone = "America/Hermosillo";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	# X11 windowing system.
	services.xserver = {
		enable = true;
		displayManager.gdm.enable = true;
		desktopManager = {
			gnome.enable = true;
			# plasma6.enable = false;
		};
	};

	environment.gnome.excludePackages = (with pkgs; [
		gnome-photos
		gnome-tour
		cheese # webcam tool
		gedit # text editor
		epiphany # web browser
		geary # email reader
		yelp # help view
		# totem # video player
		gnome-terminal
		# gnome-console
		xterm
	]) ++ (with pkgs.gnome; [
		# gnome-music
		gnome-contacts
		# evince # document viewer
		# gnome-characters
		tali # poker game
		iagno # go game
		hitori # sudoku game
		atomix # puzzle game
	]);
	
	# Resolver el conflicto de SSH askPassword with KDE 6
	programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
	# programs.ssh.askPassword = lib.mkForce "${pkgs.plasma5Packages.ksshaskpass}/bin/ksshaskpass";


	# fix wayland scale
	environment.sessionVariables = {
		# TERMINAL = "kitty";
		# NIXOS_OZONE_WL = "1";
		# XDG_SESSION_TYPE = "wayland";
		# GDK_BACKEND = "wayland";
		# GTK_USE_PORTAL = "1";
		# QT_QPA_PLATFORMTHEME = "qt5ct";
		# QT_QPA_PLATFORM = "wayland";
		# QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
		# QT_AUTO_SCREEN_SCALE_FACTOR = "1";
		# MOZ_ENABLE_WAYLAND = "1";
	};

	# Configure keymap in X11
	services.xserver = {
		xkb.layout = "us";
		xkb.variant = "";
	};

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound with pipewire.
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	nix = {
		settings.experimental-features = ["nix-command" "flakes"];
		settings.auto-optimise-store = true;
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 14d";
		};
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# xbox controller drivers
	hardware.xone.enable = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# xbox controller drivers
		linuxKernel.packages.linux_zen.xone

		libsForQt5.qt5ct

		git
		vim
		wget
		curl
		tmux
		yazi
		bat
		eza
		fastfetch
		# Dev
		fzf
		fd
		ripgrep
		lazygit
		delta

		# Languages
		# c/c++ toolchain
		gcc
		clang
		# ---
		rustup
		go
		lua
		nodejs
		nodejs.pkgs.pnpm
		bun

		# Python
		python310Full
		# python310.pkgs.pip
		# python310.pkgs.requests
		# python310.pkgs.beautifulsoup4
		# python3.pkgs.tk

		# Dev tools
		dbmate

		# Desktop environment things
		# gnome-tweaks
		# gnomeExtensions.valent
		# gnomeExtensions.pop-shell
		# gnomeExtensions.unite
		# ulauncher # launcher

		# Here, the helix package is installed from the helix input data source
		# inputs.helix.packages."${pkgs.system}".helix

		# programs
    	vmware-workstation
		wine # 32 bits
		wine64 # 64 bits
	];

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.poke = {
		isNormalUser = true;
		description = "poke";
		extraGroups = [ "networkmanager" "wheel" "docker" ];
		openssh.authorizedKeys.keys = [];
		# packages = with pkgs; [];
		#shell = pkgs.zsh;
	};

	fonts.packages = with pkgs; [
		jetbrains-mono
		(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
	];
	
	# Default shell
	programs.zsh.enable = true;
	users.defaultUserShell = pkgs.zsh;
	environment.shells = with pkgs; [ zsh ];
	
	# remove extras like: java
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};
	
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	# Virtualisation

	virtualisation.vmware.host.enable = true;

	virtualisation.docker.enable = true;
	virtualisation.docker.rootless = {
		enable = true;
		setSocketVariable = true;
	};

	# List services that you want to enable:

	# Service to start
	systemd.user.services.ulauncher = {
		enable = true;
		description = "Start Ulauncher";
		script = "${pkgs.ulauncher}/bin/ulauncher --hide-window";

		documentation = [ "https://github.com/Ulauncher/Ulauncher/blob/f0905b9a9cabb342f9c29d0e9efd3ba4d0fa456e/contrib/systemd/ulauncher.service" ];
		wantedBy = [ "graphical.target" "multi-user.target" ];
		after = [ "display-manager.service" ];
	};

	# services.flatpak.enable = true;
	# systemd.services.flatpak-repo = {
	#   wantedBy = [ "multi-user.target" ];
	#   path = [ pkgs.flatpak ];
	#   script = ''
	#     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	#   '';
	# };

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		settings = {
			X11Forwarding = true;
			PermitRootLogin = "no"; # disable root login
			PasswordAuthentication = false; # disable password login
		};
		openFirewall = true;
	};

	# support via and vial
	services.udev.packages = with pkgs; [ vial via ];

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	#valent ports
	networking.firewall = rec {
		allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
		allowedUDPPortRanges = allowedTCPPortRanges;
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "24.05"; # Did you read the comment?

}
