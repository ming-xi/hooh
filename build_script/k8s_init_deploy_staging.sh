#!/bin/bash
cd ../build_config || exit
kubectl apply -f eks-crm-staging.yaml
kubectl apply -f eks-web-staging.yaml
cd ../build_script || exit
./k8s_print_info.sh

