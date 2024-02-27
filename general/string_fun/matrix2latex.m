function varargout = matrix2latex(x, varargin)
%MATRIX2LATEX  creates a LaTeX table based on a matrix
%
%   Transforms a matrix (double) to a LaTeX table.
%
%   Syntax:
%   varargout = matrix2latex(varargin)
%
%   Input:
%   x         = matrix (double)
%   varargin  = propertyName-propertyValue pairs as available in OPT
%               structure
%
%   Output:
%   varargout =
%
%   Example
%   matrix2latex
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 23 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: matrix2latex.m 9355 2013-10-08 15:48:30Z bieman $
% $Date: 2013-10-08 23:48:30 +0800 (Tue, 08 Oct 2013) $
% $Author: bieman $
% $Revision: 9355 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/matrix2latex.m $
% $Keywords: $

%%
OPT = struct(...
    'environment', 'tabular', ...
    'title', 'table',...
    'standalone', false,...
    'filename', 'table.tex',...
    'where', '!tbp',...
    'rowlabel', '',...
    'rowjustification', 'l',...
    'rowlabeljustification', 'l', ...
    'collabel', '',...
    'caption', '',...
    'justification', 'center', ...
    'format', [], ...
    'vlines', [], ...
    'hlines', []);

OPT = setproperty(OPT, varargin{:});

%%
[nrow ncol] = deal(size(x,1), size(x,2));
[irow icol] = deal(1);

if ~isempty(OPT.collabel)
    nrow = nrow + 1;
    irow = 2;
end

if ~isempty(OPT.rowlabel)
    ncol = ncol + 1;
    icol = 2;
end

if isempty(OPT.format)
    OPT.format = repmat({'%6.4f'}, 1, ncol);
end

format = repmat(OPT.format, nrow, 1);

xcell = cell(nrow,ncol);
xcell(irow:end,icol:end) = num2cell(x);
xcell = cellfun(@num2str, xcell, format,...
    'UniformOutput', false);

if ~isempty(OPT.collabel)
    % put columnlabels at the last n columns
    xcell(1,end+1-length(OPT.collabel):end) = OPT.collabel;
end

if ~isempty(OPT.rowlabel)
    % put rowlabels at the last n rows
    xcell(end+1-length(OPT.rowlabel):end,1) = OPT.rowlabel;
end

delimiters = repmat({' & '}, 1, size(xcell,2));
delimiters{end} = '\\';

%% build table
% table preamble 
texcell = {};

if OPT.standalone
    % document preamble
%    texcell{end+1} = sprintf('%s\n', '\documentclass{article}', '', '\begin{document}');
end

%texcell{end+1} = sprintf('%s', '\begin{table}[', OPT.where, ']');
%texcell{end+1} = sprintf('%s', ' \caption{', OPT.caption, '\label{', OPT.title, '}}'); 
%texcell{end+1} = sprintf('%s', ' \begin{', OPT.justification, '}');
texcell{end+1} = sprintf('%s', [' \caption{', OPT.caption, '}']); 

if ~isempty(OPT.rowlabel)
    OPT.vlines(end+1) = 1;
end

if ~isempty(OPT.collabel)
    OPT.hlines(end+1) = 1;
end

rowlabeljustification = OPT.rowlabeljustification;
for icol = 1:size(xcell,2)
    iicol = icol;
    if ~isempty(OPT.rowlabel); iicol = iicol-1; end;
    
    if any(OPT.vlines==iicol)
        rowlabeljustification = [OPT.rowlabeljustification];
    end
    
    rowlabeljustification = [rowlabeljustification OPT.rowjustification];
end

texcell{end+1} = sprintf('%s', [' \begin{' OPT.environment '}{', rowlabeljustification, '}\hline\hline']);

for irow = 1:size(xcell,1)
    iirow = irow;
    if ~isempty(OPT.collabel); iirow = iirow-1; end;
    
    if any(OPT.hlines==iirow)
        texcell{end+1} = '\hline';
    end
    
    rowcell = [xcell(irow,:); delimiters];
    texcell{end+1} = sprintf('%s', rowcell{:});
end

% table closure
texcell{end+1} = sprintf('%s', '\hline');

texcell{end+1} = sprintf('%s', ['\end{' OPT.environment '}']);

%texcell{end+1} = sprintf('%s', '\end{', OPT.justification, '}');

%texcell{end+1} = sprintf('%s', '\end{table}');

if OPT.standalone
    % document closure
%    texcell{end+1} = sprintf('%s\n', '', '\end{document}');
end


%% write table to file
fid = fopen(OPT.filename, 'w');
tex = fprintf(fid, '%s\n', texcell{:});
fclose(fid);