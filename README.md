# gitlab-ci-local
本地模拟 gitlab ci 的 demo
<b>

<b>

模拟应用启动命令
```shell
$: chmod +x ./build.sh
$: ./build.sh
```

<b>

<b>

实现步骤：
1. 准备应用(启动一个 gin 框架的 http 服务)
2. 准备 gitlab-ci 模拟构建环境脚本
3. 构建环节(打包成 docker 镜像) 省略
4. 部署环节（从线上拉取 docker 镜像）省略
5. 完成部署

<b>


### 生成 ci_cd_build_go 镜像 的 Dockerfile 代码

```Dockerfile
FROM golang:1.13.5
USER root
# Install golint
ENV GO111MODULE on

RUN export GO111MODULE=on
RUN go env -w  GOPROXY=https://goproxy.cn
RUN go get golang.org/x/lint
RUN go install golang.org/x/lint

# COPY docker-latest.tgz docker-latest.tgz

# install docker
RUN curl -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
    && tar zxvf docker-latest.tgz \
    && cp docker/docker /usr/local/bin/ \
    && rm -rf docker docker-latest.tgz

## 用下面的命令生成 ci_cd_build_go 镜像
# docker build -t ci_cd_build_go .
```

<b>

### 运行过程输入内容：

```shell
 ./build.sh
using executor with image ci_cd_build_go:latest ...
creating docker network local_ci ...

created docker network success

pulling docker image ci_cd_build_go:latest ...
staring image ci_cd_build_go:latest ...

running script ./local-script.sh ...

---------------------------------------------------------
go env | grep GOPROXY
GOPROXY="https://goproxy.cn"
make all ENV=test
start go build....
GOPROXY="https://goproxy.cn"
go: downloading github.com/gin-gonic/gin v1.6.2
go: extracting github.com/gin-gonic/gin v1.6.2
go: downloading gopkg.in/yaml.v2 v2.2.8
go: downloading github.com/golang/protobuf v1.3.3
go: downloading github.com/gin-contrib/sse v0.1.0
go: downloading github.com/mattn/go-isatty v0.0.12
go: downloading github.com/ugorji/go v1.1.7
go: downloading github.com/go-playground/validator/v10 v10.2.0
go: extracting gopkg.in/yaml.v2 v2.2.8
go: extracting github.com/gin-contrib/sse v0.1.0
go: extracting github.com/ugorji/go v1.1.7
go: downloading github.com/ugorji/go/codec v1.1.7
go: extracting github.com/mattn/go-isatty v0.0.12
go: downloading golang.org/x/sys v0.0.0-20200116001909-b77594299b42
go: extracting github.com/golang/protobuf v1.3.3
go: extracting github.com/go-playground/validator/v10 v10.2.0
go: downloading github.com/leodido/go-urn v1.2.0
go: downloading github.com/go-playground/universal-translator v0.17.0
go: extracting github.com/ugorji/go/codec v1.1.7
go: extracting github.com/go-playground/universal-translator v0.17.0
go: downloading github.com/go-playground/locales v0.13.0
go: extracting github.com/leodido/go-urn v1.2.0
go: extracting golang.org/x/sys v0.0.0-20200116001909-b77594299b42
go: extracting github.com/go-playground/locales v0.13.0
go: finding github.com/gin-gonic/gin v1.6.2
go: finding github.com/gin-contrib/sse v0.1.0
go: finding github.com/go-playground/validator/v10 v10.2.0
go: finding github.com/go-playground/universal-translator v0.17.0
go: finding github.com/go-playground/locales v0.13.0
go: finding github.com/leodido/go-urn v1.2.0
go: finding github.com/golang/protobuf v1.3.3
go: finding github.com/ugorji/go/codec v1.1.7
go: finding gopkg.in/yaml.v2 v2.2.8
go: finding github.com/mattn/go-isatty v0.0.12
go: finding golang.org/x/sys v0.0.0-20200116001909-b77594299b42

packing....
total 15M
-rwxr-xr-x 1 root root 15M Mar 27 17:22 gitlab-ci-local
Sending build context to Docker daemon  15.28MB
Step 1/8 : FROM alpine as certs
 ---> a187dde48cd2
Step 2/8 : RUN apk update && apk add ca-certificates
 ---> Using cache
 ---> 409d89df1e27
Step 3/8 : FROM busybox
 ---> 83aa35aa1c79
Step 4/8 : COPY --from=certs /etc/ssl/certs /etc/ssl/certs
 ---> Using cache
 ---> f3d288b6f60c
Step 5/8 : LABEL author="szliugx@gmail.com"
 ---> Using cache
 ---> 474ca6db3d19
Step 6/8 : WORKDIR /root
 ---> Using cache
 ---> ebbc723821b0
Step 7/8 : ADD ./bin/gitlab-ci-local ./gitlab-ci-local
 ---> 9d56f29bb9e0
Step 8/8 : ENTRYPOINT ["./gitlab-ci-local"]
 ---> Running in 34dd84a42931
Removing intermediate container 34dd84a42931
 ---> 5674b1245ff6
Successfully built 5674b1245ff6
Successfully tagged gitlab-ci-local:latest

ALL DONE
Program:        gitlab-ci-local
Version:        1.0.0
Env:            test
---------------------------------------------------------

Job succeeded

039aae08ef39d7b7ad1a999bf13b144a96d13ecdc9c33a3370bbd9c9c1acda2c
23ce53c3722214c6077e906669f36b391a91d234569a9a424aa5f6031aa8d782
381d27e6905d173863db5b7f2f3e3d1385363bf33affae2846fcc3a5a1ba3aba
```
