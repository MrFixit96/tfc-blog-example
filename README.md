# tfe-demo

```

```

### Configuring Terraform Enterprise Helper
```
tfh curl-config -tfrc
export TFH_hostname="app.terraform.io"
export TFH_org="hc-se-tfe-demo-neil"
```

### Setting Azure Credentials

```
export TFH_name="AZURE-PROD-two-tier-tfe-demo-app"
export ARM_SUBSCRIPTION_ID=$(echo $AZURE_SP_DATA | jq -r .appId)
export AZURE_SP_DATA=$(cat ~/.azure/sp-for-tfc.json)
export ARM_CLIENT_ID=$(echo $AZURE_SP_DATA | jq -r .appId)
export ARM_CLIENT_SECRET=$(echo $AZURE_SP_DATA | jq -r .password)
export ARM_TENANT_ID=$(echo $AZURE_SP_DATA | jq -r .tenant)
```

### Setting Google Cloud Credentials
```
export TFH_name="GCP-PROD-two-tier-tfe-demo-app"
export GOOGLE_CLOUD_KEYFILE_JSON=$(cat ~/.gcp/hashi/hc-se-tfe-demo-app-neil-dahlke-256e6066c67f.json | tr -d "\n")

tfh pushvars \
    -org hc-se-tfe-demo-neil \
    -name GCP-PROD-two-tier-tfe-demo-app \
    -overwrite-all \
    -dry-run false \
    -var "gcp_region=us-west1" \
    -var "gcp_region_zone=us-west1-a" \
    -var "gcp_project_name=neil-dahlke" \
    -hcl-var 'gcp_instance_tags=["neil-test"]' \
    -var "num_instances=1"
    # -var-file terraform.tfvars

tfh pushvars \
    -org hc-se-tfe-demo-neil \
    -name GCP-PROD-two-tier-tfe-demo-app \
    -overwrite-all \
    -dry-run false \
    -senv-var "GOOGLE_CLOUD_KEYFILE_JSON='$GOOGLE_CLOUD_KEYFILE_JSON'"
```


### Testing the Sentinel Code

```
sentinel test
```