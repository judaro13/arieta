# Installing kubernetes

In arch linux you can use an aur, install it manually because is pretty heavy or be sure you have enogth space on /tmp to download and compile it or follow the guide in kubernetes page

We will use minikube. Many of the information displayed here was taken from  
https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/

## Start cluster

```
$ minikube start --vm-driver=xhyve
``
## Create an docker image

* First create  a file 'Dockerfile': The file will describe the image that you will build

* Second build your image: Because minikube is used here, instead of pushing your Docker image to a registry, you can simply build the image using the same Docker host as the Minikube VM, so that the images are automatically present.

```
docker build -t hello-node:v1 .
```
Now the Minikube VM can run the image you built.

To  make sure you are using the Minikube Docker daemon run:

```
eval $(minikube docker-env)
```

Note: Later, when you no longer wish to use the Minikube host, you can undo this change by running
```
 eval $(minikube docker-env -u).
```

Build your Docker image, using the Minikube Docker daemon:


## Make a deploy

A Kubernetes Pod is a group of one or more Containers, tied together for the purposes of administration and networking. The Pod in this tutorial has only one Container. A Kubernetes Deployment checks on the health of your Pod and restarts the Pod’s Container if it terminates. Deployments are the recommended way to manage the creation and scaling of Pods.
Use the kubectl run command to create a Deployment that manages a Pod. The Pod runs a Container based on your hello-node:v1 Docker image:
```
$ kubectl run hello-node --image=hello-node:v1 --port=8080
```
View the Deployment:
```
$ kubectl get deployments
```
View the Pod:
```
$ kubectl get pods
```
View cluster events:
```
$ kubectl get events
```
View the kubectl configuration:
```
$ kubectl config view
```

## Create a Service

By default, the Pod is only accessible by its internal IP address within the Kubernetes cluster. To make the hello-node Container accessible from outside the Kubernetes virtual network, you have to expose the Pod as a Kubernetes Service.

From your development machine, you can expose the Pod to the public internet using the kubectl expose command:
```
kubectl expose deployment hello-node --type=LoadBalancer
```
View the Service you just created:
```
kubectl get services
```
The --type=LoadBalancer flag indicates that you want to expose your Service outside of the cluster. On cloud providers that support load balancers, an external IP address would be provisioned to access the Service. On Minikube, the LoadBalancer type makes the Service accessible through the minikube service command.
```
$ minikube service hello-node
```
This automatically opens up a browser window using a local IP address that serves your app and shows the “Hello World” message.
Assuming you’ve sent requests to your new web service using the browser or curl, you should now be able to see some logs:
```
$ kubectl logs <POD-NAME>
```

## Clean up

Now you can clean up the resources you created in your cluster:
```
$ kubectl delete service hello-node
$ kubectl delete deployment hello-node
```
Optionally, stop Minikube:
```
minikube stop
```

## Cluster access

You need to expose it

```
  $ kubectl proxy --port=8080
```
