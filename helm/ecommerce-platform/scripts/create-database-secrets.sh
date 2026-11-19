
#!/bin/bash

# Stop the script if a command fails.
set -e

echo "======================================"
echo " Creating Database Kubernetes Secrets"
echo "======================================"

# STEP 1: Collect PostgreSQL credentials.

read -rp "Enter PostgreSQL username [audit_user]: " PG_USER
PG_USER=${PG_USER:-audit_user}

read -rsp "Enter PostgreSQL password: " PG_PASSWORD
echo

# Check that a password was entered.
if [[ -z "$PG_PASSWORD" ]]; then
    echo "Error: Password cannot be empty."
    exit 1
fi

echo
echo "Creating PostgreSQL Secret..."

# STEP 2: Create PostgreSQL Secret.
kubectl create secret generic postgres-secret \
    --namespace postgres-ns \
    --from-literal=POSTGRES_USER="$PG_USER" \
    --from-literal=POSTGRES_PASSWORD="$PG_PASSWORD"

echo
echo "Creating Audit Service Secret..."

# STEP 3: Create Audit Service Secret.
kubectl create secret generic audit-service-secret \
    --namespace audit-ns \
    --from-literal=DB_USER="$PG_USER" \
    --from-literal=DB_PASSWORD="$PG_PASSWORD"

# STEP 4: Clear temporary credentials.
unset PG_USER
unset PG_PASSWORD

echo
echo "======================================"
echo " Database Secrets Created Successfully"
echo "======================================"

# STEP 5: Verify that both Secrets exist.
echo
echo "Verifying PostgreSQL Secret..."
kubectl get secret postgres-secret -n postgres-ns

echo
echo "Verifying Audit Service Secret..."
kubectl get secret audit-service-secret -n audit-ns

echo
echo "All operations completed."







# Bash script that handles matching the PostgreSQL username and password with the Kubernetes Secrets for both the PostgreSQL database and the Audit Service. The script performs the following steps:
# 1. Collects the PostgreSQL username and password.
# 2. Creates the PostgreSQL Secret in postgres-ns.
# 3. Creates the Audit Service Secret in audit-ns.
# 4. Removes the temporary credentials from the script's shell variables.
#  password is password