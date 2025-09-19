#!/bin/bash
ANDROID_ROOT="$HOME/android/lineage"
PATCH_DIR="${BASH_SOURCE%/*}"

git -C "$ANDROID_ROOT/hardware/qcom-caf/sdm845/audio/hal" am < "$PATCH_DIR/0001-PNX-Remove-conflicting-vendor-libraries.patch"
