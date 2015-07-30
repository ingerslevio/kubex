#!/bin/sh
kubectl delete -s http://localhost:8080 rc kubex-test
kubectl create -s http://localhost:8080 -f - <<- EOM
{
  "kind": "ReplicationController",
  "apiVersion": "v1",
  "metadata": {
    "name": "kubex-test",
    "labels": {
      "app": "kubex-test"
    }
  },
  "spec": {
    "replicas": 3,
    "selector": {
      "app": "kubex-test"
    },
    "template": {
      "metadata": {
        "labels": {
          "app": "kubex-test"
        },
        "generateName": "kubex-test-",
        "namespace": "default"
      },
      "spec": {
        "containers": [{
          "name": "kubex-test",
          "image": "gcr.io/kubex-test",
          "ports": [

          ]
        }],
        "restartPolicy": "Always"
      }
    }
  }
}
EOM

kubectl get -s http://localhost:8080 service kubex-test-lb || \
kubectl create -s http://localhost:8080 -f - <<- EOM
{
  "kind": "Service",
  "apiVersion": "v1",
  "metadata": {
    "name": "kubex-test-lb",
    "labels": {
      "app": "kubex-test"
    }
  },
  "spec": {
    "ports": [{
      "port": 4000,
      "targetPort": 4000
    }],
    "selector": {
      "app": "kubex-test"
    },
    "type": "LoadBalancer"
  }
}
EOM
