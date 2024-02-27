classdef DurosResult < DuneErosionResult
    
    properties (SetAccess = 'protected')
        % profiles (time dependant?)
        xPreStorm;
        zPreStorm;
        xPostStorm;
        zPostStorm;deployt
    end
    
    properties
        % DUROS profile parts
        xLand;
        zLand;
        xActive;
        zActivePreStorm;
        zActivePostStorm;
        xSea;
        zSea;

        % calculation result (information)
        resultPossible;
        precision;
        x0;
        nIterations;
        toeProfile

        % calculation result (VTV)
        AVolume; % Use duneerosionabovestormsurgelevel as a get property in future, need waterlevel for that..
        TVolume;
        GVolume;
        Ppoint;
        Rpoint;

        % input information
        inputHs;
        inputTp;
        inputD50;
        inputWL;
        inputBend;
    end
    
    methods
        function obj = DurosResult(varargin)
            if nargin == 0
                return;
            end
            if isstruct(varargin{1})
                oldResult = varargin{1};
                if length(oldResult) > 1
                    error('Us the DuneErosionResultProvider to build a DuneErosionResult object');
                end
                %% transform old result to new one
                oldResult = varargin{1};
                
                % General information
                obj.iD = oldResult.info.ID;
                
                % profile parts
                obj.xLand = oldResult.xLand;
                obj.zLand = oldResult.zLand;
                obj.xActive = oldResult.xActive;
                obj.zActivePreStorm = oldResult.zActive;
                obj.zActivePostStorm = oldResult.z2Active;
                obj.xSea = oldResult.xSea;
                obj.zSea = oldResult.zSea;
                
                % calculation result (information)
                obj.resultPossible = oldResult.info.resultinboundaries;
                obj.precision = oldResult.info.precision;
                obj.calculationTime = oldResult.info.time;
                obj.x0 = oldResult.info.x0;
                obj.messages = oldResult.info.messages;
                obj.nIterations = oldResult.info.iter;
                obj.toeProfile = oldResult.info.ToeProfile;
                
                % calculation result (volumes)
                obj.erosionVolume = oldResult.Volumes.Erosion;
                obj.accretionVolume = oldResult.Volumes.Accretion;
                obj.volumeBalance = oldResult.Volumes.Volume;
                obj.cumulativeVolumes = oldResult.Volumes.volumes;
                
                % calculation result (VTV)
                obj.AVolume = oldResult.VTVinfo.AVolume;
                obj.TVolume = oldResult.VTVinfo.TVolume;
                obj.GVolume = oldResult.VTVinfo.G;
                obj.Ppoint = cat(2, oldResult.VTVinfo.Xp, oldResult.VTVinfo.Zp);
                obj.Rpoint = cat(2, oldResult.VTVinfo.Xr, oldResult.VTVinfo.Zr);
                
                % input information
                if ~isempty(oldResult.info.input)
                    fields = {...
                        'inputHs','Hsig_t';...
                        'inputTp','Tp_t';...
                        'inputD50','D50';...
                        'inputWL','WL_t';...
                        'inputBend','Bend'};
                    for ifield = 1:size(fields,1)
                        if isfield(oldResult.info.input,(fields{ifield,2}))
                            obj.(fields{ifield,1}) = oldResult.info.input.(fields{ifield,2});
                        end
                    end
                else
                    obj.inputHs = NaN;
                    obj.inputTp = NaN;
                    obj.inputD50 = NaN;
                    obj.inputWL = NaN;
                    obj.inputBend = NaN;
                end
            end
            
        end
    end
    
    %% Get Methods
    methods
        function value = get.xPreStorm(obj)
            value = cat(1,...
                obj.xLand,...
                obj.xActive,...
                obj.xSea);
        end
        function value = get.zPreStorm(obj)
            value = cat(1,...
                obj.zLand,...
                obj.zActivePreStorm,...
                obj.zSea);
        end
        function value = get.xPostStorm(obj)
            value = cat(1,...
                obj.xLand,...
                obj.xActive,...
                obj.xSea);
        end
        function value = get.zPostStorm(obj)
            value = cat(1,...
                obj.zLand,...
                obj.zActivePostStorm,...
                obj.zSea);
        end
    end
end