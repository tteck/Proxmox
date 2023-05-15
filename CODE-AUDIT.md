In the case of the < app > LXC, the process involves running multiple scripts for each application or service.<br>
Initially, the `<app>.sh` script is executed to collect system parameters.<br>
Next, the `build.func` script adds user settings and integrates all the collected information.<br>
Then, the `create_lxc.sh` script constructs the LXC container.<br>
Following that, the `<app>-install.sh` script is executed, which utilizes the functions exported from the `install.func` script for installing the required applications.<br>
Finally, the process returns to the `<app>.sh` script to display the completion message.<br>

Thoroughly evaluating the `<app>-install.sh` script is crucial to gain a better understanding of the application installation process.<br>
Every application installation utilizes the same set of reusable scripts: `build.func`, `create_lxc.sh`, and `install.func`. These scripts are not specific to any particular application.<br>
