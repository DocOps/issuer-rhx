# AGENTS.md

AI Agent Guide for issuer-rhx Docker Image

## Project Overview

**issuer-rhx** is a combined Docker image that provides both the `issuer` and `rhx` (ReleaseHx) command-line tools in a single, convenient container.

- **Purpose:** Simplify deployment and usage of both tools together
- **Base Image:** Ruby 3.2-slim
- **Included Tools:**
  - Issuer 0.3.0 (bulk GitHub issue creator)
  - ReleaseHx 0.1.2 (changelog/release note generator)

**For usage instructions, see [README.adoc](README.adoc); it's comprehensive and up-to-date.**

## Key Files

- `Dockerfile` - Multi-stage COPY from upstream images (uses `:latest` tags)
- `build.sh` - Build automation with automatic version detection
- `entrypoint.sh` - Container entrypoint routing to issuer or rhx
- `README.adoc` - User- and developer-facing documentation (single source of truth for usage)
- `Gemfile`
- `.config/docopslab-dev.yml` - DocOps Lab tooling integration

## Development Guidelines

### Architecture

**No gem installation in Dockerfile:**
- The Dockerfile uses `COPY --from=docopslab/issuer:latest` and `COPY --from=docopslab/releasehx:latest`
- This copies pre-installed gem bundles from published upstream images
- No compilation or gem installation happens in this image
- The Gemfile is only used by build.sh for generating the manpage via asciidoctor

### Versioning Strategy

**Combined version tagging:**
- Repository tag: `v<issuer>-<rhx>` (e.g., `v0.3.0-0.1.2`)
- Docker tags: `docopslab/issuer-rhx:0.3.0-0.1.2` and `:latest`
- No independent version number - versions reflect included tools

**Automatic detection:**
- build.sh detects versions from upstream image labels (`org.opencontainers.image.version`)
- Versions passed as build args to Dockerfile
- Combined tag created automatically if both versions detected

**Known Issue:** Issuer image lacks version label (see `.agent/tmp/issuer-docker-label-issue.md`)
- Until fixed, manually tag: `docker tag docopslab/issuer-rhx:latest docopslab/issuer-rhx:0.3.0-0.1.2`
- Get versions by running commands in built container: `issuer --version` and `rhx --version`

### Building Locally

```bash
./build.sh                    # Pull from Docker Hub (default)
./build.sh --source local     # Use local images
./build.sh --no-manpage       # Skip manpage generation
```

### Testing

```bash
# Test both commands
docker run -it --rm docopslab/issuer-rhx issuer --version
docker run -it --rm docopslab/issuer-rhx rhx --version

# Test with volume mount
docker run -it --rm --user $(id -u):$(id -g) -v $(pwd):/workdir docopslab/issuer-rhx issuer --help
```

## Release Process

1. Ensure upstream images published (docopslab/issuer:latest, docopslab/releasehx:latest)
2. Update README.adoc version attributes (`:issuer_vrsn:` and `:releasehx_vrsn:`)
3. Run `./build.sh` to build image
4. Manually tag if needed: `docker tag docopslab/issuer-rhx:latest docopslab/issuer-rhx:<version>`
5. Test both commands in container
6. Commit with message "Initial commit" (or version bump message)
7. Tag repo: `git tag v<issuer>-<rhx>` (e.g., `v0.3.0-0.1.2`)
8. Push to GitHub: `git push origin main && git push origin v<tag>`
9. Push to Docker Hub: `docker push docopslab/issuer-rhx:latest && docker push docopslab/issuer-rhx:<version>`
10. Create GitHub Release

## Dependencies

**Upstream Docker images (runtime):**
- docopslab/issuer:latest
- docopslab/releasehx:latest

**Build tools (local development only):**
- Docker
- Bundler (for manpage generation)
- asciidoctor (via Gemfile)
- docopslab-dev (via Gemfile, for Rake tasks)

**No runtime dependencies** - everything is bundled in the image.

## Remember

- This is a **distribution image**, not a development environment
- Always use `:latest` upstream images to automatically get newest versions
- Combined version reflects included tool versions, not an independent project version
- README.adoc is the single source of truth for user-facing documentation
- Test both tools before releasing
- Keep version attributes in README.adoc synchronized with actual releases
