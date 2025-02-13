# Frontend service - Privacy Pulse

## Technologies
- React
- TypeScript
- Tailwind CSS with styled components from **shadcn**.

### Run with npm
```bash
npm install
npm run dev
```

### Run with Docker
```bash
docker build -t frontend .
docker run -p 3000:3000 frontend
```

### Run with minikube
```bash
minikube start
minikube addons enable ingress
kubectl apply -f k8s
minikube tunnel
(needs to be updated)
```
