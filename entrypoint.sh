#/bin/ash

set -e

if [ -z "$NAME" ]; then
	NAME=$(cat /etc/hostname)
fi

echo NAME: "${NAME}"

if [ -z "$INITIAL_IP" ]; then
	INITIAL_IP=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
fi

echo ETCD_INITIAL_IP: "${INITIAL_IP}"

if [ -z "$INITIAL_CLUSTER" ]; then
	echo -e "Please specify initial cluster environment names and IPs\nformat: INITIAL_CLUSTER=\"name01=yyy.yyy.yyy name02=xxx.xxx.xxx name03=zzz.zzz.zzz\"\n" > /dev/stderr
	exit 1;
fi

if [ -z "$TOKEN" ]; then
	length=50
	CLUSTER_TOKEN=$(tr -dc A-Za-z0-9 </dev/random | head -c ${length} ; echo '')
	echo "You didn't specified a ETCD_CLUSTER_TOKEN which is the initial cluster token, so I've genereted one for you: ${TOKEN}"
fi

CLUSTER=""

for node in $INITIAL_CLUSTER; do
	if [ "$CLUSTER" == "" ]; then
		CLUSTER=$(echo ${node} | cut -d = -f 1)=http://$(echo ${node} | cut -d = -f 2):2380;
	else
		CLUSTER=${CLUSTER},$(echo ${node} | cut -d = -f 1)=http://$(echo ${node} | cut -d = -f 2):2380; 
	fi
done

echo CLUSTER: "${CLUSTER}"

mkdir -p /etc/etcd /var/lib/etcd /etcd-data
chmod 700 /etcd-data /etc/etcd /var/lib/etcd

etcd --name ${NAME} \
  --data-dir /var/lib/etcd \
  --listen-client-urls http://${INITIAL_IP}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://${INITIAL_IP}:2379 \
  --listen-peer-urls http://${INITIAL_IP}:2380 \
  --initial-advertise-peer-urls http://${INITIAL_IP}:2380 \
  --initial-cluster ${CLUSTER} \
  --initial-cluster-token ${TOKEN} \
  --initial-cluster-state new \
  --log-level info \
  --logger zap \
  --log-outputs stderr 
