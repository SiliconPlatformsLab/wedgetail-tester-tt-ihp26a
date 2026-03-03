#!/usr/bin/env fish
set -x PDK_ROOT ~/.ciel/ihp-sg13g2

nix run github:fossi-foundation/nix-eda#magic -- \
    -rcfile ~/.ciel/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc \
    -noconsole \
    -dnull \
    magic_gds2lef.tcl

