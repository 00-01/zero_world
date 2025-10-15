# Infrastructure as Code

## Overview
Infrastructure definitions for trillion-scale deployment across multiple cloud providers and regions.

## Directory Structure

```
infrastructure/
├── kubernetes/              # Kubernetes manifests
│   ├── clusters/           # Cluster definitions (1000+ clusters)
│   ├── namespaces/        # Namespace per service
│   ├── deployments/       # Deployment configs
│   ├── services/          # Service definitions
│   ├── ingress/           # Ingress controllers
│   ├── configmaps/        # Configuration management
│   └── secrets/           # Secrets management (sealed secrets)
├── terraform/             # Cloud infrastructure provisioning
│   ├── aws/              # AWS resources
│   ├── gcp/              # Google Cloud resources
│   ├── azure/            # Azure resources
│   ├── multi-cloud/      # Multi-cloud orchestration
│   └── modules/          # Reusable modules
├── ansible/              # Configuration management
│   ├── playbooks/
│   ├── roles/
│   └── inventory/
├── helm-charts/          # Kubernetes package management
│   ├── services/        # Service charts
│   ├── infrastructure/  # Infrastructure charts
│   └── monitoring/      # Monitoring stack charts
└── service-mesh/         # Istio/Linkerd configurations
    ├── traffic-management/
    ├── security/
    └── observability/
```

## Cloud Providers

### AWS (Primary)
- **Regions:** 25+ regions worldwide
- **Services:** 
  - Compute: EC2, EKS, Lambda, Fargate
  - Storage: S3, EBS, EFS
  - Database: RDS, DynamoDB, ElastiCache
  - Networking: VPC, Route53, CloudFront
  - Message Queues: SQS, SNS, MSK (Kafka)

### Google Cloud Platform
- **Regions:** 20+ regions
- **Services:**
  - Compute: GCE, GKE, Cloud Functions
  - Storage: Cloud Storage, Persistent Disk
  - Database: Cloud SQL, Firestore, Memorystore
  - Networking: VPC, Cloud Load Balancing
  - Message Queues: Pub/Sub

### Microsoft Azure
- **Regions:** 15+ regions
- **Services:**
  - Compute: Azure VMs, AKS, Azure Functions
  - Storage: Blob Storage, Azure Disk
  - Database: Azure SQL, Cosmos DB, Azure Cache
  - Networking: Virtual Network, Azure DNS

## Kubernetes Architecture

### Cluster Strategy
```yaml
# Regional cluster distribution
clusters:
  production:
    us-east-1: 50 clusters (200M users)
    us-west-2: 50 clusters (200M users)
    eu-west-1: 40 clusters (150M users)
    ap-southeast-1: 60 clusters (250M users)
    # ... 46 more regions
  
  total_clusters: 1000+
  nodes_per_cluster: 1000+
  total_nodes: 1,000,000+
```

### Node Pools
```
- Critical services: High-memory, High-CPU (128 vCPU, 1TB RAM)
- Standard services: Medium instances (64 vCPU, 512GB RAM)
- Background jobs: Spot instances (32 vCPU, 256GB RAM)
- Edge computing: Low-latency instances near users
```

### Auto-Scaling
```yaml
horizontal_pod_autoscaler:
  min_replicas: 10
  max_replicas: 10000
  target_cpu_utilization: 70%
  target_memory_utilization: 80%

cluster_autoscaler:
  min_nodes: 100
  max_nodes: 100000
  scale_down_delay: 10m
```

## Terraform Structure

### Module Organization
```
terraform/
├── modules/
│   ├── vpc/                 # Virtual private cloud
│   ├── eks/                 # Elastic Kubernetes Service
│   ├── rds/                 # Relational Database Service
│   ├── redis/               # Redis clusters
│   ├── kafka/               # Kafka clusters
│   ├── monitoring/          # Prometheus, Grafana
│   └── security/            # Security groups, IAM
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── global/
    ├── route53/             # DNS management
    ├── cloudfront/          # CDN
    └── iam/                 # Identity & Access Management
```

### Example: EKS Cluster Module
```hcl
module "eks_cluster" {
  source = "./modules/eks"
  
  cluster_name = "zero-world-us-east-1-prod-01"
  region = "us-east-1"
  vpc_id = module.vpc.vpc_id
  
  node_groups = {
    critical = {
      instance_types = ["r6i.32xlarge"]
      min_size = 100
      max_size = 1000
      desired_size = 500
    }
    standard = {
      instance_types = ["m6i.16xlarge"]
      min_size = 500
      max_size = 5000
      desired_size = 2000
    }
    spot = {
      instance_types = ["m6i.8xlarge"]
      capacity_type = "SPOT"
      min_size = 100
      max_size = 10000
      desired_size = 1000
    }
  }
  
  tags = {
    Environment = "production"
    Region = "us-east-1"
    Cluster = "01"
  }
}
```

## Service Mesh

### Istio Configuration
```yaml
# Global mesh config
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-control-plane
spec:
  profile: production
  components:
    pilot:
      k8s:
        replicaCount: 10
        resources:
          requests:
            cpu: 4000m
            memory: 8Gi
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        replicaCount: 100
        hpaSpec:
          minReplicas: 100
          maxReplicas: 1000
```

### Traffic Management
- Intelligent routing
- Load balancing (round-robin, least-request, random)
- Circuit breaking
- Timeouts & retries
- Rate limiting

## Monitoring Stack

### Prometheus
```yaml
# Multi-cluster Prometheus federation
prometheus:
  global:
    scrape_interval: 15s
    evaluation_interval: 15s
    external_labels:
      cluster: '${CLUSTER_NAME}'
      region: '${REGION}'
  
  # Thanos for long-term storage
  thanos:
    enabled: true
    objectStorageConfig:
      type: S3
      bucket: zero-world-metrics
```

### Grafana Dashboards
- System overview (CPU, Memory, Network)
- Application metrics (Latency, Throughput, Error rate)
- Business metrics (DAU, Revenue, Churn)
- Database metrics (Query time, Connections, Replication lag)
- Cache metrics (Hit rate, Evictions)

## Security

### Network Security
```
- VPC isolation per environment
- Security groups with least privilege
- Network ACLs
- Private subnets for databases
- NAT gateways for outbound traffic
```

### Secrets Management
```
- AWS Secrets Manager / Google Secret Manager
- Sealed Secrets for Kubernetes
- External Secrets Operator
- Vault for dynamic secrets
- Regular rotation (90 days)
```

### Compliance
- SOC 2 Type II
- ISO 27001
- GDPR compliance
- HIPAA compliance (for healthcare features)
- PCI DSS (for payments)

## Disaster Recovery

### Backup Strategy
```yaml
databases:
  automated_backups:
    frequency: every_hour
    retention: 30_days
  manual_snapshots:
    frequency: daily
    retention: 1_year
  cross_region_replication: enabled
  
volumes:
  snapshots:
    frequency: every_6_hours
    retention: 14_days
```

### Failover Process
```
1. Health check failures detected (<30 seconds)
2. Route53 DNS failover triggered
3. Traffic redirected to backup region
4. Auto-scaling adjusts capacity
5. Alerts sent to on-call team
6. Post-mortem within 24 hours
```

## Cost Management

### Resource Tagging
```
Mandatory tags:
- Environment (dev/staging/prod)
- Service (service name)
- Team (owning team)
- Cost-center (budget allocation)
- Expiry (for temporary resources)
```

### Cost Optimization
- Reserved instances (1-3 years): 40% savings
- Spot instances (batch jobs): 70% savings
- Auto-scaling: Reduce idle capacity
- Right-sizing: Match resources to workload
- S3 lifecycle policies: Archive to Glacier

### Budget Alerts
```
Monthly budget: $8.3B (for 1T users @ $100/user/year)
Alerts at: 50%, 75%, 90%, 100% of budget
Daily cost tracking per service
Anomaly detection for unexpected spikes
```

## Getting Started

### Prerequisites
```bash
# Install tools
brew install terraform
brew install kubectl
brew install helm
brew install aws-cli
brew install google-cloud-sdk

# Configure credentials
aws configure
gcloud auth login
az login
```

### Deploy Infrastructure
```bash
# Initialize Terraform
cd infrastructure/terraform/production/us-east-1
terraform init

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Deploy to Kubernetes
cd infrastructure/kubernetes
kubectl apply -f namespaces/
kubectl apply -f deployments/
kubectl apply -f services/
```

### Monitoring
```bash
# Port-forward to Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# View logs
kubectl logs -f deployment/<service-name> -n <namespace>
```

## Maintenance

### Regular Tasks
- Weekly: Security patches
- Monthly: Kubernetes version upgrades
- Quarterly: Cost optimization review
- Yearly: Disaster recovery drill

### Runbooks
See `/docs/runbooks/` for detailed procedures:
- Incident response
- Database failover
- Service rollback
- Capacity planning
- Performance tuning

---

**Infrastructure designed to scale from current deployment to 1 trillion users across 50+ regions.**
