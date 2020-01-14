#!/bin/sh

DS_PROFILE=docker
CONF_DIR=/custom-config
REGISTRY_URL=consul://edgex-core-consul:8500

docker run --rm -v ~/.docker/config.json:/root/.docker/config.json -v /var/run/docker.sock:/var/run/docker.sock \
        -v ${WORK_DIR}:${WORK_DIR} -w ${WORK_DIR}/TAF/utils/scripts/edgexpert \
        --env WORK_DIR=${WORK_DIR} --env PROFILE=${PROFILE}  \
        --env DS_PROFILE=${DS_PROFILE} --env CONF_DIR=${CONF_DIR} --env REGISTRY_URL=${REGISTRY_URL} \
        iotechsys/dev-testing-edgexpertcli:1.6.0.dev \
        pull