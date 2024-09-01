{ config, pkgs, ... }:

{
	imports = [
		./modules/fonts.nix
	];

	home.username = "poke";
	home.homeDirectory = "/home/poke";

	home.sessionVariables = {
		EDITOR = "nvim";
		BROWSER = "google-chrome";
		TERMINAL = "kitty";
		NPM_CONFIG_PREFIX="${config.home.homeDirectory}/.node_modules";
	};

	# GNOME settings
	dconf.settings = {
		"org/gnome/desktop/background" = {
			picture-uri = "file://${config.home.homeDirectory}/.wallpaper";
			picture-uri-dark = "file://${config.home.homeDirectory}/.wallpaper";
			picture-options = "zoom";
		};
		"org/gnome/desktop/interface" = {
			scaling-factor = 1;
			text-scaling-factor = 1.0;
			accent-color = "slate";
			color-scheme = "prefer-dark";
			monospace-font-name = "monospace 12";
			clock-format = "24h";
			clock-show-date = true;
			clock-show-seconds = true;
		};
		"org/gnome/mutter" = {
			edge-tiling = false;
			experimental-features = [ 
				"scale-monitor-framebuffer"
				"fractional-scale-mode"
				"xwayland-native-scaling"
			];
		};
		"org/gnome/desktop/peripherals/mouse" = {
			accel-profile = "flat";
		};
		"org/gnome/desktop/interface" = {
			enable-hot-corners = false;  # disable hot corners
		};
		"org/gnome/desktop/wm/preferences" = {
			button-layout = "";  # no window buttons
			resize-with-right-button = true;
		};
		"org/gnome/monitor/0" = {
			scale = 1.5;  # fractional scaling
		};

		# Keybindings
		"org/gnome/settings-daemon/plugins/media-keys" = {
			custom-keybindings = [
				"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
			];
		};
		"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
			name = "Launch Kitty";
			command = "kitty";
			binding = "<Super>t";
		};
		"org/gnome/desktop/wm/keybindings" = {
			close = [ "<Super>q" ];
		};

		# Apps
		"org/gnome/nautilus/icon-view" = {
			default-zoom-level = "small-plus";
		};
		"org/gnome/nautilus/list-view" = {
			default-zoom-level = "medium";
		};

		# Extensions
		"org/gnome/shell" = {
			disable-user-extensions = false;
			enabled-extensions = [
				"valent@andyholmes.github.io"
				"just-perfection-desktop@just-perfection"
				"disable-workspace-animation@ethnarque"
				"middleclickclose@paolo.tranquilli.gmail.com"
			];
		};
		"org/gnome/shell/extensions/just-perfection" = {
			dash = false;
			panel = false;
			panel-in-overview = true;
			search = false;
			workspace = true;
			workspace-switcher-size = 12;
		};
	};

	# Packages that should be installed to the user profile.
	home.packages = with pkgs; [
		#fastfetch # system information tool
		#yazi # terminal file manager

		# archives
		zip
		# xz
		unzip
		p7zip

		# utils
		#ripgrep # recursively searches directories for a regex pattern
		#jq # A lightweight and flexible command-line JSON processor
		#yq-go # yaml processor https://github.com/mikefarah/yq
		#fzf # A command-line fuzzy finder

		# networking tools
		#mtr # A network diagnostic tool
		#iperf3
		#dnsutils  # `dig` + `nslookup`
		#ldns # replacement of `dig`, it provide the command `drill`
		#aria2 # A lightweight multi-protocol & multi-source command-line download utility
		#socat # replacement of openbsd-netcat
		#nmap # A utility for network discovery and security auditing
		#ipcalc  # it is a calculator for the IPv4/v6 addresses

		# misc
		#cowsay
		#file
		#which
		#gnused
		#gnutar
		#gawk
		#zstd
		#gnupg

		# nix related
		#
		# it provides the command `nom` works just like `nix`
		# with more details log output
		nix-output-monitor

		#btop  # replacement of htop/nmon
		#iotop # io monitoring
		#iftop # network monitoring

		# system call monitoring
		#strace # system call monitoring
		#ltrace # library call monitoring
		#lsof # list open files

		# system tools
		#sysstat
		#lm_sensors # for `sensors` command
		#ethtool
		#pciutils # lspci
		#usbutils # lsusb

		# Desktop environment things
		dconf-editor
		gnome-tweaks
		gnomeExtensions.valent
		gnomeExtensions.just-perfection
		gnomeExtensions.disable-workspace-animation
		gnomeExtensions.middle-click-to-close-in-overview

		# Tools
		dconf2nix
		devenv # reproducible and composable developer environments
		pgcli # postgres command-line interface
		usql # universal command-line interface for sql databases
		dbmate # database migration tool
		# wgnord
		zoxide
		# Keyboard tools
		vial
		via

		# Programs
		google-chrome
		firefox
		brave
		vlc
		discord
		obs-studio
		# zed-editor
		# davinci-resolve
		audacity

		# Entertainment
		stremio
		# Gaming
		parsec-bin
	];

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias=true;
		vimAlias=true;
		vimdiffAlias=true;
		withNodeJs = true;
		withRuby = false;
		withPython3 = false;

		extraPackages = with pkgs; [
			xclip
			wl-clipboard
		];

	};

	programs.git = {
		enable = true;
		userName = "pokedotdev";
		userEmail = "git@poke.dev";
		extraConfig.init.defaultBranch = "main";
	};

	programs.kitty = {
		enable = true;
		theme = "Tokyo Night";
		font.name = "monospace";
		settings = {
			font_size = "12.5";
			font_features = true;
			adjust_line_height = "110%";
			remember_window_size = true;
			hide_window_decorations = true;
			shell_integration = "no-title";
			confirm_os_window_close = -0;
			copy_on_select = true;
			clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
		};
	};

	programs.wezterm = {
		enable = true;
		enableZshIntegration = true;
		extraConfig = ''
		return {
			window_decorations = "RESIZE",
			window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
			font = wezterm.font("monospace"),
			font_size = 14.0,
			color_scheme = "Tokyo Night",
			hide_tab_bar_if_only_one_tab = true,
			default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
			keys = {
				{key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
			}
		}
		'';
	};

	# starship - an customizable prompt for any shell
	programs.starship = {
		enable = true;
		settings = {
			format="$all\n$character";
			add_newline = false;
			aws.disabled = true;
			gcloud.disabled = true;
			line_break.disabled = true;
		};
	};

	programs.eza = {
		enable = true;
		enableZshIntegration = true;
		enableBashIntegration = true;
		icons = true;
		extraOptions = [];
	};

	programs.bash = {
		enable = true;
		enableCompletion = true;
		bashrcExtra = ''
		export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
		'';
	};

	programs.zsh = {
		enable = true;
		autocd = true;
		enableCompletion = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;

		shellAliases = {
			up = "bash ~/nix/update_nixos_hardware.sh";

			cat = "bat --theme=base16 --style=changes,numbers";
			v = "nvim";
			pg = "pgcli postgres://postgres:postgres@localhost:5432/postgres";

			# pnpm
			pn = "pnpm";
			pna = "pnpm add";
			pnad = "pnpm add --save-dev";
			pnap = "pnpm add --save-peer";
			pnau = "pnpm add --audit";
			pnb = "pnpm run build";
			pnc = "pnpm create";
			pnd = "pnpm run dev";
			pnga = "pnpm add --global";
			pngls = "pnpm list --global";
			pngrm = "pnpm remove --global";
			pngu = "pnpm update --global";
			pni = "pnpm init";
			pnin = "pnpm install";
			pnout = "pnpm outdated";
			pnrm = "pnpm remove";
			pnun = "pnpm uninstall";
			pnr = "pnpm run";
			pnx = "pnpm dlx";
		};
		history = {
			size = 10000;
			path = "${config.xdg.dataHome}/zsh/history";
		};
		oh-my-zsh = {
			enable = true;
			plugins = ["git"];
		};
	};
	home.file."nix/update_nixos_hardware.sh" = {
		source = ../update_nixos_hardware.sh;
		executable = true;
	};

	programs.vscode = {
		enable = false;
		extensions = with pkgs.vscode-extensions; [
			vscodevim.vim
			esbenp.prettier-vscode
			svelte.svelte-vscode
			# llam4u.nerdtree
			# aurum77.nerd-tree
		];
		userSettings = {
			"window.titleBarStyle" = "custom";
			"[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
			"[svelte]"."editor.defaultFormatter" = "svelte.svelte-vscode";
			"[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
			"[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
			"[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
			"breadcrumbs.enabled" = false;
			"editor.defaultFormatter" = "esbenp.prettier-vscode";
			"editor.fontFamily" = "monospace";
			"editor.fontSize" = 16;
			"editor.formatOnSave" = true;
			"editor.glyphMargin" = false;
			"editor.lineNumbers" = "off";
			"editor.linkedEditing" = true;
			"editor.minimap.enabled" = false;
			"editor.stickyScroll.enabled" = true;
			"editor.tabSize" = 4;
			"editor.wordWrap" = "on";
			"extensions.experimental.affinity" = {
				"vscodevim.vim" = 2;
			};
			"terminal.integrated.fontSize" = 16;
			"vim.easymotion" = true;
			"vim.surround" = true;
			"vim.foldfix" = true;
			"vim.hlsearch" = true;
			"vim.incsearch" = true;
			"vim.insertModeKeyBindings" = [
				{ "after" = ["<Esc>"]; "before" = ["j" "k"]; }
				{ "after" = ["<Esc>"]; "before" = ["k" "j"]; }
			];
			"vim.leader" = "<space>";
			"vim.visualModeKeyBindings" = [
				{ "after" = ["<leader>" "<leader>" "s"]; "before" = [";"]; }
			];
			"vim.normalModeKeyBindings" = [
				{ "after" = ["<leader>" "<leader>" "s"]; "before" = [";"]; }
				{ "before" = ["K"]; "commands" = ["editor.action.showHover"]; }
				{ "before" = ["leader" "q"]; "commands" = ["editor.action.quickFix"]; }
			];
			"vim.normalModeKeyBindingsNonRecursive" = [
				{ "after" = ["d" "d"]; "before" = ["<leader>" "d"]; }
				{ "before" = ["<C-n>"]; "commands" = [":nohl"]; }
			];
			"vim.useCtrlKeys" = true;
			"vim.useSystemClipboard" = true;
			"window.commandCenter" = false;
			"workbench.activityBar.location" = "top";
			"workbench.editor.showTabs" = "single";
			"workbench.fontAliasing" = "antialiased";
			"svelte.enable-ts-plugin" = true;
			"workbench.statusBar.visible" = true;

		};
	};

	programs.btop = {
		enable = true;
		settings = {
			color_theme = "TTY";
			theme_background = false;
			proc_gradient = false;
		};
	};

	# This value determines the home Manager release that your
	# configuration is compatible with. This helps avoid breakage
	# when a new home Manager release introduces backwards
	# incompatible changes.
	#
	# You can update home Manager without changing this value. See
	# the home Manager release notes for a list of state version
	# changes in each release.
	home.stateVersion = "24.05";

	# Let home Manager install and manage itself.
	programs.home-manager.enable = true;
}
