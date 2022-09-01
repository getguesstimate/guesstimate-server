{

  description = "Flake for guesstimate-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }: {

    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ({ pkgs, ... }: {
            boot.isContainer = true;

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            system.stateVersion = "22.05";

            # Network configuration.
            networking.hostName = "pgdbCont";
            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [ 5432 ];
            networking.firewall.allowPing = true;

            users.users.guesstimateapi = {
              group = "pgUser";
              isSystemUser = true;
              extraGroups = [ "wheel" "networkmanager" ];
            };

            # Enable a web server.
            services.postgresql = {
              enable = true;
              package = pkgs.postgresql_14;
              enableTCPIP = true;
              initialScript = pkgs.writeText "backend-initScript" ''
                CREATE USER "guesstimate-api" WITH PASSWORD 'password';
                ALTER USER "guesstimate-api" CREATEDB;
                '';
              authentication = pkgs.lib.mkOverride 10 ''
                local all all trust
                host all all 127.0.0.1/32 trust
                host all all ::1/128 trust
                host all all 10.233.1.1 trust
                '';

            };
          })
        ];
    };

    devShell.x86_64-linux =
      let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
      with pkgs; mkShell { buildInputs = [ bundler ruby bundix postgresql_14 nodejs glibc ]; };
  # };
  };
}
