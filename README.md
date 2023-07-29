# Ansible Workshop Exercises

This repository contains all exercise descriptions for my Ansible Workshop, utilizing the Red Hat demo environment. The Workshop is inspired by the [Red Hat Training course for Ansible](https://github.com/ansible/workshops), but adds additional exercises and more descriptions for a multi-day workshop.
The exercises are build with MkDocs and published to [Github pages](https://timgrt.github.io/Ansible-Workshop-Exercises).
A Dockerfile is included to build a container image which publishes the exercises as a Webserver.

[![Markdown Lint](https://github.com/TimGrt/Ansible-Best-Practices/actions/workflows/ci.yml/badge.svg)](https://github.com/TimGrt/Ansible-Best-Practices/actions/workflows/ci.yml) [![Deploy MkDocs to Github pages](https://github.com/TimGrt/Ansible-Workshop-Exercises/actions/workflows/cd.yml/badge.svg)](https://github.com/TimGrt/Ansible-Workshop-Exercises/actions/workflows/cd.yml)

## Podman

During a Workshop, the page published to Github pages was not accessible by the attendees because it was blocked by firewall policies. In that case, deploy the container with the exercises on a host in the lab environment. Use *node2*, as this one is accessible from the internet on Port 8080.

SSH to *node2*, install *git* and *podman*:

```bash
sudo dnf install -y @container-tools git
```

Clone the repository:

```bash
git clone https://github.com/TimGrt/Ansible-Workshop-Exercises.git
```

Change into the cloned directory and build the container image:

```bash
podman build -t ansible-workshop-exercises .
```

Run a container from the previously build image, the webserver is available at Port 8080:

```bash
podman run -d -p 8080:80/tcp --name workshop ansible-workshop-exercises
```

Get the **public** IP address of *node2* from the lab inventory, suffix with Port 8080 and open the exercises in the browser.

> NOTE: During the exercises, Apache is started on *node2* on Port 8080. If you intend to do the exercises for demonstration purposes, this will fail as the Port is occupied.

## Docker

For the sake of completion, here is how to build and run everything with Docker.
Build the container image:

```bash
docker build -t ansible-workshop-exercises .
```

Run a container from the previously build image, the webserver is available at Port 8080:

```bash
docker run -d -p 8080:80/tcp --name workshop ansible-workshop-exercises
```

## Development

We document our Coding Guidelines in the [Contributing Guidelines](https://github.com/TimGrt/Ansible-Best-Practices/blob/main/.github/CONTRIBUTING.md), this document also includes instructions on how the setup a development environment.
