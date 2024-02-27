function varargout=delft3d_io_bch(cmd,varargin),
%DELFT3D_IO_BCH   read/write open boundaries (*.bch) <<beta version!>>
%
%  D = delft3d_io_bch('read'  ,filename);
%       delft3d_io_bch('write',filename,D);
%
% where D has fields:
%
%   D.phases     (n_endpoints x n_boundaries x n_frequencies) in [deg]
%   D.amplitudes (n_endpoints x n_boundaries x n_frequencies) in [data units]
%   D.a0         (n_endpoints x n_boundaries                ) in [data units]
%   D.frequencies(                             n_frequencies) in [deg/hr]
%
% Note length(D.frequencies) can be (n_frequencies+1) if frequencies(1)=0 to represent a0.
%
% See also: delft3d_io_bca, delft3d_io_bnd,delft3d_io_fou, delft3d_io_mdf, tide

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: delft3d_io_bch.m 11849 2015-04-03 08:51:15Z huism_b $
% $Date: 2015-04-03 16:51:15 +0800 (Fri, 03 Apr 2015) $
% $Author: huism_b $
% $Revision: 11849 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_bch.m $

if nargin ==1
   error(['AT least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
end

switch lower(cmd),
    
case 'read',
  S=Local_read(varargin{:});
  if nargout ==1
     varargout = {S};
  elseif nargout >1
     error('too much output paramters: 0 or 1');
  end
  if S.iostat<0,
     disp(['Error opening file: ',varargin{1}]);
     S.iostat = -1;
  end;
  
case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output paramters: 0 or 1');
  end
  if iostat<0,
     error(['Error writing file: ',varargin{1}]);
  end;
end;

%% ------------------------------------

function S=Local_read(varargin),

S.filename  = varargin{1};

fid              = fopen(S.filename,'r');
if fid==-1
   S.iostat = fid;
else
   S.iostat = -1;
   i             = 0;
   
   % READ FREQUENCIES 
   % ALSO SUBSEQUENT LINES ARE SCANNED (SINCE DELFT3D STORES FREQUENCY AT LINE 2 ETC)
   readFREQ=1;
   S.frequencies = [];
   while readFREQ
       freq0 = str2num(fgetl(fid));
       S.frequencies = [S.frequencies,freq0];
       if isempty(freq0)
          readFREQ = 0;
       end
   end
   S.data        = fscanf(fid,'%f');
   
   S.nof    = length(S.frequencies);
   frequency0    = find(S.frequencies==0);
   frequencyrest = find(~(S.frequencies==0));
   n_freq_data0  = length(frequency0);
   S.nobnd  = prod(size(S.data))./(2*S.nof-n_freq_data0)/2;
   
%% Read constant a0 (frequency = 0)

   indexa01 = [                            1:...
                                S.nof  :...
                  S.nobnd.*S.nof  ] + frequency0-1;   
   indexa02 = [   S.nobnd.*S.nof+1:...
                                S.nof  :...
               2.*S.nobnd.*S.nof  ] + frequency0-1;   

   S.a0(1,:,:) = S.data(indexa01);   
   S.a0(2,:,:) = S.data(indexa02);   
   
%% Remove constant a0 (frequency = 0)

   S.data(indexa01)=nan;
   S.data(indexa02)=nan;
   S.data = S.data(~isnan(S.data));
   
%% Read amplitudes
 
   amplitudesA = S.data(                                           1:...
                                (S.nof-n_freq_data0).*S.nobnd  );
   amplitudesB = S.data(   (S.nof-n_freq_data0).*S.nobnd+1:...
                             2.*(S.nof-n_freq_data0).*S.nobnd  );
   
   S.amplitudes(1,:,:) = reshape(amplitudesA,[(S.nof-n_freq_data0),S.nobnd])';
   S.amplitudes(2,:,:) = reshape(amplitudesB,[(S.nof-n_freq_data0),S.nobnd])';
   
   offset =2*S.nobnd*(S.nof-n_freq_data0);
   
%% Read phases
   
   phasesA = S.data(                                               1+offset:...
                                (S.nof-n_freq_data0).*S.nobnd  +offset);
                                
   phasesB = S.data(       (S.nof-n_freq_data0).*S.nobnd+1+offset:...
                             2.*(S.nof-n_freq_data0).*S.nobnd  +offset);
   
   S.phases(1,:,:) = reshape(phasesA,[(S.nof-n_freq_data0),S.nobnd])';
   S.phases(2,:,:) = reshape(phasesB,[(S.nof-n_freq_data0),S.nobnd])';

   S.iostat   = 1;
   S.NTables  = i;
end

%% ------------------------------------

function iostat=Local_write(filename,S),

iostat             = 1;
fid                = fopen(filename,'w');
OPT.OS             = 'windows'; % or 'unix'
OPT.fprintf_format = ' %9.6g'; % note leading space !
OPT.fprintf_spaces = '          '; % align with same width as fprintf_format

 %% A0: already in frequencies e.g. after delft3d_io_bch('read',...)

   if isfield(S,'a0')
       
       if ~(S.frequencies(1)==0 & (size(S.amplitudes,3)+1==length(S.frequencies)))
        S.frequencies = [0 S.frequencies];
       end
   end

%% FREQUENCIES

   fprintf(fid,OPT.fprintf_format,S.frequencies); % extra space before value: ' %9.6f'
   fprinteol(fid,OPT.OS(1))
   fprinteol(fid,OPT.OS(1))

%% AMPLITUDES and A0

   for i=1:size(S.amplitudes,1)
      for j=1:size(S.amplitudes,2)
         if isfield(S,'a0')
         fprintf(fid,OPT.fprintf_format,S.a0        (i,j,1)); % extra space before value: ' %9.6f'
         end
         fprintf(fid,OPT.fprintf_format,S.amplitudes(i,j,:)); % extra space before value: ' %9.6f'
         fprinteol(fid,OPT.OS(1))
      end
   end;

   fprinteol(fid,OPT.OS(1))
   
%% PHASES

   for i=1:size(S.phases,1)
      for j=1:size(S.phases,2)
         if isfield(S,'a0')
         fprintf(fid,OPT.fprintf_spaces);
         end
         fprintf(fid,OPT.fprintf_format,S.phases(i,j,:)); % extra space before value: ' %9.6f'
         fprinteol(fid,OPT.OS(1))
      end
   end;
   
   fprinteol(fid,OPT.OS(1))

fclose(fid);
iostat=1;
