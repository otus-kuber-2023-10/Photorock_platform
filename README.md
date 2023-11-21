# Photorock_platform
Photorock Platform repository


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
      value: "adservice:9555
```
