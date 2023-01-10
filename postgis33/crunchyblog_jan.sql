-- some cool functions in postgis 3.3.0!
-- run this through a linter after
-- create polygons as text 

Select ST_Letters('PostGIS');

With pt as (select 
			(st_setsrid(st_makepoint(-122.48, 37.758), 4326)) as geometry),
	letters as (select (st_setsrid(st_scale(
					   st_letters('San Francisco'), 0.001, 0.001),
								 4326)) as geometry),
	letters_geom as (
		select 
			st_translate(
			letters.geometry, 
			st_x(pt.geometry) - st_x(st_centroid(letters.geometry)),
			st_y(pt.geometry) - st_y(st_centroid(letters.geometry))

			) as geometry
		from letters, pt
	)
	select st_rotate(geometry, -pi()/4, st_centroid(geometry))
	from letters_geom;

-- What about a row for each letter and polygon?
CREATE TABLE public.words AS (
With word as (
 Select 'PostGiS' as word
), letters_geom as (
	Select ST_Letters(word.word) as geom from 
	word
)
Select regexp_split_to_table(word.word, '') as letters,
	(ST_Dump(letters_geom.geom)).geom
	from word, letters_geom
	);
	
-- generate a point cloud in those letters

select ST_GeneratePoints(geom, 1000) from words;
 
select ST_ConcaveHull(ST_GeneratePoints(geom, 1000),0.2, true ) from words;

With word as (
 Select 'PostGiS' as word
), letters_geom as (
	Select ST_Letters(word.word) as geom from 
	word
)
Select regexp_split_to_table(word.word, '') as letters,
	(ST_Dump(letters_geom.geom)).geom
	from word, letters_geom;