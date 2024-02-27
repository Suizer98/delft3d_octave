function WAQarray = flow2waq3D(FLOWarray,couplingarray,varargin)
%FLOW2WAQ3D   Maps 3D FlOW matrix to 1D WAQ array
%
% WAQarray = flow2waq3D(FLOWarray,couplingarray,<keyword,value>)
%
% where couplingarray comes from flow2waq3d_coupling(f.cco.Index)
% and f.cco.Index = Delwaq('open','*.lga') or 
% Delwaq('open','*.cco').
%
% Note 1: you should have included the standard Delft3D FLOW 
%         dummy rows and columns at first and last rows and columns 
%         of your matrix, if not add them with:
%         delft3dmatrix = addrowcol(active_center_points_matrix,[-1 1],[-1 1],nan)
%
% Note 2: The 1st dimension of FLOWarray should be n,
%         the 2nd dimension m
%         the 3rd dimension k
%
% Implemented <keyword,value> pairs are:3
% * number_of_messages:   default 10, displays every 100/10=10 % progress
%
% See also:
% FLOW2WAQ3D_COUPLING, WAQ2FLOW2D, WAQ2FLOW3D, DELWAQ,DELWAQ_MESHGRID2DCORCEN

% 2008, Oct 08: Added field 'nmk' [GJdB]
% 2008, Dec 19: Added setproperty [GJdB]
% 2009, Jan 12: Removed double .i(fldname) adressing [Claire van Oeveren]

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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: flow2waq3d.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/flow2waq3d.m $

   nWAQ = length(couplingarray);
   
   %% Options
   %% ------------------
   
   % TODO: allow for other inout matrix shape ([nxm] and [mxn])

   OPT.number_of_messages = 10;
   OPT.disp               = 0;
   OPT                    = setproperty(OPT, varargin{:});

   if isfield(couplingarray,'i') | isfield(couplingarray,'nmk')
   
   %% 1D indexing  
   %% ------------------
   
      if isfield(couplingarray,'i') | isfield(couplingarray,'nmk')
          
         if     isfield(couplingarray,'i')
             fldname = 'i';
         elseif isfield(couplingarray,'nmk')
             fldname = 'nmk';
         end
             
         for iWAQ=1:length(couplingarray)
         
            iFLOW          = round(couplingarray(iWAQ).(fldname));
         
            WAQarray(iWAQ) = nanmean(FLOWarray(iFLOW));
            
            if OPT.disp
            if mod(iWAQ,round((nWAQ/OPT.number_of_messages)))==1
               disp(['flow2waq3D finished :',num2str(round(100*iWAQ/nWAQ)),' %'])
            end
            end
         
         end % for iWAQ=1:length(couplingarray)
      
      end % if isfield(couplingarray,'i') | isfield(couplingarray,'nmk')
   
   elseif (isfield(couplingarray,'m') & ...
           isfield(couplingarray,'n') & ...
           isfield(couplingarray,'k'))
           
   %% 3D indexing        
   %% ------------------
   
      for iWAQ=1:length(couplingarray)
      
         mFLOW = round(couplingarray(iWAQ).m);
         nFLOW = round(couplingarray(iWAQ).n);
         kFLOW = round(couplingarray(iWAQ).k);
      
         temporary = 0.*mFLOW;
         for i = 1:length(mFLOW)
            temporary(i) =FLOWarray(nFLOW(i),mFLOW(i),kFLOW(i));
         end
         
         WAQarray(iWAQ) = nanmean(temporary);
         
         if OPT.disp
         if mod(iWAQ,round((nWAQ/OPT.number_of_messages)))==1
            disp(['flow2waq3D finished :',num2str(round(100*iWAQ/nWAQ)),' %'])
         end
         end
         
      end % for iWAQ=1:length(couplingarray)
   
   elseif (isfield(couplingarray,'m') & ...
           isfield(couplingarray,'n'))
   
   %% 2D indexing        
   %% ------------------
   
      for iWAQ=1:length(couplingarray)
      
         mFLOW = round(couplingarray(iWAQ).m);
         nFLOW = round(couplingarray(iWAQ).n);
      
         temporary = 0.*mFLOW;
         for i = 1:length(mFLOW)
            temporary(i) =FLOWarray(nFLOW(i),mFLOW(i));
         end
         
         WAQarray(iWAQ) = nanmean(temporary);
      
         if OPT.disp
         if mod(iWAQ,round((nWAQ/OPT.number_of_messages)))==1
            disp(['flow2waq3D finished :',num2str(round(100*iWAQ/nWAQ)),' %'])
         end
         end
         
      end % for iWAQ=1:length(couplingarray)
   
   end % isfield(couplingarray,...)
   
%% EOF