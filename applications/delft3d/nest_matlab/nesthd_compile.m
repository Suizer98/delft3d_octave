function compile_nesthd
%COMPILE_NESTHD compile nesthd
%
%See also: nest_matlab

addpath(genpath('..\..\..\'));
addpath(genpath('nest_ui'));
addpath(genpath('nesthd1'));
addpath(genpath('nesthd2'));
addpath(genpath('general'));
addpath(genpath('reawri'));
addpath(genpath('simona2mdf'));
addpath(genpath('simona2dflowfm'));
addpath(genpath('d3d2dflowfm'));
addpath(genpath('dflowfm_io'));

mcc -e -v nesthd

delete ('mccExcludedFiles.log'        ,'readme.txt' );

exit;
