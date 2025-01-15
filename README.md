# OpenEdge db image     

## release notes
see: [release notes](release-notes)<br/>

This docker images facilitates running an OpenEdge db in a Docker container. Apart from this it facilitates builing and/or updating the database from a given `.df`/`.st`.

## volumes
The following volumes are important for running the database:

`/app/db` - the db files will reside here
`/app/schema` - the location where `.df` and/or `.st` files are located
`/app/data` - the location of the .d files
`/usr/dlc/progress.cfg` - location where the `.cfg` file MUST reside (otherwise ESM kicks in)

When running the container these volume are mapped via the `-v` parameter.
For example:
```
docker run -d ^
    -v c:/sports2020/db:/app/db ^
    -v c:/sports2020/schema:/app/schema ^
    -v c:/sports2020/data:/app/data ^
    -v c:/sports2020/progress.cfg:/usr/dlc/progress.cfg ^
    -p 10000-10010:10000-10010
    --env DBNAME=sports2020 ^
    docker.io/devbfvio/openedge-db:12.8.4
```

## database name
The scripts in the container operate under the assumption that the env var `DBNAME` is set, hence:
`--env DBNAME=sports2020`.

## schema / structure files
The `.df` and `.st` files (in either /app/schema or /app/db) should have the same name as the database.

## loading .d data
The existence of `/app/data/tables.txt` is checked. If `.d` loading is required, this file should contain either a comma separated list of table names  of all tables are to be loaded (or `all` for all tables).
The `.d` files should be in `/app/data` as well. One can map (`-v` parameter) a folder on the host to `/app/data`.
 
## startup sequence
The first thing is establishing the DBNAME. If ${DBNAME} is empty is database name is derived. The first `.db` file is taken to get the database name.

Once the database name is established the initialization starts.
- if a `.lk` is found the container exits
- if a `.db` files is not found, the process searches for a `.df` and `.st` in `/app/schema` 
  - if one of these is not found, the container exits
  - otherwise a empty database is build based on the `.df` and `.st`. 
  - `/usr/dlc/empty8` is copied to the database (todo: UTF-8 support need)
  - the `.df` file is hashed and this hash is put in `/app/db/<dbname>.schema.hash` 
- otherwise (the database is already there)
  - if `/app/schema/<dbname>.df` is present this is hashed and compared to `/app/db/<dbname>.schema.hash`
  - if they differ the schema needs to be updated (create new empty db, created delta, apply delta)
  
At this point the container is either exited or has an up to date database (schema wise)
The database is started:
```
proserve /app/db/${DBNAME} -pf /app/db/db.pf
```

This implies that a `db.pf` MUST be present.

## `db.pf`
This file should container at least:
```
-S 10000
-minport 10001
-maxport 10010
```

You can use whatever ports you like.

## stopping the database
The database is gracefully shut down whenever an `SIGINT` or `SIGTERM` signal is sent to the container.
`proshut` executes and the db goes down, no `.lk` is left. Ready for the next start up.

## updating the schema
When a new `.df` is put in `/app/schema` (read: its mounted location on the host) there are two options:
- stop and start the db (see above). The db is updated offline
- run `docker exec -d /app/scripts/update-schema.sh`. This is online and it may fail subsequently.

## docker compose
The most logical things is running the db from a docker compose stack. An example `docker-compose.yaml`:
```
version: "3.8"

services:
  sports2020-db:
    image: docker.io/devbfvio/openedge-db:12.8.0
    volumes:
      - c:/docker/sports2020/db:/app/db
      - c:/docker/sports2020/schema:/app/schema
      - c:/docker/license/oe-12.8/oe128-db-dev-progress.cfg:/usr/dlc/progress.cfg
    ports:
      - 10000-10010:10000-10010
    environment:
      - DBNAME=sports2020
```

## .lk file handling
If an .lk file is found upon running the container the container exits, unless you set the `DEL_LK_FILE` to true. (f.e. `--env DEL_LK_FILE=true`)

# multi tenancy
When a db is created the `.df` is scanned for `MULTITENANT yes`. If found, the db is created as a multi tenant db.

# progress.cfg license file
With Docker (compose) it is possible to do 
```
-v c:/docker/license/oe-12.8/oe128-db-dev-progress.cfg:/usr/dlc/progress.cfg
```
In other words, volume the `progress.cfg` file into `/usr/dlc/progress.cfg`.
However, this does not work on Kubernetes. As an alternative, the `startdb.sh` startup script checks if `/app/license/progress.cfg` exists and if so, copies it to `/usr/dlc/progress.cfg`. 

# Kubernetes
See: [kubernetes.md](kubernetes.md)

