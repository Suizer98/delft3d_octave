function [fhandle fl fname] = checkfhandle(fhandle)
% CHECKFHANDLE check whether input argument is a valid function handle
%
% 
%
% Syntax:
% [fhandle fl fname] = checkfhandle(fhandle)
%
% Input:
%
% Output:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: checkfhandle.m 6244 2012-05-25 09:05:26Z heijer $ 
% $Date: 2012-05-25 17:05:26 +0800 (Fri, 25 May 2012) $
% $Author: heijer $
% $Revision: 6244 $

%%
fl = true;
if ischar(fhandle) && isvector(fhandle) && strcmp(fhandle(1), '@')
    fhandle = str2func(fhandle);
end
if ~isa(fhandle, 'function_handle')
    [path fname] = fileparts(fhandle);
    exid = exist(fhandle);
    switch exid
        case 0
            disp(['The function specified ("' fhandle '") could not be found.']);
            fl = false;
        case 1
            disp(['The function specified ("' fhandle '") turned out to be a variable in the current workspace as well.']);
            fl = false;
        otherwise
            try
                fhandle = eval(['@' fname]);
            catch
                fhandle = [];
            end
                
            if ~isa(fhandle, 'function_handle')
                disp(['The function specified ("' fname '") could not be found.']);
                fl = false;
            end
    end
else
    fname = char(fhandle);
end
