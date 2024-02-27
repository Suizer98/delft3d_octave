function obspoints=ddb_nesthd1_dflowfm_in_delft3dflow(varargin)
%ddb_nesthd1_dflowfm_in_delft3dflow  Step 1 of nesting DFlow-FM model in Delft3D-FLOW model.
%
% Creates nesting administration file
% Optionally returns structure with new observation points for Delft3D-FLOW model
% Optionally creates temporary obs file for Delft3D-FLOW model
%
%   Example
%           newpoints=ddb_nesthd1_dflowfm_in_delft3dflow('admfile','nesting.adm','extfile','test.ext', ...
%                'grdfile','newyork.grd','encfile','newyork.enc');        
%
%   See also

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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_nesthd1_dflowfm_in_delft3dflow.m 11472 2014-11-27 15:12:11Z ormondt $
% $Date: 2014-11-27 16:12:11 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_nesthd1_dflowfm_in_delft3dflow.m $
% $Keywords: $

%%

% Set defaults
csoverall.name='WGS 84';
csoverall.type='geographic';
csdetail.name='WGS 84';
csdetail.type='geographic';
admfile='nesting.adm';
obsfile='';
extfile='';
grdfile='';
encfile='';

% Input
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'admfile'}
                admfile=varargin{ii+1};
            case{'extfile'}
                extfile=varargin{ii+1};
            case{'grdfile'}
                grdfile=varargin{ii+1};
            case{'encfile'}
                encfile=varargin{ii+1};
            case{'csoverall'}
                csoverall=varargin{ii+1};
            case{'csdetail'}
                csdetail=varargin{ii+1};
        end
    end
end

obspoints=[];
newpoints=[];

% Read overall grid data
[xg,yg,enc]=ddb_wlgrid('read',grdfile);
mn=ddb_enclosure('read',encfile);
[xg,yg]=ddb_enclosure('apply',mn,xg,yg);
[xz,yz]=getXZYZ(xg,yg);

% Read ext file
s=dflowfmreadextfile(extfile);
boundaries=s.boundaries;

% Compute distances
if strcmpi(csoverall.type,'geographic')
    spheric=1;
else
    spheric=0;
end

np=0;

for ipli=1:length(boundaries)
    
    % Loop through polylines

    % Read boundary pli
    dr=fileparts(extfile);
    [x,y]=landboundary('read',[dr filesep boundaries(ipli).filename]);
    
    % Convert pli to current coordinate system (when necessary)
    if ~strcmpi(csdetail.name,'unspecified')
        if ~strcmpi(csoverall.name,csdetail.name) || ~strcmpi(csoverall.type,csdetail.type)
            [x,y]=convertCoordinates(x,y,'CS1.name',csdetail.name,'CS1.type',csdetail.type, ...
                'CS2.name',csoverall.name,'CS2.type',csoverall.type);
        end
    end
    
    % Find grid cells
    [m,n]=findgridcell(x,y,xz,yz);

    for ip=1:length(x)

        if isnan(m(ip)) || isnan(n(ip))
            error(['Error, could not finish nesting step! Point ' num2str(ip) ' of polyline ' boundaries(ipli).name ' is not surrounded by sufficient grid points!']);
        end
        
        % Loop through points in polyline
        
        np=np+1;
        
        supportpoint(np).name=[boundaries(ipli).name '_' num2str(ip,'%0.4i')];
        
        % TODO Compute angle
        if spheric
            supportpoint(np).angle=0;
        else
            supportpoint(np).angle=0;
        end
        
        xx(1)=xz(m(ip)-1,n(ip)-1);
        xx(2)=xz(m(ip)  ,n(ip)-1);
        xx(3)=xz(m(ip)  ,n(ip)  );
        xx(4)=xz(m(ip)-1,n(ip)  );

        yy(1)=yz(m(ip)-1,n(ip)-1);
        yy(2)=yz(m(ip)  ,n(ip)-1);
        yy(3)=yz(m(ip)  ,n(ip)  );
        yy(4)=yz(m(ip)-1,n(ip)  );
        
        newpoints(np,1).m=m(ip)-1;
        newpoints(np,1).n=n(ip)-1;
        
        newpoints(np,2).m=m(ip);
        newpoints(np,2).n=n(ip)-1;
        
        newpoints(np,3).m=m(ip);
        newpoints(np,3).n=n(ip);
        
        newpoints(np,4).m=m(ip)-1;
        newpoints(np,4).n=n(ip);

        % Determine relative distances (within a computational cell)
        [rmnst,rnnst] = nesthd_reldif(x(ip),y(ip),xx,yy,spheric);

        newpoints(np,1).weight = (1.0 - rmnst)*(1.0 - rnnst);
        newpoints(np,2).weight = rmnst*(1.0 - rnnst);
        newpoints(np,3).weight = (1.0 - rmnst)*rnnst;
        newpoints(np,4).weight = rmnst*rnnst;
                
    end
end

% Write nesting administration file

fid=fopen(admfile,'wt');

fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* Deltares, NESTHD1 Version 1.56.02.11129, Apr  2 2010, 13:33:25');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* Run date: 2013/08/06 17:18:50'); 
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n',['* Name grid file overall model              : ' grdfile]);                                                                   
fprintf(fid,'%s\n',['* Name enclosure file overall model         : ' encfile]);                                                                   
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n',['* Name bnd. definition file detailed model  : ' extfile]);                                
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n',['* Name nest administration file             : ' admfile]);                                                                     
fprintf(fid,'%s\n',['* Name FLOW observation file                : ' obsfile]);                                                                      
fprintf(fid,'%s\n','*');

for ip=1:np 
    fprintf(fid,'%s\n',['Nest administration for water level support point ' supportpoint(ip).name]);
    for j=1:4
        fprintf(fid,'%6i %6i %8.3f\n',newpoints(ip,j).m,newpoints(ip,j).n,newpoints(ip,j).weight);
    end
end

for ip=1:np    
    fprintf(fid,'%s\n',['Nest administration for velocity    support point ' supportpoint(ip).name '  Angle =  ' num2str(supportpoint(ip).angle)]);
    for j=1:4
        fprintf(fid,'%6i %6i %8.3f\n',newpoints(ip,j).m,newpoints(ip,j).n,newpoints(ip,j).weight);
    end
end

fclose(fid);

% Store observation points that were found in output structure
mind=[];
nind=[];
nrobs=0;
for ip=1:np 
    for j=1:4
        ii=find(mind==newpoints(ip,j).m & nind==newpoints(ip,j).n, 1);
        if isempty(ii)
            % Point not yet defined
            nrobs=nrobs+1;
            obspoints(nrobs).m=newpoints(ip,j).m;
            obspoints(nrobs).n=newpoints(ip,j).n;
            mstr=[repmat(' ',1,5-length(num2str(newpoints(ip,j).m))) num2str(newpoints(ip,j).m)];
            nstr=[repmat(' ',1,5-length(num2str(newpoints(ip,j).n))) num2str(newpoints(ip,j).n)];
            obspoints(nrobs).name=['(M,N)=(' mstr ',' nstr ')'];
            mind(nrobs)=newpoints(ip,j).m;
            nind(nrobs)=newpoints(ip,j).n;
        end
    end
end
