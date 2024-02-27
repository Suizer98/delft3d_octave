classdef XBeachOutputVariable < handle
   
    properties (Hidden = true)
        resdir;
        fid;
        filename;
        XBdims;
        contentType;
    end
    
    properties
        name;
        nx;
        ny;
        nt;
        type;
    end

    methods
        % Constructor
        function obj = XBeachOutputVariable(varargin)
            if nargin == 0
                return;
            end
            if nargin==1
                [obj.resdir fname ext] = fileparts(varargin{1});
                obj.filename = [fname ext];
            else
                obj.resdir = varargin{1};
                obj.filename = varargin{2};
            end
            obj.XBdims = xb_getdimensions(obj.resdir);
            obj.nx = obj.XBdims.nx;
            obj.ny = obj.XBdims.ny;
            
            if (length(obj.filename)>9 && strcmp(obj.filename(end-8:end), '_mean.dat'))
                obj.nt=obj.XBdims.ntm;
                nameend=9;
                obj.type = 'mean';
            elseif (length(obj.filename)>8 && strcmp(obj.filename(end-7:end), '_max.dat'))
                obj.nt=obj.XBdims.ntm;
                nameend=8;
                obj.type = 'maximum';
            elseif (length(obj.filename)>8 && strcmp(obj.filename(end-7:end), '_min.dat'))
                obj.nt=obj.XBdims.ntm;
                nameend=8;
                obj.type = 'minimumm';
            elseif (length(obj.filename)>8 && strcmp(obj.filename(end-7:end), '_var.dat'))
                obj.nt=obj.XBdims.ntm;
                nameend=8;
                obj.type = 'varriable';
            else
                obj.nt=obj.XBdims.nt;
                nameend=4;
                obj.type = 'timestep';
            end
            
            integernames={'wetz';
                'wetu';
                'wetv';
                'struct';
                'nd';
                'respstruct'};
            
            if any(strcmpi(obj.filename(1:end-nameend),integernames))
                obj.contentType='integer';
            else
                obj.contentType='double';
            end
            
            obj.fid=fopen(fullfile(obj.resdir,obj.filename),'r');
        end
        % Destructor
        function delete(obj)
            if ~isempty(obj.fid)
                if any(obj.fid==[0, 1, 2, -1])
                    return;
                end
                fclose(obj.fid);
            end
        end
    end
    methods
        % Obtain values
        function value = values(obj,it,idm,idn)
            fseek(obj.fid,(it-1)*numel(obj.XBdims.x)*8,'bof');
            value = fread(obj.fid,size(obj.XBdims.x),obj.contentType);
            if exist('idm','var')
                value = value(idm,:);
            end
            if exist('idn','var')
                value = value(:,idn);
            end
        end
    end
end