function mask=vs_mask(C,varargin);
%VS_MASK   Read active/inactive mask of Delft3D results in trim- or com-file.
%
%   centermask = vs_mask(NFStruct,<timeindex>,<keyword,value>);
%
%   By default timeindex is the last time step, timeindex
%   can also be a vector. Set to 0 for all times.
%   The 1st dimension of centermask is time
%
%   Keyword/value pairs are:
%
%   * datatype:
%     - 'd<oubles>'   0/NaN   for inactive/active cells for multiplication (default)
%       'r<eal>'      
%     - 'b<oolean>'   0/  1   for inactive/active cells for logical indexing    
%       'l<ogical>'   
%     - 'i<ndex>'     index   for active cells for 1D indexing like in x(:)
%       'i<nteger>'   
%
% See also: VS_USE, VS_GET, VS_LET, VS_DISP, VS_TIME, VS_MESHGRID *, 
%           IND2SUB, SUB2IND, FIND

%   * timedim: by default the 1st dimension is time, with this value
%              you can choose.

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

% $Id: vs_mask.m 2413 2010-04-06 10:26:26Z boer_g $
% $Date: 2010-04-06 18:26:26 +0800 (Tue, 06 Apr 2010) $
% $Author: boer_g $
% $Revision: 2413 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_mask.m $

% C is the NFS struct handle as returned by C = vs_use(...)

   %% Input
   %% --------------------

   if odd(nargin)
     NFS=vs_use('lastread');
     switch vs_type(C),
     case 'Delft3D-com',
       Info = vs_disp(C,'CURTIM',[]);
       t    = Info.SizeDim;
     case 'Delft3D-trim',
       Info = vs_disp(C,'map-series',[]);
       t    = Info.SizeDim;
     end;
     i = 1; % argument counter
   elseif ~odd(nargin)
     if isstruct(C),
      t     = varargin{1};
     else,
        error('syntax centermask = vs_mask(NFStruct,<timeindex>,<keyword,value>);')
     end;
     i = 2; % argument counter
   end;
   
   %% Input
   %% --------------------
   datatype = 'real';
   while i<=nargin-2,
     if ischar(varargin{i}),
       switch lower(varargin{i})
       case 'datatype'   ;i=i+1;datatype    = varargin{i};
       otherwise
          error(sprintf('Invalid string argument: %s.',varargin{i}));
       end
     end;
     i=i+1;
   end;   
   
   
   %% Read velocity masks
   %% --------------------
   switch vs_type(C),
   case 'Delft3D-com',
     kfu = vs_let(C,'KENMTIM'   ,{t},'KFU','quiet');
     kfv = vs_let(C,'KENMTIM'   ,{t},'KFV','quiet');
   case 'Delft3D-trim',
     kfu = vs_let(C,'map-series',{t},'KFU','quiet');
     kfv = vs_let(C,'map-series',{t},'KFV','quiet');
   otherwise,
     error('Invalid NEFIS file for this action.');
   end;
   
   %% Apply velocity masks
   %% with loop over times
   %% --------------------

   if t==0
      t = 1:Info.SizeDim;
   end

   if     strcmp(lower(datatype(1)),'i') | ...
          strcmp(lower(datatype(1)),'i') ; % index for 1D indexing
      mask = cell(length(t));
   elseif strcmp(lower(datatype(1)),'r') | ...
          strcmp(lower(datatype(1)),'d') ; % real/double for multipliation
      mask = repmat(1.0,size(kfu));
   elseif strcmp(lower(datatype(1)),'l') | ...
          strcmp(lower(datatype(1)),'b') ; % logical/boolean for logical indexing
      mask = repmat(true,size(kfu));
   end

   for it=1:length(t)
   
      kfu_now  = kfu(it,:,:);
      kfv_now  = kfv(it,:,:);

      %% alghorithm below from actzwl.m by B. Jagers, WL | Delft Hydraulics
      
      kfu_now  = conv2([double(kfu_now(:,1)>0) double(kfu_now(:,:)>0)],[1 1],'valid');
      kfv_now  = conv2([double(kfv_now(1,:)>0);double(kfv_now(:,:)>0)],[1;1],'valid');
      
      if     strcmp(lower(datatype(1)),'i') | ...
             strcmp(lower(datatype(1)),'i') ; % index for 1D indexing
         
             mask_now                             = repmat(true,size(kfu_now));
             mask_now(it,kfu_now==0 & kfv_now==0) = false;
             
             %% make indices form booleans
             mask{it} = find(mask_now);
      
      elseif strcmp(lower(datatype(1)),'r') | ...
             strcmp(lower(datatype(1)),'d') ; % real/double for multipliation
             
             mask(it,kfu_now==0 & kfv_now==0) = NaN;
             
      elseif strcmp(lower(datatype(1)),'l') | ...
             strcmp(lower(datatype(1)),'b') ; % logical/boolean for logical indexing
             
             mask(it,kfu_now==0 & kfv_now==0) = false;
             
      end   
   end


