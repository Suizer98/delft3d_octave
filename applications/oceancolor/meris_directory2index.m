function S = meris_directory2index(directory,varargin)
%MERIS_DIRECTORY2INDEX  retrieves meta-information from all MERIS filename in a directory.
%
% S = meris_directory2index(directory,<extension>)
%
% returns a struct with all MERIS filenames in a directory
% and the associated meta information and datenumbers (start + end of swath)
%
%    filenames: [582x1 struct]
%            n: 582
%         meta: [1x582 struct]
%      datenum: [582x2 double]
%
% The default for the optional <extension> is '.mat'.
%
%See also: MERIS_NAME2META, MERIS_FLAGS, MERIS_MASK

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Dec. Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: meris_directory2index.m 1933 2009-11-16 10:18:35Z boer_g $
% $Date: 2009-11-16 18:18:35 +0800 (Mon, 16 Nov 2009) $
% $Author: boer_g $
% $Revision: 1933 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_directory2index.m $
% $Keywords: $

      ext = '.mat';
   if nargin>1
      ext = varargin{1};
   end

   S.filenames = dir([directory,filesep,'*',ext]);
   S.n         = length(S.filenames);
   
   %% Get and group relevant meta info
   %------------------------------------

   for ifile=1:length(S.filenames)
   
      S.meta(ifile)      = meris_name2meta(S.filenames(ifile).name);
      S.datenum(ifile)   = S.meta(ifile).datenum(1);
      S.datenum(ifile,1) = S.meta(ifile).datenum(1);
      S.datenum(ifile,2) = S.meta(ifile).datenum(2);
      
   end


%% EOF