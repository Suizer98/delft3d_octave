PostgreSQL for Matlab
=====================

1) Download JDBC driver from http://jdbc.postgresql.org/download.html or use the ones in this directory
2 - option a) run PG_SETTINGS once in every new Matlab session.
              Does not occupy memory when PG_SETTINGS is not called in a Matlab session.
2 - option b) Add path to JAR file to <matlabroot>/toolbox/local/classpath.txt once and (Re)start Matlab once.
              JDBC driver now loads automatically every Matlab new session, but note: always occupies memory.
