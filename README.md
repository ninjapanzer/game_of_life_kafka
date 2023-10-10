# game_of_life_kafka
A Game of Life Variant where cell communication is handled by kafka streams

## In Development

This takes advantage of Nix to manage the Kafka dependencies. Once nix is installed, use `nix develop`

This will download and then start kafka with kraft in a subshell when the shell is exited the kafka cluster will shutdown.

__NOTE:__

> Because Nix Develop runs a shell script on each run we need to make resource maintenance idempotent.
> Kafka does this naturally as we can call server start on the same properties file over and over with no impact. But as we exit shells the trap to shutdown the server will depovision kafka early if there are multiple shells open.
> To make life simplier this will track open forks against the same project using the `nix.env.local` to track fork count on the same machine. When all shells are terminated kafka will then be shutdown. If you have other services that need to be deprovisioned during shutdown you can append them to the deprovision function in the `flake.nix`

## Running
start with `nix develop` and then run `bundle exec ruby main` to start the game of life server.

When you are done run `exit` to shutdown the kafka cluster.

## Sample
![Recording 2023-10-10 at 00 06 02](https://github.com/ninjapanzer/game_of_life_kafka/assets/159591/5fa6f127-8b7e-4a6d-a6bd-48f18208585d)
