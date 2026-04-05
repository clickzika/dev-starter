# HashiCorp Vault Configuration Template
# DevStarter — Enterprise Secrets Management
# Usage: Copy to your infrastructure repo, fill in {{PLACEHOLDERS}}
#
# Requires: Vault 1.15+ (OSS or Enterprise)
# Docs: https://developer.hashicorp.com/vault/docs

# ─── Storage Backend ──────────────────────────────────────────────────────────
# Option A: Integrated storage (Raft) — recommended for new deployments
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-1"

  # For HA cluster add additional nodes:
  # retry_join {
  #   leader_api_addr = "https://vault-node-2:8200"
  # }
}

# Option B: Consul backend (existing Consul cluster)
# storage "consul" {
#   address = "127.0.0.1:8500"
#   path    = "vault/"
#   token   = "{{CONSUL_ACL_TOKEN}}"
# }

# ─── Listener ─────────────────────────────────────────────────────────────────
listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/etc/vault/tls/vault.crt"
  tls_key_file       = "/etc/vault/tls/vault.key"
  tls_min_version    = "tls12"

  # Telemetry endpoint (Prometheus scraping)
  telemetry {
    unauthenticated_metrics_access = false
  }
}

# ─── Seal (auto-unseal) ───────────────────────────────────────────────────────
# Option A: AWS KMS auto-unseal
seal "awskms" {
  region     = "{{AWS_REGION}}"
  kms_key_id = "{{KMS_KEY_ID}}"
}

# Option B: Azure Key Vault auto-unseal
# seal "azurekeyvault" {
#   tenant_id      = "{{AZURE_TENANT_ID}}"
#   client_id      = "{{AZURE_CLIENT_ID}}"
#   client_secret  = "{{AZURE_CLIENT_SECRET}}"
#   vault_name     = "{{AZURE_VAULT_NAME}}"
#   key_name       = "{{AZURE_KEY_NAME}}"
# }

# Option C: GCP Cloud KMS auto-unseal
# seal "gcpckms" {
#   project     = "{{GCP_PROJECT}}"
#   region      = "{{GCP_REGION}}"
#   key_ring    = "{{GCP_KEY_RING}}"
#   crypto_key  = "{{GCP_CRYPTO_KEY}}"
# }

# ─── Core Settings ────────────────────────────────────────────────────────────
api_addr     = "https://{{VAULT_DOMAIN}}:8200"
cluster_addr = "https://{{VAULT_DOMAIN}}:8201"
ui           = true

log_level  = "info"   # trace | debug | info | warn | error
log_format = "json"

# ─── Telemetry ────────────────────────────────────────────────────────────────
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}
