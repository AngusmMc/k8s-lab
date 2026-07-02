
## Changing the role labels on the worker nodes so they come up as workers instead of none when using kubectl get nodes
``` bash
sudo kubectl label node k3s-worker-1 kubernetes.io/role=worker
```
Do the same for k3s-worker-2


## Tested on this cluster:

### Self-healing
- Created an nginx deployment
```bash
sudo kubectl create deployment nginx --image=nginx
sudo kubectl get deployments -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES   SELECTOR
nginx   1/1     1            1           3m41s   nginx        nginx    app=nginx
```
- Deleted pod to simulate crash
```bash
sudo kubectl delete pod nginx-66686b6766-6qjqb
```
- Control plane automatically recreated it on another pod generated straight away

### Scaling
- Scaled nginx to 10 replicas
```bash
sudo kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
nginx-66686b6766-6qjqb   1/1     Running   0          84s     10.42.2.4    k3s-worker-2   <none>           <none>
nginx-66686b6766-6zslb   1/1     Running   0          31s     10.42.1.7    k3s-worker-1   <none>           <none>
nginx-66686b6766-8lxqn   1/1     Running   0          55s     10.42.0.15   k3s-control    <none>           <none>
nginx-66686b6766-8xmk6   1/1     Running   0          31s     10.42.0.16   k3s-control    <none>           <none>
nginx-66686b6766-kk9nz   1/1     Running   0          2m56s   10.42.1.6    k3s-worker-1   <none>           <none>
nginx-66686b6766-lltdp   1/1     Running   0          31s     10.42.1.8    k3s-worker-1   <none>           <none>
nginx-66686b6766-nlssv   1/1     Running   0          31s     10.42.2.7    k3s-worker-2   <none>           <none>
nginx-66686b6766-nw9bm   1/1     Running   0          31s     10.42.2.6    k3s-worker-2   <none>           <none>
nginx-66686b6766-rq2bg   1/1     Running   0          31s     10.42.0.17   k3s-control    <none>           <none>
nginx-66686b6766-vm5mn   1/1     Running   0          31s     10.42.2.5    k3s-worker-2   <none>           <none>
```
- Pods are automatically distributed across worker nodes

### Taints
- Tainted control plane to prevent app scheduling, k3s let's the control node run apps on it by default unlike full k8s
```bash
sudo kubectl taint node k3s-control node-role.kubernetes.io/control-plane=:NoSchedule
node/k3s-control tainted
```
- Verified pods only schedule on worker nodes
```bash
sudo kubectl scale deployment nginx -replicas=0
sudo kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
nginx-66686b6766-5v8wl   1/1     Running   0          9s    10.42.1.9    k3s-worker-1   <none>           <none>
nginx-66686b6766-9f6zj   1/1     Running   0          9s    10.42.1.12   k3s-worker-1   <none>           <none>
nginx-66686b6766-c2ksq   1/1     Running   0          9s    10.42.2.11   k3s-worker-2   <none>           <none>
nginx-66686b6766-kltb6   1/1     Running   0          9s    10.42.1.13   k3s-worker-1   <none>           <none>
nginx-66686b6766-knkcw   1/1     Running   0          9s    10.42.1.11   k3s-worker-1   <none>           <none>
nginx-66686b6766-m62mz   1/1     Running   0          9s    10.42.2.9    k3s-worker-2   <none>           <none>
nginx-66686b6766-qjrzc   1/1     Running   0          9s    10.42.2.12   k3s-worker-2   <none>           <none>
nginx-66686b6766-x58t9   1/1     Running   0          9s    10.42.1.10   k3s-worker-1   <none>           <none>
nginx-66686b6766-xdk7c   1/1     Running   0          9s    10.42.2.10   k3s-worker-2   <none>           <none>
nginx-66686b6766-z5srx   1/1     Running   0          9s    10.42.2.8    k3s-worker-2   <none>           <none>
```


## Key points
- Deployments manage pods
- Taint means that pods cannot run on that node
