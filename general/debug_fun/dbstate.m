function varargout = dbstate(varargin)
%DBSTATE sets and/or returns the a user debug state
%
% This routine sets and returns the user debug state. It can be used in
% functions to swicht between normal / debug mode without entering various
% breakpoints. This also enables the possibility to include parts in your
% code that only have to be executed when running in user debugmode.
%
% Syntax:       stop = dbstate(state);
%               dbstate on
%               dbstate off
%
% Input: 
%               state     = either 'on' or 'off' to switch debugmode on or
%                           off
%
% Output:       stop      = returns a logical value (true/false) indicating
%                           the user debug state.
%
% See also: dbstop, dbstatus, dbquit, dbup, dbdown, dbcont, dbclear

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

% $Id: dbstate.m 188 2009-02-06 14:31:52Z heijer $ 
% $Date: 2009-02-06 22:31:52 +0800 (Fri, 06 Feb 2009) $
% $Author: heijer $
% $Revision: 188 $

%% initiate debug indicator
persistent stp

%% if not specified yet, default value (false)
if isempty(stp)
    stp = false;
end

%% if input resambles 'on', set dbstate to true
if nargin > 0
    stp = strcmp(varargin{1},'on');
    if ~stp
        dbstopcurrent clear
    else
        dbstop if error
    end
end

%% if required, create output
if nargout>0 || nargin==0
    varargout{1} = stp;
end