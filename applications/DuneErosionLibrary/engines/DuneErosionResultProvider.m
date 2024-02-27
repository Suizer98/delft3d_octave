classdef DuneErosionResultProvider < handle
    
    properties
        description = 'This class provides dune erosion calculation results. It does not have meaningfull properties and can only be used as a factory to make the results.'
    end
    
    methods (Static = true)
        function durosResult = createDurosResult(varargin)
            if nargin==0
                durosResult = DurosResult;
                return;
            end
            if isstruct(varargin{1})
                oldResult = varargin{1};
                
                durosResult = repmat(DurosResult,1,length(oldResult));
                
                for ires = 1:length(oldResult)
                    durosResult(ires) = DurosResult(oldResult(ires));
                end
            end 
        end
        function xBeachResult = createXBeachResult(varargin)
            if nargin == 0
                xBeachResult = XBeachResult;
                return;
            end
            % Read xbeach result dir
        end
    end
end