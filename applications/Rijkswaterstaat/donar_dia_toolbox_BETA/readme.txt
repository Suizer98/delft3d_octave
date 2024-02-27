This scripts are still are a working progress. A lot of effort is still needed, specially in explanatory headers.

If you need any support on how to use them and interpret their results, don't hesitate to contact me. 

Ivan Garcia
ivan.garcia@deltares.nl


GENERALITIES, 

Files with the suffix "thedon_" are the sort of managing files that use the
donar_....mscripts to produce a particular outcome. In these files, the name
and path of the particular file, the variable of interest, the name of the
files... are specified.

The donar_...m scripts are mainly devoted to the generation of plots of different
sort. I tried to keep them simple and practical... but of course that is relative
to the application. 

The folder "utilities" contain other scripts that are not directly related to
manipulating the donar files, but are stil necessary for some of the data processing.


STEP BY STEP EXPLANATION ON HOW TO PRODUCE NETCDF FILES FROM DIA FILES:

1. Modify thedon_dia2donarmat to fit to your particular
   need and execute.
2. Modify thedon_donarmat2NC to read the outcome of step 1  
   and execute.