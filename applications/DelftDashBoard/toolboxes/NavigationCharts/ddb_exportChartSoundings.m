function ddb_exportChartSoundings(s,filename,newsys)
%DDB_EXPORTCHARTSOUNDINGS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_exportChartSoundings(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_exportChartSoundings
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

orisys.name='WGS 84';
orisys.type='geographic';

fn=fieldnames(s);
nf=length(fn);

pnts=[];
for i=1:nf
    n=length(s.(fn{i}));
    for j=1:n
        if isfield(s.(fn{i})(j),'Type')
            if ~isempty(lower(s.(fn{i})(j).Type))
                switch(lower(s.(fn{i})(j).Type))
                    case{'multipoint'}
                        pnts=[pnts;s.(fn{i})(j).Coordinates];
                end
            end
        end
    end
end

if ~isempty(pnts)
    
    x=pnts(:,1);
    y=pnts(:,2);
    z=pnts(:,3);
    
    [x,y]=ddb_coordConvert(x,y,orisys,newsys);
    
    fid=fopen(filename,'wt');
    for j=1:size(pnts,1)
        fprintf(fid,'%16.8e %16.8e %16.8e\n',x(j),y(j),z(j));
    end
    fclose(fid);
    
end