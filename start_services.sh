#!/bin/bash
echo -e "\e[92mstarting minikube..."
echo -e "\e[39m"
# minikube start --vm-driver=xhyve

# echo ""
# echo -e "\e[92mexposing minikube..."
# echo -e "\e[39m"
# kubectl proxy --port=4000 &
# echo "done, port 4000"

echo ""
echo -e "\e[92mstarting zookeeper and kafka..."
echo -e "\e[39m"
cd kafka

bin/zookeeper-server-start.sh config/zookeeper.properties  2>&1 > /tmp/zoo.log  &
bin/kafka-server-start.sh config/server.properties 2>&1 > /tmp/kafka.log &

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic kudesktop
cd ..
echo "done"
