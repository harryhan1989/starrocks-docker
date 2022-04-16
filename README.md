# starrocks-docker
starrocks docker

先去 https://www.starrocks.com/zh-CN/download/community 这里下载指定版本，将版本号带入docker build中

docker build \
-t harryhan1989/starrokcs:2.2.0-rc01 \
--build-arg VERSION='2.2.0-rc01' \
--no-cache .