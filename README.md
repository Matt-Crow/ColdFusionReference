# ColdFusion Reference
Examples and references for CFML (ColdFusion).

## Local Dev Environment
My development environment was set up using Lucee on MacOS, but other configurations may work for you.
1. download [Lucee Express](https://download.lucee.org/)
2. unzip it
3. for ease of development, make a symlink from the repo folder to the Lucee root folder. `ln -s /path/to/repo/ToDoApp /path/to/lucee/webapps/ROOT/ToDoApp`
4. from the Lucee installation, run `bin/startup.sh` to start the server
5. go to [http://localhost:8888/ToDoApp/root/index.cfm](http://localhost:8888/ToDoApp/root/index.cfm)
6. when you're done, run `bin/shutdown.sh` from the Lucee installation.

## To Do
- Figure out how to server only the files under root while still allowing Lucee to find the other files