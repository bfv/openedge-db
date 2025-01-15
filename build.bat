rem this script is for local testing only

rem for testing we use 
docker build ^
    --build-arg="OE_VERSION=12.8.4" ^
    --build-arg="RESPONSE_FILE=oe128-db-dev-response.ini" ^
    -t docker.io/devbfvio/openedge-db:12.8.4 . 

rem remove intermediate containers
docker image prune -f

