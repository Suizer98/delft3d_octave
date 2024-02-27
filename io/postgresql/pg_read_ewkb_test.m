function OK = pg_read_ewkb_test
%pg_read_ewkb_TEST test for pg_read_ewkb
%
%See also: pg_read_ewkb, http://svn.osgeo.org/postgis/trunk/regress/

OK = [];

%% http://en.wikipedia.org/wiki/Well-known_text
[S]=pg_read_ewkb('000000000140000000000000004010000000000000'                );OK(end+1) = (S.srid==0    ) & all(S.coords==[2 4]); % http://en.wikipedia.org/wiki/Well-known_text

%% http://postgis.refractions.net/docs/using_postgis_dbmanagement.html#EWKB_EWKT
[S]=pg_read_ewkb('01010000200400000000000000000000000000000000000000'        );OK(end+1) = (S.srid==4    ) & all(S.coords==[0 0]);

%% http://jaspa.upv.es/jaspa/v0.2.0/manual/html/ST_GeomFromEWKB.html
[S]=pg_read_ewkb('010100000000000000000014400000000000001440'                );OK(end+1) = (S.srid==0    ) & all(S.coords==[5 5]);
[S]=pg_read_ewkb('0101000020e664000000000000000014400000000000001440'        );OK(end+1) = (S.srid==25830) & all(S.coords==[5 5]);

%% https://docs.djangoproject.com/en/dev/ref/contrib/gis/geos/
[S]=pg_read_ewkb('0101000000000000000000F03F000000000000F03F'                );OK(end+1) = (S.srid==0    ) & all(S.coords==[1 1]);
[S]=pg_read_ewkb('00000000013FF00000000000003FF0000000000000'                );OK(end+1) = (S.srid==0    ) & all(S.coords==[1 1]);
[S]=pg_read_ewkb('0101000020E6100000000000000000F03F000000000000F03F'        );OK(end+1) = (S.srid==4326 ) & all(S.coords==[1 1]);
[S]=pg_read_ewkb('0101000080000000000000F03F000000000000F03F000000000000F03F');OK(end+1) = (S.srid==0    ) & all(S.coords==[1 1 1]);

%% http://svn.osgeo.org/postgis/trunk/regress/wkb_expected
%  http://svn.osgeo.org/postgis/trunk/regress/wkb.sql

OK = all(OK);