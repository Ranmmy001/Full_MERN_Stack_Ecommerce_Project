# Stage 9 — GitHub Actions CI/CD

## Workflows

### 1. CI workflow

File: `.github/workflows/ci.yml`

Runs on:
- Pushes to `main`
- Pull requests targeting `main`

It:
- Installs dependencies for Backend, Frontend, Admin and Audit-Service.
- Builds the Frontend and Admin React applications.
- Builds all four Docker images for validation.
- Lints and renders the Helm chart.

The localhost API address used during CI is only for build validation. CI images are not published.

### 2. AWS release workflow

File: `.github/workflows/release.yml`

Runs:
- Manually through GitHub Actions, using the `aws_api_url` input.
- Automatically on pushes to `main` after the repository variable `AWS_API_URL` has been configured.

It:
- Builds and publishes the four application images to GHCR.
- Tags each image with the Git commit SHA and `latest`.
- Builds Frontend and Admin with the supplied AWS API URL.
- Updates only `helm/ecommerce-platform/values-aws.yaml`.
- Commits the updated AWS image tags to `main`.

### Container image repositories

- `ghcr.io/ranmmy001/mern-ecommerce-backend`
- `ghcr.io/ranmmy001/mern-ecommerce-frontend`
- `ghcr.io/ranmmy001/mern-ecommerce-admin`
- `ghcr.io/ranmmy001/mern-ecommerce-audit-service`

### Minikube and AWS separation

- `helm/ecommerce-platform/values.yaml` remains the Minikube values file.
- `helm/ecommerce-platform/values-aws.yaml` is the AWS values file.
- The release workflow updates only `values-aws.yaml`.
- The existing Minikube ArgoCD Application must continue using the default `values.yaml`.
- A separate ArgoCD Application targeting EKS will be configured after the EKS cluster and its endpoint are available.

### GitHub configuration required for production releases

In the repository, open:

Settings → Secrets and variables → Actions → Variables → New repository variable

Create:

- Name: `AWS_API_URL`
- Value: the public base URL of the AWS backend API, without a trailing slash.

Alternatively, run the AWS Release workflow manually and provide the `aws_api_url` input.

The AWS API URL must point to the deployed AWS backend. Do not use localhost or the Minikube IP.

### GHCR access

After the first successful image publication, check the four packages under the GitHub account's Packages section.

For a demonstration cluster that pulls images without registry credentials, set the packages to Public. If they remain Private, configure an image pull secret in EKS before deploying.

### Stage 9 completion evidence

Stage 9 is fully verified when:
1. The CI workflow completes successfully.
2. The release workflow publishes all four images.
3. `values-aws.yaml` contains the published commit SHA tags.
4. The Minikube values file and running Minikube deployment remain unchanged.
5. The EKS ArgoCD Application is configured and verified after EKS is provisioned.
