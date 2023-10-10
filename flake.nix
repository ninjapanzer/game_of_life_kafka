{
  description = "My Kafka Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
      kafka = pkgs.apacheKafka;
      ruby = pkgs.ruby_3_2;
      buf = pkgs.buf;
      protoc = pkgs.protobuf;
    in {
      defaultPackage.x86_64-linux = kafka;
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "My-project build environment";
        buildInputs = [
          kafka
          ruby
          buf
          protoc
        ];
        shellHook = ''
          touch nix.env.local
          handle_shell() {
            local reason="$1"
            if [ "$reason" = "register" ]; then
              awk -F= '/^fork_count=/ {$2 = $2 + 1} {print $1 "=" $2}' nix.env.local > tmp_nix.env.local
            elif [ "$reason" = "unregister" ]; then
              awk -F= '/^fork_count=/ {$2 = $2 - 1} {print $1 "=" $2}' nix.env.local > tmp_nix.env.local
            fi
            cat tmp_nix.env.local
            if [ -f tmp_nix.env.local ]; then
              mv tmp_nix.env.local nix.env.local
            fi
          }

          no_more_shells() {
            fork_count=$(grep '^fork_count=' nix.env.local | cut -d= -f2)
            if [ "$fork_count" -eq 0 ]; then
              is_zero=0
            else
              is_zero=1
            fi

            echo $is_zero
          }

          deprovision() {
            handle_shell "unregister"
            shell_count=$(no_more_shells)
            if [ "$shell_count" -eq 0 ]; then
              echo "Last Shell Closing Shutting Kafka Down"
              kafka-server-stop.sh
            fi
          }

          handle_shell "register"
          echo "Welcome in $name"
          KAFKA_CLUSTER_ID="$(kafka-storage.sh random-uuid)"
          kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c kraft.properties
          kafka-server-start.sh -daemon kraft.properties

          trap deprovision EXIT
          bundle install
        '';
      };
    };
}
