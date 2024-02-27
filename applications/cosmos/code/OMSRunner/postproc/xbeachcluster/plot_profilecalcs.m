function plot_profilecalcs(figuredir,ncdir,xmldir,mopid)

% plot_profile_calcs.m:  This program reads in the .mat file with profile
%  statistics, plots the results and saves the figure in the output
%  directory.

%    usage:  plot_profilecalcs(inputdir,outputdir,mopid);
%
%        where: inputdir - directory path where input data files are stored
%                       (ex: 'M:\Coastal_Hazards\Xbeach\post_xbeach\');
%               outputdir - directory path where netcdf output files are
%                       stored (ex: ''M:\Coastal_Hazards\Xbeach\post_xbeach\');
%               mopid - MOP profile ID which is used to read in the netcdf
%                       file (ex: 3401);


% JLE 11/30/09

% close all;

% load the processed data and start and end profiles
% eval(['load ',outputdir,mopid,'_proc.mat']);

% s=xml_load([xmldir mopid '.xml']);
% 
% hmax=s.profile.proc.hmax;
% max_r=s.profile.proc.max_runup;
% change=s.profile.proc.shoreline_change;
% bb_change=s.profile.proc.backbeach_change;
% pchangeperm=s.profile.proc.profile_accretion;
% perosionperm=s.profile.proc.profile_erosion;
% pchangebeach=s.profile.proc.beachprofile_change;
% flood_flag=s.profile.proc.flood_flag;
% inund_flag=s.profile.proc.inund_flag;
% flood_dur=s.profile.proc.flood_duration;
% WLdif=s.profile.proc.wl_diff;

load([ncdir mopid '_proc.mat']);

% Make cell array of strings for plotting
celldata{1}=['H max = ',num2str(hmax,'%6.2f'),' m'];
celldata{2}=['Maximum Runup Elevation = ',num2str(max_r,'%6.2f'),' m'];
celldata{3}=['Shoreline Change (mhw) = ',num2str(change,'%6.2f'),' m'];
celldata{4}=['Back Beach Change (mhhw) = ',num2str(bb_change,'%6.2f'),' m'];
celldata{5}=['Profile Accretion = ',num2str(pchangeperm,'%6.2f'),' m^2/m'];
celldata{6}=['Profile Erosion = ',num2str(perosionperm,'%6.2f'),' m^2/m'];
celldata{7}=['Profile Change (0 to 1.6m)  = ',num2str(pchangebeach,'%6.2f'),' m^2/m'];
if(flood_flag==1)
    celldata{8}='Flooding = yes';
else
    celldata{8}='Flooding = no';
end
if(inund_flag==1)
    celldata{9}='Inundation = yes';
else
    celldata{9}='Inundation = no';
end
celldata{10}=['Flood Duration = ',num2str(flood_dur,'%4.0f'),' hrs'];
celldata{11}=['WL dif (runup-tide) = ',num2str(WLdif,'%6.2f'),' m'];

% Plot information for comparison
fig=figure('Position',[300 300 1000 600],'Visible','off');

plot(d,zbstart,'-k','LineWidth',1.4)
hold on
grid on
plot(d,zbend,'-r','LineWidth',1.4);
plot(out(1,4),out(1,3),'*k','MarkerSize',6.0);
plot(out(2,4),out(2,3),'*r','MarkerSize',6.0);
plot([0,d(end)],[max_r,max_r],'-b','LineWidth',1.2);
plot(d_bb,z_bb,'ok','MarkerFaceColor','m');
plot(d_bb2,z_bb2,'ok','MarkerFaceColor','g');

%tb = annotation('textbox',[0.15,0.65,0.25,0.25],'BackgroundColor','w','Color','k','EdgeColor','k','FitBoxToText','on','String',celldata);

xlabel('Distance Along Profile (m)');
ylabel('Elevation NAVD88 (m)');
legend('initial profile','final profile','initial shoreline (mhw) location',...
    'final shoreline (mhw) location','maximum runup height','initial back beach (mhhw) location',...
    'final back beach (mhhw) location','Location','SouthEast');
title(['MOP Profile ',num2str(mopid)],'FontSize',14.0,'FontWeight','bold');

% save the figure in the output directory
% saveas(gcf,[outputdir,mopid,'.fig']);
[success,message,messageid]=mkdir(figuredir);
print('-dpng','-r80',[figuredir,mopid,'.png']);
close(fig);
