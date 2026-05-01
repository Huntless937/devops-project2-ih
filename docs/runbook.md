# Runbook — Burger Builder Production Operations

## Quick Reference

| Resource | Value |
|---|---|
| Resource Group | rg-tfstate-Group7 |
| App Gateway IP | 40.67.225.150 |
| Frontend VM | vm-frontend-group7 (10.0.1.4) |
| Backend VM | vm-backend-group7 (10.0.2.4) |
| SQL Server | sql-burgerbuilder-group7.database.windows.net |
| Region | North Europe |

---

## 1. Check Application Health

```bash
# Frontend
curl http://40.67.225.150/

# API health
curl http://40.67.225.150/api/health

# API ingredients (proves SQL connection)
curl http://40.67.225.150/api/ingredients
```

Expected response for health:
```json
{"service":"burger-builder-backend","version":"1.0.0","status":"UP"}
```

---

## 2. SSH into VMs

> VMs have no public IPs by default. Requires public IP or Bastion.

```bash
# Frontend VM
ssh -i ~/.ssh/burgerbuilder azureuser@<frontend-public-ip>

# Backend VM
ssh -i ~/.ssh/burgerbuilder azureuser@<backend-public-ip>
```

---

## 3. Check Backend Service

```bash
# SSH into backend VM first
ssh -i ~/.ssh/burgerbuilder azureuser@<backend-ip>

# Check service status
sudo systemctl status burgerbuilder

# View logs
sudo journalctl -u burgerbuilder -f

# View last 50 lines
sudo journalctl -u burgerbuilder -n 50 --no-pager

# Restart service
sudo systemctl restart burgerbuilder

# Stop service
sudo systemctl stop burgerbuilder

# Start service
sudo systemctl start burgerbuilder
```

---

## 4. Check Frontend Service (Nginx)

```bash
# SSH into frontend VM first
ssh -i ~/.ssh/burgerbuilder azureuser@<frontend-ip>

# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx

# Test Nginx config
sudo nginx -t
```

---

## 5. Backend Environment Variables

```bash
# SSH into backend VM
ssh -i ~/.ssh/burgerbuilder azureuser@<backend-ip>

# View env file
cat /opt/burgerbuilder/.env

# Edit env file
sudo nano /opt/burgerbuilder/.env

# After editing, restart service
sudo systemctl restart burgerbuilder
```

---

## 6. Deploy New Version Manually

### Frontend
```bash
# Build locally
cd frontend
npm run build

# Run Ansible deploy
ansible-playbook config/ansible/site.yml \
  -i config/ansible/inventories/dev/hosts.yml \
  --limit frontend \
  --private-key ~/.ssh/burgerbuilder \
  --extra-vars "frontend_build_path=frontend/dist/" \
  -u azureuser
```

### Backend
```bash
# Build locally
cd backend
mvn clean package -DskipTests

# Run Ansible deploy
ansible-playbook config/ansible/site.yml \
  -i config/ansible/inventories/dev/hosts.yml \
  --limit backend \
  --private-key ~/.ssh/burgerbuilder \
  --extra-vars "backend_jar_path=backend/target/burger-builder-backend-1.0.0.jar" \
  -u azureuser
```

---

## 7. Terraform Operations

```bash
cd infra/terraform/environments/dev

# Check current state
terraform show

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy everything (careful!)
terraform destroy
```

---

## 8. Check Azure Resources

```bash
# List all VMs and IPs
az vm list-ip-addresses \
  --resource-group rg-tfstate-Group7 \
  --output table

# Check App Gateway health
az network application-gateway show-backend-health \
  --name appgw-burgerbuilder-group7 \
  --resource-group rg-tfstate-Group7

# Check SQL server status
az sql server show \
  --name sql-burgerbuilder-group7 \
  --resource-group rg-tfstate-Group7 \
  --query "{name:name, publicAccess:publicNetworkAccess, state:state}"
```

---

## 9. Monitoring & Alerts

### View Alerts in Azure Portal
1. Go to **portal.azure.com**
2. Search **Monitor**
3. Click **Alerts**
4. Filter by resource group `rg-tfstate-Group7`

### Active Alerts
| Alert | Threshold | Action |
|---|---|---|
| alert-appgw-backend-health | UnhealthyHostCount > 0 | Check VM health, restart services |
| alert-vm-cpu-high | CPU > 70% for 5 min | Check running processes, consider scaling |
| alert-sql-dtu-high | DTU > 80% for 5 min | Optimize queries, consider scaling up |

### Kusto Queries (Log Analytics)

```kusto
-- Recent backend errors
AppExceptions
| where TimeGenerated > ago(1h)
| order by TimeGenerated desc
| take 20

-- App Gateway requests by status
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where TimeGenerated > ago(1h)
| summarize count() by httpStatus_d
| order by httpStatus_d asc

-- VM CPU over time
Perf
| where TimeGenerated > ago(1h)
| where CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart
```

---

## 10. Scaling

### Scale VM Size (Terraform)

Edit `infra/terraform/environments/dev/terraform.tfvars`:
```hcl
vm_size = "Standard_D4ads_v7"  # Upgrade from D2
```

Then apply:
```bash
terraform apply
```

### Scale SQL Database (Terraform)

Edit `infra/terraform/modules/database/main.tf`:
```hcl
resource "azurerm_mssql_database" "main" {
  sku_name = "S1"  # Upgrade from Basic
}
```

---

## 11. Common Issues & Fixes

### Frontend shows "Failed to load ingredients"
```bash
# Check API is responding
curl http://40.67.225.150/api/health

# Check backend service
ssh -i ~/.ssh/burgerbuilder azureuser@<backend-ip>
sudo systemctl status burgerbuilder
sudo journalctl -u burgerbuilder -n 20 --no-pager
```

### Backend service won't start
```bash
# Check env file exists
ls -la /opt/burgerbuilder/.env

# Check env file contents
cat /opt/burgerbuilder/.env

# Check Java is installed
java -version

# Check JAR exists
ls -la /opt/burgerbuilder/app.jar
```

### Terraform state lock error
```bash
# Force unlock (use lock ID from error message)
terraform force-unlock <lock-id>
```

### SSH Permission denied
```bash
# Re-add SSH key to VM
az vm user update \
  --resource-group rg-tfstate-Group7 \
  --name <vm-name> \
  --username azureuser \
  --ssh-key-value "$(cat ~/.ssh/burgerbuilder.pub)"
```

---

## 12. Backup & Recovery

### Terraform State Backup
State is stored in Azure Blob Storage:
- Storage Account: `tfstatefidail`
- Container: `tfstate`
- Key: `dev.terraform.tfstate`

Azure Blob Storage automatically versions state files.

### Database Backup
Azure SQL Basic tier includes automated backups:
- Full backup: weekly
- Differential: every 12 hours
- Transaction log: every 5-12 minutes
- Retention: 7 days

To restore:
1. Go to Azure Portal → SQL Database
2. Click **Restore**
3. Select point in time
4. Restore to new database