#!/bin/bash
cd ../build_config || exit
kubectl apply -f eks-crm-production.yaml
kubectl apply -f eks-web-production.yaml
cd ../build_script || exit
./k8s_print_info.sh

