rem local testing script

docker run -d ^
  -v c:/docker/openedge-db/testdb1:/app/db ^
  -v c:/docker/openedge-db/schema%1:/app/schema ^
  -v c:/docker/license/oe-12.8/progress.cfg:/usr/dlc/progress.cfg ^
  --env DBNAME=sports2020 ^
  oedb
