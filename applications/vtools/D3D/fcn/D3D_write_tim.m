%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17449 $
%$Date: 2021-08-06 18:38:36 +0800 (Fri, 06 Aug 2021) $
%$Author: chavarri $
%$Id: D3D_write_tim.m 17449 2021-08-06 10:38:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_tim.m $
%
%write a tim file based on information in structure

function D3D_write_tim(data_loc,path_dir_out,fname_tim_v,val_str_v,ref_date)

warning('deprecated, use D3D_io_input')

%make varargin
fig_print=1;
tim_u='minutes';

nloc=numel(data_loc);
for kloc=1:nloc
    path_tim=fullfile(path_dir_out,sprintf('%s.tim',fname_tim_v{kloc,1}));
    fid=fopen(path_tim,'w');
    fprintf(fid,'* Column 1: Time (%s) w.r.t. refdate=%s \n',tim_u,datestr(ref_date,'yyyy-mm-dd HH:MM:ss'));
    fprintf(fid,'* Column 2: %s \n',val_str_v{kloc,1});
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
    for kl=1:nl
        fprintf(fid,'%f %f \n',tim_ref(kl),data_loc(kloc).val(kl));
    end %kl
    fclose(fid);
    
    %plot
    if fig_print
        path_fig=fullfile(path_dir_out,sprintf('%s.png',fname_tim_v{kloc,1}));
        figure('visible',0)
        plot(data_loc(kloc).tim,data_loc(kloc).val)
        ylabel(val_str_v{kloc,1})
        title(strrep(fname_tim_v{kloc,1},'_','\_'))
        print(gcf,path_fig,'-dpng','-r300')
    end
    
    %disp
    messageOut(NaN,sprintf('file written: %s',path_tim))
end %kloc