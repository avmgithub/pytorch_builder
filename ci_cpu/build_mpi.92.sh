#!/bin/bash

set -xe

./build_nimbix_with_scipy_92.sh  pytorch HEAD master foo ${PYTHON_VERSION} LINUX ${BUILD_ONLY}
