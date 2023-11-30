#!/bin/bash

externalip=$(kubectl get svc --all-namespaces -o jsonpath='{range.items[?(@.status.loadBalancer.ingress)]}{.status.loadBalancer.ingress[*].ip}')

helm registry login --username=$1 --password=$2 harbor.$externalip.sslip.io

helm push hipster-shop-0.1.0.tgz oci://harbor.$externalip.sslip.io/library

helm push frontend-0.1.0.tgz oci://harbor.$externalip.sslip.io/library
