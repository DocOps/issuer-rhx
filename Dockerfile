# Final image for docopslab/issuer-rhx

# Use a specific, stable base image
FROM ruby:3.2-slim

# Build arguments for version tracking
ARG ISSUER_VERSION
ARG RELEASEHX_VERSION

# Metadata labels
LABEL Name="Issuer-RHx" \
      Vendor="DocOps Lab" \
      IssuerVersion="${ISSUER_VERSION}" \
      ReleaseHxVersion="${RELEASEHX_VERSION}" \
      org.opencontainers.image.source="https://github.com/DocOps/issuer-rhx"

# Install man pages viewer and less for viewing manpages
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends man-db less && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Copy the installed gems and executables from the pre-built images.
# Using :latest tags to automatically pull most recent published versions
COPY --from=docopslab/issuer:latest /usr/local/bundle/ /usr/local/bundle/
COPY --from=docopslab/releasehx:latest /usr/local/bundle/ /usr/local/bundle/

# Copy the generated manpage and the fallback help text.
# The build.sh script is responsible for creating these files.
COPY docs/issuer-rhx.1 /usr/share/man/man1/
COPY help.txt /usr/local/share/ 

# Copy the entrypoint script and make it executable.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the working directory for user commands.
WORKDIR /workdir

# Set the entrypoint.
ENTRYPOINT ["entrypoint.sh"]

# Default command to show help via the entrypoint.
CMD ["--help"]