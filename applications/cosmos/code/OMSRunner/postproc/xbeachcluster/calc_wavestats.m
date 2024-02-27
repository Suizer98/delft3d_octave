function [t,Dp,Tp,Hs] = calc_wavestats(inputdir)

% calc_wavestats.m:  This program reads in the timeseries of SWAN spectral
% files at the 10 m contour for the MOP station and calculates bulk
% parameters.

%    usage:  [Dp,Tp,Hs,dt]=calc_wavestats(inputdir);
%
%   Input:
%         inputdir - directory path where input data files are stored
%                (ex: 'M:\Coastal_Hazards\Xbeach\post_xbeach\');
%   Output:
%         Hs - timeseries of significant wave height
%         Tp - timeseries of peak wave period
%         Dp - timeseries of peak wave direction
%         dt - time 

% JLE 4/21/10
% Read in the list of spectral filenames.
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
%           tmp = sscanf(line,'%s');
           [aaa,bbb,ccc]=strread(deblank(line),'%f%f%s','delimiter',' ');
           specfile{nt,1}=ccc;
           dtcum=dtcum+aaa;
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

%Now, read in each individual spectral files and get the peak period,
%wave height, and peak direction from the spectral information.
for ii=1:length(specfile)
%    out = readSwan2DSpec([inputdir,char(specfile(ii))]);
    out=readSP2([inputdir,char(specfile{ii})]);
    
    t(ii)=out.time.time;
    out.s(1,:,:)=out.time.points.Factor*out.time.points.energy;
    out.f=out.Freqs;
    out.d=out.dirs';
    
    % Convert the spectral data from energy density to variance units.
    out.sfix=(out.s.*2)./(row*g);
    % Sum the energy over each direction to get the 1D Spectra
    dirres=abs(out.d(2)-out.d(1));
    S1d=sum(out.sfix,3)*dirres;
    % Calculate Hs from the 1D spectra
    fi = [out.f(1):min(diff(out.f)):out.f(end)]';
    Hs(ii) = 4*sqrt(trapz(trapz(interp2(out.d,out.f,squeeze(out.sfix(1,:,:)),out.d,fi')))*(fi(2)-fi(1))*abs(out.d(2)-out.d(1)));
    % Find the frequency with the maximum energy
    imax=find(S1d==max(S1d));
    imax=imax(1);
    Tp(ii)=1/out.f(imax);
    [id,jd]=find(squeeze(out.sfix)==max(max(out.sfix)));
    id=id(1);
    jd=jd(1);
    Dp(ii)=out.d(jd);
    clear out fi
end