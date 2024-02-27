%% This script converts a roughcombination file from WAQUA (SIMONA) to D-Flow FM
% It is not used in the automatic conversion and should be run manually
%
% Jurjen de Jong
% 12-5-2015
clear;clc;close all;


%% INPUT
inputfile='roughcombination.karak_allen';
outputfile=[inputfile '.ttd'];

% Siminp file for the name of the discharge-dependent stations
siminpfile='siminp.j95_5-cal';

roughnesscategory= [ % Start-range, end-range, formula-code
       1,   50,   1;   % Ruwheidsformulering voor gebouwen en watervrij terrein (geen input nodig)
      51,  100,   0;   % Not defined   
     101,  300,  51;   % White-Colebrook
     301,  500,  53;   % Manning  or 63 when also a 'b' parameter is defined
     501,  600,  52;   % Chezy 
     601,  900, 101;   % Nikuradse-values (main-channel) 
     901, 1200,   0;   % Not defined  
    1201, 1400, 152;   % Ruwheidsformulering voor door- en overstroomde vegetatie
    1401, 1500,   0;   % Not defined  
    1501, 1600, 251;   % Ruwheidsformulering voor door- en overstroomde bomen
    1601, 1700, 202;   % Ruwheidsformulering voor door- en overstroomde heggen 
    1701, 1800,   0;   % Not defined  
    1801, 1999,   2;   % Combinatie van ruwheidscodes 
    ];

warning('Eb-flood variation not yet implemented');    


%% First find station names for all discharge dependent stations
fid=fopen(siminpfile);
siminp=textscan(fid,'%s','delimiter','\n');
fclose(fid);

ii=cellfun(@(x) ~isempty(strfind(lower(x),'r_code')),siminp{1});
r_code_lines=siminp{1}(ii);

r_code_to_station=cell(numel(r_code_lines),4);
for i=1:numel(r_code_lines)
    % Example line: 
    % R_CODE 616 DISCHARGE C4007 #  dodewaard - tiel
    line=r_code_lines{i};
    line_split=strsplit(line,' ');
    r_code_to_station{i,1}=line_split{2}; % R_CODE ID
    r_code_to_station{i,2}=line_split{3}; % Parameter
    r_code_to_station{i,3}=line_split{4}; % Curve ID
    
    % Find Curve names to curve id's.
    jj=cellfun(@(x) (~isempty(strfind(x,r_code_to_station{i,3})) && ~isempty(strfind(lower(x),'name'))),siminp{1});
    % Example line:
    % C4007= line (P4007,P4008, NAME='Q-NijmegenTielWl')
    if any(jj)
        Qline=strsplit(siminp{1}{jj},'''');
        r_code_to_station{i,4}=strtrim(Qline{end-1}); % Curve name
    else
        warning(['Could not find the name corresponding with Curve ID ' r_code_to_station{i,3}]); % Any easy work-around: paste the curve info at the bottom of the siminp
        r_code_to_station{i,4}=r_code_to_station{i,3}; % Cant find station name, using curve id
    end
end
    

%% Read WAQUA ruwkarak
fid=fopen(inputfile);
WAQUAruwkarakfile=textscan(fid,'%s','delimiter','\n');
fclose(fid);


%% Convert each line of the ruwkarak file

fid=fopen(outputfile,'w');

new_line='# This file has been created by conversion from WAQUA using the matlab script by Jurjen de Jong \n';
fprintf(fid,new_line);

% Add default values
new_line=['1 1 \n2 1 \n3 1 \n'];
fprintf(fid,new_line);

for i=1:numel(WAQUAruwkarakfile{1})
    line=WAQUAruwkarakfile{1}{i};
    if isempty(line)
        % regel is leeg...
        new_line=line;
    elseif isequal(line(1),'#')
        % regel bevat enkel commentaar
        new_line=line;
    elseif isequal(lower(line(1:6)),'r_code')
        % regel bestaat uit r_code = xxx, {variabel = xxxx} en commentaar
        line_split=strsplit(line,{' ','='});
        r_code=line_split{2};
        r_code_num=str2double(r_code);
        
        new_line=[r_code];
        
        % check if r_code uses 'PARAM' for certain r_code for the first
        % time, and add a line if this is the case
        if isequal(lower(line_split{3}),'param') && ~isequal(r_code_old,r_code) 
            ii=cellfun(@(x) strcmp(x,r_code),r_code_to_station(:,1));
            type=r_code_to_station{ii,2};
            station_name=r_code_to_station{ii,4};
            new_line=[new_line ' ' type ' ' station_name '\n' r_code];            
        end       
        
        % check if line uses 'PARAM' and include the discharge relation
        if isequal(lower(line_split{3}),'param')
            new_line=[new_line ' ' line_split{4}];
            coefstart=6;
        else
            coefstart=4;
        end
        
        % find formula for this r_code
        ii=min(r_code_num>=roughnesscategory(:,1),r_code_num<=roughnesscategory(:,2));
        if ~any(ii)
            warning(['code ' r_code ' could not be found. Using placeholder 999']);
            formulaid=999;
        else
            formulaid=roughnesscategory(ii,3);
        end

        new_line=[new_line ' ' num2str(formulaid)];
        
        line_comment=strfind(line,'#');
        line_split_comment=find(strcmp(line_split,'#'));
        
        % Process coefficients
        for j=coefstart:2:line_split_comment-1
            coefficient=line_split{j};
            new_line=[new_line ' ' coefficient];
        end
        new_line=[new_line ' ' line(line_comment:end)]; % keeping the unchanged comment-string
        r_code_old=r_code; % used to check discharge lines
    else
        new_line='skipped';
        warning('skipped line');
    end
    new_line=[new_line ' \n'];
    new_line=strrep(new_line,'%','%%');
    
    fprintf(fid,new_line);
end

fclose(fid);