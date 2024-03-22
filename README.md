# Bashortcut
## Description
Bashortcut is a simple bash script to display a graphical selection menu of user defined commands. A selected command is then run in your current shell.  
This makes Bashortcut a user-friendly, low mental load alternative to defining aliases.  
Shortcuts are defined in a ``.bashortcuts`` file, each line of that text document will be displayed as a menu item.  
### Example
```
user@os ~ : s
[ h ] cd /etc/nixos
[ j ] echo "hello world"
Which command do you want to run? Press the shown key (case sensitive!) or Ctrl-C to cancel
(case-sensitive user input:) j
cd /etc/nixos
user@os /etc/nixos :
```
## Installation
Clone this repository to a directory where it will stay, such as ~/bashscripts
```
cd ~
mkdir bashscripts
cd bashscripts
git clone https://github.com/BaumerEDV/bashortcut.git
```
Create an alias in your .bashrc (or whatever other file you use to automatically declare aliases on shell start-up) that sources ``bashortcut.sh``:
```
alias s="source $HOME/bashscripts/bashortcut/bashortcut.sh"
```
Note that you can customize the alias ``s`` to your liking. The path must point to the exact location of ``bashortcut.sh``
## Creating Shortcuts
The easiest way to get started is to create a ``.bashortcuts`` file in your home directory, this will then make these shortcuts accessible via your set alias no matter from which directory you call the alias from.  
Example contents of ~/.bashortcuts:
```
cd /etc/nixos
echo "hello world"
```
Invoking your alias will lead to the output in the above example session.
### Directory Specific Shortcuts
You can have more than one ``.bashortcuts`` file. This will allow you to display additional shortcuts in other directories.  
With default settings, Bashortcut will look for ``.bashortcuts`` files and add them to the menu in the following order:
- Your shell's current working directory
- The parent directory of your current working directory (iteratively, until the file system root is reached)
- Your home directory  
For example, if you create a ``.bashortcuts`` file in ``/etc/nixos`` with the contents ``sudo nixos-rebuild switch`` and you invoke your alias whilst in ``/etc/nixos`` or one of its sub-directories, your shortcut menu will look as follows:
```
user@os /etc/nixos : s
[ h ] sudo nixos-rebuild switch
[ j ] cd /etc/nixos
[ k ] echo "hello world"
Which command do you want to run? Press the shown key (case sensitive!) or Ctrl-C to cancel
```
The first command is contained in ``/etc/nixos/.bashortcuts``, the other two in ``~/.bashortcuts`` from the previous example. However, if you invoke your alias from ``~``, the first entry will not be shown as it is not defined in any parent directory or your home directory.
## Configuration
Some behaviours of the script can be customized by editing ``bashortcuts.sh``. Externalizing configuration to a ``.bashortcutsrc`` file is on the project roadmap.
### Shortcut Keys
The ``SHORTCUT_KEYS`` variable defines which shortcut key is used for which menu item. Each menu item is assigned a single character and characters are assigned from left to right. Thus if ``SHORTCUT_KEYS`` is "hjkl", the first menu item will have the shortcut ``h``, the second ``j`` and so on. 
### Clear Menu After Selection
``DO_CLEAR_MENU`` sets if the script will attempt to erase the displayed menu after selection to reduce clutter. Set this to ``false`` if you prefer the menu to be in your visual history after use or if the clearing is malfunctioning due to the capabilities of your terminal emulator or environment. The default value is ``true``.
### Customize Location of the Default .bashortcuts File
``DEFAULT_COMMANDS_SOURCE`` sets where the global ``.bashortcuts`` file is sourced from. It is the full file path of that file, so it must include ``.bashortcuts`` at the end. The default value is the user's home directory.
### Contain Current / Parent Directory Search to First Match
If you want to stop searching through parent directories after a single ``.bashortcuts`` file has been found, set ``SEARCH_IN_PARENT_DIRECTORIES_AFTER_SOMETHING_WAS_FOUND`` to ``false``. This is useful if you have many shortcuts in deeply nested directories while their utility is local to those directories. The default value is ``true``.
### Don't Display Home / Default Shortcuts if a Local Shortcut was Found
If you *only* want to display local commands from current and parent directories, provided there are some, you can set ``SEARCH_IN_PARENT_DIRECTORIES_AFTER_SOMETHING_WAS_FOUND`` to ``false``. This is useful if some of your shortcut files are expansive or you only use your home shortcuts for navigation from the home directory. The default value is ``true``
