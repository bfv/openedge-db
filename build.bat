rem docker build -t openedge-db:12.7.0 -t openedge-db:latest -t devbfvio/openedge-db:12.7.0-dev .

rem for testing we use 
docker build ^
    --build-arg="OE_VERSION=12.8.0" ^
    --build-arg="RESPONSE_FILE=oe128-db-dev-response.ini" ^
    -t docker.io/devbfvio/openedge-db:12.8.0 . 

rem remove intermediate containers
docker image prune -f

