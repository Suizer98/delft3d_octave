function handles = ddb_dnami_compute(handles)
%DDB_DNAMI_COMPUTE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_dnami_compute(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_dnami_compute
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_dnami_compute.m 10889 2014-06-25 08:09:38Z boer_we $
% $Date: 2014-06-25 16:09:38 +0800 (Wed, 25 Jun 2014) $
% $Author: boer_we $
% $Revision: 10889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tsunami/dnami/ddb_dnami_compute.m $
% $Keywords: $

%%
wb = waitbox('Generating Initial Tsunami ...');

progdir=[handles.ToolBoxDir 'tsunami'];

workdir=pwd;

degrad=pi/180;
raddeg=180/pi;

nseg=handles.toolbox.tsunami.NrSegments;

for i=1:nseg
    userfaultL(i)=handles.toolbox.tsunami.FaultLength(i);
    strike    (i)=handles.toolbox.tsunami.Strike(i);
    dip       (i)=handles.toolbox.tsunami.Dip(i);
    slip      (i)=handles.toolbox.tsunami.SlipRake(i);
end

Mw=handles.toolbox.tsunami.Magnitude;
totflength=handles.toolbox.tsunami.TotalFaultLength;
fwidth=handles.toolbox.tsunami.FaultWidth;
disloc=handles.toolbox.tsunami.Dislocation;
fdtop=handles.toolbox.tsunami.DepthFromTop;

faultX=handles.toolbox.tsunami.FaultX;
faultY=handles.toolbox.tsunami.FaultY;
xvrt=handles.toolbox.tsunami.VertexX;
yvrt=handles.toolbox.tsunami.VertexY;

filout=['dtt_out.txt'];
fid=fopen(filout,'w');

fprintf(fid,'%s %s\n','* East   North  strike    area   depth  dip   lambda         mu', .....
    '    U1    U2      U3     L     W     name     Figure');
fprintf(fid,'%s %s \n','* (km)   (km)  (deg CW N)  0/1  (km)   (deg)         ', .....
    '             (mm)   (mm)    (mm)  (km)   (km)            ');
%
% assume strike and fault direction are identical (as in the rest of the program)
% i.e. U3 == 0 always
%
utmz = fix( ( faultX(1) / 6 ) + 31);
for i=1:nseg
    [x,y] = ddb_deg2utm(xvrt(i,4),yvrt(i,4),utmz);
    fd = fwidth*sin(dip(i)*degrad) + fdtop;
    x=x/1000;
    y=y/1000;
    U1=disloc*cos(slip(i)*degrad)*1000;
    U2=disloc*sin(slip(i)*degrad)*1000;
    U3=0;
    txt=['Segment' int2str(i)];
    fprintf(fid,'%s %6.1f %6.1f %6.1f %2s %6.1f %6.1f %s %6.0f %6.0f %6.0f %6.1f %6.1f %s %s\n', ......
        ' ',x,y,strike(i), '        1',fd,dip(i),' 4.39e+9   3.64e+9 ', ......
        U1,U2,U3,userfaultL(i),fwidth,txt,' xxx');
end
fclose(fid);
%
% Write data to file 2; grid input for the OKADA model
%
filout='gridspec.txt';
fid=fopen(filout,'w');
%
% First the zone
%
% axes(handles.GUIHandles.Axis);
xgrdarea=get(handles.GUIHandles.mapAxis,'XLim');
ygrdarea=get(handles.GUIHandles.mapAxis,'YLim');
grdsize=(xgrdarea(2)-xgrdarea(1))/200;
%grdsize=(xgrdarea(2)-xgrdarea(1))/100;

fprintf(fid,'%s %4.0f %6.1f %6.1f\n', 'Z ', utmz,((utmz-1)*6-180),ygrdarea(1));
%
% Simple Grid; single file no mask
%
Mg=fix((xgrdarea(2)-xgrdarea(1))/grdsize) + 1;
Ng=fix((ygrdarea(2)-ygrdarea(1))/grdsize) + 1;
fprintf(fid,'%s %12.5f %12.5f %12.5f %12.5f %5s %5s\n', 'G ', .....
    xgrdarea(1),ygrdarea(1),grdsize,grdsize,int2str(Mg),int2str(Ng));

ngfile=1;
fprintf(fid,'%s %s\n', 'S ', [workdir '\' handles.Model(md).Input(ad).GrdFile]);
fprintf(fid,'%s %s\n', 'D ', [workdir '\' handles.Model(md).Input(ad).DepFile]);
fclose(fid);
pause(2);
%
% execute program
%
%evaltxt=['"' progdir '\rngchn_init.exe" "' workdir '\gridspec.txt" "' workdir '\dtt_out.txt" "' workdir '\disp.xyz" ascii'];
evaltxt=['"' progdir '\rngchn_init.exe" gridspec.txt dtt_out.txt disp.xyz ascii'];
system(evaltxt);
%
%present result only on the simple grid file
%
close(wb);
fig3 = figure('Tag','Figure3','Name', 'Result');
set(fig3,'menubar','none');
set(fig3,'toolbar','figure');
set(fig3,'renderer','opengl');
tbh = findall(fig3,'Type','uitoolbar');
delete(findall(tbh,'TooltipString','Edit Plot'));
delete(findall(tbh,'TooltipString','Rotate 3D'));
delete(findall(tbh,'TooltipString','Show Plot Tools and Dock Figure'));
delete(findall(tbh,'TooltipString','New Figure'));
delete(findall(tbh,'TooltipString','Open File'));
delete(findall(tbh,'TooltipString','Save Figure'));
delete(findall(tbh,'TooltipString','Print Figure'));
delete(findall(tbh,'TooltipString','Data Cursor'));
delete(findall(tbh,'TooltipString','Insert Colorbar'));
delete(findall(tbh,'TooltipString','Insert Legend'));
delete(findall(tbh,'TooltipString','Hide Plot Tools'));
delete(findall(tbh,'TooltipString','Show Plot Tools'));

title('Initial Tsunami');

xrange = xgrdarea(1):grdsize:xgrdarea(2); M = length(xrange);
yrange = ygrdarea(1):grdsize:ygrdarea(2); N = length(yrange);

[X Y] = meshgrid(xrange,yrange);

dp=ddb_wldep('read','disp.ini',[M N]);
dp(dp==-999)=NaN;
surf(X,Y,dp');
shading flat;
grid on;
hold on;

load([handles.SettingsDir 'geo\worldcoastline.mat']);
xldb=wclx;
yldb=wcly;
z=zeros(size(xldb))+10;
landb=plot3(xldb,yldb,z,'k');

load([handles.SettingsDir 'geo\plates.mat']);
platesz=zeros(size(platesx))+10;
h=plot3(platesx,platesy,platesz);
set(h,'Color',[1.0 0.5 0.00]);
set(h,'LineWidth',1.5);
set(h,'HitTest','off');

xlabel ('X');
ylabel ('Y');
clbar=colorbar;
set(get(clbar,'YLabel'),'String','Initial water level (m w.r.t. MSL)');
axis equal;
view(2);
set(gca,'XLim',xgrdarea,'YLim',ygrdarea);


if ~isempty(handles.Model(md).Input(ad).GrdFile)
    s=handles.Model(md).Input(ad).GrdFile;
    ii=findstr(s,'.grd');
    fname=[handles.Model(md).Input(ad).GrdFile(1:ii-1) '.ini'];
else
    fname=handles.Model(md).Input(ad).AttName;
end

[filename, pathname, filterindex] = uiputfile('*.ini', 'Select Initial Conditions File',fname);
if strcmpi(pathname(1:end-1),pwd)
    handles.Model(md).Input(ad).IniFile=filename;
else
    handles.Model(md).Input(ad).IniFile=[pathname filename];
end
handles.Model(md).Input(ad).InitialConditions='ini';

evaltxt=['! move ' fname ' ' filename];
eval(evaltxt);

ButtonName = questdlg('Reset all boundaries to Riemann?','','No', 'Yes', 'Yes');
switch ButtonName,
    case 'Yes',
        id=ad;
        for nb=1:handles.Model(md).Input(id).NrOpenBoundaries
            handles.Model(md).Input(id).OpenBoundaries(nb).Type='R';
            handles.Model(md).Input(id).OpenBoundaries(nb).Forcing='T';
            t0=handles.Model(md).Input(id).StartTime;
            t1=handles.Model(md).Input(id).StopTime;
            handles.Model(md).Input(id).OpenBoundaries(nb).TimeSeriesT=[t0 t1];
            handles.Model(md).Input(id).OpenBoundaries(nb).TimeSeriesA=[0.0 0.0];
            handles.Model(md).Input(id).OpenBoundaries(nb).TimeSeriesB=[0.0 0.0];
        end
end

figure(handles.GUIHandles.MainWindow);

