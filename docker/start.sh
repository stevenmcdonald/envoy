#!/bin/bash

set -e

[[ ! -d "$CHROMIUM_SRC_ROOT" ]] && echo "chromium directory not mounted!" && exit 1
#[[ ! -d "$DEPOT_TOOLS_ROOT" ]] && echo "depot_tools directory not mounted!" && exit 2
[[ ! -d /build/envoy ]] && echo "envoy directory not mounted!" && exit 3

#/usr/sbin/icecc-scheduler -d -vvv -l /tmp/icecc-scheduler.log

cd /build/envoy
exec /bin/bash
