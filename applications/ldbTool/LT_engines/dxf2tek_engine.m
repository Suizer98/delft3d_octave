function outList=dxf2tek_engine(dxfFile,options)
%DXF2TEK_ENGINE Converts dxf (AutoCAD) to tek (tekal) file
%
% This tool can be used to read a dxf-file and convert it to a tekal file.
% Save DXF as ASCII DXF R12, with the 'Select objects' option. Blocks, 
% Tables and other advanced stuff is ignored. Explode your stuff first!
%
% Syntax:
% outList=dxf2tek_engine(dxfFile,options)
%
% dxfFile:  name of dxf-file
% options:  (optional) structure with fields:
%           options.txt:   set to 0 to ignore text
%           options.dang:  specify angle-resolution (degrees) for arcs
% outList:  output array, [Mx2] for landboundaries, [Mx3] for samples
%
% See also: DXF2TEK, LDBTOOL, SHAPE2LDB, KML2LDB, DXF

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robin Morelissen / Arjan Mol
%
%       robin.morelissen@deltares.nl
%       arjan.mol@deltares.nl
%
%       Deltares
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

%% Code
lineCount=[];

if ~exist('options','var')
    options.dummy=[]; %make dummy struct and use defaults along the way
end

%Default: ignore text
if ~isfield(options,'txt')
    options.txt=0;
end
%Default dang for arc=1
if ~isfield(options,'arcdang')|isempty(str2num(options.arcdang))
    options.arcdang=1;
end


d=textread(dxfFile,'%s','whitespace','\n');
%Find all objects
id=find(strcmp(d,'0'));
id=id+1; %Object type will be in the next cell

%Known objects
knownObjects={'text','polyline','line','point','arc','circle','3dface'};

objCount=0;

%Loop through known objects
for ko=1:length(knownObjects)
    
    co=find(strcmpi(d(id),knownObjects{ko})); %Find current objects
    
    wH=waitbar(0,['Working on ' knownObjects{ko} ' objects (step ' num2str(ko) ' of ' num2str(length(knownObjects)) ')']);
    set(wH,'doublebuffer','on');
    
    
    %loop through found objects
    for fo=1:length(co)
        
        waitbar(fo/length(co),wH);
        drawnow;
        
        %Reset lineCount
        lineCount=-1; %so that value and code will be right!
        
        [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
        
        switch lower(knownObjects{ko})
            case 'text'
                if options.txt~=0
                    objCount=objCount+1;
                    gCode=999;
                    while gCode~=0
                        switch gCode
                            case 10
                                objs(objCount).x(1)=str2num(gValue);
                            case 20
                                objs(objCount).y(1)=str2num(gValue);
                            case 30
                                if options.txt==1
                                    objs(objCount).z=str2num(gValue);
                                    if isempty(str2num(gValue))
                                        objCount=objCount-1;
                                    end
                                    
                                end
                            case 1
                                if options.txt==2
                                    objs(objCount).z=str2num(gValue);
                                    if isempty(str2num(gValue))
                                        objCount=objCount-1;
                                    end
                                    
                                end
                        end
                        [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                    end
                else
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                
                
            case 'polyline'
                %Read until first VERTEX
                [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                while ~strcmp(lower(gValue),'vertex')
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                %Start of polyline
                objCount=objCount+1;
                gCode=999;
                vertexCount=0;
                while ~(gCode==0&strcmp(lower(gValue),'seqend'))
                    if strcmp(lower(gValue),'vertex')
                        vertexCount=vertexCount+1;
                    end
                    switch gCode
                        case 10
                            objs(objCount).x(vertexCount)=str2num(gValue);
                        case 20
                            objs(objCount).y(vertexCount)=str2num(gValue);
                        case 30
                            objs(objCount).z(vertexCount)=str2num(gValue);
                            if isempty(objs(objCount).z(vertexCount))
                                objs(objCount).z(vertexCount)=0;
                            end
                    end
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                    
                end
                
                
                
            case 'line'
                objCount=objCount+1;
                gCode=999;
                while gCode~=0
                    switch gCode
                        case 10
                            objs(objCount).x(1)=str2num(gValue);
                        case 20
                            objs(objCount).y(1)=str2num(gValue);
                        case 30
                            objs(objCount).z(1)=str2num(gValue);
                            if isempty(objs(objCount).z(1))
                                objs(objCount).z(1)=0;
                            end
                            
                        case 11
                            objs(objCount).x(2)=str2num(gValue);
                        case 21
                            objs(objCount).y(2)=str2num(gValue);
                        case 31
                            objs(objCount).z(2)=str2num(gValue);
                            if isempty(objs(objCount).z(2))
                                objs(objCount).z(2)=0;
                            end
                            
                            
                    end
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                
                
                
            case 'point'
                objCount=objCount+1;
                gCode=999;
                while gCode~=0
                    switch gCode
                        case 10
                            objs(objCount).x(1)=str2num(gValue);
                        case 20
                            objs(objCount).y(1)=str2num(gValue);
                        case 30
                            objs(objCount).z(1)=str2num(gValue);
                            if isempty(objs(objCount).z(1))
                                objs(objCount).z(1)=0;
                            end
                    end
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                
                
                
                
            case 'arc'
                objCount=objCount+1;
                gCode=999;
                while gCode~=0
                    switch gCode
                        case 10
                            cx=str2num(gValue);
                        case 20
                            cy=str2num(gValue);
                        case 30
                            cz=str2num(gValue);
                            if isempty(cz)
                                cz=0;
                            end
                        case 40
                            radius=str2num(gValue);
                        case 50
                            a1=str2num(gValue);
                        case 51
                            a2=str2num(gValue);
                    end
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                
                [x,y]=arc(cx, cy, a1, a2, radius, options.arcdang);
                objs(objCount).x=x;
                objs(objCount).y=y;
                objs(objCount).z=repmat(cz,1,length(x));
                
                
                
                
            case 'circle'
                objCount=objCount+1;
                gCode=999;
                while gCode~=0
                    switch gCode
                        case 10
                            cx=str2num(gValue);
                        case 20
                            cy=str2num(gValue);
                        case 30
                            cz=str2num(gValue);
                            if isempty(cz)
                                cz=0;
                            end
                        case 40
                            radius=str2num(gValue);
                    end
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                
                [x,y]=arc(cx, cy, 0, 360, radius, options.arcdang);
                objs(objCount).x=x;
                objs(objCount).y=y;
                objs(objCount).z=repmat(cz,1,length(x));
                
            case '3dface'
                %Read until gValue = CONTINUOUS
                [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                while ~strcmpi(gValue,'CONTINUOUS')
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                end
                % read extra dummy row
                [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                
                % now starts object
                objCount=objCount+1;
                gCode=999;
                pointCount = 0;
                
                while gCode~=0
                    [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                    if gCode~=0
                        pointCount = pointCount+1;
                        objs(objCount).x(pointCount) = str2num(gValue);
                        [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                        objs(objCount).y(pointCount) = str2num(gValue);
                        [gCode,gValue,lineCount]=readDXFPair(d,id(co(fo)),lineCount);
                        objs(objCount).z(pointCount) = str2num(gValue);
                    end
                end
                              
        end %end switch
    end %current object loop
    close(wH);
end %known objects loop


try;delete(wH);end



%Write tekal
if isfield(options,'delSmall')&options.delSmall==1
    for ii=1:length(objs)
        firstX(ii)=objs(ii).x(1);
    end
    id=find(abs(firstX)<10);
    objs(id)=[];
end

%Write tekal
if isfield(options,'delSinglePoint')&options.delSinglePoint==1
    for ii=1:length(objs)
        lengthObj(ii)=length(objs(ii).x);
    end
    id=find(lengthObj<2);
    objs(id)=[];
end

if ~isfield(options,'numOfCols')
    options.numOfCols=2;
end


switch options.numOfCols
    case 2
        outList=[];
        
        cx={objs.x};
        lc=length(cx);
        cx(1:2:lc*2-1)=cx;
        cx(2:2:lc*2)={999.999};
        cy={objs.y};
        cy(1:2:lc*2-1)=cy;
        cy(2:2:lc*2)={999.999};
        
        outList=[[cx{:}]' [cy{:}]'];
        
    case 3
        outList=[];
        
        for ii=1:length(objs)
            if ~isempty(objs(ii).z)
                outList=[outList;objs(ii).x' objs(ii).y' objs(ii).z';999.999 999.999 999.999];
            end
        end
end





function [gCode,gValue,lineCount]=readDXFPair(d,id,lineCount)


gCode=str2num(char(d(id+lineCount)));
gValue=char(d(id+lineCount+1));
%Linecount
lineCount=lineCount+2;






function [x,y]=arc(cx, cy, a1, a2, radius,dang)

d2r = pi/180;

if ~exist('dang','var')
    dang = 1;
end

if (a2-a1)<0
    nseg = ceil(abs((360-a1)+a2)/dang);
    da=((360-a1)+a2)/nseg;
else
    nseg = ceil(abs(a2-a1)/dang);
    da=(a2-a1)/nseg;
end
alpha=a1;

n=nseg+1;
for i=1:n
    x(i) = cx+radius*cos(alpha*d2r);
    y(i) = cy+radius*sin(alpha*d2r);
    alpha=alpha+da;
    if alpha>=360
        alpha=alpha-360;
    end
    if alpha<=0
        alpha=alpha+360;
    end
end

