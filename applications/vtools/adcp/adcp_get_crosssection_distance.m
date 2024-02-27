%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: adcp_get_crosssection_distance.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_get_crosssection_distance.m $
%

function [s,idx_out2,cords_xy_4326,cords_xy_28992]=adcp_get_crosssection_distance(data_block,varargin)

flg.use_cords=0;
flg=setproperty(flg,varargin);

if flg.use_cords
    cords_all=cell2mat({data_block.cords}');
    cords_xy_4326=cords_all;
    idx_out=cords_xy_4326==30000;
    idx_out2=idx_out(:,1)==1|idx_out(:,2)==1;
    cords_xy_4326(idx_out2,:)=[];

    [cords_x_28992,cords_y_28992]=convertCoordinates(cords_xy_4326(:,1),cords_xy_4326(:,2),'CS1.code',4326,'CS2.code',28992);

    if isnan(data_block(1).distance(1))
        s=[0;cumsum(sqrt((cords_x_28992(2:end)-cords_x_28992(1:end-1)).^2+(cords_y_28992(2:end)-cords_y_28992(1:end-1)).^2))];
    else
        s=[data_block(~idx_out2).distance];
    end
    cords_xy_28992=[cords_x_28992,cords_y_28992];
else
    s=[data_block.distance];
    s=reshape(s,1,[]);
    idx_out2=false(size(s));
    cords_xy_4326=NaN;
    cords_xy_28992=[[data_block.distance_east],[data_block.distance_north]];
end

end %function