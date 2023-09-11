{
  description = "My Kafka Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
      kafka = pkgs.apacheKafka;
    in {
      defaultPackage.x86_64-linux = kafka;
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "My-project build environment";
        buildInputs = [
          kafka
        ];
        shellHook = ''
          echo "Welcome in $name"
          KAFKA_CLUSTER_ID="$(kafka-storage.sh random-uuid)"
          kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c kraft.properties
          kafka-server-start.sh -daemon kraft.properties
          trap "kafka-server-stop.sh" EXIT
        '';
      };
    };
}
