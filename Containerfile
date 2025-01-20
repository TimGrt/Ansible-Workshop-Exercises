FROM python:3.13-alpine AS builder
WORKDIR /tmp
# Copy Python packages/dependencies file
COPY requirements.txt .
# Install Python dependencies
RUN python3 -m pip install --no-cache-dir -r requirements.txt
# Install Git executable for git-revision-date-localized-plugin
RUN apk upgrade --update-cache -a \
 && apk add --no-cache git\
 && rm -rf /var/cache/apk/*
# Copy .git folder for git-revision-date-localized-plugin
COPY .git .git
# Copy documentation source files to working directory
COPY docs docs
COPY mkdocs.yml .
COPY includes includes
# Build new documentation
RUN mkdocs build

FROM busybox
RUN adduser -D static
USER static
WORKDIR /home/static
COPY --from=builder /tmp/site .
CMD ["busybox", "httpd", "-f", "-v", "-p", "8080"]
