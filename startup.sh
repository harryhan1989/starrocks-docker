#!/bin/bash

set -e

initFe(){
    echo "start starrocks fe"
    [ -d "${FE_META}" ] || mkdir -p ${FE_META}
    sed -i "s|^[[:space:]]*\$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe.*|    exec \$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe \${HELPER} \"\$@\"|g" ${STARROCKS_HOME}/fe/bin/start_fe.sh
    echo "priority_networks = ${FE_NETWORK}" >> ${STARROCKS_HOME}/fe/conf/fe.conf
    echo "meta_dir = ${FE_META}" >> ${STARROCKS_HOME}/fe/conf/fe.conf
    exec bash ${STARROCKS_HOME}/fe/bin/start_fe.sh
}

initBe(){
    echo "start starrocks be"
    [ -d "${BE_DATA}" ] || mkdir -p ${BE_DATA}
    sed -i "s@^storage_root_path.*@storage_root_path = ${STARROCKS_HOME}/be/data@g" ${STARROCKS_HOME}/be/conf/be.conf
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


