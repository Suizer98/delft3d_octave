% --------------------------------------
% Script to compare two sims. 
% path1: sim created with matlab scripts
% path2: sim created with MorphAn
% --------------------------------------

clear all
close all

% --- sim 1
path1 = 'referentie/';
zs1      = nc_varget([path1 'xboutput.nc'],'zs');
zb1      = nc_varget([path1 'xboutput.nc'],'zb');
globalx1 = nc_varget([path1 'xboutput.nc'],'globalx');

% --- sim 2
path2 = 'c:\Users\ridde_mo\OneDrive - Stichting Deltares\Desktop\tmp\referentie\Ref.dsproj_data\XBeach_Erosie_Model_output\XBeach_1D\A_2_1 (2000) H90P1600RP50A10dt0\';

zs2      = nc_varget([path2 'xboutput.nc'],'zs');
zb2      = nc_varget([path2 'xboutput.nc'],'zb');
globalx2 = nc_varget([path2 'xboutput.nc'],'globalx');

%% plotting

% --- plot domain
figure;
plot(globalx1, squeeze(zb1(1,:)),'o-')
hold on
plot(globalx2, squeeze(zb2(1,:)),'*-')
grid on
xlabel('x [m+RSP]')
ylabel('zb [m+NAP]')
legend({'sim 1','sim2'})

% --- plot domain
figure;
subplot(2,1,1)
plot(globalx1, squeeze(zb1(1,:)))
hold on
plot(globalx2, squeeze(zb2(1,:)),'--')
grid on
xlabel('x [m+RSP]')
ylabel('zb [m+NAP]')
subplot(2,1,2)
plot(globalx1(2:end), diff(globalx1))
hold on
plot(globalx2(2:end), diff(globalx2),'--')
grid on
xlabel('x [m+RSP]')
ylabel('dx [m]')

% --- plot erosion
figure;
subplot(2,1,1)
plot(globalx1, squeeze(zb1(1,:)),'k')
hold on
plot(globalx2, squeeze(zb2(1,:)),'m--')
plot(globalx1, squeeze(zb1(end,:)),'b')
plot(globalx2, squeeze(zb2(end,:)),'r--')
grid on
xlabel('x [m+RSP]')
ylabel('zb [m+NAP]')
legend({'zb(t=0) sim 1','zb(t=0) sim 2','zb(t=tend) sim 1','zb(t=tend) sim 2'})

subplot(2,1,2)
% -- interpolate results
zb2_inital_int  = interp1(globalx2,squeeze(zb2(1,:)),globalx1);
zb2_end_int     = interp1(globalx2,squeeze(zb2(end,:)),globalx1);

plot(globalx1, zb1(1,:)'-zb2_inital_int,'k')
hold on
plot(globalx1, zb1(end,:)'-zb2_end_int,'r-')
legend({'zb(t=0) sim 2 - zb(t=0) sim 1','zb(t=tend) sim 2-zb(t=tend) sim 1'})
grid on
xlabel('x [m+RSP]')
ylabel('zb [m+NAP]')

%% boundary

% --- tide
tide1 = load([path1, 'tide.txt']);
tide2 = load([path2, 'tide.txt']);

% read waves sim 1 (jonswap.txt)
jons        = load([path1, 'jonswap.txt']);
time_wave1  = cumsum(jons(:,6));
Hm0_bc1     = jons(:,1);
Tp_bc1      = jons(:,2);


% --- read waves sim 2 (MorphAn, waves.lst & *.bnd)
fid     = fopen([path2, 'waves.lst'], 'r');
wavelst = textscan(fid,  '%f %f %s', Inf , 'Headerlines', 1);
t_bins  = wavelst{1,1}; %tijd (s) per bin
% --- time axis
time_wave2 = cumsum(t_bins); 

% --- read *.bnd files
bndfiles    = ls([path2, '*bnd']);
Hm0_bc2     = NaN(1,length(bndfiles));
Tp_bc2      = NaN(1,length(bndfiles));
for i = 1 : length(bndfiles)

    wavef       = ['waves', num2str(i), '.bnd' ] ;
    fid         = fopen([path2, wavef], 'r');
    wavedata    = textscan(fid,  '%s %s %f', Inf );
    

    Hm0_bc2(i)   = wavedata{1,3}(1);
    Tp_bc2(i)    = 1./wavedata{1,3}(2);

end 

% --- plot results
figure;
subplot(3,1,1)
plot(tide1(:,1)/3600, tide1(:,2),'o-')
hold on
plot(tide2(:,1)/3600, tide2(:,2),'*-')
subplot(3,1,2)
plot(time_wave1/3600, Hm0_bc1,'-o')
hold on
plot(time_wave2/3600, Hm0_bc2,'-*')
subplot(3,1,3)
plot(time_wave1/3600, Tp_bc1,'-o')
hold on
plot(time_wave2/3600, Tp_bc2,'-*')
