{ pkgs, ... }:

let
	defaultMono = "GitLab Mono";
in
{
	fonts.fontconfig.enable = true;

	home.packages = with pkgs; [
		jetbrains-mono
		(nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "JetBrainsMono" ]; })
		(stdenv.mkDerivation {
			name = "gitlab-mono";
			src = fetchurl {
				url = "https://gitlab-org.gitlab.io/frontend/fonts/fonts/GitLabMono.ttf";
				sha256 = "08bkfn76x05aylqmixxkky2wv5m3f14rabzcz6n48knjdmqncfkl";
			};
			dontUnpack = true;
			installPhase = ''
				mkdir -p $out/share/fonts/truetype
				cp $src $out/share/fonts/truetype/GitLabMono.ttf
			'';
		})
	];

	fonts.fontconfig.defaultFonts = {
		monospace =  [defaultMono "Symbols Nerd Font Mono"];
	};

	xdg.configFile."fontconfig/conf.d/99-nerd-font-symbol-fallback.conf".text = ''
		<?xml version="1.0"?>
		<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
		<fontconfig>
		<alias>
			<family>${defaultMono}</family>
			<prefer>
			<family>${defaultMono}</family>
			<family>Symbols Nerd Font Mono</family>
			</prefer>
		</alias>
		</fontconfig>
	'';
}
