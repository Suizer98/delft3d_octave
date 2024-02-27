%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_dep.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_dep.m $
%
function D3D_convert_dep(paths_grd_in,paths_enc_in,paths_dep_in,paths_dep_out)

nd=numel(paths_grd_in);

tmp=[];
for kd=1:nd
    %read gris
    G=delft3d_io_grd('read',paths_grd_in{kd,1},'enclosure',paths_enc_in{kd,1});
    %corners
    % xh            = G.cor.x';
    % yh            = G.cor.y';
    %DPSOPT=DP
    xh            = G.cend.x';
    yh            = G.cend.y';

    mmax          = G.mmax;
    nmax          = G.nmax;

    warning('is this needed? I think only when data is at corners, but not when dpsopt=dp')
    xh(mmax,:)    = NaN;
    yh(mmax,:)    = NaN;
    xh(:,nmax)    = NaN;
    yh(:,nmax)    = NaN;

    % Check coordinate system (for grd2net)
    % spher         = 0;
    % if strcmp(G.CoordinateSystem,'Spherical')
    %     spher     = 1;
    % end

    % Read the depth data
    if  ~ischar (paths_dep_in{kd,1})
        zh(1:mmax,1:nmax) = -paths_dep_in{kd,1};
    elseif exist(paths_dep_in{kd,1},'file') && ~strcmp(paths_dep_in{kd,1}(end),'\')
        depthdat      = wldep('read',paths_dep_in{kd,1},[mmax nmax]);
        zh            = depthdat;
        zh(zh==-999)  = NaN;
        zh            = -zh;
        zh(mmax,:)    = NaN;
        zh(:,nmax)    = NaN;
    else
        zh            = -5.*ones(mmax,nmax);      % -5 m+NAP as default value, as in D-Flow FM
    end

    % Make file with bathymetry samples
        %one file
    tmp_a=NaN(mmax*nmax,3);
    tmp_a(:,1)      = reshape(xh,mmax*nmax,1);
    tmp_a(:,2)      = reshape(yh,mmax*nmax,1);
    tmp_a(:,3)      = reshape(zh,mmax*nmax,1);
        %several files
    tmp=[tmp;tmp_a];

end %kf

%remove NaN
nonan         = ~(isnan(tmp(:,1)) | isnan(tmp(:,2)) | isnan(tmp(:,3))) ;
LINE.DATA     = num2cell(tmp(nonan,:));

%chech
figure
scatter(tmp(nonan,1),tmp(nonan,2),10,tmp(nonan,3),'filled')
colorbar

% Write to unstruc xyz file
dflowfm_io_xydata('write',paths_dep_out,LINE);

end %function