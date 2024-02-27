function [R2,max_R2,dt_R2,beta,Tp,Hs] = calc_emprunup_H2(inputdir,s_d,d_bb,zbstart)

% calc_emprunup.m:  This program calculates the empirical runup using the
% method of Stockdon et al., 2006

%    usage:  calc_emprunup(inputdir,outputdir,mopid,s_d,d_bb);
%
%   Input:
%         inputdir - directory path where input data files are stored
%                (ex: 'M:\Coastal_Hazards\Xbeach\post_xbeach\');
%         s_d - distance along profile corresponding to shoreline position
%               (mhw)
%         d_bb - distance along profile corresponding to back beach
%                position (mhhw)
%         zbstart - starting bottom elevation for profile run
%   Output:
%         R2 - timeseries of extreme 2% runup
%         max_R2 - maximum runup from timeseries of extreme 2% runup
%         dt_R2 - time for maximum runup

% JLE 12/1/09

% Read in the timeseries of SWAN spectral files at the 10 m contour
% Open filelist and read in the spectral file names

% modified 12/28/09
% This version reverse shoals the wave heights at the MOP location to deep
% water to see if that is an important step in predictions.

fid = fopen([inputdir,'sp2list.txt'],'r');
specfile=[];
nt=1;
dt_R2=[];
dtcum=0;
while 1
   line = fgetl(fid);
   if strncmpi(line,'FILELIST',8)
       line = fgetl(fid);
       while line~=-1
           tmp = sscanf(line,'%s');
           specfile{nt,1}=tmp(10:end);
           dtcum=dtcum+str2num(tmp(1:6));
           dt_R2(nt)=dtcum;
           nt=nt+1;
           line = fgetl(fid);
       end
       if ~ischar(line)
            break
       end
   end
end
fclose(fid);

row=1025;
g=9.81;

%Now, read in each individual spectral file and get the peak period and
%wave height from the spectral information.
for ii=1:length(specfile)
    out = readSwan2DSpec([inputdir,char(specfile(ii))]);
    % Convert the spectral data from energy density to variance units.
    out.sfix=(out.s.*2)./(row*g);
    % Sum the energy over each direction to get the 1D Spectra
    dirres=abs(out.d(2)-out.d(1));
    S1d=sum(out.sfix,3)*dirres;
    % Calculate Hs from the 1D spectra
    fi = [out.f(1):min(diff(out.f)):out.f(end)]';
    Hs(ii) = 4*sqrt(trapz(trapz(interp2(out.d,out.f,squeeze(out.sfix(1,:,:)),out.d,fi')))*(fi(2)-fi(1))*abs(out.d(2)-out.d(1)));
    % Find the frequency with the maximum energy
    Tp(ii)=1/out.f(S1d==max(S1d));
    clear out fi
end

% Read in the timeseries of water level and the timeseries of bottom elevation 
% to get depth at the offshore end of the profile.
load([inputdir,'tide.txt']);
wl=tide(:,2);
%interpolate the water level to the zb times
wl2=interp1q(tide(:,1),wl,dt_R2');
h=(wl2-zbstart(1))';

% Back Caculate Ho from wave height at MOP station
for ii=1:length(Tp)
    % Deep water wave characterstics
    Co(ii)=(g*Tp(ii))/(2*pi);
    % Estimate local water depth wave length
    L(ii)=LDIS(Tp(ii),h(ii));
end
C=L./Tp;
k=(2*pi)./L;
kh2=2*k.*h;
Cg=C.*(1+kh2./sinh(kh2))/2;
Ks=sqrt(Co./(2*Cg));
Ho=Hs./Ks;
Lo=(g*Tp.^2)/(2*pi);

% Estimate the beach steepness from the input profile.  Use the slope of
% the section between the shoreline and the back beach feature to be
% consistent with the cliff failure methodology (mhw to mhhw).
beta=(1.6-1.3)/(d_bb-s_d);
setup=0.35*beta.*sqrt(Ho.*Lo);
S_inc=0.75*beta.*sqrt(Ho.*Lo);
S_IG=0.06.*sqrt(Ho.*Lo);
S=sqrt((S_inc.^2)+(S_IG.^2));
R2=1.1*(setup+(S/2));
max_R2=max(R2);