# Data Readme

Vanlife Spot Finder uses Spatialite/SQLite to store data. This configuration allows for powerful GIS capabilities and doesn't require a database server.

## Create Database

To create the database from scratch you will need to have Spatialite installed. On Ubuntu, you can install it with the following command:

```
sudo apt-get install spatialite-bin
```

To create an empty database with the required schema, run the following command:

```
spatialite data.db < create_db.sql
```


## Scrape Data

Need an API key

Only performed periodically to limit API requests and website page loads

## Populating Database

To allow diffs to work, the database data in committed to the repository as insert actions that must be executed to build the database.

To populate the database, run the following command:

```
spatialite data.db < populate_db.sql
```



