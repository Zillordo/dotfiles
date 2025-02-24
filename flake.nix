{
  description = "Home Manager and NixOS configuration of Allan";

  outputs = { self, home-manager, nixpkgs, zen-browser, unstable, ... }@inputs:
    let
      username = "allank";
      hostname = "nixos";
      system = "x86_64-linux";
      overlays = [ inputs.neovim-nightly-overlay.overlays.default ];
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstablePkgs = import unstable {
        inherit system;
        config.allowUnfree = true;
      };
      asztal = pkgs.callPackage ./dotfiles/ags { inherit inputs; };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username hostname;
          asztal = self.packages.${system}.default;
          unstable = unstablePkgs;
        };
        modules = [ ./nixos/configuration.nix ];
      };

      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs username asztal system; };
          modules =
            [ ./home-manager/home.nix { nixpkgs.overlays = overlays; } ];
        };

      packages.${system}.default = asztal;
    };

  inputs = {
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    ghostty = { url = "github:ghostty-org/ghostty"; };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    matugen.url = "github:InioX/matugen";
    ags.url = "github:Aylur/ags/v1";
    astal.url = "github:Aylur/astal";
    stm.url = "github:Aylur/stm";

    lf-icons = {
      url = "github:gokcehan/lf";
      flake = false;
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
  };
}
