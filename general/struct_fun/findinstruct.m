function n=findinstruct(h,fld1,val1,varargin)
%FINDINSTRUCT   find struct indices where field has value (numeric fields)
%
% n=findinstruct(h,fld1,val1)
% n=findinstruct(h,fld1,val1,fld2,val2)
%
% finds indices n in multidimensional struct S
% where field fld1 has the value val1.
%
% Example:
%
%   S(1).name   = 'mercury';
%   S(2).name   = 'venus';
%   S(3).name   = 'mars';
%   S(4).name   = 'earth';
%   
%   S(1).sequence  = 1;
%   S(2).sequence  = 2;
%   S(3).sequence  = 3;
%   S(4).sequence  = 4;
%   
%   findstrinstruct(S,'name'    ,'venus')
%   findinstruct   (S,'sequence',2)
%
%See also: STRMATCH, FINDSTRINSTRUCT

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

% $Id: findinstruct.m 316 2009-03-31 15:29:26Z boer_g $
% $Date: 2009-03-31 23:29:26 +0800 (Tue, 31 Mar 2009) $
% $Author: boer_g $
% $Revision: 316 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/findinstruct.m $
% $Keywords$

% 2009 mar 30: added comments [Gerben de Boer]

       n    = [];
       flds = fieldnames(h);
       c0   = struct2cell(h);
   
       ii1  = strmatch(fld1,flds,'exact');
       c1   = squeeze(c0(ii1,1,:));
   
   if nargin==3
       m1   = squeeze(cell2mat(c1));
       n    = find(m1==val1);
   else
       fld2 = varargin{1};
       val2 = varargin{2};
       m1   = squeeze(cell2mat(c1));
   
       ii2  = strmatch(fld2,flds,'exact');
       c2   = squeeze(c0(ii2,1,:));
       m2   = squeeze(cell2mat(c2));
   
       n    = find(m1==val1 & m2==val2);
   end

%% EOF
