# Microservices Kubernetes Deployment Guide

## **Objective**
Deploy a microservices application on Kubernetes using Minikube, implementing proper service communication and ingress configuration.

---

## 📌 Prerequisites

Microservices application code hosted in GitHub repository

- Fork [https://github.com/mohanDevOps-arch/Microservices-Task.git](https://github.com/mohanDevOps-arch/Microservices-Task.git) to [https://github.com/ankitalodha05/Microservices-Task-1.git](https://github.com/ankitalodha05/Microservices-Task-1.git)
- Make sure Docker & Docker Compose, kubectl, and Minikube are installed on your machine.

Clone the GitHub repository:
```bash
git clone https://github.com/ankitalodha05/Microservices-Task-1.git
cd Microservices-Task-1.git
```

---

## **Step 1: Create Dockerfiles for Microservices**
Each microservice (User, Product, Order, Gateway) requires a `Dockerfile` inside its respective folder.

1. **Navigate to the microservices directory:**
```bash
cd Microservices
```

2. **Create a `Dockerfile` for each microservice:**
```dockerfile
# Dockerfile
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the service port
EXPOSE 3003

# Start the service
CMD ["node", "app.js"]
```

3. **Build and tag Docker images:**
```bash
docker build -t ankitalodha05/<microservice-name>:latest .
```
Example:
```bash
docker build -t ankitalodha05/user-service:latest .
docker build -t ankitalodha05/product-service:latest .
docker build -t ankitalodha05/order-service:latest .
docker build -t ankitalodha05/gateway-service:latest .
```

4. **Push images to Docker Hub:**
```bash
docker push ankitalodha05/<microservice-name>:latest
```

---

## **Step 2: Create Docker Compose File**
Create a `docker-compose.yml` file to run all microservices simultaneously.

```yaml
version: "3.8"
services:
  user-service:
    build:
      context: ./user-service
    ports:
      - "3000:3000"
    networks:
      - microservices-network
  product-service:
    build:
      context: ./product-service
    ports:
      - "3001:3001"
    networks:
      - microservices-network
  order-service:
    build:
      context: ./order-service
    ports:
      - "3002:3002"
    networks:
      - microservices-network
  gateway-service:
    build:
      context: ./gateway-service
    ports:
      - "3003:3003"
    networks:
      - microservices-network
    depends_on:
      - user-service
      - product-service
      - order-service

networks:
  microservices-network:
    driver: bridge

```

**Run the services:**
```bash
docker-compose up
```

---

## **Step 3: Install & Setup Minikube**
1. **Install Minikube** ([Download Here](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download))
2. **Start Minikube:**
```bash
minikube start --driver=docker
```
3. **Enable Ingress Controller:**
```bash
minikube addons enable ingress
```

---

## **Step 4: Create Kubernetes Manifests**
### **Folder Structure:**
```
k8s-manifests/
├── deployments/
│   ├── user-service.yaml
│   ├── product-service.yaml
│   ├── order-service.yaml
│   └── gateway-service.yaml
├── services/
│   ├── user-service.yaml
│   ├── product-service.yaml
│   ├── order-service.yaml
│   └── gateway-service.yaml
└── ingress/
    └── ingress.yaml
```

### **Deployment YAML (Example for User Service):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
        - name: user-service
          image: ankitalodha05/user
          ports:
            - containerPort: 3000
          resources:
            limits:
              memory: "256Mi"
              cpu: "500m"
            requests:
              memory: "128Mi"
              cpu: "250m"
          command: ["node" ,"app.js"]
          args: []

```

### **Ingress YAML:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
spec:
  rules:
  - host: microservices.local
    http:
      paths:
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /api/products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
      - path: /api/orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gateway-service
            port:
              number: 80


```

**Apply the manifests:**
```bash
kubectl apply -f k8s-manifests/deployments/
kubectl apply -f k8s-manifests/services/
kubectl apply -f k8s-manifests/ingress/
```

---

## **Step 5: Verify Deployment**
### **Check Running Pods:**
```bash
kubectl get pods
```
### **Check Services:**
```bash
kubectl get svc
```
### **Check Ingress:**
```bash
kubectl get ingress
```

---

## **Step 6: Access Services**
1. **Get Minikube IP:**
```bash
minikube ip
```
2. **Add to `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows):**
```
192.168.49.2 microservices.local
```
3. **Flush DNS (Windows):**
```powershell
ipconfig /flushdns
```
4. **Access Services:**
```bash
curl http://microservices.local/user
```

---

## **Final Checklist**
✅ Hosts file updated (`192.168.49.2 microservices.local`)
✅ Flushed DNS cache (`ipconfig /flushdns`)
✅ Minikube running (`minikube status`)
✅ Ingress enabled (`minikube addons enable ingress`)
✅ Services running (`kubectl get svc`)

If `microservices.local` is still not reachable, access services using:
```bash
minikube service user-service --url
```

🎯 **Congratulations! You have successfully deployed a microservices application on Kubernetes using Minikube! 🚀**
