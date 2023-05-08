"""
This script presents a method to load geometry data in a local DB.
First, you will need 4 shape files present in the data directory :
data/Nonterrestrial_WDPA_Jan2023.dbf
data/Nonterrestrial_WDPA_Jan2023.prj
data/Nonterrestrial_WDPA_Jan2023.shp
data/Nonterrestrial_WDPA_Jan2023.shx
The, you will have to spawn a database and a pgadmin containers locally,
using the db.yaml docker compose file.
#! docker compose up -d postgres pgadmin

Once images are built and running, you can run the following
python script from the root of the bloom project.
"""
import logging
import os

import geopandas as gpd
from sqlalchemy import create_engine

logging.basicConfig()
logging.getLogger("sqlalchemy.engine").setLevel(logging.INFO)

postrges_user = os.environ.get("POSTGRES_USER")
postrges_password = os.environ.get("POSTRGES_PASSWORD")
postrges_hostname = os.environ.get("POSTGRES_HOSTNAME")
postrges_db = os.environ.get("POSTGRES_DB")


# The db url is configured with the db connexion variables declared in the db.yaml file.
db_url = (
    "postgresql://"
    + postrges_user
    + ":"
    + postrges_password
    + "@"
    + postrges_hostname
    + ":5432/"
    + postrges_db
)
engine = create_engine(db_url, echo=False)
gdf = gpd.read_file("data/Nonterrestrial_WDPA_Jan2023.shp")

gdf.to_postgis("mpa", con=engine, if_exists="append", index=False)
