%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17794 $
%$Date: 2022-02-25 21:03:37 +0800 (Fri, 25 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_write_tim_2.m 17794 2022-02-25 13:03:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_tim_2.m $
%
%write a tim file based on information in structure

function D3D_write_tim_2(data_loc,path_dir_out,fname_tim_v,ref_date,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ylims',NaN)
addOptional(parin,'print',1)
addOptional(parin,'unit','minutes')
addOptional(parin,'local',1)

parse(parin,varargin{:});

fig_print=parin.Results.print;
tim_u=parin.Results.unit;
if strcmp(tim_u,'minutes')==0
    error('I think that the input should be minutes')
end
write_local=parin.Results.local;
ylims=parin.Results.ylims;

nylim=size(ylims,1);

%% CALC

nloc=numel(data_loc);
for kloc=1:nloc
    fname_tim=sprintf('%s.tim',fname_tim_v{kloc});
    path_tim=fullfile(path_dir_out,fname_tim);
    if write_local==1
        path_tim_loc=fullfile(pwd,fname_tim);
    else
        path_tim_loc=path_tim;
    end
    fid=fopen(path_tim_loc,'w');
    nq=numel(data_loc(kloc).quantity); %considering time, which must be in first column
    if size(data_loc(kloc).val,2)~=nq-1
        error('size of data does not match with size of quantity')
    end
    fprintf(fid,'* Column 1: Time (%s) w.r.t. refdate=%s \n',tim_u,datestr(ref_date,'yyyy-mm-dd HH:MM:ss'));
    for kq=2:nq
        fprintf(fid,'* Column %d: %s \n',kq,data_loc(kloc).quantity{kq});
    end
    nl=numel(data_loc(kloc).tim);
    tim_loc=data_loc(kloc).tim-ref_date;
    switch tim_u
        case 'seconds'
            tim_ref=seconds(tim_loc);
        case 'minutes'
            tim_ref=minutes(tim_loc);
        otherwise
            error('to do')
    end
    str_write=repmat('%f ',1,nq);
    str_write_2=strcat(str_write,'\n');
    for kl=1:nl
        fprintf(fid,str_write_2,tim_ref(kl),data_loc(kloc).val(kl,:));
    end %kl
    fclose(fid);
    
    if write_local==1
        copyfile_check(path_tim_loc,path_tim);
        delete(path_tim_loc);
    end
    
    %disp
    messageOut(NaN,sprintf('file written: %s',path_tim))
    
    %plot
    if fig_print
        for kq=2:nq
            for kylim=1:nylim
                if nylim==1
                    fname_fig=sprintf('%s_%s.png',fname_tim_v{kloc},data_loc(kloc).quantity{kq});
                else
                    fname_fig=sprintf('%s_%s_%02d.png',fname_tim_v{kloc},data_loc(kloc).quantity{kq},kylim);
                end
                path_fig=fullfile(path_dir_out,fname_fig);
                if write_local==1
                    path_fig_loc=fullfile(pwd,fname_fig);
                else
                    path_fig_loc=path_fig;
                end
                figure('visible',0)
                plot(data_loc(kloc).tim,data_loc(kloc).val(:,kq-1))
                ylabel(strrep(data_loc(kloc).quantity(kq),'_','\_'))
                title(strrep(fname_tim_v{kloc},'_','\_'))
                if ~isnan(ylims(kylim,1))
                    ylim(ylims(kylim,:));
                end
                print(gcf,path_fig_loc,'-dpng','-r300')
                close(gcf)
                if write_local==1
                    copyfile_check(path_fig_loc,path_fig);
                    delete(path_fig_loc);
                end
            end
        end
    end
    

end %kloc