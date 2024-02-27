function varargout = matchDDDepths(varargin)
%MATCHDDDEPTHS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = matchDDDepths(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   matchDDDepths
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: matchDDDepths.m 5557 2011-12-01 16:25:56Z boer_we $
% $Date: 2011-12-02 00:25:56 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5557 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/DD/matchDDDepths.m $
% $Keywords: $

%%
% Changes first one (in case of dpsopt=dp and coarse domain to the right/top of fine domain) or two depth rows
% in finer domain (with runid2), based on value found in coarser domain (with runid1).
% e.g.
% matchDDDepths('runid1','coa.mdf','runid2','fin.mdf','ddboundfile','model.ddb','depthfile1','coarse.dep','mmax1',100,'nmax1',50, ...
%   'depthfile2','fine.dep','mmax2',200,'nmax2',100,'dpsopt','DP');
% or
% z2=matchDDDepths('runid1','coa','runid2','fin','depth1',z1,'depth2',z2,'ddboundfile','model.ddb','dpsopt','DP');

dpsopt='DP';

depthfile1=[];
depthfile2=[];
depthfileout=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'runid1'}
                runid1=varargin{i+1};
            case{'runid2'}
                runid2=varargin{i+1};
            case{'depthfile1'}
                depthfile1=varargin{i+1};
            case{'mmax1'}
                mmax1=varargin{i+1};
            case{'nmax1'}
                nmax1=varargin{i+1};
            case{'depthfile2'}
                depthfile2=varargin{i+1};
            case{'mmax2'}
                mmax2=varargin{i+1};
            case{'nmax2'}
                nmax2=varargin{i+1};
            case{'depth1'}
                z1=varargin{i+1};
            case{'depth2'}
                z2=varargin{i+1};
            case{'dpsopt'}
                dpsopt=varargin{i+1};
            case{'ddboundfile'}
                ddbound=readDDBound(varargin{i+1});
            case{'ddbound'}
                ddbound=varargin{i+1};
            case{'newdepthfile'}
                depthfileout=varargin{i+1};
        end
    end
end

if ~isempty(depthfile1)
    z1=wldep('read',depthfile1,[mmax1 nmax1]);
    z1=getDepthZ(z1,dpsopt);
end

if ~isempty(depthfile2)
    z2=wldep('read',depthfile2,[mmax2 nmax2]);
end

if strcmpi(dpsopt,'dp')
    madd=0;
else
    madd=1;
end

% ddbound=readDDBound(ddboundfile);

ndb=length(ddbound);

for k=1:ndb
    if strcmpi(ddbound(k).runid1,runid1) && strcmpi(ddbound(k).runid2,runid2)
        % Coarse domain to the left/bottom of fine domain
        m1a=ddbound(k).m1a;
        m1b=ddbound(k).m1b;
        n1a=ddbound(k).n1a;
        n1b=ddbound(k).n1b;
        m2a=ddbound(k).m2a;
        m2b=ddbound(k).m2b;
        n2a=ddbound(k).n2a;
        n2b=ddbound(k).n2b;
        if m1a==m1b
            % Coarse domain at left
            nref=(n2b-n2a)/(n1b-n1a);
            j=0;
            for n=n1a+1:n1b
                j=j+1;
                ma=m2a;
                mb=m2a+1;
                na=n2a+(j-1)*nref+1;
                nb=n2a+j*nref;
                z2(ma:mb,na:nb)=z1(m1a,n);
            end
        else
            % Coarse domain at bottom
            mref=(m2b-m2a)/(m1b-m1a);
            j=0;
            for m=m1a+1:m1b
                j=j+1;
                na=n2a;
                nb=n2a+1;
                ma=m2a+(j-1)*mref+1;
                mb=m2a+j*mref;
                z2(ma:mb,na:nb)=z1(m,n1a);
            end
        end
    elseif strcmpi(ddbound(k).runid2,runid1) && strcmpi(ddbound(k).runid1,runid2)
        % Coarse domain to the right/top of fine domain
        m1a=ddbound(k).m2a;
        m1b=ddbound(k).m2b;
        n1a=ddbound(k).n2a;
        n1b=ddbound(k).n2b;
        m2a=ddbound(k).m1a;
        m2b=ddbound(k).m1b;
        n2a=ddbound(k).n1a;
        n2b=ddbound(k).n1b;
        if m1a==m1b
            % Coarse domain at right
            nref=(n2b-n2a)/(n1b-n1a);
            j=0;
            for n=n1a+1:n1b
                j=j+1;
                ma=m2a;
                mb=m2a-madd;
                na=n2a+(j-1)*nref+1;
                nb=n2a+j*nref;
                z2(ma:mb,na:nb)=z1(m1a+1,n);
            end
        else
            % Coarse domain at top
            mref=(m2b-m2a)/(m1b-m1a);
            j=0;
            for m=m1a+1:m1b
                j=j+1;
                na=n2a;
                nb=n2a-madd;
                ma=m2a+(j-1)*mref+1;
                mb=m2a+j*mref;
                z2(ma:mb,na:nb)=z1(m,n1a+1);
            end
        end
    else
        % Different domains
    end
end

% Write new depth file
if ~isempty(depthfileout)
    wldep('write',depthfileout,z2);
end

% Set output argument to z2
if nargout>0
    varargout{1}=z2;
end

%%
function ddbound=readDDBound(fname)

txt=ReadTextFile(fname);

nbnd=length(txt)/10;

rids={''};

nd=0;

k=1;
for i=1:nbnd
    ddbound(i).runid1=txt{k};
    ii=strmatch(txt{k},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k};
    end
    ddbound(i).m1a=str2double(txt{k+1});
    ddbound(i).n1a=str2double(txt{k+2});
    ddbound(i).m1b=str2double(txt{k+3});
    ddbound(i).n1b=str2double(txt{k+4});
    ddbound(i).runid2=txt{k+5};
    ii=strmatch(txt{k+5},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k+5};
    end
    ddbound(i).m2a=str2double(txt{k+6});
    ddbound(i).n2a=str2double(txt{k+7});
    ddbound(i).m2b=str2double(txt{k+8});
    ddbound(i).n2b=str2double(txt{k+9});
    k=k+10;
end

%%
function txt=ReadTextFile(FileName)

fid=fopen(FileName);

k=0;
for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if size(v0,1)>0
        if strcmp(tx0(1),'#')==0
            v=strread(tx0,'%q');
            nowords=size(v,1);
            for j=1:nowords
                k=k+1;
                txt{k}=v{j};
            end
            clear v;
        end
    end
end

fclose(fid);

%%
function varargout=wldep(cmd,varargin)
% WLDEP read/write Delft3D field files (e.g. depth files)
%    WLDEP can be used to read and write Delft3D field
%    files used for depth and roughness data.
%
%    DEPTH=WLDEP('read',FILENAME,SIZE)
%    or
%    DEPTH=WLDEP('read',FILENAME,GRID)
%    where GRID was generated by WLGRID.
%
%    STRUCT=WLDEP(...,'multiple') to read multiple fields
%    from the file. The function returns a structure vector
%    with one field: Data.
%    [FLD1,FLD2,...]=WLDEP(...,'multiple') to read multiple
%    fields from the file. The function returns one field
%    to one output argument.
%
%    WLDEP('write',FILENAME,MATRIX)
%    or
%    WLDEP('write',FILENAME,STRUCT)
%    where STRUCT is a structure vector with one field: Data.
%

% (c) copyright, Delft Hydraulics, 2000
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
    if nargout>0,
        varargout=cell(1,nargout);
    end;
    return;
end;

switch cmd,
    case 'read',
        if nargout>1, % automatically add 'multiple'
            if nargin==3, % cmd, filename, size
                varargin{3}='multiple';
            end;
        end;
        Dep=Local_depread(varargin{:});
        if isstruct(Dep),
            if length(Dep)<nargout,
                error('Too many output arguments.');
            end;
            if nargout==1
                varargout{1}=Dep;
            else
                for i=1:max(1,nargout),
                    varargout{i}=Dep(i).Data;
                end;
            end
        elseif nargout>1,
            error('Too many output arguments.');
        else, % nargout<=1
            varargout={Dep};
        end;
    case {'write','append'}
        Out=Local_depwrite(cmd,varargin{:});
        if nargout>0,
            varargout{1}=Out;
        end;
    otherwise,
        error('Unknown command');
end;

function DP=Local_depread(filename,dimvar,option)
% DEPREAD reads depth information from a given filename
%    DEPTH=DEPREAD('FILENAME.DEP',SIZE)
%    or
%    DEPTH=DEPREAD('FILENAME.DEP',GRID)
%    where GRID was generated by GRDREAD.
%
%    ...,'multiple') to read multiple fields from the file.

DP=[];

if nargin<2,
    error('No size or grid specified.');
end;

if nargin<3,
    multiple=0;
else,
    multiple=strcmp(option,'multiple');
    if ~multiple,
        warning('Unknown option.');
    end;
end;

if strcmp(filename,'?'),
    [fname,fpath]=uigetfile('*.*','Select depth file');
    if ~ischar(fname),
        return;
    end;
    filename=[fpath,fname];
end;

fid=fopen(filename);
if fid<0,
    error(['Cannot open ',filename,'.']);
end;
if isstruct(dimvar), % new grid format G.X, G.Y, G.Enclosure
    dim=size(dimvar.X)+1;
elseif iscell(dimvar), % old grid format {X Y Enclosure}
    dim=size(dimvar{1})+1;
else
    dim=dimvar;
end;
i=1;
More=1;
while 1,
    %
    % Skip lines starting with *
    %
    line='*';
    cl=0;
    while ~isempty(line) && line(1)=='*'
        if cl>0
            DP(i).Comment{cl,1}=line;
        end
        cl=cl+1;
        currentpoint=ftell(fid);
        line=fgetl(fid);
    end
    fseek(fid,currentpoint,-1);
    %
    [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
    if NRead==0 % accept bagger input files containing 'keyword' on the first line ...
        str=fscanf(fid,['''%[^' char(10) char(13) ''']%['']']);
        if ~isempty(str) && isequal(str(end),'''')
            [DP(i).Data,NRead]=fscanf(fid,'%f',dim);
            DP(i).Keyword=str(1:end-1);
        end
    end
    DP(i).Data=DP(i).Data;
    %
    % Read remainder of last line
    %
    Rem=fgetl(fid);
    if ~ischar(Rem)
        Rem='';
    else
        Rem=deblank(Rem);
    end
    if NRead<prod(dim)
        if strcmp(Rem,'')
            Str=sprintf('Not enough data in the file for complete field %i (only %i out of %i values).',i,NRead,prod(dim));
            if i==1 % most probably wrong file format
                error(Str);
            else
                warning(Str);
            end
        else
            error(sprintf('Invalid string while reading data: %s',Rem));
        end
    end
    pos=ftell(fid);
    if isempty(fscanf(fid,'%f',1)),
        break; % no more data (at least not readable)
    elseif ~multiple,
        fprintf('More data in the file. Use ''multiple'' option to read all fields.\n');
        break; % don't read data although there seems to be more ...
    end;
    fseek(fid,pos,-1);
    i=i+1;
end;
fclose(fid);
if ~multiple,
    DP=DP.Data;
end;


function OK=Local_depwrite(cmd,filename,DP,varargin)
% DEPWRITE writes depth information to a given filename
%
% Usage: depwrite('filename',Matrix)
%
%    or: depwrite('filename',Struct)
%        where Struct is a structure vector with one field: Data
negate='y';
bndopt='9';

if nargin>3
    for i=1:nargin-3
        switch lower(varargin{i})
            case{'negate'}
                negate=varargin{i+1}(1);
            case{'bndopt'}
                bndopt=varargin{i+1}(1);
        end
    end
end

OK=0;
if isstruct(DP),
    % DP(1:N).Data=Matrix;
    fid=fopen(filename,'w');
    
    for i=1:length(DP),
        if isfield(DP,'Keyword') && ~isempty(DP(i).Keyword)
            fprintf(fid,'''%s''\n',DP(i).Keyword);
        end
        DP(i).Data=DP(i).Data;
        DP(i).Data(isnan(DP(i).Data))=-999;
        
        Frmt=repmat('%15.8f  ',[1 size(DP(i).Data,1)]);
        k=8*12;
        Frmt((k-1):k:length(Frmt))='\';
        Frmt(k:k:length(Frmt))='n';
        Frmt(end-1:end)='\n';
        fprintf(fid,Frmt,DP(i).Data);
    end;
    
    fclose(fid);
    
else
    % DP=Matrix;
    if DP(end,end)~=-999,
        switch lower(negate)
            case {'y'}
                DP=-DP;
        end;
        switch lower(bndopt)
            case {'9'}
                DP=[DP -999*ones(size(DP,1),1); ...
                    -999*ones(1,size(DP,2)+1)];
            case {'b'}
                DP=[DP DP(:,end); ...
                    DP(end,:) DP(end,end)];
        end
    end
    
    DP(isnan(DP))=-999;
    
    switch cmd,
        case{'write'}
            fid=fopen(filename,'w');
        case{'append'}
            fid=fopen(filename,'a');
    end
    
    Frmt=repmat('%15.8f  ',[1 size(DP,1)]);
    k=8*12;
    Frmt((k-1):k:length(Frmt))='\';
    Frmt(k:k:length(Frmt))='n';
    Frmt(end-1:end)='\n';
    fprintf(fid,Frmt,DP);
    
    fclose(fid);
end;
OK=1;

%%
function zz=getDepthZ(z,dpsopt)

zz=zeros(size(z));
zz(zz==0)=NaN;

z1=z(1:end-1,1:end-1);
z2=z(2:end  ,1:end-1);
z3=z(2:end  ,2:end  );
z4=z(1:end-1,2:end  );

switch lower(dpsopt)
    case{'dp'}
        zz=z;
    case{'min'}
        zz0=max(z1,z2);
        zz0=max(zz0,z3);
        zz0=max(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'max'}
        zz0=min(z1,z2);
        zz0=min(zz0,z3);
        zz0=min(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'mean'}
        zz(2:end,2:end)=(z1+z2+z3+z4)/4;
end

