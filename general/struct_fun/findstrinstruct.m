function n=findstrinstruct(h,fld1,val1,varargin)
%FINDSTRINSTRUCT   find struct indices where field has value (character fields)
%
% n=findstrinstruct(S,fld1,val1)
% n=findstrinstruct(S,fld1,val1,fld2,val2)
%
% finds indices n in multidimensional struct S
% where field fld1 has the value val1.
%
% Example:
%
%   S(1).name  = 'Huey';
%   S(2).name  = 'Dewey';
%   S(3).name  = 'Louie';
%   
%   S(1).color = 'red';
%   S(2).color = 'blue';
%   S(3).color = 'green';
%   
%   findstrinstruct(S,'name','Louie')
%   findstrinstruct(S,'name','Louie','color','green')
%   findstrinstruct(S,'name','Louie','color','red')
%
%See also: STRMATCH, FINDINSTRUCT

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: findstrinstruct.m 2511 2010-05-06 12:28:15Z boer_g $
% $Date: 2010-05-06 20:28:15 +0800 (Thu, 06 May 2010) $
% $Author: boer_g $
% $Revision: 2511 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/findstrinstruct.m $
% $Keywords$

% 2009 mar 30: added comments [Gerben de Boer]

      h = h(:)'; % allow for both (1,3) and S(3,1)

      n     = [];
      flds  = fieldnames(h);
      c0    = struct2cell(h);
   
      ii1   = strmatch(fld1,flds,'exact');
      c1    = c0(ii1,1,:);
       
   if nargin==3
       n    = strmatch(val1,c1,'exact');
   else
       fld2 = varargin{1};
       val2 = varargin{2};

       hhh  = strmatch(val1,c1,'exact');

       ii2  = strmatch(fld2,flds,'exact');
       c2   = c0(ii2,1,:);
       iii  = strmatch(val2,c2,'exact');

       n    = intersect(hhh,iii);
   end

%% EOF