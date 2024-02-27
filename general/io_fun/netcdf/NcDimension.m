classdef NcDimension < handle
    %NCDIMENSION  Wraps a netcdf dimension for easy read access.
    %
    %   NcDimension wraps a netcdf dimension for easy read access and can
    %   be contained in a NcFile or NcVariable object. There is no method
    %   to create an NcDimension object on itself
    %
    %   See also NcFile NcVariable
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2011 Deltares
    %       Pieter van Geer
    %
    %       pieter.vangeer@deltares.nl
    %
    %       Rotterdamseweg 185
    %       2629 HD Delft
    %       P.O. 177
    %       2600 MH Delft
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
    % Created: 30 Sep 2011
    % Created with Matlab version: 7.12.0.635 (R2011a)
    
    % $Id: NcDimension.m 5296 2011-10-04 08:19:30Z geer $
    % $Date: 2011-10-04 16:19:30 +0800 (Tue, 04 Oct 2011) $
    % $Author: geer $
    % $Revision: 5296 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/netcdf/NcDimension.m $
    % $Keywords: $
    
    %% Properties
    properties
        FileName    % Location of the netcdf file (either local or on an opendap server)
        Name        % Name of the dimension
        Length      % Length of the dimension
        Unlimited   % Specifies whether the dimension is unlimited
    end
    
    %% Methods
    methods
        function this = NcDimension(url,info)
            %NCDIMENSION  Creates an NcDimension object
            %
            %   This method creates an NcDimension object and is internally
            %   used in NcVariable and Ncfile.
            %
            %   Syntax:
            %   this = NcDimension(url,info)
            %
            %   Input:
            %   url        = The url / path to the netcdf file
            %   info       = The struct with information about the
            %                dimension returned by nc_info.
            %
            %   Output:
            %   this       = Object of class "NcDimension"
            %
            %
            %   See also NcFile NcVariable
            
            if nargin == 0
                return;
            end
            
            if isempty(info)
                this(1) = [];
            elseif length(info) > 1
                this(1,length(info)) = NcDimension;
                for i = 1:length(info)
                    this(i) = NcDimension(url,info(i));
                end
            else
                this.FileName = url;
                this.Name = info.Name;
                this.Length = info.Length;
                this.Unlimited = info.Unlimited;
            end
        end
    end
end
