%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: expectedEnd.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/expectedEnd.m $
%
%This function computes the expected date in which an FM simulation will be
%done

function datetime_finish=expectedEnd(path_mdu)

[folder_n,file_n,~]=fileparts(path_mdu);

%identify whether there is RTC or multiple cores
simulation_type=1; %1=several nodes; 2=rtc
isrtc=false(1,2);

folder_up=fullfile(folder_n,'../');
dir_up=dir(folder_up);
nf=numel(dir_up);
for kf=1:nf
   if dir_up(kf).isdir
       if strcmp(dir_up(kf).name,'dflowfm')
           isrtc(1)=true;
       elseif strcmp(dir_up(kf).name,'rtc')
           isrtc(2)=true;
       end
   end
end

if ~any(~isrtc)
    simulation_type=2;
end
    
switch simulation_type
    case 1
        path_outfile=fullfile(folder_n,'out.txt');
    case 2
        folders=regexp(folder_up,filesep,'split');
        folder_run_name=folders{1,end-3};
        for kf=1:nf
            if strfind(dir_up(kf).name,folder_run_name)
                path_outfile=fullfile(folder_up,dir_up(kf).name);
            end
        end
        if ~exist('path_outfile','var')
            error('I could not find the output file...')
        end
    otherwise
        error('ups...')
end
        

pdone=EHY_simulationStatus(path_mdu);
% datetime_start=find_start_simulation_time(path_outfile,simulation_type);
% 
% datetime_now=datetime('now');
% time2finish=(datetime_now-datetime_start)/pdone*(100-pdone);
% datetime_finish=datetime_now+time2finish;
% str_finish=datestr(datetime_finish);
% fprintf('Simulation %s will finish on %s \n',file_n,str_finish)


end %expectedEnd

%% find_start_simulation_time

function datetime_start=find_start_simulation_time(path_outfile,simulation_type)

switch simulation_type
    case 1 % * File creation date: 02:32:16, 26-09-2019
        %attention! check the space after ':' in combination with the lack
        %of space between '%s%s' in date_start_str
        str2find='* File creation date: '; 
        time_format='(\d{2}:\d{2}:\d{2}, \d{1,4}([.\-/])\d{1,2}([.\-/])\d{1,4})';
        input_format='HH:mm:ss, dd-MM-yyyy';
    case 2 %Dimr [2020-03-03 19:19:30.321771]
        str2find='Dimr ['; 
        time_format='(\d{1,4}([.\-/])\d{1,2}([.\-/])\d{1,4} \d{2}:\d{2}:\d{2})';
        input_format='yyyy-MM-dd HH:mm:ss';
end

fID=fopen(path_outfile,'r');
found=false;
while ~found
    out_file=fgetl(fID);
    date_start_str=regexp(out_file,sprintf('%s%s',str2find,time_format),'once');
    if ~isempty(date_start_str)
        date_start_str=regexp(out_file,sprintf('%s%s',str2find,time_format),'tokens');
        datetime_start=datetime(date_start_str{1,1}{1,1},'InputFormat',input_format);
        found=true;
    end
end 
    fclose(fID);

end %=find_start_simulation_time