%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_mn2xyz.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_mn2xyz.m $
%

function D3D_convert_mn2xyz(paths_grd_in,paths_enc_in,paths_int_in,paths_int_out)

nd=numel(paths_grd_in); %number of domains

tmp=[];
for kd=1:nd

    %load grid
    G=delft3d_io_grd('read',paths_grd_in{kd,1},'enclosure',paths_enc_in{kd,1});

    %values at cell centre with dummy values
    xh=G.cend.x';
    yh=G.cend.y';

    mmax=G.mmax;
    nmax=G.nmax;
%             xh(mmax,:)    = NaN;
%             yh(mmax,:)    = NaN;
%             xh(:,nmax)    = NaN;
%             yh(:,nmax)    = NaN;

    %read data
    if isempty(paths_int_in{kd})
        dat=zeros(mmax,nmax);
    else
        dat=wldep('read',paths_int_in{kd},[mmax nmax]);
    end

    %remove no data
    dat(dat==-999) = NaN;
%             dat(mmax,:)    = NaN;
%             dat(:,nmax)    = NaN;


    %buid xyz
    tmp_a=NaN(mmax*nmax,3);
    tmp_a(:,1)      = reshape(xh,mmax*nmax,1);
    tmp_a(:,2)      = reshape(yh,mmax*nmax,1);
    tmp_a(:,3)      = reshape(dat,mmax*nmax,1);

    %combine files
    tmp=[tmp;tmp_a];
end %kd

%remove NaN
nonan = ~(isnan(tmp(:,1)) | isnan(tmp(:,2)) | isnan(tmp(:,3))) ;
tmp_nn=tmp(nonan,:);

%add points outside the grid to avoid lack of data for interpolations (I think that what I am doing is not general enough)
epsi=10000; %[m]

[min_x,min_x_idx]=min(tmp_nn(:,1));
[max_x,max_x_idx]=max(tmp_nn(:,1));
[min_y,min_y_idx]=min(tmp_nn(:,2));
[max_y,max_y_idx]=max(tmp_nn(:,2));

extra_points(1,:)=[min_x-epsi,tmp_nn(min_x_idx,2:3)];
extra_points(2,:)=[max_x+epsi,tmp_nn(max_x_idx,2:3)];
extra_points(3,:)=[tmp_nn(min_y_idx,1),min_y-epsi,tmp_nn(min_y_idx,3)];
extra_points(4,:)=[tmp_nn(max_y_idx,1),max_y+epsi,tmp_nn(max_y_idx,3)];

% %check
% figure
% hold on
% scatter(tmp_nn(:,1),tmp_nn(:,2),10,'k')
% scatter(extra_points(:,1),extra_points(:,2),10,'r')

data=[tmp_nn;extra_points];

% Write to unstruc xyz file
LINE.DATA=num2cell(data);
dflowfm_io_xydata('write',paths_int_out,LINE);

end %function