#!/bin/bash

set -e

initFe(){
    echo "start starrocks fe"
    [ -d "${FE_META}" ] || mkdir -p ${FE_META}
    sed -i "s|^[[:space:]]*\$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe.*|    exec \$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe \${HELPER} \"\$@\"|g" ${STARROCKS_HOME}/fe/bin/start_fe.sh
    sed -i "s@^priority_networks.*@@g" ${STARROCKS_HOME}/fe/conf/fe.conf
    sed -i "s@^meta_dir.*@@g" ${STARROCKS_HOME}/fe/conf/fe.conf
    echo "priority_networks = ${FE_NETWORK}" >> ${STARROCKS_HOME}/fe/conf/fe.conf
    echo "meta_dir = ${FE_META}" >> ${STARROCKS_HOME}/fe/conf/fe.conf

    #ENV MASTER_FE_HOST, FE_HOST, FE_TYPE(follower,observer), FOR HA
    if [[ -n ${MASTER_FE_HOST} ]];
    then
        COUNT=$(mysql -h${MASTER_FE_HOST} -P9030 -uroot -e"SHOW PROC '/frontends'\G;" | grep ${FE_HOST} | wc -l)
        if [ $COUNT -lt 1  ];
        then
            mysql -h${MASTER_FE_HOST} -P9030 -uroot -e"ALTER SYSTEM ADD ${FE_TYPE} \"${FE_HOST}:9010\";"
        fi
        exec bash ${STARROCKS_HOME}/fe/bin/start_fe.sh --helper "${MASTER_FE_HOST}:9010"
    else
        exec bash ${STARROCKS_HOME}/fe/bin/start_fe.sh
    fi
}

initBe(){
    echo "start starrocks be"
    [ -d "${BE_DATA}" ] || mkdir -p ${BE_DATA}
    #sed -i "s@^storage_root_path.*@storage_root_path = ${STARROCKS_HOME}/be/data@g" ${STARROCKS_HOME}/be/conf/be.conf
    sed -i "s@^priority_networks.*@@g" ${STARROCKS_HOME}/be/conf/be.conf
    sed -i "s@^storage_root_path.*@@g" ${STARROCKS_HOME}/be/conf/be.conf
    echo "priority_networks = ${BE_NETWORK}" >> ${STARROCKS_HOME}/be/conf/be.conf
    echo "storage_root_path = ${BE_DATA}" >> ${STARROCKS_HOME}/be/conf/be.conf
    sed -i "s|^[[:space:]]*\$LIMIT \${STARROCKS_HOME}/lib/palo_be.*|    exec \$LIMIT \${STARROCKS_HOME}/lib/palo_be \"\$@\"|g" ${STARROCKS_HOME}/be/bin/start_be.sh

    #ENV FE_HOST, add be to fe
    #ENV BE_HOST
    COUNT=$(mysql -h${FE_HOST} -P9030 -uroot -e"SHOW PROC '/backends'\G;" | grep ${BE_HOST} | wc -l)
    if [ $COUNT -lt 1  ];
    then
        mysql -h${FE_HOST} -P9030 -uroot -e"ALTER SYSTEM ADD BACKEND \"${BE_HOST}:9050\";"
    fi
    exec bash ${STARROCKS_HOME}/be/bin/start_be.sh
}

printUsage() {
    echo -e "Usage: [ fe | be ]\n"
    printf "%-13s:  %s\n" "fe" "StarRocks master."
    printf "%-13s:  %s\n" "be" "StarRocks worker."
}

case "$1" in
    (fe)
        initFe
    ;;
    (be)
        initBe
    ;;
    (help)
        printUsage
        exit 1
    ;;
    (*)
        printUsage
        exit 1
    ;;
esac


