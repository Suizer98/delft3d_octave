function delft3dfm_write_bc_file(boundary,refdate,varargin)
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_DFlowFM_writeComponentsFile.m 9233 2013-09-19 09:19:19Z ormondt $
% $Date: 2013-09-19 11:19:19 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9233 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_writeComponentsFile.m $
% $Keywords: $

pth='.\';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'path','folder','dir'}
                pth=varargin{ii+1};   % water level correction
        end
    end                
end

types={'water_level','normal_velocity','tangential_velocity','riemann'};
quantities={'waterlevelbnd','normalvelocitybnd','tangentialvelocitybnd','riemannbnd'};
units={'m','m/s','m/s','m/s','m'};

% First delete existing forcing files
for ibnd = 1:length(boundary)
    
    bnd=boundary(ibnd).boundary;
    
    for iq=1:length(types)
        
        tp=types{iq};
        
        if bnd.(tp).time_series.active
            try
                fil=[pth filesep bnd.(tp).time_series.forcing_file];
                delete(fil);
            end
        end
        
        if bnd.(tp).astronomic_components.active
            try
                fil=[pth filesep bnd.(tp).astronomic_components.forcing_file];
                delete(fil);
            end
        end
        
    end
end

for ibnd = 1:length(boundary)
    
    bnd=boundary(ibnd).boundary;
    
    for iq=1:length(types)
        
        tp=types{iq};
        quant=quantities{iq};
        unit=units{iq};
        
        for ip=1:bnd.nrnodes

            nodename=[bnd.name '_' num2str(ip,'%0.4i')];
            
            if bnd.(tp).time_series.active
                fil=[pth filesep bnd.(tp).time_series.forcing_file];
                fid=fopen(fil,'a');
                % Header
                fprintf(fid,'%s\n',['[forcing]']);
                fprintf(fid,'%s\n',['Name                            = ' nodename]);
                fprintf(fid,'%s\n',['Function                        = timeseries']);
                fprintf(fid,'%s\n','Time-interpolation              = linear');
                fprintf(fid,'%s\n',['Quantity                        = time']);
                fprintf(fid,'%s\n',['Unit                            = ','seconds since ' datestr(refdate,'yyyy-mm-dd HH:MM:SS')]);
                switch quant
                    case{'ucxucyadvectionvelocitybnd'}
                        fprintf(fid,'%s\n',['Quantity                        = uxuyadvectionvelocitybnd']);
                        fprintf(fid,'%s\n','Unit                            = m/s');
                        fprintf(fid,'%s\n',['Quantity                        = uxuyadvectionvelocitybnd']);
                        fprintf(fid,'%s\n','Unit                            = m/s');
%                        fprintf(fid,'%s\n',['Quantity                        = ucyadvectionvelocity']);
%                        fprintf(fid,'%s\n','Unit                            = m/s');
                        % Values
                        for it=1:length(bnd.(tp).time_series.nodes(ip).time)
                            fprintf(fid,'%12.2f %8.4f %8.4f\n',(bnd.(tp).time_series.nodes(ip).time(it)-refdate)*86400,bnd.(tp).time_series.nodes(ip).u(it),bnd.(tp).time_series.nodes(ip).v(it));
                        end
                    otherwise
                        fprintf(fid,'%s\n',['Quantity                        = ' quant]);
                        fprintf(fid,'%s\n',['Unit                            = ' unit]);
                        % Values
                        for it=1:length(bnd.(tp).time_series.nodes(ip).time)
                            fprintf(fid,'%12.2f %8.4f\n',(bnd.(tp).time_series.nodes(ip).time(it)-refdate)*86400,bnd.(tp).time_series.nodes(ip).value(it));
                        end
                end
                fprintf(fid,'%s\n','');
                fclose(fid);                
            end
            
            if bnd.(tp).astronomic_components.active
                fil=[pth filesep bnd.(tp).astronomic_components.forcing_file];
                fid=fopen(fil,'a');
                % Header
                fprintf(fid,'%s\n',['[forcing]']);
                fprintf(fid,'%s\n',['Name                            = ' nodename]);
                fprintf(fid,'%s\n',['Function                        = astronomic']);
                fprintf(fid,'%s\n',['Quantity                        = astronomic component']);
                fprintf(fid,'%s\n', 'Unit                            = -');
                fprintf(fid,'%s\n',['Quantity                        = ' quant ' amplitude']);
                fprintf(fid,'%s\n',['Unit                            = ' unit]);
                fprintf(fid,'%s\n',['Quantity                        = ' quant ' phase']);
                fprintf(fid,'%s\n',['Unit                            = deg']);
                % Values
                for kk = 1 : length(bnd.(tp).astronomic_components.nodes(ip).name)
                    name = bnd.(tp).astronomic_components.nodes(ip).name{kk};
                    name = [name repmat(' ',1,6-length(name))];
                    amp = bnd.(tp).astronomic_components.nodes(ip).amplitude(kk);
                    phi = bnd.(tp).astronomic_components.nodes(ip).phase(kk);
                    fprintf(fid,'%s %8.5f %7.2f\n',name,amp,phi);
                end
                fprintf(fid,'%s\n','');
                fclose(fid);
            end
        end
    end
end

