%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: create_m_file_from_type1.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/create_m_file_from_type1.m $
%

function create_m_file_from_type1(flg,ffulname,fsave)

fprintf('Start processing file: %s\n',ffulname);
fid=fopen(ffulname,'r');

%lines 1 and 2 must be empty
for kl=1:2 
    raw=fgetl(fid);
    raw=strrep(raw,' ','');  %allow for spaces
    if ~isempty(raw)
        fprintf('file header is wrong: %s \n',ffulname);
        return        
    end
end

%line 3 has no info
raw=fgetl(fid);

%possibility of empty file
if feof(fid)
    fprintf('file is empty, no data in it: %s \n',ffulname);
    return        
end

kls=1;
% data_blocks=struct('time',[],'cords',[]);
while ~feof(fid)
    data_block(kls)=read_block(fid); %preallocating would be cool...
    kls=kls+1;
    if ~isstruct(data_block)
        fprintf('file skiped: %s \n',ffulname);
        return
    end
    if flg.debug
        fprintf('Number of blocks = %d \n',numel(data_block));
    end
end %while

fclose(fid);
% [ffolder,fname,~]=fileparts(ffulname);
% fsave=fullfile(ffolder,sprintf('%s.mat',fname));
save(fsave,'data_block');
fprintf('File created: %s\n',fsave);
end %function

%%

function data_block=read_block(fid)

%% line 2
%1 ENSEMBLE TIME -Year (at start of ensemble)
%2 - Month
%3 - Day
%4 - Hour
%5 - Minute
%6 - Second
%7 - Hundredths of seconds
%8 ENSEMBLE NUMBER (or SEGMENT NUMBER for processed or averaged raw data)
%9 NUMBER OF ENSEMBLES IN SEGMENT (if averaging ON or processing data)
%10 PITCH – Average for this ensemble (degrees)
%11 ROLL – Average for this ensemble (degrees)
%12 CORRECTED HEADING - Average ADCP heading (corrected for one cycle error) + heading offset + magnetic variation
%13 ADCP TEMPERATURE - Average for this ensemble (°C)

% 13 2 1 9 16 32 64  1829      1    1.570   -2.590  162.120    5.950 

raw=get_nonemty_line_data(fid);
tok=regexp(raw,'(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)','tokens');
aux_y=strcat('20',tok{1,1}{1,1});
aux_s=strcat(tok{1,1}{1,6},'.',tok{1,1}{1,7});
data_block.time=datetime(str2double(aux_y),str2double(tok{1,1}{1,2}),str2double(tok{1,1}{1,3}),str2double(tok{1,1}{1,4}),str2double(tok{1,1}{1,5}),str2double(aux_s));

%% line 2
%2 1 BOTTOM-TRACK VELOCITY - East(+)/West(-); average for this ensemble (cm/s or ft/s)
%2 Reference = BTM - North(+)/South(-)
%3 - Vertical (up[+]/down[-])
%4 - Error
%2 1 BOTTOM-TRACK VELOCITY – GPS (GGA or VTG) Velocity (calculated from GGA String)
%Reference = GGA East(+)/West (-1)
%2 Reference = VTG - GPS (GGA or VTG) North(+)/South(-) Velocity
%3 - BT (up[+]/down[-]) Velocity
%4 - BT Error
%5 GPS/DEPTH SOUNDER - corrected bottom depth from depth sounder (m or ft)
%as set by user (negative value if DBT value is invalid)
%6 - GGA altitude (m or ft)
%7
%- GGA ?altitude (max – min, in m or ft)
%8 - GGA HDOP x 10 + # satellites/100 (negative value if invalid for ensemble)
%9 DEPTH READING – Beam 1 average for this ensemble (m or ft, as set by user)
%10 (Use River Depth - Beam 2
%11 = Bottom Track) - Beam 3
%12 - Beam 4
%9 DEPTH READING – Depth Sounder depth
%10 (River Depth - Depth Sounder depth
%11 = Depth Sounder) - Depth Sounder depth
%12 - Depth Sounder depth
%9 DEPTH READING – Vertical Beam depth
%10 (River Depth - Vertical Beam depth
%11 = Vertical Beam) - Vertical Beam depth
%12 - Vertical Beam depth

% -46.99   -26.45    -0.60    -0.00     0.00     4.09     0.07     7.16     4.87     6.06     6.06     4.77 

raw=fgetl(fid);
tok=regexp(raw,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
if numel(tok)~=12
    error('something is not fine')
end
flg_loc.unit='';
data_block.h1=clean_velocity_type1(str2double(tok{1,9}),flg_loc);
data_block.h2=clean_velocity_type1(str2double(tok{1,10}),flg_loc);
data_block.h3=clean_velocity_type1(str2double(tok{1,11}),flg_loc);
data_block.h4=clean_velocity_type1(str2double(tok{1,12}),flg_loc);

%% line 3
%3 1 TOTAL ELAPSED DISTANCE - Through this ensemble (from bottom-track or GPS data; in m or ft)
%2 TOTAL ELAPSED TIME – Through this ensemble (in seconds)
%3 TOTAL DISTANCED TRAVELED NORTH (m or ft, as set by user)
%4 TOTAL DISTANCED TRAVELED EAST (m or ft, as set by user)
%5 TOTAL DISTANCE MADE GOOD – Through this ensemble (from bottom-track or GPS data in m or ft)

% 0.52         0.96        -0.27        -0.44         0.52

raw=fgetl(fid);
tok=regexp(raw,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
data_block.distance=str2double(tok{1,1});
data_block.timetravel=str2double(tok{1,2});
data_block.distance_north=str2double(tok{1,3});
data_block.distance_east=str2double(tok{1,4});

if numel(tok)~=5
    fprintf('file format not correct \n')
    data_block=NaN;
    return
end

%% line 4
% 1 NAVIGATION DATA –
% 2 - Latitude (degrees and decimal degrees)
% 3 - Longitude (degrees and decimal degrees)
% 4 - GGA or VTG East velocity (in m/s or ft/s)
% 5 - GGA or VTG North velocity (in m/s or ft/s)
% 6 - Distance traveled in m or ft reference to GGA or VTG

% 51.89029351     5.48826673   -40.46   -28.37          0.5

raw=fgetl(fid);

tok=regexp(raw,'(?:\s)?(-?\d+.\d+)','tokens');
data_block.cords=[str2double(tok{1,2}),str2double(tok{1,1})];

%% line 5
% 1 DISCHARGE VALUES – Middle part of profile (measured); m 3 /s or ft 3 /s
% 2 (referenced to - Top part of profile (estimated); m 3 /s or ft 3 /s
% 3 Ref = BTM - Bottom part of profile (estimated); m 3 /s or ft 3 /s
% 4 and Use Depth - Start-shore discharge estimate; m 3 /s or ft 3 /s
% 5 Sounder - Starting distance (boat to shore); m or ft
% 6 options) - End-shore discharge estimate; m 3 /s or ft 3 /s
% 7 - Ending distance (boat to shore); m or ft
% 8 - Starting depth of middle layer (or ending depth of top layer); m or ft
% 9 - Ending depth of middle layer (or starting depth of bottom layer); m or ft

% 0.4           0.2           0.1           0.0           5.0           0.0          12.0  0.00   0.00

raw=fgetl(fid);

%% line 6
% 1 NUMBER OF BINS TO FOLLOW
% 2 MEASUREMENT UNIT – cm or ft
% 3 VELOCITY REFERENCE – BT, GGA, VTG, or NONE for current velocity data rows 7-26 fields 2-7
% 4 INTENSITY UNITS - dB or counts
% 5 INTENSITY SCALE FACTOR – in dB/count
% 6 SOUND ABSORPTION FACTOR – in dB/m

% 20 cm BT dB 0.46  0.139

raw=fgetl(fid);

tok=regexp(raw,'(\d+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)','tokens');
nl=str2double(tok{1,1}{1,1});

%% data lines

% 1 DEPTH – Corresponds to depth of data for present bin (depth cell); includes ADCP depth and
% blanking value; in m or ft.
% 2 VELOCITY MAGNITUDE
% 3 VELOCITY DIRECTION
% 4 EAST VELOCITY COMPONENT – East(+)/West(-)
% 5 NORTH VELOCITY COMPONENT - North(+)/South(-)
% 6 VERTICAL VELOCITY COMPONENT - Up(+)/Down(-)
% 7 ERROR VELOCITY
% 8 BACKSCATTER – Beam 1
% 9 - Beam 2
% 10 - Beam 3
% 11 - Beam 4
% 12 PERCENT-GOOD
% 13 DISCHARGE

data_block.depth=NaN(nl,1);
data_block.vmag=NaN(nl,1);
data_block.vdir=NaN(nl,1);
data_block.veast=NaN(nl,1);
data_block.vnorth=NaN(nl,1);
data_block.vvert=NaN(nl,1);
data_block.verr=NaN(nl,1);
data_block.backscatter=NaN(nl,4);
data_block.percentgood=NaN(nl,1);
data_block.discharge=NaN(nl,1);

for kl=1:nl
    raw=fgetl(fid);
    
    tok=regexp(raw,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
    
    data_block.depth(kl,1)      =str2double(tok{1,1});
    data_block.vmag(kl,1)       =clean_velocity_type1(str2double(tok{1,2}));
    data_block.vdir(kl,1)       =clean_velocity_type1(str2double(tok{1,3}));
    data_block.veast(kl,1)      =clean_velocity_type1(str2double(tok{1,4}));
    data_block.vnorth(kl,1)     =clean_velocity_type1(str2double(tok{1,5}));
    data_block.vvert(kl,1)      =clean_velocity_type1(str2double(tok{1,6}));
    data_block.verr(kl,1)       =clean_velocity_type1(str2double(tok{1,7}));
    if numel(tok)>7
        data_block.backscatter(kl,:)=[str2double(tok{1,8}),str2double(tok{1,9}),str2double(tok{1,10}),str2double(tok{1,11})];
        data_block.percentgood(kl,1)=str2double(tok{1,12});
        data_block.discharge(kl,1)  =str2double(tok{1,13});
    end

end

end %read_block

function raw=get_nonemty_line_data(fid)
search_begin=1;

while search_begin
    raw=fgetl(fid);
    tok=regexp(raw,'(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)','tokens');
    if ~isempty(tok)
        search_begin=0;
    end
end
end






