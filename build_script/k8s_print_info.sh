#!/bin/bash
echo '::Nodes'
kubectl get nodes -n hooh-crm -o wide
echo '::crm'
kubectl get all -n hooh-crm
kubectl get pods -n hooh-crm -o wide
kubectl get ingress -n hooh-crm --output=wide
echo '::web'
kubectl get all -n hooh-web
kubectl get pods -n hooh-web -o wide
kubectl get ingress -n hooh-web --output=wide
