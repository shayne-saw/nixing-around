# PostgreSQL Initialization and Startup Commands

```bash
initdb -D ./postgres
sudo mkdir /run/postgresql
sudo chown "${USER}:${USER}" /run/postgresql
postgres -D ./postgres
```

You can then run stuff like

```bash
createdb postgres
createuser -s postgres
```
