# NGINX Deployment with Commit Info

This repository builds and deploys an `nginx:1.27.1-alpine` container with a custom welcome page displaying the latest Git commit hash and the build timestamp. The container is automatically built and pushed to GitHub Container Registry (GHCR) on every push to the `main` branch.

## How It Works

1. **GitHub Actions**: The workflow is triggered on every push to the `main` branch.
2. **Commit Hash & Timestamp**: The custom `index.html` page shows the latest Git commit hash and a human-readable build timestamp.
3. **Docker Image**: The Docker image is always tagged as `latest` and pushed to GHCR.

## Steps to Use

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Push Changes
On every push to the `main` branch, the workflow automatically:
- Updates the HTML file with the commit hash and build timestamp.
- Builds the Docker image and pushes it to GHCR with the `latest` tag.

### 3. Running the Container Locally
After the image is pushed to GHCR, you can run it locally using Docker:

```bash
docker run -d -p 80:80 ghcr.io/<your-username>/nginx-test:latest
```

Visit `http://localhost` in your browser to see the NGINX welcome page with the latest commit hash and build time.
