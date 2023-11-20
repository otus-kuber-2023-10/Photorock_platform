# Photorock_platform
Photorock Platform repository

TASK 3

Идем по методичке и последовательно создаем и применяем манифесты и указания по установке IPVS, которые указаны в ней

Mmetallb ставим так

MetalLB_RTAG=$(curl -s https://api.github.com/repos/metallb/metallb/releases/latest|grep tag_name|cut -d '"' -f 4|sed 's/v//')
echo $MetalLB_RTAG
wget https://raw.githubusercontent.com/metallb/metallb/v$MetalLB_RTAG/config/manifests/metallb-native.yaml

Проверяем установку

kubectl get pods -n metallb-system
NAME                          READY   STATUS    RESTARTS   AGE
controller-565ccc769f-hm26r   1/1     Running   0          10h
speaker-x55dl                 1/1     Running   0          10h

Проверяем http://172.17.255.1/index.html - старница открывается

Задание со * 1

Применяем манифест из ./coredns репозитория

Проверяем

nslookup web.default.cluster.local 172.17.255.10
Server:         172.17.255.10
Address:        172.17.255.10#53

** server can't find web.default.cluster.local: NXDOMAIN

Идем по методичке и последовательно создаем и применяем манифесты и указания по установке Ingress, которые указаны в ней

Ingress-nginx-controller ставим отсюда 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml 

Проверяем установку

kubectl get pod -n ingress-nginx 
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-f8grp        0/1     Completed   0          7h32m
ingress-nginx-admission-patch-mb4xf         0/1     Completed   0          7h32m
ingress-nginx-controller-778d4c6454-pcbsc   1/1     Running     0          7h32m

При следующей проверке видим, что создание и применение манифеста из методички nginx-lb.yaml избыточна, так как необходимая служба уже создана при установке Ingress-nginx-controller

kubectl get svc -n ingress-nginx 
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx                        LoadBalancer   10.110.123.98   172.17.255.3   80:30426/TCP,443:30875/TCP   7h8m
ingress-nginx-controller             LoadBalancer   10.99.71.30     172.17.255.2   80:31434/TCP,443:31684/TCP   7h13m
ingress-nginx-controller-admission   ClusterIP      10.102.209.83   <none>         443/TCP                      7h13m

Проверяем http://172.17.255.2/web/index.html - страница открывается

Задание со * 2
Ставим дащбоард отсюда
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

Применяем манифест из ./dashboard репозитория

Проверяем http://172.17.255.2/dashboard/ - страница переадресовывается на http://172.17.255.2/dashboard/#/login и открывается

Задание со * 3

Создаем канареечный под на основе ./web-deploy.yaml c заменой index.html на следующий шаблон 

<!DOCTYPE html>
<html>
<head>
        <title>Заголовок</title>
</head>
<body>
        "Hello World!"
</body>
</html>

Применяем манифесты из ./canary репозитория

Проверяем - при изменении заголока на канареечный - мы попадем на канареечную страницу

curl -H "canary: always" http://172.17.255.2/web/index.html
<!DOCTYPE html>
<html>
<head>
        <title>Заголовок</title>
</head>
<body>
        "Hello World!"
</body>
</html>
