#!/bin/bash

set -e

# Create a temporary directory and store its name in a variable ...
TMPDIR=$(mktemp -d)

# Bail out if the temp directory wasn't created successfully.
if [ ! -e $TMPDIR ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi

# Make sure it gets removed even if the script exits abnormally.
trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$TMPDIR"' EXIT

git clone https://github.com/gentoo/gentoo $TMPDIR
pushd $TMPDIR
SHA=$(git rev-parse origin/master)
popd

d=`date +%Y%m%d`

echo "Generating portage spec for $d - $SHA"
basedir=$ROOT_DIR/overlays/portage/0.$d

mkdir -p $basedir

mottainai-cli task compile "$ROOT_DIR"/templates/portage.yaml.tmpl \
                            -s LayerCategory="layer" \
                            -s LayerVersion=0.1 \
                            -s LayerName="base" \
                            -s Commit="$SHA" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="portage" \
                                -o $basedir/definition.yaml

basedir=$ROOT_DIR/overlays/sabayon-build-overlays/portage/0.$d

mkdir -p $basedir

mottainai-cli task compile "$ROOT_DIR"/templates/portage.yaml.tmpl \
                            -s LayerCategory="layer" \
                            -s LayerVersion=0.1 \
                            -s LayerName="build" \
                            -s Commit="$SHA" \
                            -o $basedir/build.yaml

mottainai-cli task compile "$ROOT_DIR"/templates/definition.yaml.tmpl \
                                -s PackageCategory="layer" \
                                -s PackageVersion="0.$d" \
                                -s PackageName="sabayon-build-portage" \
                                -o $basedir/definition.yaml
