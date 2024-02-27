% --------------------------------------
% Script to analyse the xbeach output
% --------------------------------------

clear all
close all


%% input

% --- path of snc file
fname   = 'referentie\xboutput.nc';
% --- Rp
Rp      = 5;


%% read nc

% --- read variables
zb          = nc_varget(fname,'zb');
x           = nc_varget(fname,'globalx');
zswet_max   = nc_varget(fname,'zswet_max');
% --- set variables
zswet_max   = squeeze(zswet_max(:,1,:));
zbe         =  squeeze( zb(end,1,:) ); 
zb0         =  squeeze( zb(1,1,:) ); 

% --- plot results
figure(10)
plot(x, zb0,'k-','linewidth',2)
hold on
plot(x, zbe,'r-')
plot(x, x*0+Rp,'b--')
grid on

%% analyse

% --- erosion volume
V                   = get_erosionvolume_2(x,zb0,zbe,Rp);
title(sprintf('V=%2.2f m^3/m',V))

% --- erosion point
[xafslag,zafslag]   = get_xafslag_xbBOI(x,zb0,zbe);

scatter(xafslag, zafslag,'r','filled')

% --- xwet-t
[xnat_t,znat_t] = get_xnat_t_xbBOI(x,zswet_max');

scatter(xnat_t, znat_t,5,'m','filled')

% --- xwet
slopeland=1/2;
[xnat,znat,itxnat] = get_xnat_xbBOI(xnat_t,znat_t,slopeland,x,zbe);

scatter(xnat, znat,'g','filled')

% --- boundary profile
X0 = loc_boundary_profile(znat,xnat,x,zbe,Rp);

% --- plot
height = znat+1.5 - Rp;
figure(10)
plot([X0 X0+height*1 X0+height+3 X0+height+3+height*2],[Rp, znat+1.5 znat+1.5 Rp],'b-','linewidth',2)

legend({'zb[t=0]','zb[t=tend]','rekenpeil','afslag punt','natte punten', 'natte punt','grensprofiel'},'Location','northwest')

string = sprintf('V=%2.2f m^3/m\nXaf=%2.2f m; Zaf=%2.2f m\nXnat=%2.2f m; Znat=%2.2f m',V,xafslag,zafslag,xnat,znat);
text(0.6,0.15,string,'Units','normalized')
set(gcf,'Position',[100 100 800 500])
xlabel('Afstand [m+RSP]'); ylabel('Hoogte [m+NAP]')