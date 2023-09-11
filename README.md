# game_of_life_kafka
A Game of Life Variant where cell communication is handled by kafka streams

## In Development

This takes advantage of Nix to manage the Kafka dependencies. Once nix is installed, use `nix develop`

This will download and then start kafka with kraft in a subshell when the shell is exited the kafka cluster will shutdown.
