FROM python:3.8-slim

WORKDIR /tmp

# Copy Python packages/dependencies file
COPY requirements.txt .

# Update pip and install Python dependencies
RUN python3 -m pip install --no-cache-dir -U pip
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Copy documentation source files to working directory
COPY docs docs
COPY mkdocs.yml .

# Build new documentation
RUN mkdocs build

# Run webserver
CMD python -m http.server -d site/
