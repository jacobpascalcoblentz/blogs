With pt As (Select (st_setsrid(st_makepoint(-122.48, 37.758), 4326)) As geometry),

letters As (Select (st_setsrid(st_scale(
                    st_letters('San Francisco'), 0.001, 0.001),
                4326)) As geometry),

letters_geom As (
    Select st_translate(
            letters.geometry,
            st_x(pt.geometry) - st_x(st_centroid(letters.geometry)),
            st_y(pt.geometry) - st_y(st_centroid(letters.geometry))

        ) As geometry
    From letters, pt
)

Select st_rotate(geometry, -pi() / 4, st_centroid(geometry))
From letters_geom;
