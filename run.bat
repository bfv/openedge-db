

rem docker run -d -v c:/docker/openedge-db/testdb1:/app/db devbfvio/openedge-db:12.7.0-dev

docker run -d ^
  -v c:/docker/openedge-db/testdb1:/app/db ^
  -v c:/docker/openedge-db/schema%1:/app/schema ^
  -v c:/docker/openedge-db/oe127-db-dev-progress.cfg:/usr/dlc/progress.cfg ^
  --env DBNAME=sports2020 ^
  oedb
