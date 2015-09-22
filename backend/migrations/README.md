### README

We're using the uuid library [uuid-ossp](http://www.postgresql.org/docs/devel/static/uuid-ossp.html "UUID-OSSP").
Installed with:
```sql
CREATE EXTENSION "uuid-ossp";
```
after connecting to the database with:
```sh
psql -h localhost -U{USERNAME} -dpostgres
```

## INFO
The database name is `party`, as is the schema name. This means that database
entities should be namespaced with `party.`

## HOWTO

You Can run a migration with:
```sh
$ psql -h localhost -U{USERNAME} -dparty < {MIGRATION}.sql
```
