#!/bin/python

import sys
import psycopg2
import json

if len(sys.argv) < 4:
   print("Filename of COCOMs and AOR must be passed along with database password, e.g.:")
   print("/path/to/file.json CENTCOM <db_password>")
   exit()

jsonfile = sys.argv[1]
aor = sys.argv[2]
passwd = sys.argv[3]

print(passwd)

with open(jsonfile, 'r') as loadfile:
    data=loadfile.read()

jsondata = json.loads(data)

jsoncoords = json.dumps(jsondata["features"][0]["geometry"])

#sqlStr = "select ST_SetSRID(ST_GeomFromGeoJSON('" + jsoncoords + "'),4267)"
sqlStr = "select ST_SetSRID(ST_GeomFromGeoJSON('" + jsoncoords + "'),4326)"
#sqlStr = "select ST_GeomFromGeoJSON('" + jsoncoords + "')"
#print(sqlStr)

# Connect to the database
try:
    conn = psycopg2.connect("dbname='trackdb' user='pgadmin' host='postgresqldb02' password=" + passwd)
except:
    print "I am unable to connect to the database"

cur = conn.cursor()
try:
   cur.execute(sqlStr)
except:
   print "Unable to execute SQL!"

rows = cur.fetchone()

sqlStr = "insert into s2a_trk.aor_cocoms2(geom, cocom_aor_name) values('" + rows[0] + "', '" + aor + "')"
#sqlStr = "insert into s2a_trk.aor_cocoms(geom, cocom_aor_name) values('" + rows[0] + "', '" + aor + "')"
#sqlStr = "insert into s2a_trk.aor_cocoms(geom, cocom_aor_name) values('" + rows[0] + "', '" + aor + "')"
#sqlStr = "insert into s2a_trk.aor_cocoms(geom, cocom_aor_name) values(ST_SetSRID('" + rows[0] + "'),4326), '" + aor + "')"
#print(sqlStr)

try:
   cur.execute(sqlStr)
   conn.commit()
except:
   print("Could not insert geom value in s2a_trk.aor_cocoms table!")

cur.close()
conn.close()
