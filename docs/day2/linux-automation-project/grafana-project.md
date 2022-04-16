# Project - Linux automation

To further enhance your Ansible skills, let's deploy the monitoring tool *Grafana* to one of the nodes in the demo environment.

![Grafana Logo](grafana-logo.png)

## Objective

Create an Ansible project *from scratch* and automate some basic linux configurations.

## Guide

### Step 1 - Prepare project

Create a new project folder in your home directory:

```bash
[student<X>@ansible-1 ~]$ mkdir grafana-deployment
```

Create an inventory file with a *grafana* group definition. You will deploy Grafana to one of the nodes in the lab environment. Copy the *node1* configuration from the default inventory file to your *grafana* group.

### Step 2 - Install Grafana

The Grafana package

Achieve the following tasks:

- [X] Running Grafana instance on node1
- [X] Grafana service 

### Step 3 - Configure Grafana

Currently, you are not able to access the Grafana UI, using the IP address of your *node1* and the Grafana default port of 3000, you will get a 
The lab environment only allows access to Port 80 and 8080, yesterday you started an Apache webserver on these ports with Ansible. You'll have to configure Grafana to start on Port 8080 to able to access the UI.

!!! warning
    There should be no running Apache webserver on *node1*, if otherwise, you'll need to stop *httpd* on *node1*! If the port is occupied, Grafana can not be started!  
    You could ensure a stopped Apache easily with an Ansible task...

By default, Grafana uses a black background. You will adjust the Grafana configuration with Ansible to show the Grafana UI with white background. You will change the look from this:

![Grafana with black background](grafana-dark-background.png)

To this:

![Grafana with white background](grafana-light-background.png)

The configuration for Grafana is stored in `/etc/grafana/grafana.ini`. You need to adjust the theme configuration in the *users* section, as well as the *http_port* in the *server* section. Take a look at the [Grafana documentation](https://grafana.com/docs/grafana/latest/administration/configuration/) on how to change the parameters.  
Naturally, you should achieve this with Ansible! Find a appropriate module (there is more than one way to achieve the solution...) and adjust the Grafana configuration file.

!!! tip
    Configuration changes require a service restart!

Achieve the following tasks:

- [X] Accessable Grafana UI on port 8080
- [X] Grafana UI in `light` theme
- [ ] Bonus: Can you manage to control the look of Grafana by just switching a variable?

### Step 4 - Re-format project to role structure

All Ansible projects should use the role structure, if your project does not already uses it, now is the time to rearrange your content. Create a `roles` folder and an appropriately named sub-folder for the grafana deployment with all ncessary folder and files.  
Change your playbook to use your role, e.g.:

```yaml
---
# This is the main Playbook for the 'Grafana Deployment' Project

- name: Deploy Grafana instance
  hosts: grafana
  roles:
    - grafana

```

Make sure everything works by executing your playbook again, you should not see any changes, all tasks should return a green "Ok" status.

Achieve the following tasks:

- [X] Project uses Ansible role structure
- [X] Playbook references role

### Step 5 - Bonus: Upload project to Github

Create a new project in your personal Github account and commit your Ansible project.

### Step 6 - Bonus: Run your project within AAP

Create a new project in AAP, reference your Grafana project from Github as the code source. Create a template and run your playbook.

