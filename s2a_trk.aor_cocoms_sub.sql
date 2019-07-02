/*
Create the aor_cocoms_sub table that will use the ST_Subdivide function to sub-divide the geometries in the aor_cocoms table

This will improve query lookup significantly
*/

create table s2a_trk.aor_cocoms_sub (
id serial primary key, 
cocom_aor_name char(20), 
geom geometry, 
seclab char(20)
);

create index on s2a_trk.aor_cocoms_sub using gist (geom);
