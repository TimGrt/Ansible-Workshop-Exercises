# 1.2 - The Ansible Basics

## Objective

In this exercise, we are going to explore the Ansible command line utility `ansible-inventory` to learn how to work with inventory files, using the utility `ansible` to run commands on hosts in the inventory file and getting help by the `ansible-doc` utility.  
The goal is to familiarize yourself with some of the different cli tools Ansible provides and how it can be used to enrich your Ansible experience.

This exercise will cover

* Working with inventory files
* Locating and understanding an `ini` formatted inventory file
* Running commands on inventory groups with Ansible Ad-Hoc commands
* Listing modules and getting help when trying to use them

## Guide

### Step 1 - Work with your Inventory

An inventory file is a text file that specifies the nodes that will be managed by the control machine. The nodes to be managed may include a list of hostnames and/or IP addresses of those nodes. The inventory file allows for nodes to be organized into groups by declaring a host group name within square brackets ([ ]).

To use the `ansible-inventory` command for host management, you need to provide an inventory file which defines a list of hosts to be managed from the control node.  
In this lab, the inventory is provided by your instructor. The inventory file is an `ini` formatted file listing your hosts, sorted in groups, additionally providing some variables. It looks like:

```bash
[web]
node1 ansible_host=<X.X.X.X>
node2 ansible_host=<Y.Y.Y.Y>
node3 ansible_host=<Z.Z.Z.Z>

[control]
ansible-1 ansible_host=44.55.66.77
```

Ansible is already configured to use the inventory specific to your environment. We will show you in the next step how that is done. For now, we will execute some simple commands to work with the inventory.

To reference all the inventory hosts, you supply a pattern to the `ansible-inventory` command. The `--list` option can be useful for displaying all the hosts that are part of an inventory file including what groups they are associated with.

=== "Ansible"

    ```bash
    [student<X>@ansible-1 ~]$ ansible-inventory --list
    {
        "_meta": {
            "hostvars": {
                "ansible-1": {
                    "ansible_host": "3.236.186.92"
                },
                "node1": {
                    "ansible_host": "3.239.234.187"
                },
                "node2": {
                    "ansible_host": "75.101.228.151"
                },
                "node3": {
                    "ansible_host": "100.27.38.142"
                }
            }
        },
        "all": {
            "children": [
                "control",
                "ungrouped",
                "web"
            ]
        },
        "control": {
            "hosts": [
                "ansible-1"
            ]
        },
        "web": {
            "hosts": [
                "node1",
                "node2",
                "node3"
            ]
        }
    }

    ```

=== "Navigator"

    ```bash
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --list -m stdout
    {
        "_meta": {
            "hostvars": {
                "ansible-1": {
                    "ansible_host": "3.236.186.92"
                },
                "node1": {
                    "ansible_host": "3.239.234.187"
                },
                "node2": {
                    "ansible_host": "75.101.228.151"
                },
                "node3": {
                    "ansible_host": "100.27.38.142"
                }
            }
        },
        "all": {
            "children": [
                "control",
                "ungrouped",
                "web"
            ]
        },
        "control": {
            "hosts": [
                "ansible-1"
            ]
        },
        "web": {
            "hosts": [
                "node1",
                "node2",
                "node3"
            ]
        }
    }

    ```

If `--list` is too verbose, the option of `--graph` can be used to provide a more condensed version of `--list`.

=== "Ansible"
    ```bash
    [student1@ansible-1 ~]$ ansible-inventory --graph
    @all:
    |--@control:
    |  |--ansible-1
    |--@ungrouped:
    |--@web:
    |  |--node1
    |  |--node2
    |  |--node3

    ```
=== "Navigator"
    ```bash
    [student1@ansible-1 ~]$ ansible-navigator inventory --graph -m stdout
    @all:
    |--@control:
    |  |--ansible-1
    |--@ungrouped:
    |--@web:
    |  |--node1
    |  |--node2
    |  |--node3

    ```

We can clearly see that nodes: `node1`, `node2`, `node3` are part of the `web` group, while `ansible-1` is part of the `control` group.

An inventory file can contain a lot more information, it can organize your hosts in groups or define variables. In our example, the current inventory has the groups `web` and `control`.

Using the `ansible-navigator` command, we can also run commands that provide information only for one host or group. For example, give the following commands a try to see their output.

=== "Ansible"
    ```bash
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph web -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph control -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --host node1 -m stdout
    ```

=== "Navigator"
    ```bash
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph web -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph control -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --host node1 -m stdout
    ```

!!! tip
    The inventory can contain more data.

### Step 2 - Use the inventory with ad-hoc commands