function PRN2kml_lines(PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile,EPSGcode,EPSG)
%function PRN2kml_lines : Converts a UNIBEST PRN-file into a KML-file with coastlines 
%
%   Syntax:
%     PRN2kml_lines(PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile,EPSGcode,EPSG)
%
%   Input:
%     PRNfile      string with PRN filename
%     MDAfile      (optional) MDA file used to compute the angle of coast (if applied than the orientation of the bars will be improved)
%     timesteps    timesteps for which output is generated (leave empty for all data)
%     reftime      reference time for start of model simulation ('yyyy-mm-dd' or in datenum format)
%     vectorscale  scale of the vector
%     KMLfile      output filename of KML (possible to include the path)
%     EPSGcode     code for transforming the cartesian system back to WGS84 geo (EPSGcode=28992 for RD-coordinates)
%     EPSG         matlab structure database with EPSG information
%
%   Output:
%     .sos files
% 
%   Example:
%     PRNfile = 'd:\UB7\HollandCoast_HK41\A_defaultCL2005\BWN2005REFERENCE.PRN';
%     MDAfile = 'd:\UB7\HollandCoast_HK41\A_defaultCL2005\Basis.mda';
%     timesteps=[1:40];
%     reftime='2005-01-01';
%     vectorscale = 10;
%     EPSGcode=28992;
%     EPSG = load('EPSG');
%     KMLfile=''; %<- will then automatically get name of PRNfile
%     PRN2kml_lines(PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile,EPSGcode,EPSG)
%
%   See also 
%     PRN2kml_bars

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: PRN2kml_lines.m 8631 2013-05-16 14:22:14Z huism_b $
% $Date: 2013-05-16 16:22:14 +0200 (Thu, 16 May 2013) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/postprocess/PRN2kml_lines.m $
% $Keywords: $


    %% load data
    %PRNfile,MDAfile,timesteps,reftime,vectorscale,KMLfile
    PRNdata = readPRN(PRNfile);
    [pthnm,filnm,extnm]=fileparts(PRNfile);
    if ~isempty(MDAfile);    MDAdata=readMDA(MDAfile);end
    if isempty(vectorscale); vectorscale=10; end
    if isempty(EPSG);        EPSG=load('EPSG'); end
    if isempty(EPSGcode);    EPSGcode=28992; end
    if isempty(KMLfile);     KMLfile = [filnm,'.kml']; end

    %% reference time
    reftimenum = 0;
    DT=1000;
    if ~isempty(reftime);reftimenum = datenum(reftime,'yyyy-mm-dd');end
    if isempty(timesteps);timesteps=[1:PRNdata.year];end
    if length(timesteps)>1;DT = PRNdata.year(2)-PRNdata.year(1);end

    %% coast angle
    ANGLEcoast = mean(PRNdata.alfa(:,timesteps),2);
    smoothvar(ANGLEcoast,10);
    if ~isempty(MDAdata)
        ANGLEcoast = MDAdata.ANGLEcoast;
    end

    %%-------------------------------------------------------------------------
    %% write coastlines to KML file
    %%-------------------------------------------------------------------------
    colours     = jet(length(timesteps));
    fid         = fopen(KMLfile,'wt');
    kml         = KML_header('kmlName',filnm);
    for tt=timesteps
        S.name      = ['col',num2str(tt)];
        x = PRNdata.x(:,tt);
        y = PRNdata.y(:,tt);
        z = PRNdata.zminz0(:,tt);
        t1 = PRNdata.year(tt)*365.25+reftimenum; 
        if tt<length(timesteps)
        t2 = PRNdata.year(tt+1)*365.25+reftimenum;
        else
        t2 = PRNdata.year(tt)*365.25+reftimenum+DT*365.25;
        end
        tstart = datestr(t1,'yyyy-mm-ddTHH:MM:SS');
        tend   = datestr(t2,'yyyy-mm-ddTHH:MM:SS');
        S.lineColor = colours(tt,:);  % color of the lines in RGB
        S.lineAlpha = [0.8] ;     % transparency of the line, (0..1) with 0 transparent
        S.lineWidth = 2;        % line width, can be a fraction     
        S0 = S; 
        S0.name      = ['col0'];
        S0.lineColor = [0.3 0.3 0.3];

        [lon,lat] = convertCoordinates(x,y,EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');

        if tt==1
        kml         = [kml KML_style(S0)];
        kml         = [kml KML_line(lat,lon,'styleName',S0.name)];
        end 
        kml         = [kml KML_style(S)];
        kml         = [kml KML_line(lat,lon,'styleName',S.name,'timeIn',tstart,'timeOut',tend)];
    end
    kml         = [kml KML_footer];
    fprintf(fid,kml);
    fclose all;
end

%%-----------------------------------------------------------------------------
%% sub-functions
%%-----------------------------------------------------------------------------
function smoothvar(value,iter)
    rotval=0;
    if size(value,2)>size(value,2)
        value=value';
        rotval=1;
    end
    for ii=1:iter
    value = [value(1);(value(2:end)+value(1:end-1))/2;value(end)];
    end
    if rotval==1
        value=value';
    end
end
