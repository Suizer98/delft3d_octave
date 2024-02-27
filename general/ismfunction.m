function tf = ismfunction(fname)
%ISMFUNCTION  Determines whether the specified function is a matlab function
%
%   This function checks whether the specified function is inside one of
%   the subdirs of the matlabroot.
%
%   Syntax:
%   tf = ismfunction(fname)
%
%   Input:
%   fname  = Name of a function.
%
%   Output:
%   tf     = true if the function is in one of the subdirs of the
%            matlabroot.
%            false if the function was not found in one of the subdirs of
%            the matlabroot
%
%   Example
%   ismfunction publish
%   ismfunction ismfunction
%   tf = ismfunction('plot');
%
%   See also exist matlabroot isa

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       <ADDRESS>
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

% Created: 08 May 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: ismfunction.m 449 2009-05-08 15:09:02Z geer $
% $Date: 2009-05-08 23:09:02 +0800 (Fri, 08 May 2009) $
% $Author: geer $
% $Revision: 449 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/ismfunction.m $
% $Keywords: $

%% Check function
% Check wheter the matlabroot is part of the location of the functionname.
% If the function is not found, which(fname) is empty and tf will be false.

tf = ~isempty(strfind(which(fname),matlabroot));