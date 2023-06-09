#!/bin/sh
# Copyright 2018 gRPC authors.
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
cd $(dirname $0)/../..
base_dir=$(pwd)

pip install mako
pip install pyyaml
./packages/grpc-native-core/tools/buildgen/generate_projects.sh

OS=`uname`

case $OS in
Linux)
    docker build -t kokoro-native-image tools/release/native
    docker build -t kokoro-cross-image tools/release/cross
    docker run -v /var/run/docker.sock:/var/run/docker.sock -v $base_dir:$base_dir kokoro-native-image $base_dir/packages/grpc-native-core/tools/run_tests/artifacts/build_all_linux_artifacts.sh --native-only --nodejs-only
    cp -rv packages/grpc-native-core/artifacts .
    docker run -v /var/run/docker.sock:/var/run/docker.sock -v $base_dir:$base_dir kokoro-cross-image $base_dir/packages/grpc-native-core/tools/run_tests/artifacts/build_all_linux_artifacts.sh --cross-only --nodejs-only
    cp -rv packages/grpc-native-core/artifacts .
    ;;
Darwin)
    JOBS=8 ARTIFACTS_OUT=$base_dir/artifacts ./packages/grpc-native-core/tools/run_tests/artifacts/build_artifact_node.sh
    ;;
esac
