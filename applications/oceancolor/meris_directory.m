function varargout = meris_directory(directory,varargin)
%MERIS_DIRECTORY   retrieves all image and SIOP names from directory with meris images
%
%  IMAGE_names             = MERIS_DIRECTORY(directory,<extension>)
% [IMAGE_names,SIOP_names] = MERIS_DIRECTORY(directory,<extension>)
%
% Example: a directory with the following 3 files:
%
%   MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089Belgica2000SubT.mat
%   MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089Restwes99Oroma02SubT.mat
%   MER_RR__2CQACR20050403_091134_000026242036_00079_16165_0000_hydropt74.mat
%   12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
%            11111111112222222222333333333344444444445555555555666666666677777777778888888888 
% would give 1 NAME (first 59 identical characters) and 3 SIOPS:
%
%   IMAGE_names = {'MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089'};
%   SIOP_names  = {'Belgica2000SubT','Restwes99Oroma02SubT','_hydropt74'};
%
% The default for the optional <extension> is '.mat'.
%
%See also: MERIS_NAME2META, MERIS_FLAGS, MERIS_MASK, findAllFiles

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
% $Id: meris_directory.m 5473 2011-11-14 11:23:49Z boer_g $
% $Date: 2011-11-14 19:23:49 +0800 (Mon, 14 Nov 2011) $
% $Author: boer_g $
% $Revision: 5473 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_directory.m $
% $Keywords: $

      ext = '.mat';
   if nargin>1
      ext = varargin{1};
   end
   
   S.filenames = dir([directory,filesep,'MER*',ext]);
   S.n         = length(S.filenames);
  
   %% Check for double occurences of images after removal of extensions (SIOPS)
   
   iname       = 0;
   isiop       = 0;
   
   NAMEs = [];
   SIOPs = [];

   for ifile=1:length(S.filenames)
   
      meris.name = S.filenames(ifile).name( 1:59 );
      meris.siop = S.filenames(ifile).name(60:end);
      
      if iname==0
      
         NAMEs{1} = meris.name;
         iname    = 1;
   
      else
      
         if ~any(strcmp(NAMEs,meris.name))
            iname         = iname + 1;
            NAMEs{iname} = meris.name;
         end
   
      end
      
      %% Check for double occurences of extensions (SIOPS)

         if ~isempty(meris.siop)
         
            if isiop==0
   
               SIOPs{1}   = meris.siop;
               isiop      = 1;
               
            else
         
               if ~any(strcmp(SIOPs,meris.siop))
                  isiop        = isiop+ 1;
                  SIOPs{isiop} = meris.siop;
               end
            
            end
            
         end
   
   end
   
   %% Output

   if nargout<2
      varargout = {NAMEs};
   else
      varargout = {NAMEs,SIOPs};
   end

%% EOF