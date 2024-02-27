THESE ARE REVERSED ENGINEERED FUNCTIONS AND WILL PROBABLY NOT WORK, BUT THIS IS IN SHORT HOW IT *SHOULD* WORK:
ALTERNATIVETY TRY THE +donar PACKAGE.

Basic read commands:

DIA = donar_dia_read('some_file.dia');
DIA = donar_dia_read('some_file.dia','to',10);
DIA = donar_dia_read('some_file.dia','stride',10);
DIA = donar_dia_read('some_file.dia','index',[1 20 100]);

You can first investigate the data and then use the lookup table to load specific blocks (should become a sort of filter to be used at once):

DIA = donar_dia_read('some_file.dia','nodata',true);
DIA = donar_dia_read('some_file.dia','index',DIA.parameters.MUX.combined.GOLFHTSTM50);

It automatically calls donar_dia_parse afterwards to guess the axes (time, frequency, etc.) and split the data accordingly. This is where it most probably will go wrong :-)

You can view the data like this:

donar_dia_view(D)

### RATIONALE:

What you will get (if it works) is a structure array D.data with an element corresponding to each data block in the file. Each data block is divided in sections (W3H,MUX,WRD,etc) that are fields in this structure array. Two types exist: meta and data.
Meta fields are structures with unique fieldnames based on the first few values found. Other values are added in the corresponding cell arrays.
Data fields are structures with fieldnames dataX. A data section contains two intertwined data structures. They are separated and appear as data1 and data2. If the parse routine guesses the data2 field is not matching any specific axes, it starts to cut it in pieces. That's why sometimes X in dataX may become larger than 2.
