#!/bin/sh

HOST=`hostname -f`
DOMAIN=`hostname -d`
CONTAINER_NAME="rabbit"

case $HOST in        
        node-11-rabbit)
	    echo 'Тестовое плечо 11';
	    VOLUME=/rabbit_cluster_data
	    HOSTNAME=$HOST;
	    COOKIE="abcdefg"
	    CLUSTER_WITH="NO"
	;;
        node-22-rabbit)
	    echo 'Тестовое плечо 22';
	    VOLUME=/rabbit_cluster_data
	    HOSTNAME=$HOST;
	    COOKIE="abcdefg"
	    CLUSTER_WITH="node-11-rabbit"
	;;
        node-33-rabbit)
	    echo 'Тестовое плечо 33';
	    VOLUME=/rabbit_cluster_data
	    HOSTNAME=$HOST;
	    COOKIE="abcdefg"
	    CLUSTER_WITH="node-11-rabbit"
esac

# останавливаем текущую ноду, если она есть
docker stop $CONTAINER_NAME || true

# удаляем контейнер - так как данные мы храним на диске хоста
docker rm $CONTAINER_NAME || true


if [ "$CLUSTER_WITH" = "NO" ]; then

docker run -d --restart=always --network=host --hostname=$HOSTNAME \
   --name=$CONTAINER_NAME -v /data:/var/lib/rabbitmq \
   -v /data/logs:/var/log/rabbitmq \
   -e "RABBITMQ_USE_LONGNAME=true"                          \
   -e "RABBITMQ_ERLANG_COOKIE=${COOKIE}" \
   -p 4369:4369 -p 5672:5672 -p 15672:15672 -p 25672:25672 \
   rabbitmq:3.6.6-management
else

# стартуем ноду в сети хоста, чтобы пока не использовать Swarm кластер
docker run -d --restart=always --network=host --hostname=$HOSTNAME \
   --name=$CONTAINER_NAME -v /data:/var/lib/rabbitmq \
   -v /data/logs:/var/log/rabbitmq \
   -e "RABBITMQ_USE_LONGNAME=true"                          \
   -e "RABBITMQ_ERLANG_COOKIE=${COOKIE}" -e "CLUSTER_WITH=$CLUSTER_WITH" \
   -p 4369:4369 -p 5672:5672 -p 15672:15672 -p 25672:25672 \
   rabbitmq:3.6.6-management
fi