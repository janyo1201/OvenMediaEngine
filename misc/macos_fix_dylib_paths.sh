#!/bin/bash

install_name_tool -change /usr/local/lib/libopenh264.4.dylib "${PREFIX}/libopenh264.4.dylib" $1 || exit 1