/*
Create the table to load the geoJSON data
*/

create table s2a_trk.aor_cocoms (
id serial primary key,
cocom_aor_name character(20),
geom geometry);

create index on s2a_trk.aor_cocoms using gist (geom);
