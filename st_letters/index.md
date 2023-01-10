# Fun with Letters in PostGIS 3.3!

There are a few new fun functions in PostGIS 3.3 which are worth exploring in this post.

## ST_Letters

First, my colleague at Crunchy Data, Paul Ramsey introduced a function to generate polygons that look like letters! This is objectively really cool and a fun use case for demos. Here's a simple example.

`Select ST_Letters('PostGIS');`
![Alt text](postgis_letters.png)


But it's also possible to overlay letters on a map, just like any other polygon. Since the default for `ST_Letters` results in a polygon starting at the baseline at the origin of the chosen projection, with a maximum height of 100 "units" (from the bottom of the descenders to the tops of the capitals),we need a way to both move it and resize it. For context, this is what the default args look like with the WGS84 projection. 

![Alt text](postgis_letters_unscaled.png)

Hmmm. Not ideal. First, we want to make a point in the middle of San Francisco in order to serve as a centroid for where we want to move the letters, and we also want to rescale the letters in order to approximately fit over the City of San Francisco. Using the formula for convering units in WGS84 to meters, 0.001 works approximately well enough to fit over the San Francisco Bay Area. Next we use `ST_Translate` in order to move the letters from the top of the map to fit over the Bay Area. Finally, mostly because it looks cool, we use `ST_Rotate` to rotate the polygon 45 degrees. 

```
With san_fran_pt AS (Select (ST_SetSRID(ST_Makepoint(-122.48, 37.758), 4326)) AS geom),
letters AS (Select (ST_SetSRID(ST_Scale(
                    ST_Letters('San Francisco'), 0.001, 0.001),
                4326)) AS geom),

letters_geom AS (
    Select ST_Translate(
            letters.geom,
            ST_X(pt.geom) - st_x(ST_Centroid(letters.geom)),
            ST_Y(pt.geom) - st_y(ST_Centroid(letters.geom))

        ) AS geom
    From letters, san_fran_pt
)
Select ST_Rotate(geom, -pi() / 4, ST_Centroid(geom))
From letters_geom;

```

![Alt text](postgis_letters_sf.png)