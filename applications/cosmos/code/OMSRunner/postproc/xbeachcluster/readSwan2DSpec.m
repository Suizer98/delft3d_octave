function out = readSwan2DSpec(specfile)


%readSwan2DSpec   Reads SWAN 2D Spectral input/output files.
%   OUT = readSwan2DSpec(SPECFILE) reads the SWAN 2D spectra
%   data in SPECFILE (full path and file name) and gives the locations 
%   (OUT.locs), frequencies (OUT.f), directions 
%   (OUT.d), and variance densities (OUT.s).
% 

% modified by JLE 12/3/09 for only one time and one location and to remove
% Hs calculation 


fid = fopen(specfile,'r');
dates = [];
nl = 1;
while 1
   line = fgetl(fid);
   % exit at end of file
   if ~ischar(line)
      break
   end
   % get the locations
   if strncmpi(line,'LOCATIONS',9)
      line = fgetl(fid);
      nlocs = sscanf(line,'%f');
      locs = [];
      for ii=1:nlocs
         line = fgetl(fid);
         tmp = sscanf(line,'%f');
         locs = [locs;tmp(1),tmp(2)];
      end
   end
   % get the frequencies
   if regexp(line,'^\wFREQ')
      %ftext = regexp(line,'^\wFREQ','match');
      line = fgetl(fid);
      nfreqs = sscanf(line,'%f');
      freqs = [];
      for ii=1:nfreqs
         line = fgetl(fid);
         tmp = sscanf(line,'%f');
         freqs = [freqs;tmp(1)];
      end
   end
   % get the directions
   if strncmpi(line,'CDIR',4) | strncmpi(line,'NDIR',4)
      %if strncmpi(line,'CDIR',4)
      %   dirs = 1;
      %else
      %   dirs = 2;
      %end
      dirs = [];
      line = fgetl(fid);
      ndirs = sscanf(line,'%f');
      for ii=1:ndirs
         line = fgetl(fid);
         tmp = sscanf(line,'%f');
         dirs = [dirs;tmp(1)];
      end
   end
   % read in the variance densities
   if strncmpi(line,'FACTOR',6)
      line = fgetl(fid);
      fact = sscanf(line,'%f');
      for ii=1:nfreqs
         line = fgetl(fid);
         tmp = sscanf(line,'%f');
         S(nl,ii,:) = fact*tmp';
      end
      if nl==nlocs
         nl = 1;
      else
         nl = nl + 1;
      end
   end
end
fclose(fid);


out = struct('locs',locs,'f',freqs,'d',dirs,'S',S); 