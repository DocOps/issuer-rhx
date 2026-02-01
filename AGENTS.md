# AGENTS.md

AI Agent Guide for issuer-rhx Docker Image

## Project Overview

**issuer-rhx** is a combined Docker image that provides both the `issuer` and `rhx` (ReleaseHx) command-line tools in a single, convenient container.

- **Purpose:** Simplify deployment and usage of both tools together
- **Base Image:** Ruby 3.2-slim
- **Included Tools:**
  - Issuer 0.3.0 (bulk GitHub issue creator)
  - ReleaseHx 0.1.2 (changelog/release note generator)

## Key Files

- `Dockerfile` - Multi-stage build combining both tools
- `build.sh` - Build automation script with versioning support
- `entrypoint.sh` - Container entrypoint handling command routing
- `README.adoc` - User-facing documentation

## Development Guidelines

### Version Pinning

**CRITICAL:** This image pins specific versions of both tools:
- Update `Dockerfile` COPY --from lines when upstream versions change
- Update `README.adoc` version attributes
- Version format: `{major}.{minor}.{patch}` (e.g., 1.0.0)

### Building Locally

```bash
./build.sh                    # Use remote images from Docker Hub
./build.sh --source local     # Use locally built images
VERSION=1.0.0 ./build.sh      # Tag with specific version
```

### Testing

Before releasing, test both commands:

```bash
# Test issuer
docker run -it --rm -v $(pwd):/workdir docopslab/issuer-rhx issuer --help

# Test rhx
docker run -it --rm -v $(pwd):/workdir docopslab/issuer-rhx rhx --version
```

### Version Detection and Tagging

The build script automatically detects versions from upstream Docker images by reading the `org.opencontainers.image.version` label and creates a combined version tag (e.g., `0.3.0-0.1.2`).

**Known Issue:** The Issuer image currently lacks the version label. Until this is fixed (see issue DocOps/issuer#[TBD]), you must manually tag after building:

```bash
# After ./build.sh completes
docker tag docopslab/issuer-rhx:latest docopslab/issuer-rhx:0.3.0-0.1.2
```

Replace version numbers with actual versions from `issuer --version` and `rhx --version` commands run inside the built container.

## Release Process

1. Update Dockerfile with new gem versions
2. Update README.adoc version attributes
3. Build and test locally
4. Commit and tag (e.g., v1.0.0)
5. Push to GitHub
6. Build and push to Docker Hub
7. Create GitHub Release

## Dependencies

- **Upstream:** docopslab/issuer and docopslab/releasehx images
- **Build Tools:** Docker, bash, Bundler (for manpage generation)
- **Runtime:** Docker only

## Remember

- This is a distribution image, not a development environment
- Pin exact versions, never use :latest in production
- Test both tools before releasing
- Keep README examples up to date
