classdef XBeachLimitStateFunctionChecker < handle
    %XBEACHLIMITSTATEFUNCTIONCHECKER
    %
    %   Creates an object that checks if an XBeach simulation has finished
    %   yet
    %
    %   See also XBeachLimitStateFunctionChecker.XBeachLimitStateFunctionChecker
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2014 Deltares
    %       Joost den Bieman
    %
    %       joost.denbieman@deltares.nl
    %
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
    % Created: 31 Jan 2014
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: XBeachLimitStateFunctionChecker.m 11966 2015-06-08 13:52:38Z bieman $
    % $Date: 2015-06-08 21:52:38 +0800 (Mon, 08 Jun 2015) $
    % $Author: bieman $
    % $Revision: 11966 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/adapters/XBeach/XBeachLimitStateFunctionChecker.m $
    % $Keywords: $
    
    %% Properties
    properties
        Abort
        Delay
        KeepChecking
        TimeOut
        Timer
    end
    
    %% Events
    events
        SimulationStarted
        SimulationCompleted
        SimulationNotCompleted
    end
    
    %% Methods
    methods
        %% Constructor
        function this = XBeachLimitStateFunctionChecker
            %XBEACHLIMITSTATEFUNCTIONCHECKER  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = XBeachLimitStateFunctionChecker(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "XBeachLimitStateFunctionChecker"
            %
            %   Example
            %   XBeachLimitStateFunctionChecker
            %
            %   See also XBeachLimitStateFunctionChecker
            
            this.SetDefaults
        end
        
        %% Other methods
        % Check whether the simulation is done
        function CheckProgress(this, modelOutputDir)
            this.KeepChecking   = true;
            this.Abort          = false; 
            
            while ~this.Abort && this.KeepChecking
                % Check if simulation is completed
                if this.CheckLogFile(modelOutputDir)
                    % If so, trigger event
                    notify(this, 'SimulationCompleted');
                    this.KeepChecking   = false;
                else
                    % If not: wait for a bit
                    pause(this.Delay)
                end
            end
        end
        
        % Check XBeach logfile to see if the simulation is done
        function completed = CheckLogFile(this, modelOutputDir)
            completed   = false;
            if exist(fullfile(modelOutputDir,'xboutput.nc'),'file') ...
                    && ~exist(fullfile(modelOutputDir,'XBerror.txt'),'file')
                completed   = true;
            end
        end
        
        % Stop waiting for the simulation to end
        function StopWaiting(this)
            this.Abort  = true;
            notify(this, 'SimulationNotCompleted')
        end
        
        % Set default property values
        function SetDefaults(this)
            this.Abort          = false;
            this.Delay          = 1;
            this.KeepChecking   = true;
            this.TimeOut        = 900; 
        end
    end
end 