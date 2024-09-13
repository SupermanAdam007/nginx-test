# NGINX Deployment with Git Tag

This repository is designed to build and deploy an `nginx:1.27.1-alpine` container with a custom welcome page that displays the current Git tag of the repository. The container is pushed to GitHub Container Registry (GHCR) using the Git tag as the image version.

## How It Works

1. **Dockerfile**: The Dockerfile pulls the `nginx:1.27.1-alpine` image and sets up a custom `index.html` page.
2. **Custom HTML**: The `index.html` page contains a placeholder (`{{GIT_TAG}}`) for the Git tag. This tag will be dynamically inserted during the build process.
3. **`update_tag.sh` script**: This script fetches the current Git tag and updates the `index.html` file by replacing the `{{GIT_TAG}}` placeholder with the actual Git tag.
4. **GitHub Actions Workflow**:
   - The workflow is triggered when changes are pushed to the `main` branch or when a Git tag is pushed.
   - It builds a Docker image from the `nginx:1.27.1-alpine` base image, replaces the tag in the HTML file, and pushes the Docker image to GHCR, tagging the image with the current Git tag.

## Steps to Use

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Create a New Git Tag
You can create a new Git tag locally and push it to the repository. The tag will be used to build the Docker image and displayed on the NGINX welcome page.

```bash
git tag -a v1.0.0 -m "First version"
git push origin v1.0.0
```

### 3. Push Changes to Trigger Build
Once you push to the `main` branch or create a new Git tag, the GitHub Actions workflow will automatically:
- Build the Docker image
- Replace the Git tag in the HTML page
- Push the Docker image to GHCR, tagged with the Git tag

### 4. Check the GitHub Actions Workflow
You can monitor the workflow in the "Actions" tab of your GitHub repository to ensure that the Docker image is successfully built and pushed to GHCR.

### 5. Running the Container Locally
After the image has been pushed to GHCR, you can run it locally using Docker:

```bash
docker run -d -p 80:80 ghcr.io/<your-username>/nginx-test:<git-tag>
```

For example, if the Git tag is `v1.0.0`, run:

```bash
docker run -d -p 80:80 ghcr.io/<your-username>/nginx-test:v1.0.0
```

Visit `http://localhost` in your browser, and you should see the NGINX welcome page with the Git tag displayed.

## Workflow Overview

- **Trigger**: The workflow runs on every push to the `main` branch and when a new Git tag is created.
- **Steps**:
  1. Checkout the repository code.
  2. Replace the `{{GIT_TAG}}` placeholder in the HTML file with the actual Git tag.
  3. Build the Docker image.
  4. Push the image to GitHub Container Registry (GHCR) with the Git tag as the image tag.

## Customization

- **Changing the Git Tag**: You can modify the Git tag by creating a new tag in your local Git repository and pushing it to the remote repository.
- **Customizing the HTML**: You can modify the `nginx/index.html` file to customize the NGINX welcome page with additional information or branding.

## Prerequisites

- **GitHub Actions**: The GitHub Actions workflow requires that the `GITHUB_TOKEN` is available to authenticate and push Docker images to GHCR. GitHub automatically provides this token in workflows.
- **Docker**: Docker must be installed locally if you plan to run the container on your machine.
