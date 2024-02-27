%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_defmet_1.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_defmet_1.m $
%

function modify_defmet_1(path_file,bcn,loclabels)

%% OPEN FILES

[folder_in,fname_in,ext_in]=fileparts(path_file);
path_aux=fullfile(folder_in,'DEFMET_aux.1');
fID_in=fopen(path_file,'r');
fID_out=fopen(path_aux,'w');

%% LOOP ORIGINAL FILE
while ~feof(fID_in)
    fline=fgets(fID_in);
    tok=regexp(fline,'''Wind (\w+)''','tokens'); %if it has this tag, it is a line before a table
    fprintf(fID_out,'%s',fline); %write the line
    if ~isempty(tok) %if dealing with 'wind something'
        
        idx_bcn=NaN;
        switch tok{1,1}{1,1}
            case 'Direction'
                idx_bcn=find(strcmp('WINDRTG',{bcn.tsc.Parametercode}));
            case 'Velocity'
                idx_bcn=find(strcmp('WINDSHD',{bcn.tsc.Parametercode}));
        end
        
        if numel(idx_bcn)>1
           error('The new boundary conditions have more than one input for wind velocity and/or direction')
        end
            
        if isnan(idx_bcn)
            error('I could not find the index of the new boundary conditions file')
        end

        %write time series
        aux_time=bcn.tsc(idx_bcn).daty;
        aux_val=bcn.tsc(idx_bcn).val;

        %units
        paramcode=bcn.tsc(idx_bcn).Parametercode;
        switch paramcode
            case 'WINDRTG'
                unit_p='degrees';
            case 'WINDSHD'
                unit_p='m/s';
            otherwise
                error('You should not get here')
        end %paramcode
% 
%                 %function time
%                 switch loclabels(idx_loc).function_sre
%                     case 1 
%                         aux_time=aux_time+minutes(loclabels(idx_loc).function_param_sre);
%                 end
% 
%                 %function val
%                 switch bcn.tsc(idx_bcn).Parametereenheid
%                     case 'mg/l'
%                         aux_val=aux_val/1000;
%                     otherwise
%                         error('Unknown unit')
%                 end

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

        %plot
        han.fig=figure;
        hold on
        plot(aux_time,aux_val)
        xlabel('time')
        ylabel(sprintf('%s [%s]',paramcode,unit_p))
        title(sprintf('%s - %s',strrep(tok{1,1}{1,1},'_','\_'),bcn.tsc(idx_bcn).Locatiecode))
        print(han.fig,sprintf('%s_%d.png',tok{1,1}{1,1},idx_bcn),'-dpng','-r300')
        close(han.fig)

        %display
        fprintf('Finished writing time serie %s \n',bcn.tsc(idx_bcn).Locatiecode)
    end %isempty(tok)
end %while ~feof

%close files
fclose(fID_in);
fclose(fID_out);

%% REPLACE OLD WITH AUX

copy_and_delete(path_aux,path_file)

end %function