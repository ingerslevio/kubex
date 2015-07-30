#!/bin/sh
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
docker build -t=gcr.io/kubex-test $DIR/..
