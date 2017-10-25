#!/bin/bash
echo -e "\e[93mstoping minikube ...."
echo -e "\e[39m"
minikube stop
#
# echo -e "\e[93mstoping kafka and zookeeper ...."
# echo -e "\e[39m"
# kill -9  $(ps aux | grep 'kafka' | awk '{print $2}')
