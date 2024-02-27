function [xOut, yOut,midLine]=line2curvi(x,y,parStep,perStep,varargin)
%LINE2CURVI converts a line given by coordinates (x,y) to a curvi linear 
% grid where one dimension is perpendicular to the line.
%
%Syntax:
%	[xOut yOut]=line2curvi(x,y,perStep,parStep)

%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   x  = x line coordinate
%   y  = y line coordinate
%   parStep  = parallel step
%   perStep  = perpendicular step
%
%   Optional input:
%   rmax = maximum grid distance from line
%
%   Output:
%   xOut = x grid coordinate
%   yOut = y grid coordinate
%   midLine = coordinate of center line grid
%
%   Example
%   myspl(:,1) = 1:500;
%   myspl(:,2) = zeros(500,1);
%   [xOut yOut]=line2curvi(myspl(:,1),myspl(:,2),50,10,'rmax',50);
%
%   Note:
%   The grid may have the wrong grid orientation for Delft3D. In that case,
%   read the grid with delft3d_io_grd and write it back with another
%   filename. The delft3d_io_grd function writes the grid with the correct
%   orientation
%
%   See also delft3d_io_grd


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 28 Jul 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: line2curvi.m 12043 2015-06-29 21:32:52Z bartgrasmeijer.x $
% $Date: 2015-06-30 05:32:52 +0800 (Tue, 30 Jun 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 12043 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/line2curvi.m $
% $Keywords: $

%%PREPROCESSING

%keywords
OPT.dstep=1e1;
OPT.rmax=[];
OPT.length_transect=[]; 
OPT.waitbar=true; 
OPT=setproperty(OPT,varargin); 


%check consistency dimension
if length(x)~=length(y)
	error('x and y must have the same dimension'); 
else
	%convert to column vectors
	x=reshape(x,[],1); y=reshape(y,[],1); 
end

%If closed polygon remove last point
if x(end)==x(1) && y(end)==y(1)
	x=x(1:end-1); y=y(1:end-1); 
end

%interpolate
[di,xi,yi]=local_lineInterp(x,y,OPT.dstep); 

%calculate default Rmax
if isempty(OPT.rmax)
    OPT.rmax=di(end);
end

%calculate default length_transect
if length(OPT.length_transect)<2
	OPT.length_transect=[OPT.rmax,OPT.rmax];
end


%% CALCULATE GRID POINTS ON LINE

if OPT.waitbar
	display('Calculating location grid points parallel to line'); 
end

switch(local_testStepStruct(parStep))
	case 1
		%constant value parStep
		parStepIn=parStep; parStep=struct('d',di,'step',parStepIn*ones(size(di)));				
	case 2
		%value defined in tangential coordinates
		parStep=parStep; 
	case 3
		%value defined on grid
			
		%write step size
		step=interp2(parStep.x,parStep.y,parStep.step,xi,yi); 
		meanStep=nanmean(parStep.step(:)); 
		parStep=struct('d',[],'step',[]); 
		parStep.d=di; parStep.step=step; 
		parStep.step(isnan(parStep.step) | parStep.step<=0)=meanStep; 	
	otherwise
		error('Input format parStep is invalid.'); 
end %end if parStep

midLine=[di(1),xi(1),yi(1)];
while 1
	%calculate (d,x,y)-coordinates points on line
	dnew=midLine(end,1)+interp1(parStep.d,parStep.step,midLine(end,1)); 
	xnew=interp1(di,xi,dnew); 
	ynew=interp1(di,yi,dnew); 
	
	if dnew>di(end)
		break;
	else
		midLine=[midLine; dnew, xnew, ynew]; 
	end
end %end while

%% CALCULATE PERPENDICULAR TRANSECTS

if OPT.waitbar
	display('Calculating transects perpendicular to line.'); 
end

dMidLine=diff(midLine,[],1); 
dMidLine=[dMidLine(1,:); dMidLine; dMidLine(end,:)]; 


for k=1:size(midLine,1)		
		%calculate begin and end points transect
		normal=0.5*dMidLine(k,2:3)/hypot(dMidLine(k,2),dMidLine(k,3))+...
		0.5*dMidLine(k+1,2:3)/hypot(dMidLine(k+1,2),dMidLine(k+1,3)) ;
		transect1=local_transect(normal,OPT.length_transect);
		transect1(2,1)=midLine(k,1); 
		transect1(:,2:3)=transect1(:,2:3)+repmat(midLine(k,2:3),[3 1]); 
		transect{k}=transect1; 
end %end for k


%% REMOVE CROSSING LINES

if OPT.waitbar
	display('Remove intersecting transects.'); 
end

for k=1:length(transect)
	for l=k+1:length(transect)
	
		%calculate point crossing right
		line1=transect{k}([2,3],2:3); line1=line1'; 
		line2=transect{l}([2,3],2:3); line2=line2';
		[xy inter]=local_intersection(line1,line2); 
		
		if inter(1)<1 & inter(2)<1 & inter(1)>0 & inter(2)>0
			%intersection takes place
			transect{k}(3,:)=[transect{k}(3,1)*inter(1),xy'];
			transect{l}(3,:)=[transect{l}(3,1)*inter(2),xy']; 
		end
		
		%calculate point crossing left
		line1=transect{k}([2,1],2:3); line1=line1'; 
		line2=transect{l}([2,1],2:3); line2=line2';
		[xy inter]=local_intersection(line1,line2); 
		
		if inter(1)<1 & inter(2)<1 & inter(1)>0 & inter(2)>0
			%intersection takes place
			transect{k}(1,:)=[transect{k}(1,1)*inter(1),xy'];
			transect{l}(1,:)=[transect{l}(1,1)*inter(2),xy']; 
		end	
		
	end %end for l
end %end for k

%% CALCULATE GRID POINTS ON TRANSECTS

if OPT.waitbar
	display('Calculating location grid points on transects.'); 
end

per_points_max=[0 0]; 
for k=1:length(transect)
	
	transect1=[0,transect{k}(2,2:3)]; 
	dpar=transect{k}(2,1); 
	perStepType=local_testStepStruct(perStep); 
	
	
	%right side
	dmax=transect{k}(3,1); 
	while 1
		dnew=transect1(end,1)+local_perStep(dpar,transect1(end,2),transect1(end,3),perStep,perStepType); 
		
		if dnew>=dmax
			break;
		else
			xnew=interp1([0 dmax]',transect{k}([2,3],2),dnew); 
			ynew=interp1([0 dmax]',transect{k}([2,3],3),dnew); 
			transect1=[transect1; dnew, xnew, ynew]; 
		end %end if dnew
	end %end while right
	
	%left side
	dmax=transect{k}(1,1); 
	while 1
		dnew=transect1(1,1)-local_perStep(dpar,transect1(1,2),transect1(1,3),perStep,perStepType); 
		
		if dnew<=dmax
			break;
		else
			xnew=interp1([dmax 0]',transect{k}([1,2],2),dnew); 
			ynew=interp1([dmax 0]',transect{k}([1,2],3),dnew); 
			transect1=[dnew, xnew, ynew; transect1]; 
		end %end if dnew
	end %end while left	
	
	%write new transect
	transect{k}=transect1;

	%count number of points on transect
	if sum( transect1(:,1)<0 )>per_points_max(1)
		per_points_max(1)=sum( transect1(:,1)<0 );
	end %end if size max
	if sum ( transect1(:,1)>0 )>per_points_max(2)
		per_points_max(2)=sum( transect1(:,1)>0 ); 
	end %end if size max
	
end %end for k transect

%% CAST TRANSECTS INTO GRID

if OPT.waitbar
	display('Creating output grid.'); 
end

%create grid that can contain all points
grd.x=nan( length(transect),sum(per_points_max)+1 );
grd.y=nan( length(transect),sum(per_points_max)+1 );
grdMid=per_points_max(1)+1; 

%fill grid transect by transect 
for k=1:length(transect)
	
	%find index where midlle line crosses transect
	iMid=find(transect{k}(:,1)==0,1); 
	if isempty(iMid)
		error(sprintf('Cannot find crossing middle line with transect %d',k)); 
	end %end if error
	
	%right side transect
	grdMax=grdMid+length(transect{k}(iMid:end,2))-1; 
	grd.x(k,grdMid:grdMax)=transect{k}(iMid:end,2)'; 
	grd.y(k,grdMid:grdMax)=transect{k}(iMid:end,3)';
	
	%left side transect
	grdMax=grdMid-length(transect{k}(1:iMid,2))+1;
	grd.x(k,grdMax:grdMid)=transect{k}(1:iMid,2); 
	grd.y(k,grdMax:grdMid)=transect{k}(1:iMid,3); 
	
end %end for k

%remove points that cannot form close grid cells
 for l=1:size(grd.x,2)
	iremove=isnan( grd.x(1:end-2,l) ) & isnan( grd.x(3:end,l) ) ; 
end
iremove=[0;iremove;0]; 
if isnan(grd.x(2,l))
	iremove(1)=1; 
else
	iremove(1)=0; 
end
if isnan(grd.x(end-1,l))
	iremove(end)=1; 
else
	iremove(end)=0;
end
iremove=logical(iremove);
grd.x(iremove,l)=NaN; grd.y(iremove,l)=NaN; 

%% CREATE OUTPUT
xOut=grd.x; yOut=grd.y; 



end %end function line2curvi

%----------------------------------------------------------------------------------

function [di xi yi]=local_lineInterp(x,y,dstep)
%LOCAL_LINEINTERP Create points with a distance dstep apart along line given by (x,y)

%remove double points
d=distancepoly(x,y); 
[d id1 id2]=unique(d); 
x=x(id1);y=y(id1); 

%check if line contains sufficient points for interpolation
if length(d)<2
	error('Line must be defined by two or more unique points.'); 
end

%Interpolate tangential coordinates
di=[d(1):dstep:d(end)]; 
di=unique([di,d]); 


%Interpolate cartesian coordinates
xi=interp1(d,x,di); 
yi=interp1(d,y,di); 


%convert to column vector
di=reshape(di,[],1); xi=reshape(xi,[],1); yi=reshape(yi,[],1);

end %end function local_lineInterp

%----------------------------------------------------------------------------------

function out=local_testStepStruct(stepStruct)
%LOCAL_TESTSTEPSTRUCT Test if format of parStep or perStep struct is valid.

out=0;

if isnumeric(stepStruct)
	out=1; 
end %end if isnumeric

if isstruct(stepStruct)
	%test name fields
	if isfield(stepStruct,'d') & isfield(stepStruct,'step')
		%test dimension 
		if sum(size(stepStruct.d)~=size(stepStruct.step))>0
			out=0;
		else
			stepStruct.d=reshape(stepStruct.d,[],1); 
			stepStruct.step=reshape(stepStruct.step,[],1); 
			out=2; 
		end %end if size
	elseif isfield(stepStruct,'x') & isfield(stepStruct,'y') & isfield(stepStruct,'step')
		%test dimension
		if sum(size(stepStruct.x)~=size(stepStruct.step))>0 | sum(size(stepStruct.y)~=size(stepStruct.step))>0
			out=0;
		else
			out=3; 
		end %end if size
	end %end if isfield
end %end if isstruct

end %end function local_testStepStruct

%----------------------------------------------------------------------------------

function  dxy=local_transect(normal,length_transect)
%LOCAL_PERLINE Draws line perpendicular to normal with length to each side specified in length_transect

normal=reshape(normal,[],1); 

%normalize normal
dnormal=hypot(normal(1),normal(2));
if dnormal==0
	error('Normal cannot be the zero vector')
else
	normal=normal/dnormal; 
end %end if

%rotate normal clockwise
theta=1/2*pi; 
normal=[cos(theta) sin(theta); -sin(theta) cos(theta)]*normal; ; 

%x-coordinates transect
dxy=[ -length_transect(1)*[1 normal'];[0 0 0]; length_transect(2)*[1 normal'] ];


end %end function local_perLine

%----------------------------------------------------------------------------------

function perStepLoc=local_perStep(d,x,y,perStep,perStepType)

switch(perStepType)
	case 1
		perStepLoc=perStep;
	case 2
		perStepLoc=interp1(perStep.d,perStep.step,d,'linear',mean(perStep.step)); 
	case 3 
		%[xStep yStep valStep]=grid2xyz(perStep.x,perStep.y,perStep.step); 
		%perStepLoc=griddata(xStep,yStep,valStep,x,y);
		perStepLoc=interp2(perStep.x,perStep.y,perStep.step,x,y); 
		if isnan(perStepLoc) | perStepLoc<=0
			perStepLoc=nanmean(perStep.step(:));
		end
	otherwise
		error('Invalid perStep format.'); 
end %end switch
end %end function local_perStep

%----------------------------------------------------------------------------------

function [dxy]=local_createTransect(dxy0,perStep)

dxy=dxy0(:,2); dxy(1,1)=0; 

perStepType=local_testStepStruct;

%right side
while 1
	dnew=dxy(end,1)+local_perStep( dxy0(1,2),dxy(end,2),dxy(end,3),perStep,perStepType); 
	if dnew>dxy0(1,3)
		break; 
	else
		x1=interp1([0,dxy0(1,3)],[dxy0(2,2),dxy0(2,3)],dnew); 
		y1=interp1([0,dxy0(1,3)],[dxy0(3,2),dxy0(3,3)],dnew); 
		dxy=[dxy; dnew, x1, y1]; 
	end
end %end while right side

%left side
while 1
	dnew=dxy(1,1)-local_perStep( dxy0(1,2),dxy(1,2),dxy(1,3),perStep,perStepType); 
	if dnew<dxy0(1,1)
		break; 
	else
		x1=interp1([dxy0(1,1),0],[dxy0(2,1),dxy0(2,2)],dnew); 
		y1=interp1([dxy0(1,1),0],[dxy0(3,1),dxy0(3,2)],dnew); 
		dxy=[dnew, x1, y1; dxy]; 
	end
end %end while right side

end %end function local_createTransect

%----------------------------------------------------------------------------------

function [xy inter]=local_intersection(line1,line2)
%LOCAL_INTERSECTION Calculate the intersection point of two straight lines.

dVectors=[-diff(line1,[],2),diff(line2,[],2)]; 

if abs(det(dVectors))<1e-3
	%no line intersection
	inter=[NaN;NaN];
	xy=[NaN;NaN]; 
else
	inter=inv(dVectors)*[line1(:,1)-line2(:,1)];

	xy=line2(:,1)+inter(2)*dVectors(:,2);
	xy_check=line1(:,1)-inter(1)*dVectors(:,1); 

	if hypot(xy(1)-xy_check(1),xy(2)-xy_check(2))>1e3
	%check correctness algorithm
		error('Intersection not calculated correctly.'); 
	end	%end if check	
	
end %end if det

end %end function local_intersection

%----------------------------------------------------------------------------------


