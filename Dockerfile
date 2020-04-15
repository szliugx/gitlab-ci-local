# 基础镜像是 docker 仓库的 busybox
FROM alpine as certs
# 更新安装源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk update && apk add ca-certificates
# 从别的镜像中 copy 证书
FROM busybox
COPY --from=certs /etc/ssl/certs /etc/ssl/certs
# 作者签名
LABEL author="szliugx@gmail.com"
# 工作目录
WORKDIR /root
# 添加文件
ADD ./bin/gitlab-ci-local ./gitlab-ci-local
# 运行容器执行时的口令
ENTRYPOINT ["./gitlab-ci-local"]