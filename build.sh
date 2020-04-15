chmod +x local-ci.sh
./local-ci.sh -i ci_cd_build_go:latest -S ./local-script.sh

# =================== 省略步骤 =========================
# 省略了镜像推送到镜像仓库的步骤

# # =================== 模拟线上执行脚本 =========================
# # 省略了拉取镜像到宿主机的操作，及镜像升级
# # 暴露端口启动容器 -p 将本地端口映射到容器中的端口
# docker run --name gitlab-ci-local-1 -d -p 8081:8080 gitlab-ci-local:latest
# docker run --name gitlab-ci-local-2 -d -p 8082:8080 gitlab-ci-local:latest
# docker run --name gitlab-ci-local-3 -d -p 8083:8080 gitlab-ci-local:latest