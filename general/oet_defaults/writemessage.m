function varargout = writemessage(code, text)
%WRITEMESSAGE writes message codes and text into a stored variable
%
%This function remembers messages and message codes that can be stored
%during the execution of multiple functions. All messages can be recalled
%or reset using the same function.
%
%syntax:
%   writemessage('init');
%   writemessage(msgcode, msgtext);
%   outp = writemessage(msgcode, msgtext);
%   outp = writemessage('get');
%
%input:
%   'init'  -   clears all stored messages and message codes.
%   'get'   -   retrieves the variable outp in which all messages and codes
%               are stored.
%   msgcode -   code of the message (numeric)
%   msgtext -   message text
%
%output:
%   outp    -   an n-by-2 cell array with the stored message codes in
%               column one and text messages in column 2. 
%
%See also persistent

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

% $Id: writemessage.m 188 2009-02-06 14:31:52Z heijer $ 
% $Date: 2009-02-06 22:31:52 +0800 (Fri, 06 Feb 2009) $
% $Author: heijer $
% $Revision: 188 $

%% Call persistent variable
persistent MessageVar;

%% Read input
if ischar(code)
    switch code
        case 'init'
            MessageVar = {};
        case 'get'
            varargout = {MessageVar};
        otherwise
            disp('incorrect input argument');
    end
    return
end

%% Determine line
id = size(MessageVar,1)+1;

%% Write message

% % retrieve invoking function information
% mfilestr=dbstack(1);

%write
MessageVar{id,1}=code;
MessageVar{id,2}=text;

%% Create output, only if an output argument is requested or code is 'get' 
if nargout == 1 || strcmp(code, 'get')
    varargout = {MessageVar};
end

%% Display message
if dbstate
    guidisp(text);
end