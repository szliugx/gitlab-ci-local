#!/bin/sh

network="local_ci"

services=()

image=""

script=""

# The container started by this script automatically closes over time
# to prevent the last cleanup from becoming system garbage when it is not executed
timeout=600

# -S  specifies the script to run, required
# -i  specify mirror name, optional
# -s  add a service, optional
# -n  specify the docker network name to create, optional
# -t  specifies the duration of the image timeout cleanup, optional
while getopts 's:i:n:S:t:' OPT; do
    case ${OPT} in
        s)
            services=(${services[@]} $OPTARG)
            ;;
        i)
            image=$OPTARG
            ;;
        n)
            network=$OPTARG
            ;;
        S)
            script=$OPTARG
            ;;
        t)
            timeout=$OPTARG
            ;;
    esac
done

if [[ -z ${script} ]]; then
    echo "script is required"
    exit 1
fi


info() {
    echo "\033[32m$1\033[0m \033[35m$2\033[0m" $3 ...
}

success() {
    echo "\033[32m\n$1\n\033[0m"
}

error() {
    echo "\033[31m\n$1\n\033[0m"
}

# runs in a local shell
run_script_only() {
    info "\nrunning" "script" ${script}
    echo "\n---------------------------------------------------------"
    bash -v ${script}
    exit_code=$?
    echo "---------------------------------------------------------"
    return ${exit_code}
}

# runs in the specified container
run_image() {

    info "using" "executor with image" ${image}

    stop_ids=()

    # create docker network
    if ! docker network inspect ${network} &>/dev/null; then
        info "creating" "docker network" ${network}
        docker network create ${network} &>/dev/null
    fi

    success "created docker network success"

    # start the services
    for service in ${services[@]}; do
        # remove the content after the colon
        service_nv=${service%\:*}
        # remove the port
        service_np=${service_nv/\:*\//\/}
        # name it after rule 1
        name1=${service_np//\//__}
        # name it after rule 2
        name2=${service_np//\//-}
        info "pulling" "docker image" ${service}
        docker pull ${service} &>/dev/null
        info "staring" "service image" ${service}
        cid=$(docker run -d --rm --stop-timeout ${timeout} ${service})
        # ddd to the list of container ids to be closed
        stop_ids=(${stop_ids[@]} ${cid})
        docker network connect --alias ${name1} --alias ${name2} ${network} ${cid}
    done

    info "pulling" "docker image" ${image}
    docker pull ${image} &>/dev/null

    info "staring" "image" ${image}
    image_id=$(docker run -itd --rm --stop-timeout ${timeout} -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:`pwd` -w `pwd` ${image} top)

    stop_ids=(${stop_ids[@]} ${image_id})

    docker network connect ${network} ${image_id}

    info "\nrunning" "script" ${script}

    echo "\n---------------------------------------------------------"

    docker exec -it ${image_id} bash -v ${script}

    exit_code=$?

    echo "---------------------------------------------------------"

    return ${exit_code}
}

clear() {
    # clean up the container
    docker stop ${stop_ids[@]} &>/dev/null

    if docker network inspect ${network} | grep '"Containers": {}' &>/dev/null; then
        docker network rm ${network} &>/dev/null
    fi
}

# 捕捉退出信号
trap 'clear; exit' SIGINT SIGQUIT

if [[ -z ${image} ]]; then
    run_script_only
else
    run_image
fi

script_exit=$?

if [[ ${script_exit} == "0" ]]; then
    success "Job succeeded"
else
    error "Job failed"
fi

clear

exit ${script_exit}
