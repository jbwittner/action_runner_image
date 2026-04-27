# action_runner_image

Self-hosted GitHub Actions runner images, one per consumer Git repo.

## Convention

One folder = one consumer repo. The folder name is the repo name and is reused as the GHCR image name.

```
<consumer-repo>/Dockerfile
```

## Published images

| Folder | Image |
| --- | --- |
| [bankwiz_server/](bankwiz_server/) | `ghcr.io/jbwittner/bankwiz_server` |

Tags: `main-latest` and `main-<sha>` are pushed on every commit to `main`.

## Add a new image

1. Create `<consumer-repo>/Dockerfile`.
2. Add `<consumer-repo>: <consumer-repo>/**` to the `filters` block in both `.github/workflows/pull_request.yaml` and `.github/workflows/main_branches.yaml`.
3. Add a `docker` entry to [.github/dependabot.yaml](.github/dependabot.yaml) for `directory: /<consumer-repo>`.
