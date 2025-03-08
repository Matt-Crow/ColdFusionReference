# ColdFusion Reference
Examples and references for CFML (ColdFusion).

## Local Dev Environment
My development environment was set up using Lucee on MacOS, but other configurations may work for you.
1. download [Lucee Express](https://download.lucee.org/)
2. unzip it
3. for ease of development, add this line to `server.xml`, within `<host>`: `<Context path="/to-do-app" docBase="/Users/matt/Repositories/ColdFusionReference/ToDoApp" />`
4. from the Lucee installation, run `bin/startup.sh` to start the server
5. go to [http://localhost:8888/to-do-app/root/index.cfm](http://localhost:8888/to-do-app/root/index.cfm)
6. when you're done, run `bin/shutdown.sh` from the Lucee installation.