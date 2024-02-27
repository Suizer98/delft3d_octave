function s=xml2struct(varargin)
%XML2STRUCT  load xml file into struct
%
%   s = xml2struct(fname) loads xml file or url fnamer into struct X.
%   Options can be supplied as s = xml2struct(fname,<keyword,value>)
%
% Option short (short, as used by Muppet, CoSMoS, DDB etc.)            % No attributes possible
%   s = xml2struct(fname,'structuretype','short')
%
%       model(2).model.station(3).station=2;
%
% Option long (Long, but includes all options)
%   s = xml2struct(fname,'structuretype','long')
%
%       model(2).model.station(3).station.ATTRIBUTES.file.value='asd.sdasf';
%       model(2).model.station(3).station.ATTRIBUTES.file.PREFIX='ows:';
%       model(2).model.station(3).station.name.value=5;
%       model(2).model.station(3).station.name.PREFIX='ows:';
%       model(2).model.station(3).station.name.ATTRIBUTES.id.value='123';
%       model(2).model.station(3).station.name.ATTRIBUTES.id.PREFIX=2;
%       model(2).model.station(3).station.nr.value='Delft';
%       model(2).model.station(3).station.nr.PREFIX='ows:';
%       model(2).model.station(3).station.nr.ATTRIBUTES.name.value=2;
%       model(2).model.station(3).station.nr.ATTRIBUTES.name.PREFIX=2;
%
% Option 3 supershort
%   s = xml2struct(fname,'structuretype','supershort')
%
%       model(2).station(3).nr=2;                                      % No attributes possible
%
%   See also: xmlread, xml_load, xml_read, var2evalstr

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
% Created: 23 Feb 2013
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: xml2struct.m 17361 2021-06-22 15:49:17Z ormondt $
% $Date: 2021-06-22 23:49:17 +0800 (Tue, 22 Jun 2021) $
% $Author: ormondt $
% $Revision: 17361 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/xml2struct.m $
% $Keywords: $

%%
% Writes xml data to Matlab structure

filename          = varargin{1};
includeattributes = 1;
structuretype     = 'short';
includeroot       = 0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
%             case{'includeattributes'}
%                 includeattributes=1;
            case{'structuretype'}
                structuretype=lower(varargin{ii+1});
            case{'includeroot'}
                includeroot=1;
        end
    end
end

if isa(filename, 'org.apache.xerces.dom.DeferredDocumentImpl') || isa(filename, 'org.apache.xerces.dom.DeferredElementImpl')
    % Input is a java xml object
    % Convert to string
    str = xmlwrite(filename);
else
    % Input is a file or url    
    % Read entire file into one string
    switch filename(1:3)
        case{'htt','ftp'}
            str=urlread(filename);
        otherwise
            str=fileread(filename);
    end
end
  
str=deblank(str);

% Find opening and closing characters
iopen=strfind(str,'<');
iclose=strfind(str,'>');

n=length(iopen);

% Allocate arrays
nodeNames      =  cell(1,n);
nodeAttributes =  cell(1,n);
nodeData       =  cell(1,n);
nodeOptions    = zeros(1,n);
nodeLocations  = zeros(n,2);
nodeParents    = zeros(1,n);
endNodes       = zeros(1,n);

if includeroot
    s.COMMENTS=[];
end

n=0;
for ii=1:length(iopen)
    ii1=iopen(ii);
    % Skip comment lines
    if str(ii1+1)~='?' && str(ii1+1)~='!'        
        % Position of closing character is ii1
        ii1=iopen(ii);
        % Position of closing character is ii2
        ii2=iclose(ii);
        % Name is whatever is in between        
        name=str(ii1+1:ii2-1);
        % Determine type of node        
        if name(1)=='/'
            % Closing
            opt=3;
            name=name(2:end);
        elseif name(end)=='/'
            % Opening and closing
            opt=2;
            name=name(1:end-1);
        else
            % Opening
            opt=1;
        end
        % Find attributes in node
        attributes=[];
        name=deblank(name);
        isp=find(name==' ');
        if ~isempty(isp)
            attstr = name(isp(1)+1:end);
            name   = name(1:isp(1)-1);
            % Name string includes attributes
            a=textscan(attstr,'%q','delimiter',' ');
            for j=1:length(a{1})
                ieq=find(a{1}{j}=='=');
                attributes(j).Name  = a{1}{j}(1:ieq-1);
                val=a{1}{j}(ieq+1:end);
                if strcmpi(val(1),'"') || strcmpi(val(1),'''')
                    attributes(j).Value = a{1}{j}(ieq+2:end-1);
                else
                    attributes(j).Value = a{1}{j}(ieq+1:end);
                end
            end
        end
        % Set some values for this node        
        n=n+1;
        nodeOptions(n)     = opt;
        nodeLocations(n,1) = ii1;
        nodeLocations(n,2) = ii2;
        nodeNames{n}       = name;
        nodeAttributes{n}  = attributes;
    else
        if includeroot
            s.COMMENTS{length(s.COMMENTS)+1}=str(iopen(ii)+1:iclose(ii)-1);
        end
    end
end

% Now find parents of each node (first node has parent 0) and read data
nextParent=0;
for ii=1:n        
    nodeParents(ii)=nextParent;    
    switch nodeOptions(ii)        
        case 1                        
            % Opening
            % Check what next element does
            switch nodeOptions(ii+1)
                case 1
                    % Also opening, parent of next node is this node
                    nextParent=ii;
                case 2
                    % Opening and closing, parent of next node is this node
                    nextParent=ii;
                case 3
                    % Closing, parent stays the same, read the data
                    nodeData{ii}=str(nodeLocations(ii,2)+1:nodeLocations(ii+1,1)-1);
                    endNodes(ii)=1;
            end            
        case 2
            % Opening and closing                       
            % Check what next element does
            endNodes(ii)=1;
            switch nodeOptions(ii+1)
                case 1
                    % Also opening, parent stays the same
                case 2
                    % Opening and closing, parent stays the same
                case 3
                    % Closing, parent of next node is grandparent of this node
                    nextParent=nodeParents(nodeParents(ii));                    
            end            
        case 3
            % Closing
            % Check what next element does
            switch nodeOptions(ii+1)
                case 1
                    % Opening, parent stays the same
                case 2
                    % Opening and closing, parent stays the same
                case 3
                    % Closing, parent of next node is grandparent of this node
                    nextParent=nodeParents(nodeParents(ii));
            end
            
    end
end

% Set parents of closing nodes to 0, so they won't be seen as children
nodeParents(nodeOptions==3)=0;

% Set data for first node
node(1).Name    =nodeNames{1};
node(1).Attributes=nodeAttributes{1};
node(1).Data    =[];
node(1).Children=[];

% And now find children, grandchildren etc. for first node
node.Children=getChildren(1,nodeNames,nodeAttributes,nodeData,nodeParents,endNodes);

% And convert node to structure
if includeroot
    switch structuretype
        case{'long'}
            [name,prefix]=nocolon(nodeNames{1});
            s.(name)=node2struct(node,includeattributes,structuretype);
            if ~isempty(prefix)
                s.(name).PREFIX=prefix;
            end
            if ~isempty(nodeAttributes{1})
                for ii=1:length(nodeAttributes{1})
                    [attrname,prefix]=nocolon(nodeAttributes{1}(ii).Name);
                    s.(nocolon(nodeNames{1})).ATTRIBUTES.(attrname).value=nodeAttributes{1}(ii).Value;
                    if ~isempty(prefix)
                        s.(nocolon(nodeNames{1})).ATTRIBUTES.(attrname).PREFIX=prefix;
                    end
                end
            end
        otherwise
            s.(nocolon(nodeNames{1}))=node2struct(node,includeattributes,structuretype);
    end
else
    s=node2struct(node,includeattributes,structuretype);
end

%%
function Children=getChildren(nr,nodeNames,nodeAttributes,nodeData,nodeParents,endNodes)

Children=[];

if ~endNodes(nr)    
    % Find indices of children of this node (only if this is not an end node)
    ichildren=find(nodeParents==nr);    
    % Loop through children
    for ic=1:length(ichildren)
        n=ichildren(ic);
        Children(ic).Name=nodeNames{n};
        Children(ic).Attributes=nodeAttributes{n};
        Children(ic).Data=nodeData{n};
        Children(ic).Children=getChildren(n,nodeNames,nodeAttributes,nodeData,nodeParents,endNodes);
    end    
end

%%
function s=node2struct(node,includeattributes,structuretype)

s=[];

for ii=1:length(node.Children)
    
    child=node.Children(ii);
    
    if isempty(child.Children)
        
        % Must be and end node

        [name,prefix]=nocolon(child.Name);
        val=child.Data;
        
        % Try to convert data to correct type
        attributes=getAttributes(child);
        if ~isempty(val)
            if ~isempty(attributes)
                if isfield(attributes,'type')
                    switch lower(attributes.type.value)
                        case{'int','real'}
                            val=str2num(val);
                    end
                end
            end
        end        

        switch structuretype
            case{'long'}
                k=1;
                if isfield(s,name)
                    k=length(s.(name))+1;
                end
                s.(name)(k).(name).value=val;
                if ~isempty(prefix)
                    s.(name)(k).(name).PREFIX=prefix;
                end
                if ~isempty(attributes)
                    s.(name)(k).(name).ATTRIBUTES=attributes;
                end
            case{'short'}
                k=1;
                if isfield(s,name)
                    % Field already exists
                    if ~isstruct(s.(name))
                        % But is not a structure yet
                        oldval=s.(name);
                        s.(name)=[];
                        s.(name)(1).(name)=oldval;
                        s.(name)(2).(name)=val;
                    else                        
                        k=length(s.(name))+1;
                        s.(name)(k).(name)=val;
                    end
                else
                    % Field does not yet exists
                    s.(name)=val;
                end
            case{'supershort'}
                k=1;
                if isfield(s,name)
                    if ischar(s.(name)) || isempty(s.(name))
                        % Must make this a cell array
                        oldval=s.(name);
                        s.(name)=[];
                        s.(name){1}=oldval;
                        k=2;
                    else
                        k=length(s.(name))+1;
                    end
                end
                if isempty(val)
                    if k==1
                        s.(name)=[];
                    else
                        s.(name){k}=[];
                    end
                else
                    if isnumeric(val)
                        % Store data in vector
                        s.(name)(k)=val;
                    else
                        % Store data in cell array
                        if k==1
                            s.(name)=val;
                        else
                            s.(name){k}=val;
                        end
                    end
                end
        end
               
    else
        
        % Next node
        
        s0=node2struct(child,includeattributes,structuretype);
        
        if ~isempty(s0)
            [name,prefix]=nocolon(child.Name);
            name = mkvar(name); % get rid of special characters that are not a valid matlab fieldname
            k=1;
            if isfield(s,name)
                % Field already exists
                k=length(s.(name))+1;
            end
            switch structuretype
                case{'long'}
                    s.(name)(k).(name)=s0;
                    attributes=getAttributes(child);
                    if ~isempty(attributes)
                        s.(name)(k).(name).ATTRIBUTES=attributes;
                    end
                    if ~isempty(prefix)
                        s.(name)(k).(name).PREFIX=prefix;
                    end
                case{'short'}
                    s.(name)(k).(name)=s0;
                case{'supershort'}
                    fldnames=fieldnames(s0);
                    for j=1:length(fldnames)
                        s.(name)(k).(fldnames{j})=s0.(fldnames{j});
                    end
            end
        end
    end
end

%%
function attributes=getAttributes(child)

attributes=[];
if ~isempty(child.Attributes)
    for ii=1:length(child.Attributes)
        [name,prefix]=nocolon(child.Attributes(ii).Name);
        attributes.(name).value=child.Attributes(ii).Value;
        if ~isempty(prefix)
            attributes.(name).PREFIX=prefix;
        end
    end
end

%%
function [str,prefix]=nocolon(str)
% Get rid of everything in string up to and including last colon. This is needed to
% because field names in structures cannot contain colons 
n=find(str==':');
prefix=[];
if ~isempty(n)
    n1=n(end)+1;
    n2=length(str);
    prefix=str(1:n(end));
    str=str(n1:n2);
end
