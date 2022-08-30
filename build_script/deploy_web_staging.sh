#!/bin/bash
cd ../web || exit
if ! flutter build web -t lib/main_staging.dart --release; then
    echo "web build error"
    exit
fi
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com
cd ..
if ! docker build -f build_config/WebDockerfile --build-arg ROOT_DIR=web/build -t hooh-web:staging-latest .; then
    echo "docker image build error"
    exit
fi

docker tag hooh-web:staging-latest 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com/hooh-web:staging-latest

if ! docker push 040439641041.dkr.ecr.ap-southeast-1.amazonaws.com/hooh-web:staging-latest; then
    echo "docker push error"
    exit
fi
cd build_script || exit
./k8s_update_deploy_web_staging.sh