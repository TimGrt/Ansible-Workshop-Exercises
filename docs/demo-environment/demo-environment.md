# RedHat Demo Environment

Every Workshop attendant has his own demo environment.

## Lab Diagram

The Lab environment consist of an *Ansible control node* (called `ansible-1`) and three *Managed nodes* (called `node1`, `node2` and `node3`). All managed nodes are RHEL 8 hosts and are reachable password-less with SSH.

![ansible rhel lab diagram](rhel_lab_diagram.png)

You will be logged in to the *Ansible Control node* with the Code editor *Visual Studio Code*. From here you will be writing all your playbooks and issuing all Ansible CLI commands.

## Visual Studio Code

At its heart, Visual Studio Code is a code editor. Like many other code editors, VS Code adopts a common user interface and layout of an explorer on the left, showing all of the files and folders you have access to, and an editor on the right, showing the content of the files you have opened.

!!! tip
    It is highly recommended to use the *VS Code Editor* to write your playbooks, it has **automatic saving** and syntax highlighting enabled!

If you want the real YAML challenge, try to write all your playbooks in the terminal/on the command-line. Expect to struggle at first with indentation, which leads to errors trying to run your playbooks.  
Nevertheless, mastering to write Ansible playbooks without the help of a Code editor is the best possible way to really understand the YAML syntax. It doesn't take long and is highly rewarding.

### Useful VScode configuration

#### Color theme for syntax highlighting

The *Ansible* extension supports *syntax-highlighting* for Ansible content. Depending on the used *theme* of VScode, this might not be shown correctly. Use the **Default Dark+** theme.  
Click on *File* in the top menu bar, click on *Preferences* and open *Settings*. Search for `theme` and choose the *Dark+ (default dark)* from the drop-down menu.

![Workbench Color Theme](WorkbenchColorTheme.png)

#### Terminal Scrollback

By default, scrollback of only 1000 lines is possible. If you need to scroll back further, you need to adjust this limit.  
Click on *File* in the top menu bar, click on *Preferences* and open *Settings*. Search for `scrollback` and adjust the number to 10000 in the second configuration parameter (*Terminal > Integrated: Scrollback*).

![Terminal Scrollback configuration](TerminalScrollback.png)
