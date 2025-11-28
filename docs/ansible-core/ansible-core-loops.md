---
pdf: true
covers:
  front: ./docs/assets/pdf/ansible-core-cover.html.j2
---

# 6 - Run tasks multiple times

## Objective

Get to know the `loop`, `with_<lookup>`, and `until` keywords to execute a task multiple times.  

The `loop` keyword is not yet a full replacement for `with_<lookup>`, but we recommend it for most use cases. Both keywords achieve the same thing (although a bit differently under the hood).  
You may find e.g. `with_items` in examples and the use is not (*yet*) deprecated - that syntax will still be valid for the foreseeable future - but try to use the `loop` keyword whenever possible.  
The `until` keyword is used to retry a task until a certain condition is met. For example, you could run a task up to `X` times (defined by a *retries* parameter) with a delay of `X` seconds between each attempt. This may be useful if your playbook has to wait for the startup of a process before continuing.

## Guide

Loops enable us to repeat the same task over and over again. For example, lets say you want to create multiple users. By using an Ansible loop, you can do that in a single task. Loops can also iterate over more than just basic lists. For example, if you have a list of users with their corresponding group, loop can iterate over them as well.  

Find out more about loops in the [Ansible Loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html){:target="_blank"} documentation.

### Step 1 - Simple Loops

To show the loops feature we will generate three new users on `node1`. For that, create the file `loop_users.yml` in `~/ansible_files` on your control node as your student user. We will use the `user` module to generate the user accounts.

```yaml
--8<-- "loops-step1-loop-users.yml"
```

Understand the playbook and the output:

* The names are not provided to the user module directly. Instead, there is only a variable called `{{ item }}` for the parameter `name`.
* The `loop` keyword lists the actual user names. Those replace the `{{ item }}` during the actual execution of the playbook.
* During execution the task is only listed once, but there are three changes listed underneath it.

### Step 2 - Loop complex lists

Sometimes, your list items contain multiple key-value-pairs. Imagine that the users should be assigned to different additional groups, your list may look like this:

```yaml
- username: dev_user
  group: ftp
- username: qa_user
  group: apache
- username: prod_user
  group: admin
```

The `user` module has the optional parameter `groups` which defines the group (or list of groups) the user should be added to. To reference items in a hash, the `{{ item }}` keyword needs to reference the sub-key: `{{ item.group }}` for example.

??? note "Hint"
    By default, the user is **removed** from all other groups. Use the module parameter `append: true` to modify this.

Let's rewrite the playbook to create the users and also add them to specific groups:

```yaml
--8<-- "loops-step2-loop-users.yml"
```  

Check the output:

* Again the task is listed once, but three changes are listed. Each loop item with its content is shown.

!!! failure
    At least one user was not created because of a missing group, the playbook failed?  
    Well, we did not create all groups, the *user*-module does not do this! Some groups are already present, either they were present by default or were created when we installed packages, other groups must be created before we can use them.  

!!! success
    To ensure all groups are created, before you reference them, add one more task which creates the groups for you!  
    Use the [`ansible.builtin.group` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html){:target="_blank"} and loop over the same list as the task which creates the users, this list contains all groups which need to be created.

    ??? tip "Need help?"

        ```yaml
        --8<-- "loops-step2-loop-users-and-groups.yml"
        ```

        Instead of repeating the list in the loop, you can (and should!) relocate the loop content to a variable and reference this one. Take a look at the following playbook:

        ```yaml hl_lines="6 18 25"
        --8<-- "loops-step2-loop-users-and-groups-with-variable.yml"
        ```

**Run the playbook again** to ensure all users (and groups) are created!

Afterwards, verify that the user `prod_user` was indeed created on `node1` using the following playbook, name it `user_id.yml`:

```yaml
--8<-- "loops-step2-user-id.yml"
```

=== "Ansible"

    ``` { .console .no-copy }
    $ ansible-playbook user_id.yml

    PLAY [Get user ID play] ******************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [node1]

    TASK [Get info for prod_user] *****************************************************************************************
    ok: [node1]

    TASK [Output info for prod_user] **************************************************************************************
    ok: [node1] => {
        "msg": [
            "prod_user uid: 1002"
        ]
    }

    PLAY RECAP *******************************************************************************************************
    node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
    ```

=== "Navigator"

    ``` { .console .no-copy }
    $ ansible-navigator run user_id.yml -m stdout

    PLAY [Get user ID play] ******************************************************************************************

    TASK [Gathering Facts] *******************************************************************************************
    ok: [node1]

    TASK [Get info for prod_user] *****************************************************************************************
    ok: [node1]

    TASK [Output info for prod_user] **************************************************************************************
    ok: [node1] => {
        "msg": [
            "prod_user uid: 1002"
        ]
    }

    PLAY RECAP *******************************************************************************************************
    node1                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
    ```

!!! hint
    It is possible to insert a *string* directly into the dictionary structure like this (although it makes the task less flexible):
    ```  { .yaml .no-copy }
    - name: Output info for user
      ansible.builtin.debug:
        msg: "{{ myuser }} uid: {{ getent_passwd{--[myuser]--}{++['prod_user']++}[1] }}"
    ```
    As you can see the *value* (`prod_user`) of the variable `myuser` is used directly. It must be enclosed in single quotes. You can't use normal quotation marks, as these are used outside of the whole variable.

### Step 3 - Loops with *list*-variable

Up to now, we always provided the list to loop in the *loop* keyword directly, most of the times you will provide the list with a variable.

```yaml linenums="1"
--8<-- "loops-step3-special-variables-playbook.yml"
```

This playbook uses two *[magic variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html){:target="_blank"}*, these variables cannot be set directly by the user and are always defined.  
The second task for example, uses the special variable `ansible_play_hosts`, which contains a **list** of hosts in the current play run, failed or unreachable hosts are excluded from this list. The first task uses the special variable `groups`, this contains a **dictionary** with all the groups in the inventory and each group has the **list** of hosts that belong to it.  
Copy the contents to a file `special_variables.yml` and run the playbook.  
We can use the playbook to display that the *loop* keyword needs *list*-input, if you provide otherwise, Ansible will display an error message.

```bash
fatal: [node1]: FAILED! => {"msg": "Invalid data passed to 'loop', it requires a list, got this instead: {'all': ['node1', 'node2', 'node3'], 'ungrouped': [], 'web': ['node1', 'node2', 'node3']}. Hint: If you passed a list/dict of just one element, try adding wantlist=True to your lookup invocation or use q/query instead of lookup."}
```

You can provoke this, if you change line 8 to `loop: "{{ groups }}"`. With that change you would try to loop a dictionary, this obviously fails.
