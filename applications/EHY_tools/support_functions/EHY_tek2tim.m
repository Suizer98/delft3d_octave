function EHY_tek2tim(fileInp,varargin)
% EHY_tek2tim converts TEKAL Time series files to tim files that can be used in DFlow-FM
%
% the takal file is assumed to have one block of data with 3 columns, Date, Time and Value
%
% filename is the name, without extension (tek assumed), of the TEKAL file
%
% The following <keyword,value> pairs have been implemented:
% 1) 'sign'   , value +1 (default) or -1, multiplification factor allowing for change of sign,
%                                         can be necessary for discharge series with a different sign
% 2) 'itdate' , matlab date of the reference date of the DFlow-FM simulation, default is first time on
%                                                                             TEKAL data file
%
%
% Examples:
% EHY_tek2tim('deb-dortse_kil',);
% EHY_tek2tim('deb-dortse_kil','sign',-1.);
% EHY_tek2tim('deb-dortse_kil','sign',-1.,'itdate',datenum('20070101 000000','yyyymmdd  HHMMSS'));

%% Define
OPT.sign   = +1;
OPT.itdate = '';
OPT        = setproperty(OPT,varargin);

%% Read tekal file
Info   = tekal('open',[strtrim(fileInp) '.tek'],'loaddata');
date   = num2str(Info.Field.Data(:,1),'%8.8i');
time   = num2str(Info.Field.Data(:,2),'%6.6i');
dattim = datenum([date(:,1:8) time(:,1:6)],'yyyymmddHHMMSS');
values = OPT.sign*Info.Field.Data(:,3);

%% Times in minutes since itdate
if isempty(OPT.itdate) OPT.itdate = dattim(1); end
time_tim = round((dattim-OPT.itdate)*1440.);

%% Write to tim files
SERIES.Comments{1} = '* COLUMNN=2';
SERIES.Comments{2} = '* COLUMN1=Time (min) since the reference date';
SERIES.Comments{3} = '* COLUMN2=Value';
SERIES.Values(:,1) = time_tim;
SERIES.Values(:,2) = values;
SERIES.Values      = num2cell(SERIES.Values);
dflowfm_io_series( 'write',[strtrim(fileInp) '.tim'],SERIES);
