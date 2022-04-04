#!/bin/bash -x

set -euo pipefail

BUILD_VARIANT=${1:-release}

/build/envoy/native/build_cronet.sh $BUILD_VARIANT

