%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17110 $
%$Date: 2021-03-10 19:59:30 +0800 (Wed, 10 Mar 2021) $
%$Author: chavarri $
%$Id: D3D_print_fig.m 17110 2021-03-10 11:59:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_print_fig.m $
%
function D3D_print_fig(simdef,prnt,han)

%% RENAME

flg=simdef.flg;

if isfield(prnt,'res')==0
    prnt.res='-r300';
end

path_save=fullfile(pwd,prnt.filename);
if isfield(simdef,'D3D')
    path_save=fullfile(simdef.D3D.dire_sim,'figures',prnt.filename);
end
if isfield(flg,'save_name')
    if ~isnan(flg.save_name)
        path_save=flg.save_name;
    end
end


%% CALC

if flg.print==0
    pause
    close(han.fig)
elseif flg.print==0.5
    pause(flg.pauset);
    close(han.fig)
elseif flg.print==1
    print(han.fig,strcat(path_save,'.eps'),'-depsc2','-loose','-cmyk')
    messageOut(NaN,sprintf('figure printed: %s',strcat(path_save,'.eps')));
    close(han.fig)
elseif flg.print==2
    print(han.fig,strcat(path_save,'.png'),'-dpng',prnt.res)  
    messageOut(NaN,sprintf('figure printed: %s',strcat(path_save,'.png')));
    close(han.fig)
elseif flg.print==3
    print(han.fig,strcat(path_save,'.jpg'),'-djpeg','-r150') 
    messageOut(NaN,sprintf('figure printed: %s',strcat(path_save,'.jpg')));
    close(han.fig)
elseif isnan(flg.print)
    
else
    error('specify correct flag for saving')
end
