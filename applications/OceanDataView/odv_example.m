%odv_example  example for ODV files of profile and trajectory
%
%See also: OceanDataView

file = 'usergd30d98-data_centre630-270409_result\result_CTDCAST_98___46-270409.txt';
D    = odvread(file)
odvdisp(D) % extracts P01 description
odvplot_cast(D)
%%
figure
file = 'userkc30e50-data_centre632-090210_result\world_N50E0N40E10_20060101_20070101.txt';
S    = odvread(file)
odvdisp(S) % extracts P01 description
odvplot_overview(S)