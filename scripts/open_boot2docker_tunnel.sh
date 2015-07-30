#!/bin/bash

if [ $# -eq 0 ]
then

data=$(boot2docker ssh curl -s -X GET http://localhost:8080/api/v1/services?labelSelector=app=kubex-test)
serviceIP=$(echo $data | grep -o \"clusterIP\":\ \".*\" | egrep -o '([0-9]+.){3}[0-9]+')


eval $0 8080 $serviceIP:4000
exit 0

fi

args="boot2docker ssh"

while [ $# -gt 0 ]
do
  parts=(${1//:/ })

  if [ ${#parts[@]} -eq 1 ]
  then
    host="localhost"
    port="${parts[0]}"
  else
    host="${parts[0]}"
    port="${parts[1]}"
  fi

  args=$args" -L$port:$host:$port"
  shift
done

echo $args
eval $args
