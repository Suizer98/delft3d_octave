function guidisp(varargin)
% GUIDISP   guidisp
%
% 
%
% Syntax:
% guidisp(varargin)
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

% $Id: guidisp.m 266 2009-03-04 17:29:35Z boer_g $ 
% $Date: 2009-03-05 01:29:35 +0800 (Thu, 05 Mar 2009) $
% $Author: boer_g $
% $Revision: 266 $

%%
persistent hnd

gui=true;

if nargin>1 && ischar(varargin{1}) && strcmp(varargin{1},'set')
    if ischar(varargin{2})
        varargin{2}=findobj('Tag',varargin{2});
    end
    if ishandle(varargin{2})
        hnd=varargin{2};
        return
    else
        disp('Input is not an object handle.');
        hnd=[];
        return
    end
end

if nargin==1
    if ischar(varargin{1})
        str=varargin{1};
    end
    if isnumeric(varargin{1})
        str=num2str(varargin{1});
    end
    if ~exist('str','var')
        str=varargin{1};
    end
end

if isempty(hnd)
    gui=false;
    str=varargin{1};
end

if gui
    set(hnd,'String',[cellstr(str) ; cellstr(get(hnd,'String'))]);
    drawnow
else
    display(char(str));
end