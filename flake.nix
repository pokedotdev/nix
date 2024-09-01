{
	description = "A simple NixOS flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
		nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

		home-manager.url = "github:nix-community/home-manager/master"; # release-24.05"
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		gnomeNixpkgs.url = "github:NixOS/nixpkgs/gnome";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-stable, home-manager, gnomeNixpkgs, ... }@inputs: {
		# Hostname config
		nixosConfigurations = {
			machine = nixpkgs.lib.nixosSystem rec {
				system = "x86_64-linux";
				# Set all inputs parameters as special arguments for all submodules
				specialArgs = { 
					inherit inputs;
					pkgs-unstable = import nixpkgs-unstable {
						inherit system;
						config.allowUnfree = true;
					};
					pkgs-stable = import nixpkgs-stable {
						inherit system;
						config.allowUnfree = true;
					};
				};
				modules = [
					# Lastest gnome version
					# {
					# 	nixpkgs.overlays = [
					# 		(self: super: {
					# 			gnome = gnomeNixpkgs.legacyPackages.x86_64-linux.gnome;
					# 		})
					# 	];
					# }
					
					# Import configuration.nix
					./configuration.nix

					# make home-manager as a module of nixos
					# so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.poke = import ./home;
						# Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
						home-manager.extraSpecialArgs = { inherit inputs; };
					}

					# This module works the same as the `specialArgs` parameter we used above
					# { _module.args = { inherit inputs; };}
				];
			};
		};
	};
}
