apiVersion: apps/v1
kind: Deployment
metadata:
  name: headway-valhalla-deployment
spec:
  selector:
    matchLabels:
      app: valhalla
  replicas: 1
  template:
    metadata:
      labels:
        app: valhalla
    spec:
      initContainers:
        - name: valhalla-init
          image: ghcr.io/michaelkirk/valhalla-init:${HEADWAY_VERSION}
          imagePullPolicy: Always
          volumeMounts:
            - name: valhalla-volume
              mountPath: /data
          env:
            - name: VALHALLA_ARTIFACT_LOCK
              value: /data/imported
            - name: VALHALLA_ARTIFACT_URL
              valueFrom:
                configMapKeyRef:
                  name: deployment-config
                  key: valhalla-artifact-url
            - name: HEADWAY_AREA
              valueFrom:
                configMapKeyRef:
                  name: deployment-config
                  key: area
          resources:
            limits:
              memory: 200Mi
            requests:
              memory: 100Mi
      containers:
        - name: valhalla
          image: ghcr.io/michaelkirk/valhalla:${HEADWAY_VERSION}
          ports:
          - containerPort: 8002
          volumeMounts:
          - name: valhalla-volume
            mountPath: /data
          env:
          - name: HEADWAY_AREA
            valueFrom:
              configMapKeyRef:
                name: deployment-config
                key: area
          resources:
            limits:
              memory: 8Gi
            requests:
              memory: 4Gi
      volumes:
        - name: valhalla-volume
          ephemeral:
            volumeClaimTemplate:
              spec:
                accessModes: [ "ReadWriteOnce" ]
                resources:
                  requests:
                    storage: 200Gi