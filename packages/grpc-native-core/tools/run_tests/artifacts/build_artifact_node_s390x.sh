#!/bin/bash
# Copyright 2017 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

# https://github.com/mapbox/node-pre-gyp/issues/362
npm install -g node-gyp

cd $(dirname $0)/../../..

rm -rf build || true

mkdir -p "${ARTIFACTS_OUT}"

npm update

node_versions=( 4.0.0 5.0.0 6.0.0 7.0.0 8.0.0 9.0.0 10.0.0 11.0.0 12.0.0 13.0.0 )

for version in ${node_versions[@]}
do
  # Cross compile for s390x on x64
  # Requires debian or ubuntu packages "g++-s390x-linux-gnu".
  CC=s390x-linux-gnu-gcc CXX=s390x-linux-gnu-g++ LD=s390x-linux-gnu-g++ ./node_modules/.bin/node-pre-gyp configure rebuild package testpackage --target=$version --target_arch=s390x
  cp -r build/stage/* "${ARTIFACTS_OUT}"/
done
