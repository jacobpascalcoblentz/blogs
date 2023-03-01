## Geocoding with web APIs in Postgres!

While it's possible to build a [fully featured geocoder in PostGIS](https://.net/docs/postgis_installation.html#install_tiger_geocoder_extension),
there may be reasons one may not want to. Specifically, the Tiger geocoder requires downloading large amounts of census data, and in space-limited databases, this may not be feasible. 
What if we could use  a python function in `plpython3u` to hit a web service geocoder every time that we got a new row in the database? In this demo we'll walk through setting this up. 


# Installing plpython3u

The `plpython3u` extension comes with Crunchy Bridge
To get started run the following: 
```
CREATE EXTENSION  plpython3u;
```

# Creating a function to geocode addresses 

In this example, I'll use the [US census geocoding API](https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html) as our web service, and build a function to geocode addresses based on that. 

The function puts together parameters to hit the census geocoding API and then parses the resulting object, and returns a geometry


```sql
CREATE OR REPLACE FUNCTION geocode(address text)
RETURNS geometry
AS $$
import requests
try:
	payload = {'address' : address , 'benchmark' : 2020, 'format' : 'json'}
	base_geocode = 'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress'
	r = requests.get(base_geocode, params = payload)
	coords = r.json()['result']['addressMatches'][0]['coordinates']
	lon = coords['x']
	lat = coords['y']
	geom = f'SRID=4326;POINT({lon} {lat})'
except IndexError:
	plpy.notice(f'address failed: {address}')
	geom = None
return geom
$$
LANGUAGE 'plpython3u';
```

Using this function to geocode Crunchy Data's headquarters:

```sql
SELECT geocode('162 Seven Farms Drive Charleston, SC 29492');

```
![Geocoded Crunchy HQ](geocode_1.png)


# Deploying this function! 

But what if we want to automically run this every time an address is inserted into a table? Let's say we have a table with a field ID, an address, and a point that we want to auto-populate on inserts?

```sql
CREATE TABLE addresses (
	fid SERIAL PRIMARY KEY,
	address VARCHAR,
	geom GEOMETRY(POINT, 4326)
);
```

We can make use of a Postgres trigger to add the geocode before every insert! 

```sql
CREATE OR REPLACE FUNCTION add_geocode()
RETURNS trigger AS
$$ 
DECLARE 
    loc geometry;
BEGIN 
    loc := geocode(NEW.address);
    NEW.geom = loc;
    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;
```

```sql
CREATE TRIGGER update_geocode BEFORE INSERT ON addresses
    FOR EACH ROW EXECUTE FUNCTION add_geocode();
	
```

Now when running an insert, the value is automatically geocoded! 

```sql
INSERT INTO addresses(address) VALUES ('415 Mission St, San Francisco, CA 94105');
```

```
postgres=# select * from addresses;
 fid |                 address                 |                        geom
-----+-----------------------------------------+----------------------------------------------------
   1 | 415 Mission St, San Francisco, CA 94105 | 0101000020E610000097CD0E2B66995EC0BB004B2729E54240
```

# Summary: 

PostgresSQL triggers are a very powerful way to leverage built in functions to automatically transform your data as it enters the database, and this particular case is a great demo for them!






