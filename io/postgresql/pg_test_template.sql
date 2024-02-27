-- Simple datamodel for use in pg_test.m
-- pg_test_template.sql
-- Replace "?TABLE" with required table name
-- Replace "?USER"  with owner
-- % $Id: pg_quote.m 7264 2012-09-21 11:27:43Z boer_g $
-- % $Date: 2012-09-21 13:27:43 +0200 (vr, 21 sep 2012) $
-- % $Author: boer_g $
-- % $Revision: 7264 $
-- % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_quote.m $
-- % $Keywords: $

CREATE TABLE    "?TABLE" () WITH (OIDS=FALSE);
ALTER  TABLE    "?TABLE" OWNER TO ?USER;

-- 1) automatic counter
ALTER  TABLE    "?TABLE" ADD   COLUMN "ObservationID"   integer;
ALTER  TABLE    "?TABLE" ALTER COLUMN "ObservationID"   SET NOT NULL;
CREATE SEQUENCE "?TABLE_ObservationID_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 6 CACHE 1;
ALTER  TABLE    "?TABLE_ObservationID_seq" OWNER TO ?USER;
ALTER  TABLE    "?TABLE" ALTER COLUMN "ObservationID" SET DEFAULT nextval('"?TABLE_ObservationID_seq"'::regclass);
ALTER  TABLE    "?TABLE" ADD CONSTRAINT "?TABLE_pkey" PRIMARY KEY("ObservationID" );

-- 2) when: time stamp
ALTER  TABLE    "?TABLE" ADD   COLUMN "ObservationTime" timestamp with time zone;

-- 3) what: value
ALTER  TABLE    "?TABLE" ADD   COLUMN "Value" real;

-- 4) where: coordinates: TO DO with PostGIS
