-- some cool functions in postgis 3.3.0!
-- run this through a linter after
-- create polygons as text 

Select ST_LETTERS('PostGIS');

With pt As (Select (ST_SETSRID(ST_MAKEPOINT(-122.48, 37.758), 4326)) As geometry),

letters As (Select (ST_SETSRID(ST_SCALE(
                    ST_LETTERS('San Francisco'), 0.001, 0.001),
                4326)) As geometry),

letters_geom As (
    Select ST_TRANSLATE(
            letters.geometry,
            ST_X(pt.geometry) - ST_X(ST_CENTROID(letters.geometry)),
            ST_Y(pt.geometry) - ST_Y(ST_CENTROID(letters.geometry))

 ) As geometry
    From letters, pt
)

Select ST_ROTATE(geometry, -PI() / 4, ST_CENTROID(geometry))
From letters_geom;

-- What about a row for each letter and polygon?
Create Table public.words As (
    With word As (
        Select 'PostGiS' As word
 ),

    letters_geom As (
        Select ST_LETTERS(word.word) As geom From
            word
 )

    Select
        REGEXP_SPLIT_TO_TABLE(word.word, '') As letters,
        (ST_DUMP(letters_geom.geom)).geom
    From word, letters_geom
);

-- generate a point cloud in those letters

Select ST_GENERATEPOINTS(geom, 1000) From words;

Select ST_CONCAVEHULL(ST_GENERATEPOINTS(geom, 1000), 0.2, True ) From words;

With word As (
    Select 'PostGiS' As word
),

letters_geom As (
    Select ST_LETTERS(word.word) As geom From
        word
)

Select
    REGEXP_SPLIT_TO_TABLE(word.word, '') As letters,
    (ST_DUMP(letters_geom.geom)).geom
From word, letters_geom;
