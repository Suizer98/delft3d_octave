%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17536 $
%$Date: 2021-10-30 03:38:05 +0800 (Sat, 30 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_interpolate_fxw.m 17536 2021-10-29 19:38:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_interpolate_fxw.m $
%

function [F_crest,F_weir_height,cord,F_crest_width,F_slope_right,F_slope_left]=D3D_interpolate_fxw(fpath_fxw)

fxw=D3D_io_input('read',fpath_fxw);

%% general

ng=numel(fxw.val);

F_crest=cell(ng,1);
F_weir_height=F_crest;
cord=F_crest;
F_crest_width=F_crest;
F_slope_right=F_crest;
F_slope_left=F_crest;
F_weir_height=F_crest;

for kg=1:ng
    xc=fxw.val{1,kg}{1,1}(:,1);
    yc=fxw.val{1,kg}{1,1}(:,2);
    crest_level=fxw.val{1,kg}{1,1}(:,3);
    weir_height=fxw.val{1,kg}{1,1}(:,4); %left
    
    crest_width=fxw.val{1,kg}{1,1}(:,6);
    slope_right=fxw.val{1,kg}{1,1}(:,7);
    slope_left=fxw.val{1,kg}{1,1}(:,8);
    
    s=[0,sqrt(sum((xc-xc(1)).^2+(yc-yc(1)).^2))];

    F_crest{kg}=griddedInterpolant(s,crest_level,'linear','none');
    F_weir_height{kg}=griddedInterpolant(s,weir_height,'linear','none');
    F_crest_width{kg}=griddedInterpolant(s,crest_width,'linear','none');
    F_slope_right{kg}=griddedInterpolant(s,slope_right,'linear','none');
    F_slope_left{kg}=griddedInterpolant(s,slope_left,'linear','none');
    
    cord{kg}=[xc,yc];
end


%% at unique x position

% [xg,~,idx_un2]=unique(cellfun(@(X)X{1,1}(1),fxw.val)); %x position of groynes
% ng=numel(xg); %number of groynes
% % if do_debug
% %     ng=2;
% % end
% 
% F_crest=cell(ng,1);
% F_bed=F_crest;
% for kg=1:ng
%     idx_g=find(idx_un2==kg);
%     ngu=numel(idx_g);
%     yc=NaN(2,ngu);
%     crest_level=yc;
%     bed_level=yc;
%     for kgu=1:ngu
%         yc(:,kgu)=fxw.val{1,idx_g(kgu)}{1,1}(:,2);
%         crest_level(:,kgu)=fxw.val{1,idx_g(kgu)}{1,1}(:,3);
%         bed_level(:,kgu)=fxw.val{1,idx_g(kgu)}{1,1}(:,4);
%     end
%     [yc_un,idx_u]=unique(yc(:));
%     crest_level_uni=crest_level(:);
%     crest_level_uni=crest_level_uni(idx_u);
%     bed_level_uni=bed_level(:);
%     bed_level_uni=bed_level_uni(idx_u);
%     F_crest{kg}=griddedInterpolant(yc_un,crest_level_uni,'linear','none');
%     F_bed{kg}=griddedInterpolant(yc_un,bed_level_uni,'linear','none');
% end

end %function