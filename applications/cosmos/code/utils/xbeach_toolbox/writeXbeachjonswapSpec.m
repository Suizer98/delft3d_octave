function writeXbeachjonswapSpec(fname,name,sdur,tstep,gamma,s)

%writeXbeachjonswapSpec(fname,name,sdur,tstep) Writes jonswap spectral input 
% files for Xbeach from the MOP parameter file.
%
%   Input:
%     fname = name of MOP parameter file to read in (ex:'VE338_200802pm.txt')
%     name = 'text'; used in file name written (ex: 'VE')
%     sdur = duration of each wave spectrum condition in seconds (ex: 3600)
%     tstep = required time step in boundary condition file in seconds (ex:
%     1.0)
%     gamma = Peak enhancemen factor in the JONSWAP expression (Xbeach
%             manual p. 40, ex: 3.3)
%     s = directional spreading coeficient (Xbeach manual p. 40, ex: 10)
%   Output:
%     for length(time)==1 : jonswap_NAME_datestr(SS.t,'yyyymmddHH').inp
%     for length(time)>1  : jonswap_NAME_datestr(SS.t,'yyyymmddHH').inp for
%                           each time
%                         : jonswaplist.txt with the names of each indiv file
%                         for use with the 'bcfile' command for
%                         time-varying spectra (Xbeach manual p.45).
%
% JLE 8/24/09

%Read in MOP parameter data
filein=load(fname);
time=filein(:,1);
Hs=filein(:,2);
Tp=filein(:,3);
Dp=filein(:,4);
Ta=filein(:,5);
Sxy=filein(:,6);
Sxx=filein(:,7);
Dm=filein(:,8);

%Convert input time string to matlab datenumber
ddate=num2str(time);
dform = 'yyyymmddHH';
dt=datenum(ddate,dform);

%plot time you are making file for
%Plot wave parameters
figure
subplot(3,1,1)
plot(dt,Hs,'-b');
dateaxis
grid on
ylabel('Hs, m');
title('MOP Parameter data');
set(gca,'XTickLabel','');

subplot(3,1,2)
plot(dt,Tp,'.k');
hold on 
grid on
plot(dt,Ta,'.r');
a=axis;
axis([a(1) a(2) 0 25]);
dateaxis
ylabel('Period, sec');
legend('Tp','Tavg');
set(gca,'XTickLabel','');

subplot(3,1,3)
plot(dt,Dp,'.k');
grid on
hold on
plot(dt,Dm,'.r');
dateaxis
ylabel('Direction, deg');
legend('Dp','Dm');
set(gca,'XTickLabel','');

%__________________________________________________________________________
% Loop through for each time and write individual spectral file.  The
% jonswap angle is specified in nautical terms (Xbeach manual p. 40), as is 
% the MOP output, so no direction modification is required.

for ii=1:length(dt)
    
    % initialize file
    fid = fopen(['jonswap_',name,'_',datestr(dt(ii),'yyyymmddHH'),'.inp'],'w');
    tmp = ['Hm0      = ',num2str(Hs(ii))];
    fprintf(fid,'%s\n',tmp);
    tmp = ['fp       = ',num2str(1./Tp(ii))];
    fprintf(fid,'%s\n',tmp);
    tmp = ['mainang  = ',num2str(Dp(ii))];
    fprintf(fid,'%s\n',tmp);
    tmp = ['gammajsp = ',num2str(gamma)];
    fprintf(fid,'%s\n',tmp);
    tmp = ['s        = ',num2str(s)];
    fprintf(fid,'%s\n',tmp);
    fclose(fid);
end

%__________________________________________________________________________
%now write jonswaplist.txt with all of the filenames.
% initialize file
fid = fopen('jonswaplist.txt','w');
fprintf(fid,'%8s\n','FILELIST');
% Loop through for each time and write individual spectral file name
for ii=1:length(dt)
    tmp = ['  ',num2str(sdur),'.0      ',num2str(tstep),'.0 ','jonswap_',name,'_',datestr(dt(ii),'yyyymmddHH'),'.inp'];
    fprintf(fid,'%s\n',tmp);
end
fclose(fid);