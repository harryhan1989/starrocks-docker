# 源码： 
https://github.com/harryhan1989/starrocks-docker

# starrocks-docker
starrocks docker (后续新的版本不一定会及时更新，有需要编译新版本，可以github上给我提)

# 构建
先去 https://www.starrocks.com/zh-CN/download/community 这里下载指定版本，将版本号带入docker build中
```
docker build \
-t harryhan1989/starrokcs:2.2.0-rc01 \
--build-arg VERSION='2.2.0-rc01' \
--no-cache .
```

# 使用(docker-compose.yml)
```
version: '3'
services:

  fe:
    image: harryhan1989/starrokcs:2.2.0-rc01
    container_name: fe
    hostname: fe
    restart: always
    command: ["fe"]
    environment:
      FE_NETWORK: 192.167.1.30/24
    deploy:
      resources:
        limits:
          cpus: '8.00'
          memory: 32G
        reservations:
          cpus: '0.25'
          memory: 100M
    volumes:
      - /root/nas/starrocks/fe/log:/opt/StarRocks-2.2.0-rc01/fe/log:rw
      - /root/nas/starrocks/fe/starrocks-meta:/opt/StarRocks-2.2.0-rc01/fe/starrocks-meta:rw
      - /root/nas/starrocks/fe/temp_dir:/opt/StarRocks-2.2.0-rc01/fe/temp_dir:rw
    ports:
      - "8030:8030"
    networks:
      starrocksnet:
        ipv4_address: 192.167.1.30

  be01:
    image: harryhan1989/starrokcs:2.2.0-rc01
    container_name: be01
    hostname: be01
    restart: always
    command: [ "be" ]
    depends_on:
      - fe
    environment:
      FE_HOST: fe
      BE_HOST: be01
      BE_NETWORK: 192.167.1.31/24
    deploy:
      resources:
        limits:
          cpus: '8.00'
          memory: 32G
        reservations:
          cpus: '0.25'
          memory: 100M
    volumes:
      - /root/nas/starrocks/be01/log:/opt/StarRocks-2.2.0-rc01/be/log:rw
      - /root/nas/starrocks/be01/data:/opt/StarRocks-2.2.0-rc01/be/data:rw
    ports:
      - "8041:8040"
    networks:
      starrocksnet:
        ipv4_address: 192.167.1.31

  be02:
    image: harryhan1989/starrokcs:2.2.0-rc01
    container_name: be02
    hostname: be02
    restart: always
    command: [ "be" ]
    depends_on:
      - fe
    environment:
      FE_HOST: fe
      BE_HOST: be02
      BE_NETWORK: 192.167.1.32/24
    deploy:
      resources:
        limits:
          cpus: '8.00'
          memory: 32G
        reservations:
          cpus: '0.25'
          memory: 100M
    volumes:
      - /root/nas/starrocks/be02/log:/opt/StarRocks-2.2.0-rc01/be/log:rw
      - /root/nas/starrocks/be02/data:/opt/StarRocks-2.2.0-rc01/be/data:rw
    ports:
      - "8042:8040"
    networks:
      starrocksnet:
        ipv4_address: 192.167.1.32

networks:
  starrocksnet:
    ipam:
      driver: default
      config:
        - subnet: "192.167.1.0/24"
```