%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_defstr_4.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_defstr_4.m $
%

function modify_defstr_4(path_file,start_time,stop_time,bcn,loclabels_rtc)

%% OPEN FILES

[folder_in,fname_in,ext_in]=fileparts(path_file);
path_aux=fullfile(folder_in,'DEFSTR_aux.4');
fID_in=fopen(path_file,'r');
fID_out=fopen(path_aux,'w');

%% LOOP ORIGINAL FILE
while ~feof(fID_in)
    fline=fgets(fID_in);
    tok=regexp(fline,'CNTL id ''(\w+)''','tokens'); %search for controller ID
    if isempty(tok) %if not found, write the line
       fprintf(fID_out,'%s',fline); 
    else %if dealing with a controller
        idx_rtc=find(strcmp(tok{1,1}{1,1},{loclabels_rtc.sre}));
        fprintf(fID_out,'%s',fline);
        if ~isempty(idx_rtc) %if dealing with controller we have to modify
            
            %write time series
            idx_bcn=find(strcmp(loclabels_rtc(idx_rtc).data,{bcn.tsc.Locatiecode}));
            aux_time=bcn.tsc(idx_bcn).daty;
            aux_val=bcn.tsc(idx_bcn).val./100;
            nl=numel(aux_time);
            for kl=1:nl
                fprintf(fID_out,'''%04d/%02d/%02d;%02d:%02d:%02d'' %f < \r\n',year(aux_time(kl)),month(aux_time(kl)),day(aux_time(kl)),hour(aux_time(kl)),minute(aux_time(kl)),second(aux_time(kl)),aux_val(kl));
            end %kl
                        
            %search for end of table
            endoftable=false;
            while ~endoftable
               fline=fgets(fID_in);
               if strcmp(fline(1:4),'tble')
                   fprintf(fID_out,'%s',fline);
                   endoftable=true;
               end %'tble'
               if fline==-1
                   error('reached end of file while searching for the end of the table')
               end %fline
            end %~endoftable
            
            fprintf('Finished writing time serie %s \n',bcn.tsc(idx_bcn).Locatiecode)
            
        end %~isempty(idx_rtc)
    end %isempty(tok)
end %while ~feof

%close files
fclose(fID_in);
fclose(fID_out);

%% REPLACE OLD WITH AUX

copy_and_delete(path_aux,path_file)

end %function