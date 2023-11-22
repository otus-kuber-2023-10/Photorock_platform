# Photorock_platform
Photorock Platform repository

TASK 5

Идем по методичке и последовательно создаем и применяем манифесты которые требуются.

Задание Task01

Проверяем
```console
kubectl get sa -A
NAMESPACE            NAME                                     SECRETS   AGE
default              dave                                     0         9m40s
default              default                                  0         13m
kube-node-lease      default                                  0         13m
kube-public          default                                  0         13m
kube-system          attachdetach-controller                  0         13m
kube-system          bob                                      0         12m

kubectl get rolebinding,clusterrolebinding \
              --all-namespaces \
              -o jsonpath='{range .items[?(@.subjects[0].name=="bob")]}
                           [{.roleRef.kind},{.roleRef.name}]{end}'; echo

                           [ClusterRole,cluster-admin]
```
Task02

Проверяем
```console
kubectl get sa -n prometheus
NAME      SECRETS   AGE
carol     0         3s
default   0         7s

kubectl get ClusterRole
NAME                                                                   CREATED AT
admin                                                                  2023-11-22T15:32:20Z
all-pod-viewer                                                         2023-11-22T16:11:48Z
cluster-admin                                                          2023-11-22T15:32:20Z

kubectl describe ClusterRole all-pod-viewer
Name:         all-pod-viewer
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods.*     []                 []              [get list watch]

kubectl get rolebindings,clusterrolebindings --all-namespaces -o wide | grep prometheus
            clusterrolebinding.rbac.authorization.k8s.io/all-pod-viewer                                         ClusterRole/all-pod-viewer                                                         4m31s                                    system:serviceaccounts:prometheus 
```
Task03

Проверяем
```console
kubectl get sa -n dev
NAME      SECRETS   AGE
default   0         95s
jane      0         91s
ken       0         25s

kubectl describe Role admin-dev -n dev
Name:         admin-dev
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]


kubectl describe Role viewer-dev -n dev
Name:         viewer-dev
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [get list watch]

kubectl get rolebindings,clusterrolebindings --all-namespaces -o wide | grep dev
default       rolebinding.rbac.authorization.k8s.io/admin-dev                                           Role/admin-dev                                        101s                                                                                                                           dev/jane
default       rolebinding.rbac.authorization.k8s.io/viewer-dev                                          Role/viewer-dev                                       87s                                                                                                                            dev/ken
```
TASK 4

Задание c *

Идем по методичке и последовательно создаем и применяем манифесты и указания по установке minio, которые указаны в ней

Шифруем командой echo -n 'my_string' | base64 access_key и secret_key манифеста minio-statefulset.yaml и вносим их в secrets.yaml, затем применяем эти манифесты.

Задание - создание и использование PVC -опциональное

Проверка доступности ранее созданного файла в PVC одним подом в другом поде - файл в наличии
```console
sudo kubectl exec -it my-pod-2 -- /bin/bash
root@my-pod-2:/# cat /app/data/data.txt
Hello, Kubernetes Volumes!
```

TASK 3

Идем по методичке и последовательно создаем и применяем манифесты и указания по установке IPVS, которые указаны в ней

Mmetallb ставим так

MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest|grep tag_name|cut -d '"' -f 4|sed 's/v//')
echo $MetalLB_RTAG
wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml

Проверяем установку
```console
kubectl get pods -n metallb-system
NAME                          READY   STATUS    RESTARTS   AGE
controller-565ccc769f-hm26r   1/1     Running   0          10h
speaker-x55dl                 1/1     Running   0          10h
```
Проверяем http://172.17.255.1/index.html - старница открывается

Задание со * 1

Применяем манифест из ./coredns репозитория

Проверяем
```console
nslookup web.default.cluster.local 172.17.255.10
Server:         172.17.255.10
Address:        172.17.255.10#53

** server can't find web.default.cluster.local: NXDOMAIN
```
Идем по методичке и последовательно создаем и применяем манифесты и указания по установке Ingress, которые указаны в ней

Ingress-nginx-controller ставим отсюда 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml 

Проверяем установку
```console
kubectl get pod -n ingress-nginx 
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-f8grp        0/1     Completed   0          7h32m
ingress-nginx-admission-patch-mb4xf         0/1     Completed   0          7h32m
ingress-nginx-controller-778d4c6454-pcbsc   1/1     Running     0          7h32m
```
При следующей проверке видим, что создание и применение манифеста из методички nginx-lb.yaml избыточна, так как необходимая служба уже создана при установке Ingress-nginx-controller
```console
kubectl get svc -n ingress-nginx 
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx                        LoadBalancer   10.110.123.98   172.17.255.3   80:30426/TCP,443:30875/TCP   7h8m
ingress-nginx-controller             LoadBalancer   10.99.71.30     172.17.255.2   80:31434/TCP,443:31684/TCP   7h13m
ingress-nginx-controller-admission   ClusterIP      10.102.209.83   <none>         443/TCP                      7h13m
```
Проверяем http://172.17.255.2/web/index.html - страница открывается

Задание со * 2

Ставим дащбоард отсюда

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

Применяем манифест из ./dashboard репозитория

Проверяем http://172.17.255.2/dashboard/ - страница переадресовывается на http://172.17.255.2/dashboard/#/login и открывается

Задание со * 3

Создаем канареечный под на основе ./web-deploy.yaml c заменой index.html на следующий шаблон 
```console
<!DOCTYPE html>
<html>
<head>
        <title>Заголовок</title>
</head>
<body>
        "Hello World!"
</body>
</html>
```
Применяем манифесты из ./canary репозитория

Проверяем - при изменении заголока на канареечный - мы попадем на канареечную страницу

curl -H "canary: always" http://172.17.255.2/web/index.html
```console
<!DOCTYPE html>
<html>
<head>
        <title>Заголовок</title>
</head>
<body>
        "Hello World!"
</body>
</html>
```

TASK 2

Идем по методичке и последовательно создаем и применяем манифесты и указания которые указаны в ней

Задание со *

Проверяем Аналог blue-green манифеста paymentservice-deployment-bg.yaml

```console
kubectl apply -f paymentservice-deployment-bg.yaml | kubectl get pods -l app=paymentservice -w
NAME                             READY   STATUS    RESTARTS   AGE
paymentservice-c76466c76-79xmv   1/1     Running   0          86s
paymentservice-c76466c76-bsfj6   1/1     Running   0          86s
paymentservice-c76466c76-hmhxj   1/1     Running   0          7m10s
paymentservice-7786cfb8dc-vg7fr   0/1     Pending   0          0s
paymentservice-7786cfb8dc-67xq7   0/1     Pending   0          0s
paymentservice-7786cfb8dc-d4qjh   0/1     Pending   0          0s
paymentservice-7786cfb8dc-vg7fr   0/1     Pending   0          0s
paymentservice-7786cfb8dc-67xq7   0/1     Pending   0          0s
paymentservice-7786cfb8dc-d4qjh   0/1     Pending   0          0s
paymentservice-7786cfb8dc-vg7fr   0/1     ContainerCreating   0          0s
paymentservice-7786cfb8dc-67xq7   0/1     ContainerCreating   0          0s
paymentservice-7786cfb8dc-d4qjh   0/1     ContainerCreating   0          0s
paymentservice-7786cfb8dc-vg7fr   1/1     Running             0          2s
paymentservice-c76466c76-79xmv    1/1     Terminating         0          88s
paymentservice-c76466c76-79xmv    0/1     Terminating         0          88s
paymentservice-c76466c76-79xmv    0/1     Terminating         0          88s
paymentservice-c76466c76-79xmv    0/1     Terminating         0          88s
paymentservice-c76466c76-79xmv    0/1     Terminating         0          88s
paymentservice-7786cfb8dc-67xq7   1/1     Running             0          49s
paymentservice-c76466c76-bsfj6    1/1     Terminating         0          2m15s
paymentservice-c76466c76-bsfj6    0/1     Terminating         0          2m17s
paymentservice-c76466c76-bsfj6    0/1     Terminating         0          2m17s
paymentservice-c76466c76-bsfj6    0/1     Terminating         0          2m17s
paymentservice-c76466c76-bsfj6    0/1     Terminating         0          2m17s
paymentservice-7786cfb8dc-d4qjh   1/1     Running             0          53s
paymentservice-c76466c76-hmhxj    1/1     Terminating         0          8m3s
paymentservice-c76466c76-hmhxj    0/1     Terminating         0          8m4s
paymentservice-c76466c76-hmhxj    0/1     Terminating         0          8m4s
paymentservice-c76466c76-hmhxj    0/1     Terminating         0          8m4s
paymentservice-c76466c76-hmhxj    0/1     Terminating         0          8m4s
```
Видим, что сначала три пода создались, затем удалились 3 старых, что соответствует заданию

Проверяем Reverse Rolling Update манифеста paymentservice-deployment-reverse.yaml 
```console
kubectl apply -f paymentservice-deployment-reverse.yaml | kubectl get pods -l app=paymentservice -w
NAME                              READY   STATUS    RESTARTS   AGE
paymentservice-7786cfb8dc-d2xgm   1/1     Running   0          72s
paymentservice-7786cfb8dc-d2xgm   1/1     Terminating   0          72s
paymentservice-7786cfb8dc-d2xgm   0/1     Terminating   0          73s
paymentservice-7786cfb8dc-d2xgm   0/1     Terminating   0          73s
paymentservice-7786cfb8dc-d2xgm   0/1     Terminating   0          73s
paymentservice-7786cfb8dc-d2xgm   0/1     Terminating   0          73s
paymentservice-c76466c76-hmhxj    0/1     Pending       0          0s
paymentservice-c76466c76-hmhxj    0/1     Pending       0          0s
paymentservice-c76466c76-hmhxj    0/1     ContainerCreating   0          0s
paymentservice-c76466c76-hmhxj    1/1     Running             0          1s
```
Видим, что сначала один существующий под сначала удалился, затем заново создался, что соответствует заданию

Задания с * и ** звездочками

Для распространения DaemonSet node-exporter на ноду control-plane необходимо добавить следующую секцию
в манифест node-exporter-daemonset.yaml
```console
tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
```
Проверяем

```console
kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   25m   v1.27.3
kind-worker          Ready    <none>          24m   v1.27.3
kind-worker2         Ready    <none>          24m   v1.27.3
kind-worker3         Ready    <none>          24m   v1.27.3
```
```console
kubectl get pods -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
node-exporter-4c44p   1/1     Running   0          43s   10.244.1.5   kind-worker          <none>           <none>
node-exporter-gvmhx   1/1     Running   0          43s   10.244.2.5   kind-worker3         <none>           <none>
node-exporter-h7g2d   1/1     Running   0          43s   10.244.3.6   kind-worker2         <none>           <none>
node-exporter-kp9pz   1/1     Running   0          43s   10.244.0.5   kind-control-plane   <none>           <none>
``` 

Видим, что теперь DaemonSet распространился и на control-plane ноду

TASK 1

Идем по методичке и последовательно создаем и применяем манифесты и указания которые указаны в ней

Задание со *

Для устраннения статуса Error пода frontend необходимо включить в манифест следующую секцию
```console
    env:
    - name: PORT
      value: "8080"
    - name: PRODUCT_CATALOG_SERVICE_ADDR
      value: "productcatalogservice:3550"
    - name: CURRENCY_SERVICE_ADDR
      value: "currencyservice:7000"
    - name: CART_SERVICE_ADDR
      value: "cartservice:7070"
    - name: RECOMMENDATION_SERVICE_ADDR
      value: "recommendationservice:8080"
    - name: SHIPPING_SERVICE_ADDR
      value: "shippingservice:50051"
    - name: CHECKOUT_SERVICE_ADDR
      value: "checkoutservice:5050"
    - name: AD_SERVICE_ADDR
```    


