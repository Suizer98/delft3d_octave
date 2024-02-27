function varargout=vs_mnk(varargin),
%VS_MNK    Read the grid size from NEFIS file.
%
%                    vs_mnk(NFSstruct) Displays on mmax,nmax,kmax command line.
% G                = vs_mnk(NFSstruct) where G has fields 'mmax','nmax' and 'kmax'
% [mmax,nmax,kmax] = vs_mnk(NFSstruct)
%
% Implemented are trim-,com-,tram-,botm- and trih-file
%
%See also: VS_USE, VS_LET, VS_MESHGRID2D0, VS_MESHGRID2D, VS_MESHGRID3D

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: vs_mnk.m 2413 2010-04-06 10:26:26Z boer_g $
% $Date: 2010-04-06 18:26:26 +0800 (Tue, 06 Apr 2010) $
% $Author: boer_g $
% $Revision: 2413 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_mnk.m $

NFSstruct         = [];
OPT.issuewarnings = 0;

  if isstruct(varargin{1}),
    NFSstruct=varargin{1};
  else
    error('');
  end;

  if isempty(NFSstruct),
     NFSstruct=vs_use('lastread');
  end;
   
   switch vs_type(NFSstruct),

   % comfile
   % -----------------------------------

   case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},

     G.mmax          = vs_let(NFSstruct, 'GRID'     ,'MMAX', 'quiet');
     G.nmax          = vs_let(NFSstruct, 'GRID'     ,'NMAX', 'quiet');
     G.kmax          = vs_let(NFSstruct, 'GRID'     ,'KMAX', 'quiet');
                        
   % trimfile
   % -----------------------------------

   case 'Delft3D-trim',

     G.mmax          = vs_let(NFSstruct,'map-const','MMAX',  'quiet');
     G.nmax          = vs_let(NFSstruct,'map-const','NMAX',  'quiet');
     G.kmax          = vs_let(NFSstruct,'map-const','KMAX',  'quiet');
      
   % trihfile
   % -----------------------------------

   case 'Delft3D-trih',

     G.mmax          = nan;
     G.nmax          = nan;
     if OPT.issuewarnings
        disp('   mmax,nmax not stored in trih file')
     end
     G.kmax          = vs_let(NFSstruct,'his-const','KMAX',  'quiet');

   % wavem file
   % -----------------------------------

   case {'Delft3D-hwgxy'},

      tmp = vs_get_elm_size(NFSstruct,'CODE');
      G.mmax         = tmp(1);
      G.nmax         = tmp(2);
      G.kmax         = 1;

  otherwise,
    error('Invalid NEFIS file for this action, only trim, trih and com implemented.');
  end;

%% Return variables
%% ------------------------

   if     nargout == 0
      disp(['(mmax,nmax,kmax) = ',nums2str([G.mmax,G.nmax,G.kmax],' ',[])]);
   elseif nargout == 1
      varargout = {G};
   elseif nargout == 3
      varargout = {G.mmax,G.nmax,G.kmax};
   end
