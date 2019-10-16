#!/usr/bin/env bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Variables

if [[ $OSTYPE == "linux-gnu" && $CLOUD_SHELL == true ]]; then

    export PROJECT=$(gcloud config get-value project)
    export BASE_DIR=${BASE_DIR:="${PWD}"}
    export WORK_DIR=${WORK_DIR:="${BASE_DIR}/workdir"}

    echo "WORK_DIR set to $WORK_DIR"
    gcloud config set project $PROJECT

    source ./common/settings.env
    ./common/install-tools.sh
    echo -e "\nMultiple tasks are running asynchronously to setup your environment.  It may appear frozen, but you can check the logs in $WORK_DIR for additional details in another terminal window."

    ./gke/provision-gke.sh &> ${WORK_DIR}/provision-gke.log &
    ./connect-hub/provision-remote-gce.sh &> ${WORK_DIR}/provision-remote.log &
    wait

    kubectx gcp && ./config-management/install-config-operator.sh
    kubectx onprem && ./config-management/install-config-operator.sh

    ./hybrid-multicluster/istio-install.sh

    ./service-mesh/enable-service-mesh.sh

else
    echo "This has only been tested in GCP Cloud Shell.  Only Linux (debian) is supported".
fi
