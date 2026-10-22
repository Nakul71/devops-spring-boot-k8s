#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# Provide a robust Maven Wrapper launcher
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
WRAPPER_PROPERTIES="$DIR/.mvn/wrapper/maven-wrapper.properties"

if [ -f "$WRAPPER_PROPERTIES" ]; then
    DIST_URL=$(grep 'distributionUrl=' "$WRAPPER_PROPERTIES" | cut -d'=' -f2-)
else
    DIST_URL="https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip"
fi

MAVEN_USER_HOME="${MAVEN_USER_HOME:-$HOME/.m2}"
MAVEN_VERSION=$(echo "$DIST_URL" | sed -E 's/.*apache-maven-([0-9.]+)-bin\.zip/\1/')
MAVEN_DIR="$MAVEN_USER_HOME/wrapper/dists/apache-maven-$MAVEN_VERSION"
MAVEN_EXEC="$MAVEN_DIR/apache-maven-$MAVEN_VERSION/bin/mvn"

if [ ! -x "$MAVEN_EXEC" ]; then
    echo "Downloading Maven $MAVEN_VERSION..."
    mkdir -p "$MAVEN_DIR"
    ZIP_FILE="$MAVEN_DIR/maven.zip"
    if which curl >/dev/null 2>&1; then
        curl -fsSL "$DIST_URL" -o "$ZIP_FILE"
    elif which wget >/dev/null 2>&1; then
        wget -q "$DIST_URL" -O "$ZIP_FILE"
    else
        echo "Error: curl or wget is required to download Maven."
        exit 1
    fi
    unzip -q -o "$ZIP_FILE" -d "$MAVEN_DIR"
    rm -f "$ZIP_FILE"
    chmod +x "$MAVEN_EXEC"
fi

exec "$MAVEN_EXEC" "$@"
