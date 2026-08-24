# Certified Kubernetes Administrator

# Scheduling

- Deciding which node a pod should run on
- The kube scheduler looks for pod config files that do not have  spec>nodeName field
- Kube scheduler runs an algorithm and adds a node to the field, it has then been ‘binded’.
- If there is no scheduler then pods will stay pending

## Manual scheduling

You can add the node manually at the creation of the object in the nodeName field

```yaml
pod-definition.yaml

apiVersion: v1
kind: Pod
metadata:
	name: nginx
	labels:
		name: nginx
spec:
	containers:
	- name: nginx
		image: nginx
		ports
			- containerPorts: 8080
	nodeName: # ADD NODE NAME HERE
```

But once it has been created, you cannot edit the nodeName field, so you need to make a file like so that will mimic the scheduler. 

```yaml
pod-bind-definition.yaml

apiVersion: v1
kind: Binding
metadata:
	name: nginx
target:
	apiVersion: v1
	kind: Node
	name: node02 # specify the name of the target node
```

Then send it as a POST request to the pods binding API with the data set as the binding object in JSON format by converting the YAML format into JSON

![Screenshot 2026-07-24 at 1.04.52 pm.png](Certified%20Kubernetes%20Administrator/Screenshot_2026-07-24_at_1.04.52_pm.png)

## Labels and Selectors

- Labels are used to logically separate objects
- You can seperate objects by application, type, etc…
- Selectors are how you query the labels

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
  labels: # THIS LABEL IS ON OBJECT (HERE IT IS A REPLICA SET)
    app: my-app
    function: front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels: # THESE LABELS UNDER TEMPLATE ARE ON THE PODS
        app: my-app
        function: front-end
    spec:
      containers:
      - name: my-container
        image: nginx:1.14.2
        ports:
        - containerPort: 80   
```

## Taints and Tolerations

**Taints** go on **nodes**

**Tolerations** go on **pods**

**example:**

If you have a node that you want to keep only a specific kind of pod on, you can apply a taint to it. When the kube-scheduler goes to allocate a pod to the node, it will only allocate pods that can tolerate the taint. If you want a 

**Simplified:**

Taint x says block all pods on this node except ones with tolerations that say x

How to taint

```bash
kubectl taint nodes [node-name] [key=value:taint-effect]
#                                            ^ if pods don't tolerate the taint
```

There are THREE taint effects:

1. **NoSchedule** - pods will not be scheduled to the node
2. **PreferNoSchedule** - the kube-scheduler will try not to schedule on the node, no guarantee
3. **NoExecute** - new pods will not be scheduled on the node, existing non-tolerant pods are kicked off the node

example taint for the node

```bash
kubectl taint nodes worker1 app=mealie:NoSchedule

# applies a taint to the worker1 node
# ALL pods are barred from being scheduled to the node
# only pods with a toleration for app=mealie:NoSchedule are allowed
```

matching toleration in the pod definition **under spec**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "mealie"
    effect: "NoSchedule"
```

To remove a taint

```bash
kubectl taint nodes worker1 app=mealie:NoSchedule-

# Just add a minus to the end to untaint
```

## Node Selectors

This is a way to choose which nodes a pod is scheduled to

1. Label a node
2. Add that label to the spec.nodeSelector field in the pod definition yaml

To add a label to a node

```yaml
kubectl label node [node-name] [label-key=label-value]
```

So if we want to label a node as big 

```yaml
kubectl label node worker01 size=large
```

Now we in the pod definition yaml we add **spec.nodeSelector**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
	  size: large # Now the pod will be assigned to the Node with size = large
	  
	  
```

## Node Affinity

- Makes sure that pods are scheduled on specific nodes

Node affinity is like nodeSelector except it is more granular

There are **two types of nodeAffinity**

- determines what happens if the node labels change

**spec.affinity.nodeAffinity:**

1. **required**DuringSchedulingIgnoredDuringExecution
    - pod MUST land on that node or stays pending
    - the following MUST be true to be scheduled

1. **preferred**DuringSchedulingIgnoredDuringExecution
    - kube-scheduler will try to place on that pod, but doesn’t have to
    - the following MAY be true or not, it will always be scheduled

During scheduling is the state where the pod doesn’t exist and is just created for the first time

During execution the pod has been running and a change has been made to the node affinity ie label changes on the node

example:

```yaml
# pod-definition.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
  - name: data-processor
    image: data-processor
  affinity:                       # define affinity rules
    nodeAffinity:                 # what nodes you want the pod on
      requiredDuringSchedulingIgnoredDuringExecution:   # the following must be true, or the pod stays Pending
        nodeSelectorTerms:
        - matchExpressions:
          - key: size             # look at the node's "size" label
            operator: NotIn       # exclude nodes matching a value below
            values:
            - Small               # place on a node that is not labeled size=Small
```