# action_runner_image

Self-hosted GitHub Actions runner images, one per consumer Git repo. Each image is built on top of [`ghcr.io/actions/actions-runner`](https://github.com/actions/runner) and published to GHCR.

## Convention

One top-level folder = one consumer repo. The folder name is reused as the GHCR image name:

```
<consumer-repo>/Dockerfile  →  ghcr.io/jbwittner/action_runner_image/<consumer-repo>
```

## Published images

| Folder | Image |
| --- | --- |
| [bankwiz_server/](bankwiz_server/) | `ghcr.io/jbwittner/action_runner_image/bankwiz_server` |

Tags `main-latest` and `main-<sha>` are pushed on every commit to `main`.

## Add a new image

1. Create `<consumer-repo>/Dockerfile` (see [bankwiz_server/Dockerfile](bankwiz_server/Dockerfile) for a reference).
2. Add `<consumer-repo>: <consumer-repo>/**` to the `filters` block in **both** [.github/workflows/pull_request.yaml](.github/workflows/pull_request.yaml) and [.github/workflows/main_branches.yaml](.github/workflows/main_branches.yaml).
3. Add a `managerFilePatterns` entry for the new Dockerfile in [renovate.json](renovate.json).

## Build locally

```bash
# Single-arch build
docker build -t <consumer-repo>:local <consumer-repo>/

# Multi-arch build (matches CI)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <consumer-repo>:local \
  <consumer-repo>/
```

## CI

- **PRs** ([pull_request.yaml](.github/workflows/pull_request.yaml)): build only (no push) for `linux/amd64,linux/arm64` on changed images.
- **Main** ([main_branches.yaml](.github/workflows/main_branches.yaml)): build and push to GHCR with tags `main-latest` and `main-<sha>`.

Changed images are detected via [`dorny/paths-filter`](https://github.com/dorny/paths-filter), so unchanged images are skipped.

## Dependency updates

[Renovate](https://docs.renovatebot.com/) ([renovate.json](renovate.json)) handles Docker `FROM` digests and GitHub Actions versions. Patch and minor updates auto-merge; majors require manual approval.

## Agent guidance

See [AGENTS.md](AGENTS.md) for conventions AI coding agents should follow when contributing to this repo.
