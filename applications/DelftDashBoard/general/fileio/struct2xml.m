function struct2xml(filename, s, varargin)
%STRUCT2XML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   struct2xml(filename, s)
%
%   Input:
%   filename =
%   s        =
%
%
%
%
%   Example
%   struct2xml
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: struct2xml.m 17547 2021-11-03 16:50:40Z ormondt $
% $Date: 2021-11-04 00:50:40 +0800 (Thu, 04 Nov 2021) $
% $Author: ormondt $
% $Revision: 17547 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/struct2xml.m $
% $Keywords: $

%%

% Writes Matlab structure s to xml file
%
% e.g.
%
% or :
%
% s.model(2).model.station(3).station.ATTRIBUTES.file.value='asd.sdasf';
% s.model(2).model.station(3).station.ATTRIBUTES.file.PREFIX='ows:';
% s.model(2).model.station(3).station.name.value=5;
% s.model(2).model.station(3).station.name.PREFIX='ows:';
% s.model(2).model.station(3).station.name.ATTRIBUTES.id.value='123';
% s.model(2).model.station(3).station.name.ATTRIBUTES.id.PREFIX=2;
% s.model(2).model.station(3).station.nr.value='Delft';
% s.model(2).model.station(3).station.nr.PREFIX='ows:';
% s.model(2).model.station(3).station.nr.ATTRIBUTES.name.value=2;
% s.model(2).model.station(3).station.nr.ATTRIBUTES.name.PREFIX=2;
% struct2xml('test.xml',s,'includeattributes',0);

structuretype='long';
nindent=2;
includeattributes=0;
includeroot=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'structuretype'}
                structuretype=lower(varargin{ii+1});
            case{'includeattributes'}
                includeattributes=1;
            case{'nindent'}
                nindent=varargin{ii+1};
            case{'includeroot'}
                includeroot=1;
        end
    end
end

fid=fopen(filename,'wt');
if includeroot   
    if isfield(s,'COMMENTS')
        for ii=1:length(s.COMMENTS)
            fprintf(fid,'%s\n',['<' s.COMMENTS{ii} '>']);           
        end
    else
        fprintf(fid,'%s\n','<?xml version="1.0"?>');
    end
    fldnames=fieldnames(s);
    for ii=1:length(fldnames)
        switch fldnames{ii}
            case{'COMMENTS'}
            otherwise
                switch structuretype
                    case{'short','long'}
                        s.(fldnames{ii})=s;
                end
                splitstruct(fid,s,0,nindent,includeattributes,structuretype);
        end
    end    
else
    fprintf(fid,'%s\n','<?xml version="1.0"?>');
    fprintf(fid,'%s\n','<root>');
    splitstruct(fid,s,1,nindent,includeattributes,structuretype);
    fprintf(fid,'%s\n','</root>');
end
fclose(fid);

%%
function splitstruct(fid,s,ilev,nindent,includeattributes,structuretype)

fldnames=fieldnames(s);    

for k=1:length(fldnames)
    fldname=fldnames{k};
    switch fldname
        case{'COMMENTS','PREFIX','ATTRIBUTES'}
        otherwise
            switch structuretype
                case{'long'}
                    for j=1:length(s.(fldname))
                        endnode=0;
                        attributes=[];
                        if isfield(s.(fldname)(j).(fldname),'ATTRIBUTES')
                            attributes=s.(fldname)(j).(fldname).ATTRIBUTES;
                        end
                        prefix='';
                        if isfield(s.(fldname)(j).(fldname),'PREFIX')
                            prefix=s.(fldname)(j).(fldname).PREFIX;
                        end
                        % Find out if this is an end node
                        if isfield(s.(fldname)(j).(fldname),'value')
                            if ~isstruct(s.(fldname)(j).(fldname).value)
                                % This is an end node
                                name=fldname;
                                value=s.(fldname)(j).(fldname).value;
                                % Write end node
                                writeendnode(fid,ilev,nindent,name,prefix,value,attributes,includeattributes);
                                endnode=1;
                            end
                        end
                        if ~endnode
                            % Not an end node
                            writeopennode(fid,ilev,nindent,fldname,prefix,attributes,includeattributes);
                            ilev=ilev+1;
                            splitstruct(fid,s.(fldname)(j).(fldname),ilev,nindent,includeattributes,structuretype);
                            ilev=ilev-1;
                            writeclosenode(fid,ilev,nindent,fldname,prefix);
                        end
                    end
                case{'short'}
                    if ~isstruct(s.(fldname))
                        attributes=[];
                        prefix='';
                        name=fldname;
                        value=s.(fldname);
                        % Write end node
                        writeendnode(fid,ilev,nindent,name,prefix,value,attributes,includeattributes);
                    else
                        for j=1:length(s.(fldname))
                            attributes=[];
                            prefix='';
                            % Find out if this is an end node
                            if ~isstruct(s.(fldname)(j).(fldname))
                                % This is an end node
                                name=fldname;
                                value=s.(fldname)(j).(fldname);
                                % Write end node
                                writeendnode(fid,ilev,nindent,name,prefix,value,attributes,includeattributes);
                            else
                                % Not an end node
                                writeopennode(fid,ilev,nindent,fldname,prefix,attributes,includeattributes);
                                ilev=ilev+1;
                                splitstruct(fid,s.(fldname)(j).(fldname),ilev,nindent,includeattributes,structuretype);
                                ilev=ilev-1;
                                writeclosenode(fid,ilev,nindent,fldname,prefix);
                            end
                        end
                    end
                case{'supershort'}
                    attributes=[];
                    prefix='';
                    if ~isstruct(s.(fldname))
                        % This is an end node
                        name=fldname;
                        value=s.(fldname);
                        % Write end node
                        writeendnode(fid,ilev,nindent,name,prefix,value,attributes,includeattributes);
                    else
                        % Not an end node
                        for j=1:length(s.(fldname))
                            writeopennode(fid,ilev,nindent,fldname,prefix,attributes,includeattributes);
                            ilev=ilev+1;
                            splitstruct(fid,s.(fldname)(j),ilev,nindent,includeattributes,structuretype);
                            ilev=ilev-1;
                            writeclosenode(fid,ilev,nindent,fldname,prefix);
                        end
                    end
            end
    end
end

%%
function writeendnode(fid,ilev,nindent,name,prefix,value,attributes,includeattributes)
% Write end node
% First try to convert data to string
tp='real';
fmt=[];
if ~isempty(attributes)
    if isfield(attributes,'TYPE')
        tp=attributes.type.value;
    end
    if isfield(attributes,'FORMAT')
        fmt=attributes.format.value;
    end
end
if isnumeric(value)
    switch tp
        case{'real','double'}
            if length(value)>1
                % Vector
                if isempty(fmt)
                    fmt='%0.3f';
                end
                value=num2str(value,[fmt ',']);                
                value=value(1:end-1);
            else
                if ~isempty(fmt)
                    value=num2str(value,fmt);
                else
                    value=num2str(value);
                end
            end
        case{'int','integer'}
            value=num2str(round(value));
        case{'date','datetime'}
            if ~isempty(fmt)
                value=datestr(value,fmt);
            else
                value=datestr(value,'yyyymmdd HHMMSS');
            end
    end
end

if includeattributes && ~isempty(attributes)
    attstr=getAttributeString(attributes);
else
    attstr='';
end
if iscell(value)
    for k=1:length(value)
        if isempty(value{k})
            str=[repmat(' ',1,ilev*nindent) '<' prefix name attstr '/>'];
        else
            str=[repmat(' ',1,ilev*nindent) '<' prefix name attstr '>' value{k} '</' prefix name '>'];
        end
        fprintf(fid,'%s\n',str);
    end
else
    if isempty(value)
        str=[repmat(' ',1,ilev*nindent) '<' prefix name attstr '/>'];
    else
        str=[repmat(' ',1,ilev*nindent) '<' prefix name attstr '>' value '</' prefix name '>'];
    end
    fprintf(fid,'%s\n',str);
end

%%
function writeopennode(fid,ilev,nindent,name,prefix,attributes,includeattributes)
if includeattributes && ~isempty(attributes)
    attstr=getAttributeString(attributes);
else
    attstr='';
end
fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '<' prefix name attstr '>']);

%%
function writeclosenode(fid,ilev,nindent,name,prefix)
fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '</' prefix name '>']);

%%
function attstr=getAttributeString(attributes)
attstr='';
if ~isempty(attributes)
    fldnames=fieldnames(attributes);
    for j=1:length(fldnames)
        %         switch lower(fldnames{j})
        %             % Don't write format and value to xml file
        %             case{'value','format'}
        %             otherwise
        prefix='';
        if isfield(attributes.(fldnames{j}),'PREFIX')
            prefix=attributes.(fldnames{j}).PREFIX;
        end
        name=[prefix fldnames{j}];
        value=attributes.(fldnames{j}).value;
        %         end
        try
            attstr=[attstr ' ' name '="' value '"'];
        catch
            shite=1
        end
    end
end
