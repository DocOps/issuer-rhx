#!/bin/bash
# Build script for the combined docopslab/issuer-rhx Docker image

set -e

# --- Configuration ---
IMAGE_NAME="docopslab/issuer-rhx"
ISSUER_IMAGE="docopslab/issuer:latest"
RELEASEHX_IMAGE="docopslab/releasehx:latest"
SOURCE="remote" # Default to remote, can be overridden by flag
MANPAGE="true"    # Default to building the manpage

# --- Helper Functions ---
print_info() {
  echo "INFO: $1"
}

print_error() {
  echo "ERROR: $1" >&2
  exit 1
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --source) SOURCE="$2"; shift ;;
    --no-manpage) MANPAGE="false" ;;
    *) print_error "Unknown parameter passed: $1";;
  esac
  shift
done

# --- Build Process ---
print_info "Starting build for $IMAGE_NAME..."

export BUNDLE_USER_HOME="${BUNDLE_USER_HOME:-$(pwd)/.bundle}"

# --- Manpage Generation (Conditional) ---
if [ "$MANPAGE" = "true" ]; then
  if command -v bundle >/dev/null 2>&1; then
    print_info "Found Bundler. Generating manpage..."
    bundle config set --local path vendor/bundle >/dev/null 2>&1 || true
    if bundle install --quiet; then
      bundle exec rake manpage
    else
      print_info "WARNING: Bundler install failed (offline?). Using fallback help text."
      mkdir -p docs
      touch docs/issuer-rhx.1
    fi
  else
    print_info "WARNING: bundle command not found. Skipping manpage generation."
    print_info "A basic help screen will be used in the container as a fallback."
    mkdir -p docs
    touch docs/issuer-rhx.1
  fi
else
  print_info "Skipping manpage generation as requested by --no-manpage flag."
  mkdir -p docs
  touch docs/issuer-rhx.1
fi

# --- Image Source Handling ---
if [ "$SOURCE" = "remote" ]; then
  print_info "Pulling latest base images from DockerHub..."
  docker pull "$ISSUER_IMAGE" || print_error "Failed to pull $ISSUER_IMAGE"
  docker pull "$RELEASEHX_IMAGE" || print_error "Failed to pull $RELEASEHX_IMAGE"
elif [ "$SOURCE" != "local" ]; then
  print_error "Invalid source. Must be 'local' or 'remote'."
fi

# --- Detect Versions Before Build ---
print_info "Detecting versions from pulled images..."
ISSUER_V=$(docker inspect "$ISSUER_IMAGE" --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' 2>/dev/null || echo "unknown")
RHX_V=$(docker inspect "$RELEASEHX_IMAGE" --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' 2>/dev/null || echo "unknown")

print_info "Detected versions: Issuer=${ISSUER_V}, ReleaseHx=${RHX_V}"

# --- Docker Build ---
print_info "Building combined image: $IMAGE_NAME:latest"
docker build \
  --build-arg ISSUER_VERSION="$ISSUER_V" \
  --build-arg RELEASEHX_VERSION="$RHX_V" \
  -t "$IMAGE_NAME:latest" .

# --- Dynamic Version Tagging ---
print_info "Creating combined version tag..."

if [ "$ISSUER_V" != "unknown" ] && [ -n "$ISSUER_V" ] && [ "$RHX_V" != "unknown" ] && [ -n "$RHX_V" ]; then
  # Both versions found, create a combined tag
  COMBINED_VERSION="${ISSUER_V}-${RHX_V}"
  print_info "Tagging image with combined version: $COMBINED_VERSION"
  docker tag "$IMAGE_NAME:latest" "$IMAGE_NAME:$COMBINED_VERSION"
  print_info "Successfully tagged $IMAGE_NAME:$COMBINED_VERSION"
else
  # One or both versions were not found
  print_info "WARNING: Could not determine version from one or both base images."
  print_info "         Issuer=${ISSUER_V:-empty}, ReleaseHx=${RHX_V:-empty}"
  print_info "         Skipping combined version tag."
  print_info "         You can tag the image manually: docker tag $IMAGE_NAME:latest $IMAGE_NAME:<your-tag>"
fi

print_info "Build complete."
echo "To run: docker run -it --rm --user \$(id -u):\$(id -g) -v \$(pwd):/workdir $IMAGE_NAME"
