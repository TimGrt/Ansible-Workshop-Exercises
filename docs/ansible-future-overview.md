# Overview

This section shows tools in the Ansible world which will become more and more relevant in the upcoming future. This includes:

* Ansible Navigator
* Execution Environments
* Ansible Builder

<figure markdown>
  [![Ansible Logo](ansible-birthday-bull.png){ width="300", loading=lazy }](http://github.com/ansible/logos)
  <figcaption></figcaption>
</figure>

## Who will use the Ansible navigator?

The automation content navigator (or "Ansible Navigator") is mainly geared towards developers of automation. This can mean people creating automated tasks with available modules, those migrating roles into Collections or those who are developing modules from the ground up. Content navigator runs as a textual user interface and looks great within a terminal session, even while running inside popular code editors with included terminal panes.

## Who will use Execution Environments?

Everybody will use Execution environments, not only will they become more relevant for users of Ansible Core, but they are integral to users of the Ansible Automation platform (even if they don't know that they are using EEs). In short, Execution Environments are Container images which run the automation tasks, think about them as an Ansible Control node in a Container.  
They are a defined, consistent and portable environment for Ansible Automation consisting of a RHEL Universal Base Image, Ansible Core, Python 3, Ansible Content Collections and all dependencies.

## Who will use the Ansible Builder?

Ansible Builder is a tool that aids in the creation of Ansible Execution Environments, no container know-how is necessary, a simple YAML configuration file is used to create the Podman or Docker image. The Ansible builder will be used by Automation developers and Automation platform administrators.
