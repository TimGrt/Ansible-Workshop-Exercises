# 5 - Work with conditionals

## Objective

In a playbook, you may want to execute different tasks, or have different goals, depending on the value of a fact (data about the remote system), a variable, or the result of a previous task. You may want the value of some variables to depend on the value of other variables. Or you may want to create additional groups of hosts based on whether the hosts match other criteria. You can do all of these things with [conditionals](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

## Guide

Ansible can use conditionals to execute tasks or plays when certain conditions are met.

To implement a conditional, the `when` statement must be used, followed by the condition to test. The condition is expressed using one of the available operators like e.g. for comparison:

|      |                                                                        |
| ---- | ---------------------------------------------------------------------- |
| \==  | Compares two objects for equality.                                     |
| \!=  | Compares two objects for inequality.                                   |
| \>   | true if the left hand side is greater than the right hand side.        |
| \>=  | true if the left hand side is greater or equal to the right hand side. |
| \<   | true if the left hand side is lower than the right hand side.          |
| \<=  | true if the left hand side is lower or equal to the right hand side.   |

Ansible uses Jinja2 [tests](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html#playbooks-tests) and [filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#playbooks-filters) in conditionals. Ansible supports all the standard tests and filters, and adds some unique ones as well. 
 
For more on this, please refer to the documentation: <https://jinja.palletsprojects.com/en/latest/templates/>

### Step 1 - Install service conditionally

As an example we would like to install an FTP server, but only on hosts that are in the `ftpserver` inventory group.

To do that, first edit the inventory to add another group, and place `node2` in it. Make sure that that IP address of `node2` is always the same when `node2` is listed. Edit the inventory `~/lab_inventory/hosts` to look like the following listing:

```ini
[web]
node1 ansible_host=11.22.33.44
node2 ansible_host=22.33.44.55
node3 ansible_host=33.44.55.66

[ftpserver]
node2 ansible_host=22.33.44.55

[control]
ansible-1 ansible_host=44.55.66.77
```

!!! warning
    Do not copy the inventory above with placeholder IPs, use your own inventory file!

Next create the file `ftpserver.yml` on your control host in the `~/ansible-files/` directory:

```yaml
---
- name: Install vsftpd on ftpservers
  hosts: all
  become: true
  tasks:
    - name: Install FTP server when host in ftpserver group
      ansible.builtin.yum:
        name: vsftpd
        state: latest
      when: inventory_hostname in groups["ftpserver"]
```

!!! tip
    By now you should know how to run Ansible Playbooks, we’ll start to be less verbose in this guide. Go create and run it. :-)

Run it and examine the output. The expected outcome: The task is skipped on node1, node3 and the ansible host (your control host) because they are not in the ftpserver group in your inventory file.

```bash
TASK [Install FTP server when host in ftpserver group] *******************************************
skipping: [ansible-1]
skipping: [node1]
skipping: [node3]
changed: [node2]
```

In your condition the *magic variable* `inventory_hostname` is used, a variable set by Ansible itself. It contains the inventory name for the *current* host being iterated over in the play.

### Step 2 - Find out exact version of installed service

We installed the *vsftpd* package, we would now be able to start the *vsftp*-Service (Very Secure FTP Daemon). But what version of the package is installed?   
Lets add two more tasks to our playbook, one to gather informations about all installed packages on the target host with the module *package_facts*. This module adds the gathered informations to the `ansible_facts`, from there you can use the information as an Ansible variable. The last tasks outputs the exact version number to *stdout*, but only if the package is installed (the variable in the *packages* dictionary is defined).

```yaml
---
- name: Install vsftpd on ftpservers
  hosts: all
  become: true
  tasks:
    - name: Install FTP server when host in ftpserver group
      ansible.builtin.yum:
        name: vsftpd
        state: latest
      when: inventory_hostname in groups["ftpserver"]
    
    - name: Get informations about installed packages
      ansible.builtin.package_facts:
        manager: auto
    
    - name: Debug exact version of installed vsFTP package
      ansible.builtin.debug:
        msg: "vsFTP is installed in Version {{ ansible_facts.packages.vsftp.0.version }}"
      when: ansible_facts.packages.vsftp is defined  
```

As you can see, the simplest conditional statement applies to a single task. Create the task, then add a `when` statement that applies a test. The `when` clause is a *raw* Jinja2 expression, you can use variables here, but you **don't** have to use double curly braces to enclose the variable.

Looking back at the playbook, why did we add the condition to the last task?  
We know that we installed the package, therefor the condition is always true (the variable is definitly defined) and we could live without the condition.

You should always strive towards making your playbooks as robust as possible, what would happen if we would change the first task to *deinstall* the service?  
Let's change the title and the *state* to `absent` and run the playbook again.

```yaml hl_lines="6 9"
---
- name: Install vsftpd on ftpservers
  hosts: all
  become: true
  tasks:
    - name: Deinstall FTP server when host in ftpserver group
      ansible.builtin.yum:
        name: vsftpd
        state: absent
      when: inventory_hostname in groups["ftpserver"]
    
    - name: Get informations about installed packages
      ansible.builtin.package_facts:
        manager: auto
    
    - name: Debug exact version of installed vsFTP package
      ansible.builtin.debug:
        msg: "vsFTP is installed in Version  {{ ansible_facts.packages.vsftp.0.version }}"
      when: ansible_facts.packages.vsftpd is defined  
```

The service is removed by the playbook, therefor the result of the *package_facts* module does not include the *vsftpd* package anymore and your playbooks ends with an error message!

### Step 3 - Challenge lab

Add a task to the playbook which outputs a message if important security patches are included in the installed *vsftpd* package.

* Make sure that the *vsftd* package is installed (again).
* Output the message *"The version of vsftp includes important security patches!"* 

!!! tip
    The Ansible documention is helpful, a *test* to [compare versions](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html#comparing-versions) is available.

Run the extended playbook. 

??? success "Solution"
    
    The updated playbook:

    ```yaml
    ---
    - name: Install vsftpd on ftpservers
      hosts: all
      become: true
      tasks:
        - name: Install FTP server when host in ftpserver group
          ansible.builtin.yum:
            name: vsftpd
            state: latest
          when: inventory_hostname in groups["ftpserver"]
        
        - name: Get informations about installed packages
          ansible.builtin.package_facts:
            manager: auto
        
        - name: Debug exact version of installed vsFTP package
          ansible.builtin.debug:
            msg: "{{ ansible_facts.packages.vsftp.0.version }}"
          when: ansible_facts.packages.vsftp is defined
        
        - name: Output message when vsftp version is greater than 3.0
          debug:
            msg: "The version of vsftp includes important security patches!"
          when: ansible_facts.packages.vsftp.0.version is version('3.0', '>')
    ```

    Running the playbook outputs the following:
    ```bash
    ...
    TASK [Output message when vsftp version is greater than 3.0] *******************************************************************
    ok: [node1] => {
        "msg": "The version of vsftp includes important security patches!"
    } 
    ...
    ```

The message is shown? Awesome!  
To see if the conditions works, change the version to compare to `4.0` and run the playbook again. You should now see the last task as *skipped*.
