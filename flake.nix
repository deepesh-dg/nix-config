{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.tmux
          pkgs.curl
          # pkgs.libgcc
          pkgs.git
          pkgs.go
          pkgs.nodejs
          pkgs.ollama
          pkgs.openssl
          pkgs.pnpm

          #casks packages
          # pkgs.obs-studio
          pkgs.obsidian
          # pkgs.bitwarden-desktop
          pkgs.vscode
          # pkgs.protonvpn-gui
          # pkgs.anydesk
          pkgs.telegram-desktop
          # pkgs.spotify
          # pkgs.vlc
          pkgs.audacity
          # pkgs.blender
          # pkgs.filezilla
          pkgs.docker_27
          pkgs.zoom-us
          # pkgs.firefox
          # pkgs.brave
          # pkgs.handbrake
          pkgs.postman
          pkgs.discord
          pkgs.slack
        ];

        homebrew = {
          enable = true;
          brews = [
            "mas"
          ];
          casks = [
            "the-unarchiver"
            "iriunwebcam"
            "darktable"
            "figma"
            "wave"
            "canva"
            "inkscape"
            "airdroid"
          ];
          onActivation.cleanup = "zap";
          masApps = {
            "WhatsApp" = 310633997;
            "CleanMyMac" = 1339170533;
            "telegram" = 747648890;
            "DaVinciResolve" = 571213070;
            "Dropover" = 1355679052;
          };
        };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#air-m1
    darwinConfigurations."air-m1" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
             # Apple Silicon Only
             enableRosetta = true;
             # User owning the homebrew prefix
             user = "deepesh";

             autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."air-m1".pkgs;
  };
}
