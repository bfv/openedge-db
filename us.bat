
if NOT "%2" == "apply" (
    set DISPLAYONLY=true
) else (
    set DISPLAYONLY=false
)

docker exec --env DISPLAYONLY=%DISPLAYONLY% %1 /app/scripts/update-schema.sh 
