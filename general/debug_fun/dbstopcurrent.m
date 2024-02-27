function dbstopcurrent(varargin)
%DBSTOPCURRENT
%
% Syntax:
% dbstopcurrent(varargin)
%
% Input:
%
% Output:
%
% See also: DBSTATE, DBSTOP, DBSTATUS, DBQUIT, DBUP, DBDOWN, DBCONT, DBCLEAR

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

% $Id: dbstopcurrent.m 267 2009-03-05 13:23:10Z boer_g $ 
% $Date: 2009-03-05 21:23:10 +0800 (Thu, 05 Mar 2009) $
% $Author: boer_g $
% $Revision: 267 $

%%
persistent stops

dblayer=2;
if isempty(stops)
    stops=struct('mfile',[],...
        'lineno',[]);
    stcount=1;
else
    stcount=length(stops)+1;
    if isempty(stops(1).mfile)
        stcount=length(stops);
    end
end

if nargin>0 && strcmpi(varargin{1},'clear')
    for i=1:length(stops)
        if ~isempty(stops(1).mfile)
            try
                eval(['dbclear in ' stops(i).mfile ' at ' num2str(stops(i).lineno)]);
            catch
                disp(['No breakpoint found in file ' stops(i).mfile ' at ' num2str(stops(i).lineno)]);
            end
        end
    end
    stops(:)=[];
else
    if nargin>0 && isnumeric(varargin{1})
        dblayer=dblayer+varargin{1};
    end
    a=dbstack;
    if length(a)>1
        stops(stcount).mfile=a(dblayer).name;
        stops(stcount).lineno=num2str(a(dblayer).line+1);
        eval(['dbstop in ' stops(stcount).mfile ' at ' stops(stcount).lineno]);
    end
end