#!/bin/bash
cd ../crm || exit
if ! flutter build web -t lib/main_staging.dart --release; then
    echo "crm build error"
    exit
fi
if ! docker build -f ../build_config/CrmDockerfile --build-arg ROOT_DIR=build --build-arg SCRIPT_DIR=. -t hooh-crm:staging-latest .; then
    echo "docker image build error"
    exit
fi

docker tag hooh-crm:staging-latest registry-intl.ap-southeast-1.aliyuncs.com/hooh/hooh-crm:staging-latest

if ! docker push registry-intl.ap-southeast-1.aliyuncs.com/hooh/hooh-crm:staging-latest; then
    echo "docker push error"
    exit
fi
##!/bin/bash
#cd ../crm || exit
#if ! flutter build web -t lib/main_staging.dart --release; then
#    echo "crm build error"
#    exit
#fi
#aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com
#cd ..
#if ! docker build -f build_config/CrmDockerfile --build-arg ROOT_DIR=crm/build -t hooh-crm:staging-latest .; then
#    echo "docker image build error"
#    exit
#fi
#
#docker tag hooh-crm:staging-latest 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com/hooh-crm:staging-latest
#
#if ! docker push 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com/hooh-crm:staging-latest; then
#    echo "docker push error"
#    exit
#fi
#cd build_script || exit
#./k8s_update_deploy_crm_staging.sh

