

```
apiVersion: v1
kind: Secret
metadata:
  name: progress-cfg
  namespace: default
data:
  progress.cfg: <base64 encoded progress.cfg string here>
type: Opaque
```

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sports2020-db
  labels:
    app: sports2020
    component: db
spec:
  serviceName: "sports2020-db-svc"
  replicas: 1
  selector:
    matchLabels:
      app: sports2020
      component: db
  template:
    metadata:
      name: db-sts
      labels: 
        app: sports2020
        component: db
    spec:
      containers:
        - name: sports2020-db-cntnr
          image: docker.io/devbfvio/sports2020-db:12.8.3
          imagePullPolicy: Always

          resources:
            limits:
              memory: "1024Mi"
              cpu: "500m"

          ports:
          - containerPort: 10000
            name: brokerport
          - containerPort: 10001
            name: serverport-0
          - containerPort: 10002
            name: serverport-1
          # ...

          volumeMounts:
            - name: progress-cfg
              mountPath: /app/license/
              readOnly: true

      volumes:
        - name: progress-cfg
          secret: 
            secretName: progress-cfg
```
