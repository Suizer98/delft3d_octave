%UNDERTOW_DEMO is a demo for the undertow function
%
%   Copyright (C) 2018 Deltares
%       grasmeij

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Nov 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: stokes_return_flow_demo.m 14796 2018-11-09 08:29:11Z bartgrasmeijer.x $
% $Date: 2018-11-09 16:29:11 +0800 (Fri, 09 Nov 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14796 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/stokes_return_flow_demo.m $
% $Keywords: undertow$

%%
clearvars;close all;clc;

Hm0 = [5,5,5];%3,5,7              %significant wave height [m]
Tp = [10,10,10];%11             %signficant wave period [s]
h = [15,15,15];%10,15,20             %water depth [m]
Hdir = [0,0,0];%0,45,90  %wave direction (with respect to the coast, 0 degrees = shore normal, 90 degrees is shore parallel (coast right hand side)

[Ur, Us, zz] = undertow(Hm0 ,Tp ,h, Hdir);

figpath = cd;
figure
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Ur(1,:),zz(1,:),'k-','LineWidth',1.5)
hold on
grid on
% plot([-uda(1) -uda(1)],[0 h(1)],'r-','LineWidth',1.5)
xlabel('U_r (m/s)')
ylabel('z (m)')
title(['H_s = ',num2str(Hm0(1)),' m, T_p = ',num2str(Tp(1)),' s'])
legend('Van Rijn (2013)','depth-uniform','location','southeast');
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
print('-dpng','-r300',[figpath,filesep,'undertow_example'])  % print figure at 300 dpi

figure
figsize = [0 0 5.9 3];     % set figure size to 5.9 inch x 2.95 inch = 15 cm x 7.5 cm
set(gcf,'PaperOrientation','portrait','PaperUnits','inches' ,'PaperPosition',figsize);
plot(Ur(1,:),zz(1,:),'k-','LineWidth',1.5)
hold on
grid on
plot(Us(1,:),zz(1,:),'r-','LineWidth',1.5)
plot(Us(1,:) + Ur(1,:),zz(1,:),'b-','LineWidth',1.5)
plot([0 0],[0 h(1)],'k-','LineWidth',1)
xlabel('U (m/s)')
ylabel('z (m)')
title(['H_s = ',num2str(Hm0(1)),' m, T_p = ',num2str(Tp(1)),' s'])
legend('U_r(z)','U_s(z)','U_s + U_r(z)','location','southeast');
text(1,0,['\copyright Deltares ',datestr(now,10)],'fontsize',6,'rotation',90,'unit','n','ver','t');  % add ARCADIS copyright
annotation('textbox',[1,0.0,0,0],'string',[addslash([mfilename])],'fontsize',4,'horizontalalignment','right','verticalalignment','baseline','color',[0.5 0.5 0.5]);  % add script name
print('-dpng','-r300',[figpath,filesep,'undertow_example2'])  % print figure at 300 dpi

