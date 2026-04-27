# AGENTS.md

Guide for AI coding agents working in this repository. Read this before making changes.

## What this repo is

Self-hosted GitHub Actions runner images, one per consumer Git repo. Each top-level folder corresponds to one consumer repo and contains a single `Dockerfile` built on top of `ghcr.io/actions/actions-runner`. Images are published to GHCR under `ghcr.io/jbwittner/action_runner_image/<folder-name>`.

There is **no application code, no test suite, and no language-level build system** — the only artifacts are Dockerfiles and GitHub Actions workflows. Validation = `docker build` succeeds.

## Repository layout

```
action_runner_image/
├── .github/
│   └── workflows/
│       ├── pull_request.yaml   # build-only on PRs targeting main
│       └── main_branches.yaml  # build + push to GHCR on push to main
├── <consumer-repo>/
│   └── Dockerfile
├── renovate.json
├── README.md
└── AGENTS.md
```

## Hard rules

- **One folder = one consumer repo.** Folder name is reused as the image name. Never put more than one Dockerfile per folder.
- **When adding a new image folder, three files must be touched together** — workflows (×2) and `renovate.json`. A PR that only adds the Dockerfile is incomplete.
- **Both workflow files must stay in sync.** The `filters` block in [pull_request.yaml](.github/workflows/pull_request.yaml) and [main_branches.yaml](.github/workflows/main_branches.yaml) must list the same images.
- **No secrets, tokens, or credentials in Dockerfiles.** Authentication is handled at runtime by the runner.

## Dockerfile conventions

- Pin the base image to a specific version (Renovate updates the digest automatically).
- Switch to `USER root` to install system packages, then back to `USER runner` at the end of the Dockerfile.
- Download external binaries with `curl -fsSL`. Detect architecture with `dpkg --print-architecture` and support both `amd64` and `arm64` — CI builds multi-arch.
- Clean up download artifacts (`/tmp/*.tar.gz`, etc.) in the **same `RUN` layer** they are created in, to keep layers small.
- Use `ARG` for tool versions Renovate may bump.
- Always include OCI labels: `org.opencontainers.image.source`, `.description`, `.licenses`.

Reference: [bankwiz_server/Dockerfile](bankwiz_server/Dockerfile).

## Workflow conventions

- YAML files start with `---`.
- Use [`dorny/paths-filter`](https://github.com/dorny/paths-filter) to detect changed image directories — only affected images are built.
- PR workflow: `platforms: linux/amd64,linux/arm64`, `push: false`.
- Main workflow: same platforms, `push: true`, tags `main-latest` and `main-<sha>`.
- Always set `concurrency` with `cancel-in-progress: true`.
- Pin third-party actions to a major version (Renovate manages updates).

## Dependency management

[Renovate](https://docs.renovatebot.com/) ([renovate.json](renovate.json)) is the **only** dependency updater in this repo — it handles Docker `FROM` digests and GitHub Actions versions. Patch/minor updates auto-merge; majors do not.

When adding a new image folder, add a `managerFilePatterns` entry for the new Dockerfile in `renovate.json` so Renovate picks it up.

Do **not** introduce Dependabot or any other updater — Renovate is the single source of truth.

## Local validation

Before reporting a Dockerfile change as done, run:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <folder-name>:local \
  <folder-name>/
```

If multi-arch buildx isn't available locally, a single-arch `docker build` is acceptable — but say so explicitly. **Do not claim a build succeeds without running it.**

## Adding a new runner image — checklist

1. Create `<consumer-repo>/Dockerfile` following the conventions above.
2. Add `<consumer-repo>: <consumer-repo>/**` to the `filters` block in both `pull_request.yaml` and `main_branches.yaml`.
3. Add a `managerFilePatterns` entry for the new Dockerfile in `renovate.json`.
4. Update the "Published images" table in [README.md](README.md).
5. Run a local `docker build` to verify.

## Out of scope

- Do not introduce a build orchestrator (Make, Bazel, etc.) — the workflows are intentionally the only build entrypoint.
- Do not add a test framework — image validation is `docker build` success.
- Do not generalize Dockerfiles into a templated base image unless explicitly asked. Each consumer repo intentionally owns its own Dockerfile so its toolchain can drift independently.
