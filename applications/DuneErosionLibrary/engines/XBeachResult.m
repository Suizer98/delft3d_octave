classdef XBeachResult < DuneErosionResult
    
    properties (SetAccess = 'protected')
        % profiles (time dependant?)
        xPreStorm;
        zPreStorm;
        xPostStorm;
        zPostStorm;
    end
    
    properties (Hidden = true)
        resdir;
        XBdims;
    end
    
    properties
        outputVariables = XBeachOutputVariable;
    end
    
    methods
        function obj = XBeachResult(varargin)
            % Read xbdims
            % Construct output variables
            % read params.txt
        end
    end
end