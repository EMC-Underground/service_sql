#!/bin/bash

state="prep"
stack="sql"
service="db"

until [ $state == "complete" ]
    do
        echo "Current State=${state}"
        case $state in
            "prep")
                state="deploy"
                docker stack ps $stack > /dev/null 2>&1
                if [ $? -eq 0 ]
                then
                    state="cleanup"
                fi
                ;;
            "cleanup")
                state="deploy"
                docker stack rm $stack > /dev/null 2>&1
                if [ $? -ne 0 ]
                then
                    state="error"
                    exit 1
                fi
                sleep 2
                ;;
            "deploy")
                state="deploying"
                docker stack deploy -c docker-compose.yml $stack > /dev/null 2>&1
                if [ $? -ne 0 ]
                then
                    state="error"
                    exit 1
                fi
                ;;
            "deploying")
                state="deploying"
                service_state=`docker service ps ${stack}_${service} | awk 'FNR == 2 {print $6}'`
                if [ $service_state == "Running" ]
                then
                    state="complete"
                fi
                sleep 2
                ;;
        esac
    done
