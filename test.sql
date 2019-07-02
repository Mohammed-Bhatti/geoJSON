-- Create table using ST_Subdivide
create table s2a_trk.aor_cocoms_sub as (
        select id, cocom_aor_name, geom from (select id, cocom_aor_name, st_subdivide((st_dump(geom)).geom) as geom 
                                              from s2a_trk.aor_cocoms order by cocom_aor_name) foo
                                        );

create index on s2a_trk.aor_cocoms_sub using gist (geom);

-- Here are some queries using PostGIS functions

-- Area of Entire Set in Degrees
select st_area(st_collect(geom)) from s2a_trk.aor_cocoms;

-- Area of Entire Set in Meters
select st_area(st_collect(geom)::geography) from s2a_trk.aor_cocoms;

-- Check Performance by Picking a Point in a Particular Region
\timing

select cocom_aor_name
from s2a_trk.aor_cocoms
where ST_Intersects(geom, ST_SetSRID(st_MakePoint(0,0),4326));

    cocom_aor_name
----------------------
 AFRICOM
(1 row)

Time: 94.003 ms

select cocom_aor_name
from s2a_trk.aor_cocoms_sub
where ST_Intersects(geom, ST_SetSRID(st_MakePoint(0,0),4326));

    cocom_aor_name
----------------------
 AFRICOM
(1 row)

Time: 5.141 ms

-- Query to generate all points at one degree intervals:
with coords as (
   select * 
   from generate_series(-180, 180) lon, generate_series(-90,90) lat
), points as (
   select st_makepoint(lon, lat) as point 
   from coords
)
select * from coords;

-- or, to get the points, use this
with coords as (
   select * 
   from generate_series(-180, 180) lon, generate_series(-90,90) lat
), points as (
   select st_makepoint(lon, lat) as point 
   from coords
)
select * from points;

-- Query to Generate Points not Covered by AORs
with coords as (
   select *
   from generate_series(-180, 180) lon, generate_series(-90,90) lat
), points as (
   select st_setsrid(st_makepoint(lon, lat),4326) as point
   from coords
)
select point, aor.cocom_aor_name, aor.geom, st_astext(points.point)
from points left join s2a_trk.aor_cocoms_sub aor on st_intersects(aor.geom, points.point)
where aor.geom is null;

-- Query to Exclude Points that Fall on Outer Edges
with coords as (
   select *
   from generate_series(-180, 180) lon, generate_series(-90,90) lat
), points as (
   select st_setsrid(st_makepoint(lon, lat),4326) as point
   from coords
)
select point, aor.cocom_aor_name, aor.geom, st_astext(points.point)
from points left join s2a_trk.aor_cocoms_sub aor on st_intersects(aor.geom, points.point)
where aor.geom is null and (st_x(point) <> -180 and st_x(point) <> 180 and st_y(point) <> -90 and st_y(point) <> 90);

-- Query to Distance Between Two Points in Meters
select st_distance(st_setsrid(st_makepoint(-179, 90),4326)::geography, st_setsrid(st_makepoint(179,90),4326)::geography);
 
 
 st_distance
-------------
           0
(1 row)
 
 
select st_distance(st_setsrid(st_makepoint(-179, 89),4326)::geography, st_setsrid(st_makepoint(179,89),4326)::geography);
  st_distance
---------------
 3898.45558456
 
 -- Query to Measure Distance Between Two Points in Degrees
 select st_distance(st_setsrid(st_makepoint(-179, 90),4326), st_setsrid(st_makepoint(179,90),4326));
 
 
 st_distance
-------------
         358

-- Check Performance between Regular geom and ST_SUBDIVIDE geom
-- Given two points
select cocom_aor_name
from s2a_trk.aor_cocoms
where ST_Intersects(geom, ST_SetSRID(st_MakePoint(56.469519, 32.668505),4326));

select cocom_aor_name
from s2a_trk.aor_cocoms_sub
where ST_Intersects(geom, ST_SetSRID(st_MakePoint(56.469519, 32.668505),4326));
                                     
