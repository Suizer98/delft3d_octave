format long; close all

ini = 0;
if ini ~= 1
    ini = 1;
    
    %% The shared library and the generic header file
    % Make sure you have setup mex -setup before you run this.
    addpath(pwd)
    
    dll = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\vs2010\Debug\swan_dll.dll';
    config_file = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\tests\DMrecSWAN02\swan.inp';
    
    %% Load the library
    tic
    [bmidll] = bmi_new(dll);
    bmi_initialize(bmidll, config_file);
    bmi_update(bmidll,3600);
    
    %% Get variables
    voq = bmi_var_get(bmidll, 'VOQ');
    voqids    = bmi_var_get(bmidll, 'VOQR');
    voq2      = bmi_var_get(bmidll, 'VOQ2');
    voq2ids   = bmi_var_get(bmidll, 'VOQR2');
    s.XCGRID  = bmi_var_get(bmidll, 'XCGRID');
    s.YCGRID  = bmi_var_get(bmidll, 'YCGRID');
    s.dp2     = bmi_var_get(bmidll, 'DP2');
    
    %     s.ac2     = bmi_var_get(bmidll, 'AC2');
    %     s.spcsig  = bmi_var_get(bmidll, 'SPCSIG');
    %     s.ddir    = bmi_var_get(bmidll, 'DDIR');
    %     s.pwtail  = bmi_var_get(bmidll, 'PWTAIL');
    %% (*) (still to) get variables
    % frintf  = bmi_var_get(bmidll, 'FRINTF');
    % fx      = bmi_var_get(bmidll, 'fx');          & dS/dx ??
    % fy      = bmi_var_get(bmidll, 'fy');          & dS/dy ??
    % ubot    = bmi_var_get(bmidll, 'UBOT');
    
end
%% Process data

mip = 676;
% Check swmod1.for MODULE SWCOMM1 and swanmain.for SUBROUTINE SWINIT for administration of index.
% Set in swanout1.for SUBROUTINE SWOEXA
ids.XP    = 1;
ids.YP    = 2;
ids.depth = 4;
ids.Hs    = 10;
ids.tps   = 53;  % 'Relative peak period (smooth)'
ids.phi   = 13;  % 'Average wave direction'
ids.uorb  = 6;   % mind! ~= urms
ids.F     = 20;  % 'Wave driven force per unit surface'

% retrieve from VOQ
s.XP    = voq((mip*(voqids(ids.XP)-1)+1):(mip*(voqids(ids.XP))));
s.YP    = voq((mip*(voqids(ids.YP)-1)+1):(mip*(voqids(ids.YP))));
s.depth = voq((mip*(voqids(ids.depth)-1)+1):(mip*(voqids(ids.depth))));
s.Hs    = voq((mip*(voqids(ids.Hs)-1)+1):(mip*(voqids(ids.Hs))));
s.tps   = voq2((mip*(voq2ids(ids.tps)-1)+1):(mip*(voq2ids(ids.tps))));
s.phi   = voq((mip*(voqids(ids.phi)-1)+1):(mip*(voqids(ids.phi))));
s.uorb  = voq((mip*(voqids(ids.uorb)-1)+1):(mip*(voqids(ids.uorb))));
s.F     = voq((mip*(voqids(ids.F)-1)+1):(mip*(voqids(ids.F))));

% give 2D shape
s.twoD.XP    = reshape(s.XP,fliplr(size(s.XCGRID)));
s.twoD.YP    = reshape(s.YP,fliplr(size(s.XCGRID)));
s.twoD.depth = reshape(s.depth,fliplr(size(s.XCGRID)));
s.twoD.Hs    = reshape(s.Hs,fliplr(size(s.XCGRID)));
s.twoD.tps   = reshape(s.tps,fliplr(size(s.XCGRID)));
s.twoD.phi   = reshape(s.phi,fliplr(size(s.XCGRID)));
s.twoD.uorb  = reshape(s.uorb,fliplr(size(s.XCGRID)));
s.twoD.F     = reshape(s.F,fliplr(size(s.XCGRID)));

% remove -999
s.twoD.depth(s.twoD.depth==-999)=NaN;
s.twoD.Hs(s.twoD.Hs==-999)=NaN;
s.twoD.tps(s.twoD.tps==-999)=NaN;
s.twoD.phi(s.twoD.phi==-999)=NaN;
s.twoD.uorb(s.twoD.uorb==-999)=NaN;
s.twoD.F(s.twoD.F==-999)=NaN;

% old
s.dp2 = s.dp2(1:end-1);
s.twoD.dp2 = reshape(s.dp2,fliplr(size(s.XCGRID)));

% out = getHm0_2D(s);
% out.hs = out.hs(1:end-1);
% out.hs_2D = reshape(out.hs,fliplr(size(s.XCGRID)));


%% Print individual parameters


% figure
% surfc(double(s.XCGRID), double(s.YCGRID), flipud(double(out.hs_2D)))
% figure
% surfc(double(s.XCGRID), double(s.YCGRID), double(s.twoD.dp2)); colorbar

pl.indivP = 0;
if pl.indivP
    figure
    % plot3(double(s.XP), double(s.YP), double(s.depth))
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.depth))
    title('depth')
    xlabel('x')
    ylabel('y')
    colorbar
    
    figure
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.Hs))
    title('Hs')
    colorbar
    
    figure
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.tps))
    title('tps')
    colorbar
    
    figure
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.phi))
    title('phi')
    colorbar
    
    figure
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.F))
    title('wave force')
    colorbar
    
    figure
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.uorb))
    title('uorb')
    colorbar
    
end



%% combine parameters in one figure

pl.combP = 1;
if pl.combP
    scrsz= get(0, 'ScreenSize');
    figure('Position', scrsz, 'Visible','on');
    set(gcf,'defaultaxesfontsize',10)
    
    subplot(321)
    surfc(double(s.twoD.XP), double(s.twoD.YP), -double(s.twoD.depth))
    title('depth [m]')
    colorbar
    view(142.5, 30)
    
    
    
    subplot(322)
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.Hs))
    title('Hs [m]')
    colorbar
    view(142.5, 30)
    
    subplot(323)
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.tps))
    title('tps [s]')
    colorbar
    view(142.5, 30)
    
    subplot(324)
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.phi))
    title('phi [deg]')
    colorbar
    view(142.5, 30)
    
    subplot(325)
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.F))
    title('wave force [N/m^2]')
    xlabel('x')
    ylabel('y')
    colorbar
    view(142.5, 30)
    
    subplot(326)
    surfc(double(s.twoD.XP), double(s.twoD.YP), double(s.twoD.uorb))
    title('uorb [m/s]')
    xlabel('x')
    ylabel('y')
    colorbar
    view(142.5, 30)
end


%% cleanup
bmi_finalize(bmidll);
toc
