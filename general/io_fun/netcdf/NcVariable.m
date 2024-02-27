classdef NcVariable < handle
    %NCVARIABLE  wraps a variable in an ncfile for easy read access
    %
    %   The NcVariable wraps a variable in a netcdf file for easy read 
    %   access. It stores the url / path as a pointer and only reads the
    %   specified information (instead of the complete variable) to
    %   increase spead.
    %
    %   creating an NcVariable can be done in two ways:
    %   1. By creating an NcFile object and retrieving one of the
    %      variables:
    %           ncfile = NcFile(url);
    %           var = ncfile.Variables(1); 
    %               OR 
    %           var = ncfile.getvariable('test');
    %               OR
    %           var = ncfile.Variables('test');
    %
    %   2. Create one from scratch:
    %           var = NcVariable(url,'test');
    %
    %   The obtained object contains field (similar to fields of a struct)
    %   that provide information about the variable like data type, size
    %   and name. To read the content of a variable it should just be
    %   treated as any other double:
    %
    %           content = var(1,:)
    %           content = var(end,1:10)
    %           content = var(10:5:end,2,16)
    %           content = var(x < 15,:) % will not work yet if the specified sequence is not equidistant
    %
    %   not functioning yet:
    %           content = var([1,3,10],:)
    %
    %   The NcVariable object reads the netcdf file on every call to the
    %   values (like the examples above). for performance considerations it
    %   is therefore recommended to store the retrieved values in seperate
    %   variables in your workspace (a = var(1:10);)
    %
    %   See also NcVariable.NcVariable NcFile NcDimension nc_info nc_dump nc_varget
    
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
    
    % $Id: NcVariable.m 5309 2011-10-06 12:13:18Z geer $
    % $Date: 2011-10-06 20:13:18 +0800 (Thu, 06 Oct 2011) $
    % $Author: geer $
    % $Revision: 5309 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/netcdf/NcVariable.m $
    % $Keywords: $
    
    %% Properties
    properties
        FileName    % Location of the netcdf file (either local or on an opendap server)
        Name        % Name of the variable as present in the netcdf file
        NcType      % variable type of the variable in question (read from file)
        DataType    % Data type of the variable content (double, float, int etc.)
        Unlimited   
        Dimensions  % The dimensions of the variable (read from file) in the form of NcDimension objects
        Size        % The variable size (deduced from the dimensions
        Attributes  % Attributes (read from file)
    end
    
    %% Methods
    methods
        function this = NcVariable(url,variableInfo,dimensions)
            %NCVARIABLE  Creates an NcVariable object of the specified variable in the specified file
            %
            %   This method creates an NcVariable object from the specified
            %   variable in the specified file. The NcVariable object gives
            %   easy read access to a variable in the file.
            %
            %   Syntax:
            %   var = NcVariable(url,name)
            %
            %   Input:
            %   url        = Location of the netcdf file (url or local path)
            %   name       = Name of the desired variable in the netcdf file
            %
            %   Output:
            %   var        = NcVariable object referencing the desired
            %                variable in the specified netcdf file.
            %
            %   Example
            %   var = NcVariable('http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc','altitude');
            %   figure; plot(var(end,1,:));
            %
            %   See also NcVariable NcFile NcDimension
            
            %% return empty object when no input is given
            if nargin == 0
                return;
            end
            
            %% Cal with (url, variablename), retrieve info object
            if ischar(variableInfo)
                info = nc_info(url);
                variableInfo = info.Dataset(ismember({info.Dataset.Name}',variableInfo));
            end
            
            %% Get dimensions
            if nargin == 2
                info = nc_info(url);
                dimensions = NcDimension(url,info.Dimension);
            end
            
            if isempty(variableInfo)
                this(1) = [];
            elseif length(variableInfo) > 1
                %% multiple variables
                this(1,length(variableInfo)) = NcVariable;
                for i = 1:length(variableInfo)
                    this(i) = NcVariable(url,variableInfo(i),dimensions);
                end
            else
                %% Set properties
                this.FileName = url;
                this.Name = variableInfo.Name;
                this.NcType = variableInfo.Nctype;
                this.DataType = variableInfo.Datatype;
                this.Unlimited = variableInfo.Unlimited;
                this.Dimensions = NcDimension;
                if isempty(variableInfo.Dimension)
                    this.Dimensions(1) = [];
                end
                for i = 1:length(variableInfo.Dimension)
                   this.Dimensions(i) = dimensions(strcmp({dimensions.Name}',variableInfo.Dimension(i))); 
                end
                this.Size = variableInfo.Size;
                this.Attributes = variableInfo.Attribute;
            end
        end
        function sz = getsize(this)
            %GETSIZE  Returns the size (dimensions) of the NcVariable object
            %
            %   This function returns the size of the NcVariable (length of
            %   the dimensions)
            %
            %   Syntax:
            %   sz = var.getsize();
            %       OR
            %   sz = getsize(var);
            %
            %   Input:
            %   var        = An NcVariable object
            %
            %   Output:
            %   sz         = An 1xN double with dimension lengths in which
            %                N is the number of dimensions of this
            %                variable.
            %
            %   Example
            %   var = NcVariable('http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc','altitude');
            %   sz = getsize(var);
            %
            %   See also NcVariable NcVariable.NcVariable NcFile NcDimension
            
            if (length(this) > 1)
                sz = size(this);
            else
                sz = this.Size;
            end
        end
    end
    methods (Hidden = true)
        function ind = end(this,k,n)
            if length(this) > 1
                szd = size(this);
            else
                szd = this.Size;
            end
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
            end
        end
        function varargout = subsref(this,s)
            switch s(1).type
                % Use the built-in subsref for dot notation
                case '.'
                    for i = 1:length(this)
                        varargout{i} = builtin('subsref',this(i),s);
                    end
                case '()'
                    if length(this) > 1
                        if all(cellfun(@ischar,s(1).subs))
                            varargout{1} = NcVariable;
                            varargout{1}(1) = [];
                            for i=1:length(s(1).subs)
                                varargout{1}(i) = this(ismember({this.Name}',s(1).subs{i}));
                            end
                        elseif length(s(1).subs) > length(size(this))
                            error('Unknown reference');
                        else
                            varargout{1} = builtin('subsref',this,s(1));
                        end
                        if length(s) > 1
                            obj = varargout{1};
                            tmp = cell(1,length(obj));
                            for i = 1:length(obj)
                                tmp{i} = subsref(obj(i),s(2:end));
                            end
                            if length(obj) == 1
                                varargout{1} = tmp{1};
                            else
                                varargout{1} = tmp;
                            end
                        end
                        return;
                    end
                    if length(s)<2
                        %% Retrieve data
                        if length(s(1).subs) > length(this.Size)
                            error(['This variable has only ' num2str(length(this.Size)) ' dimensions']);
                        end
                        
                        nDims = length(this.Dimensions);
                        start = nan(1,nDims);
                        len = nan(1,nDims);
                        stride = nan(1,nDims);
                        filter = false(1,nDims);
                        s2 = s(1);
                        for i = 1:length(this.Dimensions)
                            if length(s(1).subs) < i
                                start(i) = 0;
                                len(i) = inf;
                                stride(i) = 1;
                                filter(i) = false;
                            else
                                [start(i) len(i) stride(i) filter(i)] = parsesubs(s(1).subs{i});
                            end
                            if ~filter(i)
                                s2.subs{i} = ':';
                            else
                                if islogical(s2.subs{i})
                                    s2.subs{i}=find(s2.subs{i});
                                end
                                s2.subs{i} = s2.subs{i} - start(i);
                            end
                        end
                        varargout{1} = nc_varget(this.FileName,this.Name,start,len,stride);
                        if any(filter)
                            s2.subs(strcmp(s2.subs,':'))=[];
                            varargout{1} = subsref(varargout{1},s2);
                        end
                        return
                    else
                        %% reference to one of the objects in the array
                        varargout{1} = builtin('subsref',this,s);
                    end
                case '{}'
                    if (length(this) > 1)
                        id = ismember({this.Name},s.subs);
                        if all(~id)
                            error(['Could not find variable with name: ' s.subs]);
                        end
                        varargout{1} = this(id);
                        return;
                    end
                    error('NcVariable:subsref',...
                        'Not a supported subscripted reference')
            end
        end
        function val = double(this)
            val = nc_varget(this.FileName,this.Name);
        end
    end
end

function [start len stride filter] = parsesubs(sub)
filter = false;
if islogical(sub)
    sub = find(sub==1);
end

if ischar(sub)
    if strcmp(sub,':')
        start = 0;
        len = inf;
        stride = 1;
        return;
    else
        error('Index exceeds matrix dimensions.');
    end
end
if isnumeric(sub)
    if length(sub) == 1
        start = sub - 1;
        len = 1;
        stride = 1;
        return;
    end
    d = diff(sub);
    if length(unique(d)) == 1
        start = min(sub)-1;
        stride = d(1);
        len = floor((max(sub) - min(sub)) / stride)+1;
    else
        start = min(sub)-1;
        stride = 1;
        len = max(sub);
        filter = true;
        % TODO: come up with a better solution (xb_read_dat ?)
    end
end

end