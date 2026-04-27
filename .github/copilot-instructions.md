# Copilot Instructions

## Project Overview

This repository manages self-hosted GitHub Actions runner images, one per consumer Git repository. Each image is built on top of the official `ghcr.io/actions/actions-runner` base image and published to the GitHub Container Registry (GHCR).

## Repository Structure

```
action_runner_image/
├── .github/
│   ├── workflows/
│   │   ├── pull_request.yaml      # CI: build only (no push) on PRs targeting main
│   │   └── main_branches.yaml     # CI: build and push to GHCR on push to main
│   ├── dependabot.yaml            # Dependabot config for Docker base image updates
│   └── copilot-instructions.md
├── bankwiz_server/
│   └── Dockerfile                 # Runner image for the bankwiz_server consumer repo
├── renovate.json                  # Renovate config for automated dependency updates
└── README.md
```

**Convention:** one top-level folder = one consumer repository. The folder name is reused as the GHCR image name: `ghcr.io/jbwittner/action_runner_image/<folder-name>`.

## Coding Conventions

### Dockerfile conventions
- Pin base image versions (tag + digest when possible) for reproducible builds.
- Install system packages as `root`; switch back to the non-root `runner` user at the end of the Dockerfile.
- Download external binaries with `curl -fsSL`, verify architectures with `dpkg --print-architecture`, and support both `amd64` and `arm64`.
- Remove temporary download artifacts (`/tmp/*.tar.gz`, etc.) in the same `RUN` layer they are created to keep image layers small.
- Use `ARG` for tool versions that are expected to be bumped by Renovate/Dependabot.
- Add OCI standard labels (`org.opencontainers.image.source`, `.description`, `.licenses`).

### Workflow conventions
- Workflows are written in YAML with a `---` document start marker.
- Use `dorny/paths-filter` to detect which image directories changed; only build/push affected images.
- Both `pull_request.yaml` and `main_branches.yaml` must stay in sync: add the same `filters` entry to both when adding a new image.
- PR workflow: build for `linux/amd64,linux/arm64`, **no push**.
- Main branch workflow: build and push with tags `main-latest` and `main-<sha>`.
- Always set `concurrency` with `cancel-in-progress: true` to avoid redundant runs.

### Dependency management
- **Renovate** manages Docker `FROM` digests and GitHub Actions versions (see `renovate.json`).
- **Dependabot** is configured per image directory (`.github/dependabot.yaml`).
- When adding a new image folder, add a corresponding `docker` entry to `.github/dependabot.yaml` with `directory: /<folder-name>` and a `dockerfile` entry in `renovate.json`.

## Adding a New Runner Image

1. Create `<consumer-repo>/Dockerfile` following the conventions above.
2. Add `<consumer-repo>: <consumer-repo>/**` to the `filters` block in **both** `.github/workflows/pull_request.yaml` and `.github/workflows/main_branches.yaml`.
3. Add a `docker` manager entry to `.github/dependabot.yaml` for `directory: /<consumer-repo>`.
4. Add a `managerFilePatterns` entry for the new Dockerfile in `renovate.json`.

## Building and Running Locally

There is no language-level build system — images are built with Docker.

**Build a single image locally:**
```bash
docker build -t <image-name>:local <folder-name>/
```

**Build for multiple platforms (requires Docker Buildx):**
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <image-name>:local \
  <folder-name>/
```

**Run the image interactively:**
```bash
docker run --rm -it <image-name>:local bash
```

## CI / Testing

There is no automated unit-test suite. Validation is done by Docker build success:

- **Pull Request CI** (`pull_request.yaml`): builds all changed images for both architectures but does **not** push. A passing build is the acceptance gate for PRs.
- **Main Branch CI** (`main_branches.yaml`): builds and pushes images to GHCR on every commit to `main`. Published tags: `main-latest` and `main-<git-sha>`.

To verify a Dockerfile change before opening a PR, run a local `docker build` as described above.
