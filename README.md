# Photorock_platform
Photorock Platform repository

TASK 6

Идем по методичке и последовательно создаем и применяем манифесты которые требуются.

Устанавливаем ingress-nginx

helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace nginx-ingress

Устанавливаем CRD для cert-manager и сам cert-manager

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
```console
helm install \
cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.13.2
```

Устанавливаем chartmuseum

helm repo add chartmuseum https://chartmuseum.github.io/charts
helm upgrade --install chartmuseum chartmuseum/chartmuseum --namespace=chartmuseum -f kubernetes-templating/chartmuseum/values.yaml

Проверяем
```console
curl https://chartmuseum.158.160.128.32.sslip.io
<!DOCTYPE html>
<html>
<head>
<title>Welcome to ChartMuseum!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to ChartMuseum!</h1>
<p>If you see this page, the ChartMuseum web server is successfully installed and
working.</p>

<p>For online documentation and support please refer to the
<a href="https://github.com/helm/chartmuseum">GitHub project</a>.<br/>

<p><em>Thank you for using ChartMuseum.</em></p>
</body>
</html>
```
Задание с *

Добавляем репозиторий  helm repo add ownrepo https://chartmuseum.158.160.128.32.sslip.io/api/charts
Добавлем чарт в архив helm package frontend/
Выгружаем его в chartmuseum curl --data-binary "@frontend-0.1.0.tgz" https://chartmuseum.158.160.128.32.sslip.io/api/charts
Чтобы установить чарт нужно применить команду helm upgrade --install по аналогии указанной в методичке учитывая данные выше.

Устанавливаем harbor

helm repo add harbor https://helm.goharbor.io
helm upgrade --install harbor harbor/harbor --namespace=harbor -f kubernetes-templating/harbor/values.yaml

Провеярем
```console
curl https://harbor.158.160.128.32.sslip.io/
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8"/>
        <title>Harbor</title>
        <base href="/"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link rel="icon" type="image/x-icon" href="favicon.ico?v=2"/>
    <link rel="stylesheet" href="styles.75cb4562f0127450.css"></head>
    <body>
        <harbor-app>
            <div class="spinner spinner-lg app-loading app-loading-fixed">
                Loading...
            </div>
        </harbor-app>
    <script src="runtime.8c0f1593b67df90d.js" type="module"></script><script src="polyfills.4c1d388f8edda830.js" type="module"></script><script src="scripts.3846d86d42cdb753.js" defer></script><script src="main.74c786f6199709cc.js" type="module"></script></body>
</html>
```
Ставим helmfile
```console
wget https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
tar xzvf helmfile_0.159.0_linux_amd64.tar.gz -C /usr/bin
chmod +x /usr/bin/helmfile
helmfile init

The helm plugin diff is not installed, do you need to install it [y/n]: y
Install helm plugin diff
Installed plugin: diff

The helm plugin secrets is not installed, do you need to install it [y/n]: y
Install helm plugin secrets
Installed plugin: secrets

The helm plugin s3 is not installed, do you need to install it [y/n]: y
Install helm plugin s3
Downloading and installing helm-s3 v0.14.0 ...
Checksum is valid.
Installed plugin: s3

The helm plugin helm-git is not installed, do you need to install it [y/n]: y
Install helm plugin helm-git
Installed plugin: helm-git
```
Пеерходим в каталог с helmfile и применяем его

cd helmfile
helmfile apply

Проверяем установленные helm-charts
```console
helm list --all-namespaces

cert-manager    cert-manager    1               2023-11-30 00:28:00.690636157 +0300 MSK deployed        cert-manager-v1.13.2    v1.13.2    
chartmuseum     chartmuseum     1               2023-11-30 00:28:23.619121646 +0300 MSK deployed        chartmuseum-3.10.1      0.16.0     
harbor          harbor          1               2023-11-30 00:28:23.421106273 +0300 MSK deployed        harbor-1.13.1   
```
Проверяем работу своего собтвенного helm-chart на основе hipster-shop
```console
kubectl port-forward frontend-579d4f98ff-l54ph -n hipster-shop 9999:8080

kubectl get pod -n hipster-shop
NAME                                     READY   STATUS             RESTARTS   AGE
adservice-6fc45466fb-p6ksn               0/1     ImagePullBackOff   0          85m
cartservice-6ff8c8f5d5-r4sn9             1/1     Running            0          85m
checkoutservice-5d85bbcdf6-zzk6b         1/1     Running            0          85m
currencyservice-66b766c54-vgxft          1/1     Running            0          85m
emailservice-7b6976c6fd-4xhxx            1/1     Running            0          85m
frontend-579d4f98ff-l54ph                1/1     Running            0          85m
paymentservice-747d798fcb-gz7zh          1/1     Running            0          85m
productcatalogservice-54dd969dbb-xfps2   1/1     Running            0          85m
recommendationservice-787587d98b-khfst   1/1     Running            0          85m
redis-cart-7667674fc7-2h4tv              1/1     Running            0          85m
shippingservice-5c4578569b-xdl29         1/1     Running            0          85m
```
Выносим frontend в отдельный helm-chart

helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop
Release "hipster-shop" has been upgraded. Happy Helming!
```console
kubectl get pod -n hipster-shop
NAME                                     READY   STATUS             RESTARTS   AGE
adservice-6fc45466fb-p6ksn               0/1     Running            0          86m
cartservice-6ff8c8f5d5-r4sn9             1/1     Running            0          86m
checkoutservice-5d85bbcdf6-zzk6b         1/1     Running            0          86m
currencyservice-66b766c54-vgxft          1/1     Running            0          86m
emailservice-7b6976c6fd-4xhxx            1/1     Running            0          86m
frontend-579d4f98ff-l54ph                1/1     Terminating        0          86m
paymentservice-747d798fcb-gz7zh          1/1     Running            0          86m
productcatalogservice-54dd969dbb-xfps2   1/1     Running            0          86m
recommendationservice-787587d98b-khfst   1/1     Running            0          86m
redis-cart-7667674fc7-2h4tv              1/1     Running            0          86m
shippingservice-5c4578569b-xdl29         1/1     Running            0          86m
```
helm upgrade --install frontend kubernetes-templating/frontend --namespace hipstershop

Затем удаляем чарт frontend и устанавливаем его как зависимость в hipster-shop, так же пробуем изменить значение параметра чарта при его деплое.

helm upgrade --install hipster-shop kubernetes-templating/hipster-shop --namespace hipster-shop --set frontend.service.nodePort=31234
```console
kubectl get svc -n hipster-shopNAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
adservice               ClusterIP   10.96.147.181   <none>        9555/TCP       4h57m
cartservice             ClusterIP   10.96.237.242   <none>        7070/TCP       4h57m
checkoutservice         ClusterIP   10.96.141.164   <none>        5050/TCP       4h57m
currencyservice         ClusterIP   10.96.198.144   <none>        7000/TCP       4h57m
emailservice            ClusterIP   10.96.193.249   <none>        5000/TCP       4h57m
frontend                NodePort    10.96.161.187   <none>        80:31234/TCP 
```
Задание с *

Выносим redis-cart в отдельный чарт, устанавливаем его как зависимость в hipster-shop и делаем его upgrade

helm create kubernetes-templating/redis

С помощью helm-secrets щифруем файл

sops -e -i --pgp 891F97AED24AE6D7E759A53F829F3C3089966185  kubernetes-templating/frontend/secrets.yaml

Проверяем возможность дешифрации

sops -d kubernetes-templating/frontend/secrets.yaml
visibleKey: hiddenValue

Убираем из namespace и чарта hipster-shop все,что связано с микросервисом frontend и делаем его upgrade манифестом secrets.yaml

helm secrets upgrade --install frontend kubernetes-templating/frontend -n hipster-shop  -f kubernetes-templating/frontend/values.yaml  -f kubernetes-templating/frontend/secrets.yam

Проверяем наличие серета в кластере и его значение

kubectl get secret secret -n hipster-shop -o yaml | grep visibleKey | awk '{print $2}' | base64 --decode
hiddenValue

Создаем package чартов

helm package hipster-shop/
helm package frontend/

И делаем push скриптом repo.sh

Pulled: harbor.158.160.128.32.sslip.io/library/hipster-shop:0.1.0
Digest: sha256:9dcd42f8203f71cedc65f20a73cb9526414e2c6578b0dbc1006a2f42c81831e8

Pulled: harbor.158.160.128.32.sslip.io/library/frontend:0.1.0
Digest: sha256:e847348397e54967747b01ce1f821e4cce7227edd413843aaa800130ffd73234
```
Выносим необходимы манифесты в ./kubecfg и пишем файл kubernetes-templating/kubecfg/services.jsonnet

Проверяем коректность заполнения манифестов по шаблону и устнавливаем их

kubecfg show kubernetes-templating/kubecfg/services.jsonnet
kubecfg update kubernetes-templating/kubecfg/services.jsonnet --namespace hipster-shop
```console
INFO  Validating deployments shippingservice
INFO  validate object "apps/v1, Kind=Deployment"
INFO  Validating services shippingservice
INFO  validate object "/v1, Kind=Service"
INFO  Validating deployments paymentservice
INFO  validate object "apps/v1, Kind=Deployment"
INFO  Validating services paymentservice
INFO  validate object "/v1, Kind=Service"
INFO  Fetching schemas for 4 resources
INFO  Creating services paymentservice
INFO  Creating services shippingservice
INFO  Creating deployments paymentservice
INFO  Creating deployments shippingservice
```
Проверяем, что работа корзины восстановилась

Задание с *

Выносим манифест в ./jsonnet и делаем qbec init

Правильность заполнения манифестов можно проверить командой

qbec show default > manifests.yaml

После этого прогоняем их и устанавливаем
```console
qbec apply -n default
qbec apply default

setting cluster to yc-managed-k8s-catfennlnfbrqa489fnm
setting context to yc-kub-test
cluster metadata load took 457ms
2 components evaluated in 5ms

will synchronize 2 object(s)

Do you want to continue [y/n]: y
2 components evaluated in 8ms
create deployments cartservice -n hipster-shop (source deployment)
create services cartservice -n hipster-shop (source service)
waiting for deletion list to be returned
server objects load took 625ms
---
stats:
  created:
  - deployments cartservice -n hipster-shop (source deployment)
  - services cartservice -n hipster-shop (source service)

waiting for readiness of 1 objects
  - deployments cartservice -n hipster-shop

  0s    : deployments cartservice -n hipster-shop :: 0 of 1 updated replicas are available
✓ 20s   : deployments cartservice -n hipster-shop :: successfully rolled out (0 remaining)

✓ 20s: rollout complete
command took 27.73s
```
Делаем Kustomize сервиса согласно заданию и проверяем
```console
kubectl apply -k kubernetes-templating/kustomize/overrides/dev
kubectl apply -k kubernetes-templating/kustomize/overrides/prod

kubectl get pods -n hipster-shop
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-5856d7f578-zzxlv               1/1     Running   0          119s

kubectl get pods -n hipster-shop-prodNAME                            READY   STATUS    RESTARTS   AGE
prod-adservice-f88c67c8-dw7qm   1/1     Running   0          102s
```

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

Шифруем командой echo -n 'my_string' | base64 access_key и secret_key манифеста minio-statefulset.yaml и вносим их в secrets.yaml, затем применяем эти манифесты

echo -n 'minio' | base64
bWluaW8=
echo -n 'minio123' | base64
bWluaW8xMjM=

Задание создание и использование PVC -опциональное

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
