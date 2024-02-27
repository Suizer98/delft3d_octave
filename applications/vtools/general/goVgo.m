%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17505 $
%$Date: 2021-09-30 13:10:00 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: goVgo.m 17505 2021-09-30 05:10:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/goVgo.m $
%
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function goVgo(varargin)

%% PARSE

switch numel(varargin)
    case 0
        play_music=1;
        check_rain_var=1;
    case 1
        play_music=varargin{1};
    case 2
        play_music=varargin{1};
        check_rain_var=varargin{1};
end
    
% parin=inputParser;
% 
% addOptional(parin,'music',true);
% parse(parin,varargin{:});
% play_music=parin.Results.music;

%% INPUT

path_rain='p:\i1000561-riverlab-2021\04_weather\rain.mat';
web_data='https://waterberichtgeving.rws.nl/wbviewer/maak_grafiek.php?loc=H-RN-0001&set=ecmwf_ens&nummer=2&format=wbcharts';
sisu_path='sisu.mat';

%% CALC

%discharge
web(web_data);

%music
if play_music
load(sisu_path,'sisu');
sound(sisu.y,sisu.Fs);
end

%rainvar
if check_rain_var
   load(path_rain,'rain');
   fprintf('Last rain data added was %3.1f h ago for a model on %s \n',hours(datetime('now')-rain(end).tim_anl),datestr(rain(end).tim_model));
end

%% disp

fprintf('|------------------------------------------------------------|\n');
fprintf('|------------------------------------------------------------|\n');
fprintf('|-----|                                                |-----|\n');
fprintf('|-----|           Gnothi sauton  (know thyself)        |-----|\n');
fprintf('|-----|           Meden agan (nothing in excess)       |-----|\n');
fprintf('|-----|       Engya para d''ate (surety brings ruin)    |-----|\n');
fprintf('|-----|                                                |-----|\n');
fprintf('|------------------------------------------------------------|\n');
fprintf('|------------------------------------------------------------|\n');

end %function