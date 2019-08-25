#!/bin/bash

for (( c=1; c<$1; c++ ))
do
echo -n "core-test-$c " >> allnodes.txt

echo -n "$(cat seeds/core-test-$c | sed '2!d')" >> allnodes.txt
echo -n "," >> allnodes.txt
seed=$(cat seeds/core-test-$c | sed '1!d')
sed '/export[[:blank:]]*self_node_name=/ s/IIIself_node_nameIII/'"\"core-test-$c\""'/g' .setup-env.sh.TMPL >> setup.$c
sed '/export[[:blank:]]*self_node_seed=/ s/IIIself_node_seedIII/'"\"$seed\""'/g' setup.$c >> setup-env-a.$c
rm setup.$c
done
echo -n "core-test-$1 " >> allnodes.txt
echo -n "$(cat seeds/core-test-$1 | sed '2!d')" >> allnodes.txt

seed=$(cat seeds/core-test-$1 | sed '1!d')
sed '/export[[:blank:]]*self_node_name=/ s/IIIself_node_nameIII/'"\"core-test-$1\""'/g' .setup-env.sh.TMPL >> setup.$1
sed '/export[[:blank:]]*self_node_seed=/ s/IIIself_node_seedIII/'"\"$seed\""'/g' setup.$1 >> setup-env-a.$1
rm setup.$1
##########################################
allnodes=$(cat allnodes.txt)
for (( c=1; c<=$1; c++ ))
do
sed '/export[[:blank:]]*all_nodes=/ s/IIIall_nodesIII/'"$allnodes"'/g' setup-env-a.$c >> setup-env.$c
rm setup-env-a.$c
done

sed '/export[[:blank:]]*self_node_name=/ s/IIIself_node_nameIII/'"\"core-watcher-1\""'/g' .setup-watcher.sh.TMPL >> watcher-setup.1
sed '/export[[:blank:]]*self_node_seed=/ s/IIIself_node_seedIII/'"\"$seed\""'/g' watcher-setup.1 >> setup-env-watcher.1
sed '/export[[:blank:]]*all_nodes=/ s/IIIall_nodesIII/'"$allnodes"'/g' setup-env-watcher.1 >> setup-env.watcher

rm watcher-setup.1
rm setup-env-watcher.1

rm allnodes.txt


for (( c=1; c<=$1; c++ ))
do
sed 's/III/'"$c"'/g' core-ec2-lb-tmpl > ../core-ec2-lb-$c.tf
done

#Prometheus init

echo "sudo chown  ubuntu:ubuntu /var/run/docker.sock" >> prometheus-env
echo "sudo chown ubuntu:ubuntu /data/prometheus/make-conf.sh" >> prometheus-env
echo "sudo chown /data/prometheus/prometheus.yml.TMPL" >> prometheus-env
echo "sudo chown /data/prometheus/prometheus.yml.TMPL2" >> prometheus-env
echo  "cp /data/prometheus/prometheus.yml.TMPL2 /data/prometheus/prometheus.yml.TMPL" >> prometheus-env 
echo  "sudo bash /data/prometheus/make-conf.sh $1 " >> prometheus-env

