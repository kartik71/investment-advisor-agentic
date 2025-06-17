# InvestAssist Pro - Azure Deployment Guide

This document provides instructions for deploying the InvestAssist Pro application to Azure using Docker containers.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- [Docker](https://www.docker.com/get-started) installed
- An active Azure subscription
- Azure Container Registry (ACR) created in your subscription

## Deployment Steps

### 1. Configure Azure Resources

Before deploying, update the configuration files with your specific Azure resource information:

- In `azure-deploy.sh`:
  - Update `ACR_NAME` with your Azure Container Registry name
  - Update `IMAGE_NAME` and `IMAGE_TAG` as needed

- In `azure-config.yml`:
  - Update `resourceGroup` with your Azure resource group name
  - Update `location` with your preferred Azure region
  - Adjust container resources (CPU, memory) as needed

### 2. Build and Push Docker Image

Make the deployment script executable and run it:

```bash
chmod +x azure-deploy.sh
./azure-deploy.sh
```

This script will:
- Build the Docker image using the main `Dockerfile`
- Log in to your Azure Container Registry
- Tag the image appropriately
- Push the image to your Azure Container Registry

### 3. Deploy to Azure Container Apps

You can deploy to Azure Container Apps using the Azure CLI:

```bash
# Create secrets for database and redis connection strings
az containerapp secret set --name investassist-pro --resource-group your-resource-group \
  --secrets "database-connection-string=postgresql://username:password@your-db-server.postgres.database.azure.com:5432/investassist" \
  "redis-connection-string=redis://your-redis-instance.redis.cache.windows.net:6380,password=your-password,ssl=True,abortConnect=False"

# Create the container app
az containerapp create --name investassist-pro \
  --resource-group your-resource-group \
  --environment your-container-apps-environment \
  --image your-registry.azurecr.io/investassist-pro:latest \
  --target-port 8501 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 5 \
  --secrets "database-connection-string=postgresql://username:password@your-db-server.postgres.database.azure.com:5432/investassist" \
  "redis-connection-string=redis://your-redis-instance.redis.cache.windows.net:6380,password=your-password,ssl=True,abortConnect=False" \
  --env-vars "ENVIRONMENT=production" "DATABASE_URL=secretref:database-connection-string" "REDIS_URL=secretref:redis-connection-string"
```

### 4. Alternative: Deploy to Azure Web App for Containers

You can also deploy to Azure Web App for Containers:

```bash
# Create an App Service plan
az appservice plan create --name investassist-plan --resource-group your-resource-group --sku B2 --is-linux

# Create the web app
az webapp create --resource-group your-resource-group \
  --plan investassist-plan \
  --name investassist-pro \
  --deployment-container-image-name your-registry.azurecr.io/investassist-pro:latest

# Configure environment variables
az webapp config appsettings set --resource-group your-resource-group --name investassist-pro \
  --settings ENVIRONMENT=production DATABASE_URL="postgresql://username:password@your-db-server.postgres.database.azure.com:5432/investassist" \
  REDIS_URL="redis://your-redis-instance.redis.cache.windows.net:6380,password=your-password,ssl=True,abortConnect=False"
```

## Database and Redis Setup

For production deployments, it's recommended to use Azure Database for PostgreSQL and Azure Cache for Redis:

1. **Azure Database for PostgreSQL**:
   - Create an Azure Database for PostgreSQL instance
   - Update the connection string in your deployment configuration

2. **Azure Cache for Redis**:
   - Create an Azure Cache for Redis instance
   - Update the connection string in your deployment configuration

## Monitoring and Scaling

- Set up Azure Application Insights for monitoring
- Configure auto-scaling rules in the Azure portal based on your application's needs
- Set up alerts for critical metrics

## Security Considerations

- Store sensitive connection strings in Azure Key Vault
- Configure managed identities for secure access to Azure resources
- Set up network security groups to restrict access to your resources

## Troubleshooting

- Check container logs in the Azure portal
- Use Azure Monitor to track application performance
- Review the application's health endpoint at `/_stcore/health`
