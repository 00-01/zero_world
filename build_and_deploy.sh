#!/bin/bash
# Build and deploy script for Zero World

set -e  # Exit on error

echo "🔨 Building Flutter web app..."
cd frontend/zero_world
flutter build web --release --pwa-strategy=none

echo "🐳 Building Docker image..."
cd ../..
docker-compose build frontend

echo "🚀 Deploying containers..."
docker-compose down
docker-compose up -d

echo "✅ Build and deployment complete!"
echo "🌐 App available at: https://www.zn-01.com"
