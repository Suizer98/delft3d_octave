function varargout = vs_let_statistics(NFSstruct,GroupName,GroupIndex,varargin)
%VS_LET_STATISTICS  extract temporal mean,std,max, min of any delft3d NEFIS variable
%
%  [mean]             = vs_let_statistics(NFStruct,GroupName,GroupIndex,"...")
%  [mean,std]         = vs_let_statistics(NFStruct,GroupName,GroupIndex,"...")
%  [mean,std,max,min] = vs_let_statistics(NFStruct,GroupName,GroupIndex,"...")
%
% calculates the mean and optionally the standard_deviation,max,min over 
% all time steps of GroupIndex. If GroupIndex is {[0]} all times
% are taken into account. The size of the statistical arrays
% mean,std,max,min is determined by what is passed for "...".
%
% Note these properties can more accurately be determined with 
% online Fourier analysis inside Delt3D that takes all time steps
% into account, instead of only the ones stored for map output.
%
% Example:
%
%    NFStruct   = vs_use('F:\DELFT3D\PROJECT\trim-RID.dat');
%    GroupIndex = [1:13]; % i.e. all time steps
%    GroupName  = 'map-series';
%    
%    D.mask = vs_let(NFStruct,'map-const','KCS','quiet'); D.mask(D.mask~=1) = NaN;
%    D.x    = vs_let(NFStruct,'map-const','XZ' ,'quiet').*D.mask;
%    D.y    = vs_let(NFStruct,'map-const','YZ' ,'quiet').*D.mask;
%    I      = vs_get_constituent_index(NFStruct,'salinity');
%   [D.avg,D.std,D.max,D.min] = vs_let_statistics(NFStruct,GroupName,{GroupIndex},'R1',{0,0,1,I.index},'quiet');
%    pcolorcorcen(D.x,D.y,D.avg(1,:,:,1));
%    caxis([25 34.5])
%    axis equal
%    tickmap('xy')
%    colorbarwithhtext('avg salinity [psu]','horiz')
%
%See also: VS_LET, AVG, STD, MIN, MAX, DELFT3D_IO_FOU

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Technische Universiteit Delft;Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl;gerben.deboer@deltares.nl
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_let_statistics.m 6845 2012-07-10 10:46:33Z boer_g $
%  $Date: 2012-07-10 18:46:33 +0800 (Tue, 10 Jul 2012) $
%  $Author: boer_g $
%  $Revision: 6845 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_let_statistics.m $
%  $Keywords: $

   if ischar(NFSstruct)
      NFSstruct = vs_use(NFSstruct);
   end

   times = cell2mat(GroupIndex);
   if times==0
      times = 1:vs_get_grp_size(NFSstruct,GroupName);
   end
   n   = length(times);

   %% loop
   %  http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Na.C3.AFve_algorithm
   first = 1;
   for it=times
       
     disp([num2str(it,'%0.4d'),'/',num2str(n,'%0.4d')]);
   
     data = vs_let(NFSstruct,GroupName,{it},varargin{:});
   
     if first
       vs_avg   = data;
     else
       vs_avg   = data + vs_avg;
     end
     
     if nargout>1
     if first
       vs_std   = data.^2;
     else
       vs_std   = data.^2 + vs_std;
     end
     end
     
     if nargout>2
     if first
       vs_max   = data;
     else
       vs_max(:)= max(data(:),vs_max(:));
     end
     end  
     
     if nargout>3
     if first
       vs_min   = data;
     else
       vs_min(:)= min(data(:),vs_min(:));
     end
     end
     
       first    = 0;
     
   end
   
   %% wrap up
   vs_avg = vs_avg./n;
   if nargout>1
   vs_std = sqrt(vs_std - n.*vs_avg.^2)./n; % /(n-1)
   end
   
   %% out
   if nargout==1
      varargout  = {vs_avg};
   elseif nargout==2
      varargout  = {vs_avg,vs_std};
   elseif nargout==3
      varargout  = {vs_avg,vs_std,vs_max};
   elseif nargout==4
      varargout  = {vs_avg,vs_std,vs_max,vs_min};
   end