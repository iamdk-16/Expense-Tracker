#!/bin/bash
set -e

echo "🚀 Starting local development deployment..."

# Ensure Kind cluster is running
if ! kind get clusters | grep -q expense-tracker-cicd; then
    echo "Creating Kind cluster..."
    kind create cluster --config=kind-config.yaml
fi

echo "📦 Building Docker images locally..."
docker build -t $USER/expense-tracker-backend:dev ./backend
docker build -t $USER/expense-tracker-frontend:dev ./frontend/expense-tracker

echo "📤 Loading images into Kind cluster..."
kind load docker-image $USER/expense-tracker-backend:dev --name expense-tracker-cicd
kind load docker-image $USER/expense-tracker-frontend:dev --name expense-tracker-cicd

echo "🔧 Deploying to Kubernetes..."
# Create temporary manifest with local images
sed "s|YOUR_DOCKERHUB_USERNAME/expense-tracker-backend:latest|$USER/expense-tracker-backend:dev|g; s|YOUR_DOCKERHUB_USERNAME/expense-tracker-frontend:latest|$USER/expense-tracker-frontend:dev|g" k8s/base/expense-tracker.yaml > k8s/base/expense-tracker-local.yaml

# Deploy
kubectl apply -f k8s/base/expense-tracker-local.yaml

echo "⏳ Waiting for deployments..."
kubectl rollout status deployment/expense-tracker-backend -n expense-tracker --timeout=300s
kubectl rollout status deployment/expense-tracker-frontend -n expense-tracker --timeout=300s
kubectl rollout status deployment/prometheus -n expense-tracker --timeout=300s
kubectl rollout status deployment/grafana -n expense-tracker --timeout=300s

echo "✅ Development environment ready!"
echo "🌐 Frontend: http://localhost:30080"
echo "📊 Prometheus: http://localhost:30090"
echo "📈 Grafana: http://localhost:30300"

# Cleanup temp file
rm k8s/base/expense-tracker-local.yaml
