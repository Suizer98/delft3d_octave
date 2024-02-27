%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_bnd.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_bnd.m $
%


function D3D_convert_bnd(paths_bnd_in,paths_grd_in,folder_out)

nf=numel(paths_bnd_in);

ktb=1; %counter of total boundaries
for kf=1:nf
    
    if isempty(paths_bnd_in{kf,1})==0
    grd=delft3d_io_grd('read',paths_grd_in{kf,1});
    bnd=delft3d_io_bnd('read',paths_bnd_in{kf,1},grd);
    
    n_nodes=numel(bnd.DATA);
    
    for kun=1:n_nodes
    
        bnd_type=bnd.DATA(kun).bndtype;
    
    switch bnd_type
        case 'Z'
            sorted_M=sort(bnd.DATA(kun).mn([1,3]));

            xcor_1=grd.cor.x(bnd.DATA(kun).mn(2)-1,sorted_M(1)-1); 
            ycor_1=grd.cor.y(bnd.DATA(kun).mn(2)-1,sorted_M(1)-1);
            xcor_2=grd.cor.x(bnd.DATA(kun).mn(4)-1,sorted_M(2)); 
            ycor_2=grd.cor.y(bnd.DATA(kun).mn(4)-1,sorted_M(2));
        case 'Q'         
            xcor_1=grd.cor.x(bnd.DATA(kun).n,bnd.DATA(kun).m-1); 
            ycor_1=grd.cor.y(bnd.DATA(kun).n,bnd.DATA(kun).m-1);
            xcor_2=grd.cor.x(bnd.DATA(kun).n,bnd.DATA(kun).m); 
            ycor_2=grd.cor.y(bnd.DATA(kun).n,bnd.DATA(kun).m);
    end %bnd_type
    
    name_node=bnd.DATA(kun).name;
    
    data=cell(1,1);
    kl=1;
    data{kl, 1}=sprintf('%s',name_node); kl=kl+1;
    data{kl, 1}=        '    2    2'; kl=kl+1;
    data{kl, 1}=sprintf('%0.7E  %0.7E %s_0001',xcor_1,ycor_1,name_node); kl=kl+1;
    data{kl, 1}=sprintf('%0.7E  %0.7E %s_0002',xcor_2,ycor_2,name_node); %kl=kl+1;

    %% WRITE

    file_name=fullfile(folder_out,sprintf('%s.pli',name_node));
    writetxt(file_name,data)
    
    %% STORE 
    
    bnd_fm{ktb,1}=bnd_type;
    bnd_fm{ktb,2}=sprintf('%s.pli',name_node);
    
    ktb=ktb+1;
    
    end %n_nodes
    end %isempty
end %nf

ntb=size(bnd_fm);

%write bnd fm file
data=cell(1,1);
kl=1;
for ktb=1:ntb

data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[boundary]'; kl=kl+1;
switch bnd_fm{ktb,1}
    case 'Q'
        data{kl, 1}='quantity=dischargebnd'; kl=kl+1;
    case 'Z'
        data{kl, 1}='quantity=waterlevelbnd'; kl=kl+1;
end
data{kl, 1}=sprintf('locationfile=%s',bnd_fm{ktb,2}); kl=kl+1;
data{kl, 1}='forcingfile=bc.bc'; kl=kl+1;

end

%% WRITE

file_name=fullfile(folder_out,'bnd.ext');
writetxt(file_name,data)

end %function