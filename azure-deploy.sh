#!/bin/bash
# Azure Container Registry deployment script for InvestAssist Pro

# Configuration - Update these values
ACR_NAME="investassistregistry"  # Your Azure Container Registry name
IMAGE_NAME="investassist-pro"    # Name for your container image
IMAGE_TAG="latest"               # Tag for your image version

# Login to Azure (uncomment if not already logged in)
# az login

# Build the Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Log in to Azure Container Registry
echo "Logging in to Azure Container Registry..."
az acr login --name $ACR_NAME

# Tag the image for ACR
echo "Tagging image for ACR..."
docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

# Push the image to ACR
echo "Pushing image to Azure Container Registry..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

echo "Deployment complete! Your image is now available at: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "Next steps:"
echo "1. Create an Azure Web App for Containers or Azure Container Instance"
echo "2. Configure it to use your container image: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
echo "3. Set up any required environment variables in the Azure portal"
echo ""
echo "For Azure Web App, use: az webapp create --resource-group <your-resource-group> --plan <your-app-service-plan> --name <your-app-name> --deployment-container-image-name $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
