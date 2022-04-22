# Ansible Workshop Exercises

This repository contains all exercise descriptions for my Ansible Workshop, utilizing the Red Hat demo environment. The Workshop is inspired by the [Red Hat Training course for Ansible](https://github.com/ansible/workshops), but adds additional exercises and more descriptions for a multi-day workshop.  
The exercises are build with MkDocs and published to [Github pages](https://timgrt.github.io/Ansible-Workshop-Exercises).  
A Dockerfile is included to build a container image which publishes the exercises as a Webserver.

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
docker build -t ansible-workshop-exercises .
```

Run a container from the previously build image, the webserver is available at Port 8080:
```bash
docker run -d -p 8080:80/tcp --name workshop ansible-workshop-exercises
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

Create a Python virtual environment:

```bash
pip3 -m venv mkdocs-venv
```

Activate VE:

```bash
source mkdocs-venv/bin/activcate
```

Install requirements from project directory:

```bash
pip3 install -r requirements.txt
```

Get IP address:

```bash
hostname -I
```
Start MkDocs built-in dev-server for live-preview:

```bash
mkdocs serve -a 172.26.220.226:8080
```
