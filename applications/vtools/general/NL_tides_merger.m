%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: NL_tides_merger.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/NL_tides_merger.m $
%
%Joins xml-files of tides in NL
%
%CONSIDER:
%   -tag identifying files is the position 5:6 in filename, which must be numeric. 

function NL_tides_merger(varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fdir_input',fullfile(pwd,'input'));
addOptional(parin,'fdir_out',fullfile(pwd,'output'));
addOptional(parin,'fpath_log',fullfile(pwd,'log.txt'));
% addOptional(parin,'header_lines',13);

parse(parin,varargin{:});

fdir_input=parin.Results.fdir_input;
fdir_out=parin.Results.fdir_out;
fpath_log=parin.Results.fpath_log;
% header_lines=parin.Results.header_lines;

%% INITIALIZE

%log file
[fid_log,err]=fopen(fpath_log,'w');
if ~isempty(err)
    fid_log=NaN;
    messageOut(fid_log,sprintf('I cannot open a log file: %s',fpath_log));
end
fprintf(fid_log,'NL_tides_merger $Revision: 17700 $ \r\n');

%output folder
mkdir_check(fdir_out,fid_log);

%input folder
if exist(fdir_input,'dir')~=7
    messageOut(fid_log,sprintf('directory with input does not exist: %s',fdir_input));
    fclose(fid_log);
    return
end

%% CALC

dire=dir(fdir_input);
nf=numel(dire);
tag_m1=NaN;
for kf=1:nf
    
    %cycle directories
    if dire(kf).isdir
        continue
    end
    
    %get tag
    fname=dire(kf).name; 
    tag=str2double(fname(5:6)); 
    
    %check tag
    if isnan(tag_m1) %first file
        kff=1;
        [fid_w,fpath_new]=open_new_file(tag,fdir_out,fid_log);
    elseif tag~=tag_m1 %new file
        kff=1;
        %close file
        fprintf(fid_w,'  </Rates> \r\n');
        fprintf(fid_w,'</Stream> \r\n');
        fclose(fid_w);
        %open file
        [fid_w,fpath_new]=open_new_file(tag,fdir_out,fid_log);
    elseif tag==tag_m1 %concatenate in opened file
        kff=kff+1;
        messageOut(fid_log,sprintf('adding file %s to %s',fname,fpath_new));
    end
    
    tag_m1=tag;%update tag
    
    %file to read
    fpath_r=fullfile(dire(kf).folder,dire(kf).name);
    fid_r=fopen(fpath_r,'r');
    
    %write file
    found_time_zone=false;
    while ~feof(fid_r)
        
        lin=fgetl(fid_r);
        
        %search time zone
        if ~found_time_zone
    %         tok=regexp('    <TimeZone>MET+1</TimeZone> ','<TimeZone>(.*)</TimeZone>','tokens');
            tok=regexp(lin,'<TimeZone>(.*)</TimeZone>','tokens');
            found_time_zone=~isempty(tok);
            if found_time_zone
                if kff==1
                    tzone_ref=parse_tzone(tok{1,1}{1,1},fid_log);
                    tzone_loc=tzone_ref;
                    if isnan(tzone_ref)
                        messageOut(fid_log,'ERROR! see above');
                        fclose(fid_log);
                        return
                    end
                else 
                    tzone_loc=parse_tzone(tok{1,1}{1,1},fid_log);
                    if isnan(tzone_loc)
                        messageOut(fid_log,'ERROR! see above');
                        fclose(fid_log);
                        return
                    end
                    
                    %cycle header
                    found_first_line=false;
                    while ~found_first_line
                        lin=fgetl(fid_r);
                        tok=regexp(lin,'<(\w*)>','tokens');
                        if ~isempty(tok)
                            found_first_line=strcmp(tok{1,1}{1,1},'Rate');
                        end
                    end %while
                    
                end
            else
                if kff~=1
                    continue %do not write header
                end
            end
        
        end %found_time_zone

        %don't write last line
        if strcmp(lin,'  </Rates>')
            break
        end
        
%         tok=regexp('      <Time>01/01/2019 00:00</Time> ','<Time>(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})</Time>','tokens')
        tok=regexp(lin,'<Time>(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})</Time>','tokens');
        if ~isempty(tok) %it is time
            tim=datetime(str2double(tok{1,1}{1,3}),str2double(tok{1,1}{1,2}),str2double(tok{1,1}{1,1}),str2double(tok{1,1}{1,4}),str2double(tok{1,1}{1,5}),0,'TimeZone',tzone_loc);
            tim.TimeZone=tzone_ref;
            fprintf(fid_w,sprintf('      <Time>%s</Time>\r\n',datestr(tim,'dd/mm/yyyy HH:MM'))); %01/01/2019 00:00
        else
            fprintf(fid_w,sprintf('%s\r\n',lin));
        end
        
    end %while
    fclose(fid_r);   
        
end %kf

%close files
fclose(fid_w);
fclose(fid_log);

end %function

%%
%% FUNCTIONS
%%

function [fid_w,fpath_new]=open_new_file(tag,fdir_out,fpath_log)

fpath_new=fullfile(fdir_out,sprintf('NLTR%02d.xml',tag));
[fid_w,err]=fopen(fpath_new,'w');
if ~isempty(err)
    messageOut(fpath_log,sprintf('could not open file %s because %s',fpath_new,err));
else
    messageOut(fpath_log,sprintf('file opened: %s',fpath_new));
end

end %function

%%

function str_parse=parse_tzone(str,fid_log)

str_parse=NaN;
switch str
    case 'MET'
        str_parse='+01:00';
    case 'MET+1'
        str_parse='+02:00';
    otherwise 
        messageOut(fid_log,sprintf('this time zone is not recognized: %s',str));
end

end %function