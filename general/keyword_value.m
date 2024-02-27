function [OPT Set Default] = keyword_value(OPT, varargin)
% KEYWORD_VALUE  generic routine to set values in keyword-value pairs
%
% Routine to set options based on keyword-value pairs. Can be used in any
% function where keyword-value pairs are used.
%   
% syntax:
% [OPT Set Default] = keyword_value(OPT, varargin)
%
% input:
% OPT      = structure in which fieldnames are the keywords and the values are the defaults 
% varargin = series of keyword-value pairs to set
%
% output:
% OPT     = structure, similar to the input argument OPT, with possibly
%           changed values in the fields
% Set     = structure, similar to OPT, values are true where OPT has been 
%           set (and possibly changed)
% Default = structure, similar to OPT, values are true where the values of
%           OPT are equal to the original OPT
%
% See also: setproperty

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
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

% $Id: keyword_value.m 2616 2010-05-26 09:06:00Z geer $ 
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $

%%
try
    TODO('Use setproperty instead of keyword_value', 1);
catch
    ST = dbstack(1);
    if ~isempty(ST)
        txt = sprintf('in <a href="matlab:opentoline(''%s'',%i)">%s</a> at line %i', ST(1).file, ST(1).line, ST(1).name, ST(1).line);
    else
        txt = '';
    end
    fprintf('Use setproperty instead of keyword_value %s', txt);
end
[OPT Set Default] = setproperty(OPT, varargin{:});
return

%%
keywords = fieldnames(OPT); % read keywords from structure fieldnames

% Set is similar to OPT, initially all fields are false
Set = cell2struct(repmat({false}, size(keywords)), keywords, 1);
% Default is similar to OPT, initially all fields are true
Default = cell2struct(repmat({true}, size(keywords)), keywords, 1);

[i0 iend] = deal(1, length(varargin)); % specify index of first and last element of varargin to search for keyword/value pairs
for iargin = i0:2:iend
    keyword = varargin{iargin};
    if any(strcmp(keywords, keyword))
        % set option
        if ~isequalwithequalnans(OPT.(keyword), varargin{iargin+1})
            % only renew property value if it really changes
            OPT.(keyword) = varargin{iargin+1};
            % indicate that this field is non-default now
            Default.(keyword) = false;
        end
        % indicate that this field is set
        Set.(keyword) = true;
    elseif any(strcmpi(keywords, keyword))
        % set option, but give warning that keyword is not totally correct
        realkeyword = keywords(strcmpi(keywords, keyword));
        if ~isequalwithequalnans(OPT.(realkeyword{1}), varargin{iargin+1})
            % only renew property value if it really changes
            OPT.(realkeyword{1}) = varargin{iargin+1};
            % indicate that this field is non-default now
            Default.(keyword) = false;
        end
        % indicate that this field is set
        Set.(realkeyword{1}) = true;
        warning([upper(mfilename) ':Keyword'], ['Could not find an exact (case-sensitive) match for ''' keyword '''. ''' realkeyword{1} ''' has been used.'])
    elseif ischar(keyword)
        % keyword unknown
        error([upper(mfilename) ':UnknownKeyword'], ['Keyword "' keyword '" is not valid'])
    else
        % no char found where keyword expected
        error([upper(mfilename) ':UnknownKeyword'], 'Keyword should be char')
    end
end