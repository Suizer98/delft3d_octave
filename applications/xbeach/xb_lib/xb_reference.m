function xb_reference(filename, varargin)
%XB_REFERENCE  Creates a WIKI page with a params.txt reference
%
%   Creates a WIKI page with a params.txt reference
%
%   Syntax:
%   xb_reference(filename, varargin)
%
%   Input:
%   filename  = Filename of generated file
%   varargin  = type:       Type of file (wiki)
%
%   Output:
%   none
%
%   Example
%   xb_reference('reference.txt')
%
%   See also xb_get_params

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_reference.m 5177 2011-09-06 07:14:19Z hoonhout $
% $Date: 2011-09-06 15:14:19 +0800 (Tue, 06 Sep 2011) $
% $Author: hoonhout $
% $Revision: 5177 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_reference.m $
% $Keywords: $

%% read options

OPT = struct(...
    'type', 'wiki' ...
);

OPT = setproperty(OPT, varargin{:});

%% read parameters

[params params_array] = xb_get_params;

parname = {params_array.name};
partype = {params_array.partype};
upartype = unique(partype);

%% write file

fid = fopen(filename, 'w');

for i = 1:length(upartype)
    ipars = find(strcmpi(upartype{i}, partype));
    
    if ~isempty(ipars) && sum([params_array(ipars).noinstances]) > 0
        
        addheader(fid, OPT.type, upartype{i});

        for j = ipars
            addinstance(fid, OPT.type, params_array(j));
        end

        addfooter(fid, OPT.type);
        
    end
end

fclose(fid);

function addheader(fid, type, partype)
    switch type
        case 'wiki'
            fprintf(fid, 'h3.%s\n', esc(type, partype));
            fprintf(fid, '{table-plus:width=1200}\n');
            fprintf(fid, '||Name||Units||Advanced||Deprecated||Affects||Description||Required||Default||Min||Max||Condition||\n');
        case 'html'
            fprintf(fid, '<h3>%s</h3>\n', esc(type, partype));
            fprintf(fid, '<table border="0">\n');
            fprintf(fid, '<tr><th>Name</th><th>Units</th><th>Advanced</th><th>Deprecated</th><th>Affects</th><th>Description</th><th>Required</th><th>Default</th><th>Min</th><th>Max</th><th>Condition</th></tr>\n');
    end
end

function addinstance(fid, type, param)
    for i = 1:param.noinstances
        switch type
            case 'wiki'
                if i == 1
                    fprintf(fid, '|%s|%s|%s|%s|%s|%s|', ...
                        esc(type, param.name), ...
                        esc(type, param.units), ...
                        bin(type, param.advanced), ...
                        bin(type, param.deprecated), ...
                        esc(type, param.affects), ...
                        esc(type, param.comment)            );
                else
                    fprintf(fid, '| | | | | | |');
                end

                fprintf(fid, '%s|%s|%s|%s|%s|\n', ...
                    bin(type, param.required{i}), ...
                    esc(type, param.default{i}), ...
                    esc(type, param.minval{i}), ...
                    esc(type, param.maxval{i}), ...
                    esc(type, param.condition{i})           );
            case 'html'
                if i == 1
                    fprintf(fid, '<tr><td nowrap>%s</td><td nowrap>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>', ...
                        esc(type, param.name), ...
                        esc(type, param.units), ...
                        bin(type, param.advanced), ...
                        bin(type, param.deprecated), ...
                        esc(type, param.affects), ...
                        esc(type, param.comment)            );
                else
                    fprintf(fid, '<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>');
                end

                fprintf(fid, '<td>%s</td><td nowrap>%s</td><td nowrap>%s</td><td nowrap>%s</td><td>%s</td></tr>\n', ...
                    bin(type, param.required{i}), ...
                    esc(type, param.default{i}), ...
                    esc(type, param.minval{i}), ...
                    esc(type, param.maxval{i}), ...
                    esc(type, param.condition{i})           );
        end
    end
end

function addfooter(fid, type)
    switch type
        case 'wiki'
            fprintf(fid, '{table-plus}\n');
        case 'html'
            fprintf(fid, '</table>\n');
    end
end

function str = esc(type, str)
    if ~iscell(str); str = {str}; end;
    
    switch type
        case 'wiki'
            r = '|()[]{}-';
        case 'html'
            r = '';
    end
    
    for i = 1:length(str)
        if isnumeric(str{i}); str{i} = num2str(str{i}); end;
        
        for ii = 1:length(r)
            str{i} = strrep(str{i}, r(ii), ['\' r(ii)]);
        end
    end
    
    str = [' ' sprintf('%s ', str{:})];
end

function str = bin(type, str)
    if iscell(str); str = str{1}; end;
    
    switch type
        case 'wiki'
            if str
                str = '(/)';
            else
                str = '(x)';
            end
        case 'html'
            if str
                str = 'yes';
            else
                str = 'no';
            end
    end
end

end
