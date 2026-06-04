
# What is a Service in Kubernetes?

- When pods die and are replaced, they get a new IP address
- If users or other pods were connected to the pod then communication is lost

- When you make a service you give pods a stable IP address that stays
- We just made a NodePort service type. There are ClusterIP and LoadBalancer service types too



# THREE SERVICE TYPES

## ClusterIP

Allows pods to talk to each other WITHIN a cluster.

## NodePort
=======

### Why is NodePort Service not ideals sometimes?

A NodePort Service will open the ports on every node in the cluster even if a user is not going to access it.
For example:

- there are 3 worker nodes in the cluster
- a user wants to access an app, but there is only one active pod and it is on worker-3
- the NodePort service opens the ports on all 3 nodes even though the users traffic is only going to worker-3

- Also, the user needs to know the IP address of one of the 3 nodes to connect to.
- if the user connects to worker-3s IP address and the node goes down, then connection is lost (entry point down).
- even if the app was running fine on another nodes pods.

## ClusterIP
>>>>>>> 12c3a0e (updated notes)

Allows external users to access pods inside the cluster.

## Load Balancer

This service adds a single stable IP address that users connect to when they want to access a pod.
It's like a NodePort service except the users only need to connect to a single IP address and not worry about
the IP addresses of multiple nodes or worry if the nodes will go down.

# Basic networking with a service

Pod
- has a TARGET PORT

Service
- has a PORT

Node
- has a NODE PORT


The TARGET PORT on the Pod, and PORT on the Service are the same and are mapped to eachother. 

The NODE PORT is connected to the Service.

## Flow of traffic

External traffic -> node: NODE PORT -> service: PORT -> pod:TARGET PORT


#Load Balancer - Service Type

