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

### Step 1 - Prepare infrastructure

The Ansible *master nodes* by default communicates via SSH with all *managed hosts*. As we are automating Linux hosts, this is fine and we need to make sure that we can reach every node with SSH.  
If you intend to automate hosts that can't be reached with the default method, e.g. Windows hosts, network infrastructure nodes, firewall hosts and so on, you need to instruct Ansible to use another communication method. In most cases, this is very easy and only requires setting a certain variable. But, let's focus on automating Linux nodes first.

Ansible uses SSH to communicate with Linux nodes, let's break the initially working (password-less) SSH-connection in the lab environment and establish a new one with the service user `ansible`.

Download a script using the next commands, copy the command by clicking the *copy* button on the right of the code block:

```bash
wget -q https://raw.githubusercontent.com/TimGrt/prepare-redhat-demo-system/master/prepare-attendee.sh
```

After downloading the script to your home directory, execute it:

```bash
[student1@ansible-1 ~]$ wget -q https://raw.githubusercontent.com/TimGrt/prepare-redhat-demo-system/master/prepare-attendee.sh
[student1@ansible-1 ~]$ sh prepare-attendee.sh
[student1@ansible-1 ~]$ 
```

*No output is good output.* Now we can configure the SSH connection the way it want.

!!! success
    The goal is to be able to communicate from *ansible-1* as `student<X>` to the `ansible` user on all 3 managed nodes.

We will need the (already present) SSH **public key** of user `student<X>` on *ansible-1* (use your own, not this one):

```bash
[student<X>@ansible-1 ~]$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCFeZ0j9HODBeDzP5aV5mkrsIGY1mvHTLjbCZIeHNpldIGETKflG6W0/
...
```

Next, SSH to *node1*, you will be asked for a password. This is the same password you used to login to the workshop!

```bash
[student<X>@ansible-1 ~]$ ssh node1
student1@node1's password:
[student1@node1 ~]$
```

Switch to the *root* user and create a new user `ansible` (with a home directory). After creating the user, switch to the `ansible` user:

```bash
[student1@node1 ~]$ sudo su - root
Last login: Sun Apr 17 08:36:53 UTC 2022 on pts/0
[root@node1 ~]# useradd ansible
[root@node1 ~]# su - ansible
[ansible@node1 ~]$ 
```

Ensure that you are the *ansible* user, we need to create the (hidden) `.ssh` directory and the `authorized_keys` file in it. The `authorized_keys` file houses the **public** key of user *student<X>* on the *ansible-1* host, copy the key to the file (press *i* in *vi* to enter the *insert mode*):

```bash
[ansible@node1 ~]$ mkdir .ssh
[ansible@node1 ~]$ vi .ssh/authorized_keys
```

Now we have to set the correct permissions, the `.ssh` directory needs *0700*, the `authorized_keys` file needs *0600*.

```bash
[ansible@node1 ~]$ chmod 0700 .ssh
[ansible@node1 ~]$ chmod 0600 .ssh/authorized_keys
```

Good! We now have established a service user for our automation. The user must be able to do *root-like* tasks e.g. installing and starting services, therefor he needs sudo permissions. Switch back to the *root* user by entering `exit`, you are still on *node1*.

!!! warning
    Clobering the sudoers file is one of the fastest ways to make your host unusable. Whenever you deal with suoders files, use `visudo`!

As the *root* user, create a new file under `/etc/sudoers.d`:

```bash
[root@node1 ~]$ visudo -f /etc/sudoers.d/automation
```

Copy the following line which enables the `ansible` user to use password-less sudo (use the copy button of the code block again):

```
ansible ALL=(ALL) NOPASSWD:ALL
```

We can check if the `ansible` as the required permissions:

```bash
[root@node1 ~]# sudo -l -U ansible
Matching Defaults entries for ansible on node1:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES",
    env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin, !requiretty

User ansible may run the following commands on node1:
    (ALL) NOPASSWD: ALL
```

Log out of *node1* (ensure that you are back on your ansible master node *ansible-1*, run `exit` twice) and try to log in to *node1* with the *ansible* user:

```bash
[student<X>@ansible-1 ~]$ ssh ansible@node1
[ansible@node1 ~]$ 
```

!!! failure
    If password-less SSH is not working, check the permissions of the `.ssh` folder and the `authorized_keys` file on the target host!

!!! success
    Repeat the steps above for *node2* and *node3*!

Once you can reach all managed nodes password-less (and sudo-permissions are set, you will need this later), we can start to do some Ansible stuff.

### Step 2 - Work with your Inventory

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

Using the `ansible-inventory` command, we can also run commands that provide information only for one host or group. For example, give the following commands a try to see their output.

=== "Ansible"
    ```bash
    [student<X>@ansible-1 ~]$ ansible-inventory --graph web
    [student<X>@ansible-1 ~]$ ansible-inventory --graph control
    [student<X>@ansible-1 ~]$ ansible-inventory --host node1
    ```

=== "Navigator"
    ```bash
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph web -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --graph control -m stdout
    [student<X>@ansible-1 ~]$ ansible-navigator inventory --host node1 -m stdout
    ```

!!! tip
    The inventory can contain more data.

### Step 3 - Use the inventory with ad-hoc commands

An Ansible ad hoc command uses the `ansible` command-line tool to automate a single task on one or more managed nodes. Ad hoc commands are quick and easy, but they are not reusable. So why learn about ad hoc commands first? Ad hoc commands demonstrate the simplicity and power of Ansible. The concepts you learn here will port over directly to the playbook language.

Ad hoc commands are great for tasks you repeat rarely. For example, if you want to power off all the machines in your lab for Christmas vacation, you could execute a quick one-liner in Ansible without writing a playbook. An ad hoc command looks like this:

```bash
$ ansible [pattern] -m [module] -a "[module options]"
```

Ad hoc commands can be used perfectly to check if all hosts in your inventory are reachable. Ansible offers the *ping* module for that (this is not a real ICMP ping, though). Let's try to reach all hosts of the *web* group:

```bash
[student1@ansible-1 ~]$ ansible web -m ping
```

We got an error, all three nodes aren't reachable?! But manually, we can reach all nodes via SSH!  
Observing the error message we can see what the problem is, Ansible tries to us reach all hosts as the *student<X>* user. We established the service user *ansible* for that, we must instruct Ansible to use that user. By default, Ansible will use the user that is executing the *ansible* commands.

Open the Ansible inventory file, either by clicking the *lab_inventory* folder and the *hosts* file in the VScode explorer or on the terminal.  
Create a new variable section (with *:vars*) for the *web* group and set the *ansible_user=ansible* variable:

```ini
[web]
node1 ansible_host=<X.X.X.X>
node2 ansible_host=<Y.Y.Y.Y>
node3 ansible_host=<Z.Z.Z.Z>

[web:vars]
ansible_user=ansible

[control]
ansible-1 ansible_host=44.55.66.77
```

All hosts in the *web* group will now use the *ansible* user for the SSH connection. Try with the ad hoc command again:

```bash
[student1@ansible-1 ~]$ ansible web -m ping
node2 | UNREACHABLE! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
node3 | UNREACHABLE! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

Success! All three nodes are reachable, we get a *pong* back, we proved that we can establish a SSH connection and that the node(s) have a usable Python interpreter.

Try to run the same ad hoc command against the *control* group.  

An error again?? Although being on the same host, Ansible tries to open an SSH connection. Adjust the inventory file again and set the `ansible_connection` variable for the *ansible-1* host:

```ini
[web]
node1 ansible_host=<X.X.X.X>
node2 ansible_host=<Y.Y.Y.Y>
node3 ansible_host=<Z.Z.Z.Z>

[web:vars]
ansible_user=ansible

[control]
ansible-1 ansible_host=44.55.66.77 ansible_connection=local
```

With `ansible_connection=local` (on host-level) Ansible uses the **local** Python interpreter, which is fine for our Ansible master node. Now the ad hoc command succeeds:

```bash
[student1@ansible-1 ~]$ ansible control -m ping
ansible-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

Let's play around with ad hoc commands a bit more. You can use every *module* that Ansible provides with ad hoc commands, we will learn more about *modules* later today. By default, Ansible will use the *command* module, you can send every linux command you want to all managed nodes, the arguments are provides with the `-a` parameter:

```bash
[student1@ansible-1 ~]$ ansible web -m command -a "cat /etc/os-release"
node2 | CHANGED | rc=0 >>
NAME="Red Hat Enterprise Linux"
VERSION="8.5 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.5"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.5 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/red_hat_enterprise_linux/8/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.5
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.5"
node3 | CHANGED | rc=0 >>
NAME="Red Hat Enterprise Linux"
VERSION="8.5 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.5"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.5 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/red_hat_enterprise_linux/8/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.5
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.5"
node1 | CHANGED | rc=0 >>
NAME="Red Hat Enterprise Linux"
VERSION="8.5 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.5"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.5 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/red_hat_enterprise_linux/8/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.5
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.5"
```

You can shorten the command and leave out `-m command` as this module is used by default:

```bash
[student1@ansible-1 ~]$ ansible control -a "uname -a"
ansible-1 | CHANGED | rc=0 >>
Linux ansible-1.example.com 4.18.0-348.12.2.el8_5.x86_64 #1 SMP Mon Jan 17 07:06:06 EST 2022 x86_64 x86_64 x86_64 GNU/Linux
```

Ad hoc command are very useful to gather informations about your managed nodes, the *setup* module is used. Try that against one host alone (so you won't get overwhelmed with output):

```bash
[student1@ansible-1 ~]$ ansible node1 -m setup
node1 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "172.16.9.82"
        ],
        "ansible_all_ipv6_addresses": [
            "fe80::a4:bff:fea5:6d70"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "10/16/2017",
        "ansible_bios_vendor": "Amazon EC2",
        "ansible_bios_version": "1.0",
...
```

You will get loads of useful informations and you can use every bit as variables in your playbooks later on!
