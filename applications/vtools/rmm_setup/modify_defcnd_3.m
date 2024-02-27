%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_defcnd_3.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_defcnd_3.m $
%

function modify_defcnd_3(path_file,defcnd_1,bcn,loclabels)

%% OPEN FILES

[folder_in,fname_in,ext_in]=fileparts(path_file);
path_aux=fullfile(folder_in,'DEFCND_aux.3');
fID_in=fopen(path_file,'r');
fID_out=fopen(path_aux,'w');

%get id from bc file
% search for id in id columns of FLBO and get the ci
% search for ci in loclabels and get data label
%search for data label and get index of bc

%% LOOP ORIGINAL FILE
while ~feof(fID_in)
    fline=fgets(fID_in);
    tok=regexp(fline,'FLBR id ''(\w+)''','tokens'); %search for FLBO id
    if isempty(tok) %if not found, write the line
       fprintf(fID_out,'%s',fline); 
    else %if dealing with a FLBR
        idx_defcnd=find(strcmp(tok{1,1}{1,1},{defcnd_1.FLBR.id}));
        idx_loc_aux=find(strcmp(defcnd_1.FLBR(idx_defcnd).id,{loclabels.sre})); %FLBO is applied based on ci, but FLBR is applied based on id. This line is redundant but we leave it for consistency.

        if isempty(idx_loc_aux) %if dealing with controller it is not in out list             
            fprintf(fID_out,'%s',fline);
        else %if dealing with controller it is in our list
            
            %get index in loclabels (which index from the ones with the right
            %localbels.sre has the right variable)
            nidx=numel(idx_loc_aux);
            idx_loc=NaN;
            for kidx=1:nidx
                switch loclabels(idx_loc_aux(kidx)).var
                    case {'Q','-'}
                        if ~isnan(idx_loc) %this only be set once
                            error('You should get here only once')
                        end
                        idx_loc=idx_loc_aux(kidx);
                    otherwise
                end
            end
            
            if isnan(idx_loc) %if dealing with controller we do not have to modify             
                fprintf(fID_out,'%s',fline);
            else %if dealing with controller we have to modify

                %change boundary condition type
                tokbc=regexp(fline,'lt (\d)','tokens'); 
                fline=strrep(fline,sprintf('lt %s',tokbc{1,1}{1,1}),'lt 1');

                fprintf(fID_out,'%s',fline);
            
                %get index in bcn (which index from the ones with the right
                %bcn.tsc.Locatiecode has the right variable
                idx_bcn_aux=find(strcmp(loclabels(idx_loc).data,{bcn.tsc.Locatiecode}));
                nidxbcn=numel(idx_bcn_aux);
                idx_bcn=NaN;
                for kidxbcn=1:nidxbcn
                    paramcode=bcn.tsc(idx_bcn_aux(kidxbcn)).Parametercode;
                    if strcmp(paramcode,'Q')
                        if ~isnan(idx_bcn) %this only be set once
                            error('You should get here only once')
                        end
                        idx_bcn=idx_bcn_aux(kidxbcn); 
                    end
                end

                %write time series
                aux_time=bcn.tsc(idx_bcn).daty;
                aux_val=bcn.tsc(idx_bcn).val;

                %units
                paramcode=bcn.tsc(idx_bcn).Parametercode;
                switch paramcode
                    case 'Q'
                        unit_p='m^3/s';
                    otherwise
                        error('You should not get here')
                end %paramcode

                %function
                switch loclabels(idx_loc).function_sre
                    case 1 
                        aux_time=aux_time+minutes(loclabels(idx_loc).function_param_sre);
                end

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
            end %isnan(idx_loc)
        end %~isempty(idx_rtc)
    end %isempty(tok)
end %while ~feof

%close files
fclose(fID_in);
fclose(fID_out);

%% REPLACE OLD WITH AUX

copy_and_delete(path_aux,path_file)

end %function