function handles = ddb_Delft3DWAVE_plotBathy(handles, option, varargin)
%DDB_DELFT3DFLOW_PLOTBATHY  One line description goes here.
%
%   More detailed description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_Delft3DWAVE_plotBathy.m 12131 2015-07-24 15:11:30Z ormondt $
% $Date: 2015-07-24 23:11:30 +0800 (Fri, 24 Jul 2015) $
% $Author: ormondt $
% $Revision: 12131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/plot/ddb_Delft3DWAVE_plotBathy.m $
% $Keywords: $

%%
% Default values
id=ad;
vis=1;

% model number imd

% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'visible'}
                vis=varargin{i+1};
            case{'wavedomain'}
                id=varargin{i+1};
        end
    end
end

switch lower(option)
    
    case{'plot'}
        
        % First delete old bathy
        if isfield(handles.model.delft3dwave.domain.domains(id),'bathyplot')
            if isfield(handles.model.delft3dwave.domain.domains(id).bathyplot,'handles')
                if ~isempty(handles.model.delft3dwave.domain.domains(id).bathyplot.handle)
                    try
                        delete(handles.model.delft3dwave.domain.domains(id).bathyplot.handle);
                    end
                end
            end
        end
                
        if size(handles.model.delft3dwave.domain.domains(id).depth,1)>0
            
            x=handles.model.delft3dwave.domain.domains(id).gridx;
            y=handles.model.delft3dwave.domain.domains(id).gridy;
            z=handles.model.delft3dwave.domain.domains(id).depth;
            
            handles.model.delft3dwave.domain.domains(id).bathyplot.handle=ddb_plotBathy(x,y,z,'tag','delft3dwavebathymetry');
            
            if vis
                set(handles.model.delft3dwave.domain.domains(id).bathyplot.handle,'Visible','on');
            else
                set(handles.model.delft3dwave.domain.domains(id).bathyplot.handle,'Visible','off');
            end
            
        end
        
    case{'delete'}
        try
            delete(handles.model.delft3dwave.domain.domains(id).bathyplot.handle);
        end
        
        hh=findobj(gcf,'tag','delft3dwavebathymetry');
        if ~isempty(hh)
            try
                delete(hh);
            end
        end
        
    case{'update'}
                try
                    if vis
                        set(handles.model.delft3dwave.domain.domains(id).bathyplot.handle,'Visible','on');
                    else
                        set(handles.model.delft3dwave.domain.domains(id).bathyplot.handle,'Visible','off');
                    end
                end  
end

