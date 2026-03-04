#!/usr/bin/env bash
# Script to run Xyce in a Docker container

set -eoux pipefail

# /usr/bin/docker run --rm -i -t --user 1000:1000 -v $HOME:$HOME -w $(pwd) --network host \
#     --security-opt seccomp=unconfined ghcr.io/siliconplatformslab/xyce:master Xyce "$@"

nix run github:fossi-foundation/nix-eda#xyce -- "$@"
