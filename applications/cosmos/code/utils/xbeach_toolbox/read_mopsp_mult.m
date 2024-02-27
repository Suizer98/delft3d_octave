function [out1d,out2d] = read_mopsp_mult(mopid,monthid,dstart,dend)

% read_mopsp_mult.m: Reads in MOP spectral file for the
% month, plots data, and develops a timeseries of 2d spectra from information.
% This will read only a specific time window based on the dstart and dend
% that are input.  If a range is not entered, then it reads the whole
% month of data.

% JLE 5/2/2009
% modified as a function on 9/21/09
% modified 2d spectral calculation on 9/25/09

%   Input:
%     mopid = mop station id (ex: 'VE338')
%     monthid = year and month of data (ex: '200904')
%     dstart = datestring for the first spectral file, 'yyyymmddHH' 
%              (ex: '2009041300', enter 1 to read the whole month)
%     dend = datestring for the last spectral file, 'yyyymmddHH'
%              (ex: '2009041600', enter 1 to read the whole month)
%   Output:
%     out1d = timeseries of 1D spectral data that was read in from the MOP 
%             file stored in the following format.
%     out1d.t = matlab datenumber
%     out1d.f = frequencies, (Hz)
%     out1d.e = energy densities (m2/Hz)
%     size(out1d.e) = [length(out1d.f) length(out1d.time)]
%     out1d.dmean = mean direction for each freq (deg)
%     out1d.a1 = fourier coefficient for each freq
%     out1d.b1 = fourier coefficient for each freq
%     out1d.a2 = fourier coefficient for each freq
%     out1d.b2 = fourier coefficient for each freq
%     out1d.hs = significant wave height (m)
%     out1d.tp = peak wave period (sec)
%     out1d.dp = peak wave direction (deg)
%     out1d.ta = avg wave period (sec)

%     out2d = timeseries of output 2D spectral data stored in the following
%             format.
%     out2d = array with 2D spectral data
%     out2d.t = matlab datenumber
%     out2d.f = frequencies 
%     out2d.d = directions 
%     out2d.s = variance densities,
%     size(out2d.s) = [length(out2d.f) length(out2d.dir) length(out2d.time)]

%   Assumptions:
%     1) Keep mop names standard after download with the following file
%     formats.
%           mopid_monthidpm.txt    parameter file
%           mopid_monthidsp.txt    spectral file
%__________________________________________________________________________

%Search for time window if entered
if(dstart~=1 & dend~=1) %#ok<*AND2>
    ds=datenum(dstart,'yyyymmddHH');
    de=datenum(dend,'yyyymmddHH');
    disp(['Reading data from ',datestr(ds,0),' to ',datestr(de,0)]);
elseif(dstart==1 & dend==1)
    disp('Reading the entire month of data');
else
    disp('Error, start and end dates must be valid or both specified by 1');
    return
end
%__________________________________________________________________________
%Read MOP spectral file for month.
fid = fopen([mopid,'_',monthid,'sp.txt'],'r');
t = [];
ndt=0;
hs = [];
tp = [];
dp = [];
ta = [];
while 1
   line = fgetl(fid);
   % exit at end of file
   if ~ischar(line)
      break
   end
   % get the time from the filename
   if strncmpi(line,'File name',9)
      tmp=line(isletter(line)==0);
      t = [t;datenum(tmp(7:end),'yyyymmddHH')];
      ndt = ndt + 1;
   end
   % read in the wave parameters estimated for the spectra
   if strncmpi(line,'Hs',2)
       tmp=line(isletter(line)==0);
       hs = [hs;str2num(tmp(6:9))];
       tp = [tp;str2num(tmp(17:21))];
       dp = [dp;str2num(tmp(29:31))];
       ta = [ta;str2num(tmp(39:43))];
   end
   % read in the data
   if strncmpi(line,'  Hz',4)
       edens=[];
       dmean = [];
       a1 = [];
       b1 = [];
       a2 = [];
       b2 = [];
       f = [];
      for ii=1:33
         line = fgetl(fid);
         tmp = sscanf(line,'%f');
         f = [f;tmp(1)];
         edens = [edens;tmp(3)];
         dmean = [dmean;tmp(4)];
         a1 = [a1;tmp(5)];
         b1 = [b1;tmp(6)];
         a2 = [a2;tmp(7)];
         b2 = [b2;tmp(8)];
      end
      F(:,ndt) = f;
      E(:,ndt) = edens;
      DM(:,ndt) = dmean;
      A1(:,ndt) = a1;
      B1(:,ndt) = b1;
      A2(:,ndt) = a2;
      B2(:,ndt) = b2;
      clear edens dmean a1 b1 a2 b2 f
   end
end
fclose(fid);
%__________________________________________________________________________
% now search for the time window that was entered and cut data to this
% range if the user chooses to do this

if(dstart~=1 & dend~=1)
    pr=find(t >= ds & t<=de);
    out1d = struct('t',t(pr),'f',F(:,1),'dmean',DM(:,pr),'a1',A1(:,pr),'b1',B1(:,pr),'a2',A2(:,pr),'b2',...
    B2(:,pr),'E',E(:,pr),'hs',hs(pr),'tp',tp(pr),'dp',dp(pr),'ta',ta(pr)); 
elseif(dstart==1 & dend==1)
    out1d = struct('t',t,'f',F(:,1),'dmean',DM,'a1',A1,'b1',B1,'a2',A2,'b2',...
    B2,'E',E,'hs',hs,'tp',tp,'dp',dp,'ta',ta); 
end
%__________________________________________________________________________
%plot 1d spectral timeseries read in from MOP file
maxE = max(max(out1d.e));
c = maxE;
for ii=1:31
  c = [c(1)/2; c];
end
cmap = jet(length(c)-1); 
cmap(1,:)= [1 1 1];

figure
pcolor(out1d.t',out1d.f,out1d.e)
colormap(cmap)
shading interp
colorbar
grid on
title(['Energy Density, m^2/Hz for MOP station ',mopid,' ',datestr(out1d.t(end),12)]);
xlabel('Time')
ylabel('Frequency, Hz')
dateaxis('x',2)

%__________________________________________________________________________
%Create 2D spectral file by placing the energy at each frequency in the 
%direction bin of the 2nd moment mean direction (aka the Sxy angle) to 
%preserve the correct cross- and longshore radiation stresses in the 
%nearshore modeling without invoking directional estimators. (per BOR
%recommendation on 4/23/09).  

% Define directions in degrees.  First column is
% centered at 1 degree, last column is centered at 360 deg.
dirres = 1;
dir=1:dirres:360;

%Calculate the second moment mean direction for every frequency at each 
%timestep and round angles to the nearest degree.  
for jj=1:length(out1d.t)
    for kk=1:length(out1d.f)
        DM2(kk,jj)=round((0.5*(atan2(out1d.b2(kk,jj),out1d.a2(kk,jj))))*(180/pi));
        % Convert to all positive angles
        if(DM2(kk,jj)<0)
            DM2(kk,jj)=DM2(kk,jj)+360;
        end
        % Now, check that you've picked the angle closest to the first
        % moment mean direction.  If not, add 180 degrees.
        if(abs(DM2(kk,jj)-out1d.dmean(kk,jj))>100)
            DM2(kk,jj)=DM2(kk,jj)+180;
        end
        % Now, make sure you don't have any angles greater than 360 degrees
        if(DM2(kk,jj)>360)
            DM2(kk,jj)=DM2(kk,jj)-360;
        end
    end
end

%Place energy in the bin corresponding to the second moment mean direction
%for each frequency (Find the closest directional bin)
for kk=1:length(out1d.t)
    for ii=1:length(out1d.f)
        for jj=1:length(dir)
         p(jj)=abs(DM2(ii,kk)-dir(jj));
        end
       p1=find(p==min(p));
       dbin(ii,kk)=dir(p1);
       dind(ii,kk)=p1;
       clear p p1
    end
end

for ii=1:length(out1d.t)
    for jj=1:length(out1d.f)
        for kk=1:length(dir)
            if kk==dind(jj,ii)
               S(jj,kk,ii)= (out1d.e(jj,ii))/dirres;
            else
               S(jj,kk,ii) = 0;
            end
        end
    end
end

out2d = struct('t',out1d.t,'f',out1d.f,'d',dir,'S',S); 
%__________________________________________________________________________
%Save data in a .mat file with the mopid and month id
eval(['save ',mopid,'_',monthid,'_2dspec.mat out1d out2d']);









