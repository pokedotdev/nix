{ config, pkgs, ... }:

{
	fonts.fontconfig.enable = true;

	home.packages = with pkgs; [
		jetbrains-mono
		(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
		(stdenv.mkDerivation {
			name = "gitlab-fonts";
			src = fetchFromGitLab {
				owner = "gitlab-org";
				repo = "frontend/fonts";
				rev = "main";
				sha256 = "03iy7rjlsmf63cbgdxpg7y71x5wkavl59z98j7vfybnrmvc1qrv0";
			};
			installPhase = ''
				mkdir -p $out/share/fonts/truetype
				cp -R $src/*.ttf $out/share/fonts/truetype/
			'';
		})
	];
}
