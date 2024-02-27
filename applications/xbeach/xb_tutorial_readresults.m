%% 3. Reading your model results
%
% Once an XBeach model is finished running, it's time to load the model
% output into the XBeach Toolbox. This tutorial shows you how.

%% Reading model output
%
% Reading model output is done with the _xb_read_output_ function. The
% function is capable of reading both netCDF as DAT output. Any file ending
% with _.nc_ is supposed to be a XBeach netCDF output file. Any file enign
% with _.dat_ or any directory is supposed to be or contain one or more
% XBeach DAT output files.

% reading DAT files
xbo = xb_read_output('path_to_model/');
xbo = xb_read_output('path_to_model/zb.dat');

% reading netCDF files
xbo = xb_read_output('path_to_model/xboutput.nc');

%%
% It is also possible to supply the result structure from either the
% _xb_run_ or _xb_run_remote_ function that contains information on the
% location where the model can be found on disk.

xbo = xb_read_output(xbr);

%% Narrowing the amount of data read
%
% For large models, the amount of data read from the output files can
% become very large. In order to cope with the large amounts of data, the
% amount of data read can be narrowed down to a specific part. Narrowing
% down the data can be done in two ways: limiting the number of variables
% read or limiting the amount of data read for each variable.

% limit the number of variables read from directory with DAT files
xbo = xb_read_output('path_to_model/', 'vars', {'zb', 'zs', 'H'});

% limit the number of variables read from netCDF file
xbo = xb_read_output('path_to_model/xboutput.nc', 'vars', {'zb', 'zs', 'H'});

% use asterix filtering to limit the number of parameters read
xbo = xb_read_output('path_to_model/', 'vars', {'z*', 'H', '*_mean'});

% use regular expression filtering to limit the number of parameters read
% (don't forget the starting slash)
xbo = xb_read_output('path_to_model/', 'vars', '/_(min|max|mean)$');
xbo = xb_read_output('path_to_model/', 'vars', {'/^z', '/g$'});

%%
% Limiting the amount of data read per variable is done using starting
% indices, lengths and strides. This way of filtering is common to netCDF
% files and also implemented in the DAT read functions in the XBeach
% Toolbox.
%
% The filtering works using at most three vectors (start, length and
% stride) with each a length of at most the number of dimensions in the
% variable to be read. Thus, a 3D variable has vectors of length equal to
% or smaller than 3. If the length is smaller than the number of
% dimensions, the filtering is assigned to the first few dimensions. The
% other dimensions are kept unfiltered.
%
% The start indices are zero-based and indicate which part of the data at
% the beginning of a particular dimension should be skipped. So, with zero
% nothing is skipped, with one only the first item, with ten the first ten
% items, etcetera.
%
% The lengths indicate the number of items to be read counting from the
% starting index. The strides indicates the read resolution of the data to
% be read. So, specifying a length 99 and a stride 3 means that 33 items
% are read.
%
% For example:

% using start, length and stride options to limit the amount of data read
% from a netCDF file
xbo = xb_read_output('path_to_model/xboutput.nc', ...
    'vars', {'z*', 'H'}, ...
    'start', [99 10 0], ...
    'length', [1 10 -1], ...
    'stride', [1 2 5] ...
);

% in the XBeach Toolbox limiting the amount of data read from DAT files is
% implemented according to the netCDF standards
xbo = xb_read_output('path_to_model/', ...
    'vars', {'z*', 'H'}, ...
    'start', [99 10 0], ...
    'length', [1 10 -1], ...
    'stride', [1 2 5] ...
);

%%
% In the two examples above, the 100st item is read from the first
% dimension (time), the 10th to 20th items using a stride of 2 are read
% from the second dimension (y) and all data is read from the third
% dimension (x) using a stride of 5. Consequently, the matrices read will
% have a size of [1 5 20] assuming the third dimension to have a length of
% 100.

%% Swapping your data dimensions
%
% In the model output DAT files the first two dimensions are x and y. The
% last dimension is time. In case there are more than three dimensions,
% they are located in between y and time. Following netCDF conventions, the
% dimension order in model output netCDF files is different. The first
% three dimensions are time, y and x respectively. All other dimensions are
% located thereafter. It is decided that the XBeach Toolbox is designed for
% the time, y, x dimension order. Consequently, reading DAT files using the
% XBeach Toolbox will return matrices in this order as well. To facilitate
% the use of other, older functions, the dimension order of an XBeach
% output structure can be swapped:

% swap dimension from new to old standard ...
xbo = xb_swap(xbo);

% ... and back
xbo = xb_swap(xbo);

% force swapping from new to old standard ...
xbo = xb_swap(xbo, 'order', 'tyx', 'force', true);

% ... and back
xbo = xb_swap(xbo, 'order', 'xyt', 'force', true);