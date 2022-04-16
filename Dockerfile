FROM centos:7

WORKDIR /opt

ARG VERSION

# refer to https://www.starrocks.com/zh-CN/download/community to download the required version 
ADD ./StarRocks-$VERSION.tar.gz ./jdk-8u321-linux-x64.tar.gz /opt/

ENV STARROCKS_HOME /opt/StarRocks-$VERSION
ENV FE_LOG ${STARROCKS_HOME}/fe/log
ENV FE_META ${STARROCKS_HOME}/fe/starrocks-meta
ENV FE_TMP ${STARROCKS_HOME}/fe/temp_dir

ENV BE_LOG ${STARROCKS_HOME}/be/log
ENV BE_DATA ${STARROCKS_HOME}/be/data

ENV JAVA_HOME /opt/jdk1.8.0_321
ENV PATH $PATH:$JAVA_HOME/bin

# todo invalid
#RUN mkdir -p /data/output/fe/starrocks-meta && \
#    mkdir -p /data/starrocks_storage && \
#    sed -i "s@^storage_root_path.*@storage_root_path = /data/starrocks_storage@g" /data/output/be/conf/be.conf && \
#    sed -i "s|^[[:space:]]*\$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe.*|    exec \$LIMIT \$JAVA \$JAVA_OPTS org.apache.starrocks.PaloFe \${HELPER} \"\$@\"|g" /data/output/fe/bin/start_fe.sh && \
#    sed -i "s|^[[:space:]]*\$LIMIT \${STARROCKS_HOME}/lib/palo_be.*|    exec \$LIMIT \${STARROCKS_HOME}/lib/palo_be \"\$@\"|g" /data/output/be/bin/start_be.sh

# set the time zone
RUN rm -f /etc/localtime; ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# install mysql client
RUN yum install -y mariadb.x86_64 mariadb-libs.x86_64 && yum clean all

COPY ./startup.sh /opt/startup.sh

RUN yum -y install iproute && yum clean all

VOLUME [ "${FE_LOG}","${FE_META}","${FE_TMP}","${BE_LOG}","${BE_DATA}" ]

#EXPOSE 8030 8040
EXPOSE 8030 8040 9060 9050 8060 9020 9030 9010 8000

ENTRYPOINT ["/bin/bash","-x","startup.sh"]

#CMD ["be/fe"]
