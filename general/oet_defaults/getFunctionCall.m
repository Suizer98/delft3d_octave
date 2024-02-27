function [str funinfo] = getFunctionCall(fun)
%GETFUNCTIONCALL  isolates the function call from a function file
%
% It looks for the first not commented line containing a function
% statement. Also function calls that are continued on the next line will
% be concatenated. Nested functions are not yet supported.
%
% syntax:
%       [str funinfo] = getFunctionCall(fun);
%
%   input:
%       fun     -   this can be either a string containing the name or
%                   filename of a function or a function handle.
%
%   output:
%       str     -   the function call as a sting
%       funinfo -   additional information about this function
%
%   See also functions checkfhandle

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

% $Id: getFunctionCall.m 6244 2012-05-25 09:05:26Z heijer $
% $Date: 2012-05-25 17:05:26 +0800 (Fri, 25 May 2012) $
% $Author: heijer $
% $Revision: 6244 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/getFunctionCall.m $
% $Keywords: $

%% check input
if nargin==0
    error('This function needs a function name or handle as input');
end

%% check function existence and get function handle
[fun fl fname] = checkfhandle(fun);

%% if input argument is a function, retrieve the function call
if fl
    funinfo = functions(fun);

    if strcmp(funinfo.file, 'MATLAB built-in function')
        warning([fname ' is a MATLAB built-in function, ' mfilename ' is not able to get the function call.'])
        str = '';
    elseif strcmp(funinfo.type, 'anonymous')
        str = funinfo.function;
    elseif isempty(funinfo.file)
        str = '';
    else
        % open the m-file and read text
        fid = fopen(funinfo.file);
        str = fread(fid, '*char')';
        fclose(fid);
        
        % remove comments
        matches = regexp(str, '\%.*', 'match', 'dotexceptnewline');
        for imatch = 1:length(matches)
            str = strrep(str, matches{imatch}, '');
        end
        
        % remove line breaks
        matches = regexp(str, '[\.]{3}.*?\r?\n\s', 'match', 'dotall');
        for imatch = 1:length(matches)
            str = strrep(str, matches{imatch}, '');
        end
        
        % find function call
        [matches names] = regexp(str, ['\s*function\s*(?<call>.*?' funinfo.function '.*?$)'], 'match', 'names', 'lineanchors', 'dotexceptnewline');
        
        if ~isempty(matches)
            str = strtrim(names.call);
            % remove possible occuring multiple spaces
            matches = regexp(str, '\s*', 'match');
            for imatch = 1:length(matches)
                str = strrep(str, matches{imatch}, ' ');
            end
        else
            str = '';
        end
    end
    % write call string to output struct
    funinfo.call = str;
else
    error('GETVARIABLES:NotExistingFile',['File ', fun, ' does not exist'])
end