FROM docker.io/ubuntu:24.04 AS builder
WORKDIR /tmp
# Install Git executable for git-revision-date-localized-plugin
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      python3 \
      python3-pip \
 && rm -rf /var/lib/apt/lists/*
# Copy Python packages/dependencies file
COPY requirements.txt .
# Install Python dependencies
RUN python3 -m pip install --no-cache-dir -r requirements.txt
# Install headless browser for PDF file generation
RUN playwright install chromium --with-deps
# Copy .git folder for git-revision-date-localized-plugin
COPY .git .git
# Copy documentation source files to working directory
COPY docs docs
COPY mkdocs.yml .
COPY includes includes
# Build new documentation without PDF file generation as this needs a special base image
RUN mkdocs build

FROM busybox
STOPSIGNAL SIGKILL
RUN adduser -D static
USER static
WORKDIR /home/static
COPY --from=builder /tmp/site .
CMD ["busybox", "httpd", "-f", "-v", "-p", "8080"]
