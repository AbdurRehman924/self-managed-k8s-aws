# Velero Backup & Disaster Recovery

## Overview
Velero provides backup and disaster recovery capabilities for the Hipster Shop Kubernetes cluster.

## Configuration

### Backup Storage
- **Provider**: Azure Blob Storage
- **Storage Account**: hipstershopbackups
- **Container**: velero-backups
- **Region**: Southeast Asia
- **Retention**: 30 days

### Components
- **Velero Server**: v1.13.0 (deployed in `velero` namespace)
- **Azure Plugin**: v1.9.0
- **Backup Location**: Available and validated

## Backup Operations

### Manual Backup
```bash
# Create backup of hipster-shop namespace
velero backup create <backup-name> --include-namespaces hipster-shop --wait

# List all backups
velero backup get

# Describe backup details
velero backup describe <backup-name>

# View backup logs
velero backup logs <backup-name>
```

### Scheduled Backups
- **Schedule**: Daily at 2:00 AM
- **Scope**: hipster-shop namespace
- **Retention**: 30 days
- **Manifest**: `k8s/backup/velero/schedule-daily.yaml`

```bash
# View schedules
velero schedule get

# Describe schedule
velero schedule describe hipster-shop-daily
```

## Restore Operations

### Full Namespace Restore
```bash
# Restore from backup
velero restore create <restore-name> --from-backup <backup-name> --wait

# List all restores
velero restore get

# Describe restore details
velero restore describe <restore-name>

# View restore logs
velero restore logs <restore-name>
```

### Selective Restore
```bash
# Restore specific resources
velero restore create <restore-name> \
  --from-backup <backup-name> \
  --include-resources deployments,services \
  --wait
```

## Disaster Recovery Procedure

### RTO/RPO Metrics
- **Recovery Time Objective (RTO)**: ~1 minute
- **Recovery Point Objective (RPO)**: 24 hours (daily backups)
- **Backup Duration**: ~5 seconds
- **Restore Duration**: ~36 seconds

### DR Steps
1. **Verify Backup Exists**
   ```bash
   velero backup get
   ```

2. **Disable ArgoCD Auto-Sync** (if applicable)
   ```bash
   kubectl patch application hipster-shop -n argocd --type merge -p '{"spec":{"syncPolicy":null}}'
   ```

3. **Restore from Backup**
   ```bash
   velero restore create disaster-recovery-$(date +%Y%m%d-%H%M%S) \
     --from-backup <backup-name> \
     --wait
   ```

4. **Verify Restoration**
   ```bash
   kubectl get pods -n hipster-shop
   kubectl get svc -n hipster-shop
   ```

5. **Re-enable ArgoCD Auto-Sync**
   ```bash
   kubectl patch application hipster-shop -n argocd --type merge -p '{
     "spec": {
       "syncPolicy": {
         "automated": {
           "prune": true,
           "selfHeal": true
         }
       }
     }
   }'
   ```

## Backup Verification

### Check Backup Location Status
```bash
velero backup-location get
```

### Verify Backups in Azure Storage
```bash
az storage blob list \
  --container-name velero-backups \
  --account-name hipstershopbackups \
  --output table
```

## Troubleshooting

### Backup Location Unavailable
```bash
# Check Velero logs
kubectl logs deployment/velero -n velero

# Verify credentials
kubectl get secret cloud-credentials -n velero -o yaml

# Test Azure connectivity
az storage container show \
  --name velero-backups \
  --account-name hipstershopbackups
```

### Restore Failures
```bash
# Check restore logs
velero restore logs <restore-name>

# Describe restore for warnings
velero restore describe <restore-name>
```

## Best Practices

1. **Regular Testing**: Test disaster recovery monthly
2. **Backup Validation**: Verify backups complete successfully
3. **Retention Policy**: Keep 30 days of backups
4. **Off-Cluster Storage**: Backups stored in Azure Blob (separate from cluster)
5. **Monitoring**: Monitor backup success/failure via Velero logs
6. **Documentation**: Keep DR runbook updated

## Resource Optimization

Due to cluster resource constraints:
- Node-agent DaemonSet removed (no persistent volume backups)
- Velero deployment uses minimal resources (100m CPU, 128Mi memory)
- Focus on cluster resource backups (deployments, services, configmaps, secrets)

## Backup Contents

Each backup includes:
- Deployments and ReplicaSets
- Services and Endpoints
- ConfigMaps and Secrets
- ServiceAccounts and RBAC
- Custom Resources (Istio, HPA, VPA, etc.)
- Namespace metadata

**Total Resources Backed Up**: 713 items per backup

## Tested Scenarios

✅ **Full Namespace Deletion & Restore**
- Deleted entire hipster-shop namespace
- Restored all 158 resources in 36 seconds
- All pods and services recovered successfully

## Maintenance

### Delete Old Backups
```bash
# Delete specific backup
velero backup delete <backup-name>

# Backups auto-expire after 30 days (TTL)
```

### Update Schedule
```bash
# Edit schedule
kubectl edit schedule hipster-shop-daily -n velero
```

## Cost Considerations

- **Azure Blob Storage**: ~$0.02/GB/month (Hot tier)
- **Current Backup Size**: ~565 KB per backup
- **Monthly Cost**: < $1 for 30 days of backups

---

**Last Updated**: March 1, 2026
**Velero Version**: v1.13.0
**Azure Plugin Version**: v1.9.0
