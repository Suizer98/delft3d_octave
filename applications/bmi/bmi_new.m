function [bmidll] = bmi_new(dll)
% header = 'bmi.h';
header = @bmi_header;
% Remark Freek Scheel:
% Please note that this header type is required when compiling the bmi to a matlab exe
% When functions are changing, a new bmi_header.m can be generated automatically by calling:
% loadlibrary('unstruc','bmi.h','mfilename','bmi_header.m');
[dlldir, bmidll, dllext] = fileparts(dll);
addpath(dlldir);
[notfound,warnings] = loadlibrary([bmidll dllext],header);
% TODO: Store header for people who don't have a compiler, 'mfilename', 'bmiheader')
% TODO: check for warnings if no warnings, bmi.h is printed.. pfff
disp(warnings);
% TODO: optional, print functions that are available
% libfunctions(dllname, '-full');
end
