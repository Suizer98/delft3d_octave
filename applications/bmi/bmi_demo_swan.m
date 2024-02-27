%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

if ispc
    dll = 'd:\checkouts\swanesmf\esmf40.91\vs2010\Debug\swan_dll.dll';
    config_file = 'd:\checkouts\swanesmf\esmf40.91\tests\DMrecSWAN02\swan.inp';
elseif ismac
    % Make sure the up to date gfortran is found before the ancient one
    % that comes with matlab
    % This sometimes on
    dll = '/Users/fedorbaart/Documents/checkouts/swandeltares/libswan.so';
    config_file = '/Users/fedorbaart/Documents/checkouts/swandeltares/tests/DMrecSWAN/swan.inp';
end

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);

%% Get variables



jdp2 = bmi_var_get(bmidll, 'DP2');
jdp2(1:floor(end/3)) = jdp2(1:floor(end/3))+2;
bmi_var_set(bmidll, 'DP2', jdp2);
%% Compute
bmi_update(bmidll,10800);

%% Inspect

voq = bmi_var_get(bmidll, 'VOQ');
tic
ac2 = bmi_var_get(bmidll, 'AC2');
toc
%bmi_var_set(bmidll, 'AC2', ac2+0.1);

spcsig = bmi_var_get(bmidll, 'SPCSIG');
ddir = bmi_var_get(bmidll, 'DDIR');
pwtail = bmi_var_get(bmidll, 'PWTAIL');

XCGRID = bmi_var_get(bmidll, 'XCGRID');
YCGRID = bmi_var_get(bmidll, 'YCGRID');

%% Process data

tot = squeeze(sum(sum(ac2,1),2));
tot = tot(1:end-1);

tot2D = reshape(tot,fliplr(size(XCGRID)));


%% Print
surf(double(XCGRID), double(YCGRID), double(tot2D)')


%% cleanup
bmi_finalize(bmidll);
