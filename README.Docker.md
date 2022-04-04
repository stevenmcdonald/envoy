
Quick start:
============

First some warnings:

* since this runs as root, it WILL leave files in your chromium source directory owned by root. You may need to `sudo chown` them back to use with your host tools.
* this WILL NOT update your depot_tools, `DEPOT_TOOLS_UPDATE=0` is set by default in the environment.

If you already have the chromium source, skip to "Running" below.

Getting the code:
-----------------

git clone https://github.com/greatfire/envoy.git

git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git

Add depot_tools to your path, e.g: export PATH="$PATH:`pwd`/depot_tools"

```
mkdir chromium && cd chromium
fetch --no-history android
```

You can do the rest in Docker, but the git operations might be faster on the host. You can start the Docker container first or run this in the host:

```
git fetch origin "refs/tags/87.0.4280.66:refs/tags/87.0.4280.66" --verbose
git checkout -B 87.0.4280.66 tags/87.0.4280.66
git clean -ffd
git checkout .
```

Alternatively, you can use the `checkout-to-tag.sh` script:

```
cd /build/envoy/native
./checkout-to-tag.sh
```

Running:
--------

```
docker pull stevenmcdonald/greatfire-envoy-build
docker run -it -v /path/to/chromium:/build/chromium -v /path/to/depot_tools:/build/depot_tools -v /path/to/envoy:/build/envoy stevenmcdonald/greatfire-envoy-build
```

On non-x86 platforms, like m1 macs, add `--platform linux/amd64`, eg:

```
docker run -it -v /path/to/chromium:/build/chromium -v /path/to/depot_tools:/build/depot_tools -v /path/to/envoy:/build/envoy --platform linux/amd64 stevenmcdonald/greatfire-envoy-build
``` 

this should drop you in to `/build/envoy` as root.


Building:
---------

Cronet:

```
cd /build/envoy/native
./build_cronet.sh release
./build_cronet.sh debug
```

Envoy:

```
cd /build/envoy/android
./build-envoy.sh release
./build-envoy.sh debug
```

