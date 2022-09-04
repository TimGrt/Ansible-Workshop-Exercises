# 6 - Run tasks multiple times

## Objective

Get to know the `loop`, `with_<lookup>`, and `until` keywords to execute a task multiple times.  

The `loop` keyword is not yet a full replacement for `with_<lookup>`, but we recommend it for most use cases. Both keywords achieve the same thing (although a bit differently under the hood).  
You may find e.g. `with_items` in examples and the use is not (*yet*) deprecated - that syntax will still be valid for the foreseeable future - but try to use the `loop` keyword whenever possible.  
The `until` keyword is used to retry a task until a certain condition is met. For example, you could run a task up to `X` times (defined by a *retries* parameter) with a delay of `X` seconds between each attempt. This may be useful if your playbook has to wait for the startup of a process before continuing.

## Guide

Loops enable us to repeat the same task over and over again. For example, lets say you want to create multiple users. By using an Ansible loop, you can do that in a single task. Loops can also iterate over more than just basic lists. For example, if you have a list of users with their coresponding group, loop can iterate over them as well.  


Find out more about loops in the [Ansible Loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html) documentation.

### Step 1 - Simple Loops

To show the loops feature we will generate three new users on `node1`. For that, create the file `loop_users.yml` in `~/ansible-files` on your control node as your student user. We will use the `user` module to generate the user accounts.

```yaml
---
- name: Ensure users
  hosts: node1
  become: true
  tasks:
    - name: Ensure three users are present
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
      loop:
         - dev_user
         - qa_user
         - prod_user
```

Understand the playbook and the output:

* The names are not provided to the user module directly. Instead, there is only a variable called `{{ item }}` for the parameter `name`.
* The `loop` keyword lists the actual user names. Those replace the `{{ item }}` during the actual execution of the playbook.
* During execution the task is only listed once, but there are three changes listed underneath it.

### Step 2 - Loops over hashes

As mentioned loops can also be over lists of hashes. Imagine that the users should be assigned to different additional groups:

```yaml
- username: dev_user
  groups: ftp
- username: qa_user
  groups: ftp
- username: prod_user
  groups: apache
```

The `user` module has the optional parameter `groups` which defines the group (or list of groups) the user should be added to. To reference items in a hash, the `{{ item }}` keyword needs to reference the subkey: `{{ item.groups }}` for example.

??? note "Hinweis"
    By default, the user is **removed** from all other groups. Use the module parameter `append: true` to modify this.

Let's rewrite the playbook to create the users with additional user rights:

```yaml
---
- name: Ensure users
  hosts: node1
  become: true
  tasks:
    - name: Ensure three users are present
      ansible.builtin.user:
        name: "{{ item.username }}"
        state: present
        groups: "{{ item.groups }}"
      loop:
        - username: 'dev_user'
          groups: 'ftp'
        - username: 'qa_user'
          groups: 'ftp'
        - username: 'prod_user'
          groups: 'apache'

```

Check the output:

* Again the task is listed once, but three changes are listed. Each loop with its content is shown.

Verify that the user `dev_user` was indeed created on `node1` using the following playbook, name it `user_id.yml`:

```yaml
---
- name: Get user ID
  hosts: node1
  vars:
    myuser: "dev_user"
  tasks:
    - name: Get {{ myuser }} info
      ansible.builtin.getent:
        database: passwd
        key: "{{ myuser }}"
        
    - name: Output {{ myuser }} info
      ansible.builtin.debug:
        msg: "{{ myuser }} uid: {{ getent_passwd[myuser][1] }}"

```

```bash
$ ansible-playbook user_id.yml

PLAY [Get user ID] *************************************************************

TASK [Gathering Facts] *********************************************************
ok: [node1]

TASK [Get dev_user info] *******************************************************
ok: [node1]

TASK [Output dev_user info] *******************************************************************
ok: [node1] => {
    "msg": [
        "dev_user uid: 1002"
    ]
}

PLAY RECAP *********************************************************************
node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

!!! hint
    It is possible to insert a *string* directly into the dictionary structure like this (although it makes the task less flexible):
    ```yaml
    - name: Output info for user '
      ansible.builtin.debug:
        msg:
          - "{{ myuser }} uid: {{ getent_passwd['dev_user'][1] }}"
    ```
    As you can see the *value* of the variable `myuser` is used directly. It must be enclosed in single quotes. You can't use normal quotation marks, as these are used outside of the whole variable.