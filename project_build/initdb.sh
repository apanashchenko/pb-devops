#!/bin/bash
#initdb.sh
docker-compose -f docker-compose-db.yml up -d db

docker-compose -f docker-compose-db.yml run --rm dockerize -wait-retry-interval 10s -timeout 120s -wait tcp://db:5432

PGPASSWORD=proj693B119 psql -h localhost -p 5432 -U postgres -w -f initdb.sql
#end of initdb.sh
