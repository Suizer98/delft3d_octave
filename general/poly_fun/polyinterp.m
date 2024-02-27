function out=polyinterp(x,y,varargin)
%POLYINTERP Interpolates polygon between the vertices.
%
%Usually a polygon is given as a set of coordinates of the vertices.
%POLYINTERP adds coordinates placed on the lines connecting these vertices.
%This is for example necessary to convert a polygon given in
%m,n-coordinates to x,y=coordinates. 
%
%Syntax:
%   out=polyinterp(x,y,<keyword>,<value>)
%
%Input:
%   x =     [nx1 double] x-coordinates in local coordinate system
%   y =     [nx1 double] y-coordinates in local coordinate system
%
%Output
% out =     [mx1 struct] array of structs. Each struct contains the
%           interpolated x,y-coordinates of one closed polygon
%
%Optional keywords:
% d_step =  [1x1 double] The maximal distance between the output
%           coordinates. If this is NaN interpolation for grid coordinates
%           is used. In this case the difference in m-coordinate
%           (n-coordinate) between two output points is 1 and the
%           difference in the n-coordinate (m-coordinate) is 0.
%           (Default=1);  
% seperator=[string] If seperator='NaN' a new polygon is started when NaN
%           is encountered. If seperator='equal' a new polygon is started
%           when after same coordinate is encountered for the second time. 
%           If 'none' no the out consists of only 1 polygon. 
% 
%Example
%[m n]=polyinterp(grd.Enclosure(:,1),grd.Enclosure(:,2),'d_step',NaN,...
%'seperator','equal'); 

%   --------------------------------------------------------------------
%   Copyright (C) 2013 ARCADIS
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis, Zwolle, The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

%% PREPROCESSING

%get settings
OPT.d_step=1; 
OPT.seperator='NaN'; 
OPT.close=true; 
[OPT OPTset]=setproperty(OPT,varargin); 

%check dimension input
if length(x)~=length(y)
    error('x and y must have the same dimensions.'); 
end %end if
if sum(size(x)>1)>1
    error('x and y must be either a column or row vector'); 
end

%change x,y to column vector
x=reshape(x,[],1); 
y=reshape(y,[],1); 

%seperate in different polygons
out=local_seperate(x,y,OPT.seperator,OPT.close);

%loop over polygons
for k=1:length(out)
    
   %check if polygon contains real values
   if sum(isnan(out(k).x))>0 | sum(isnan(out(k).y))>0 ...
           sum(isinf(out(k).x))>0 | sum(isinf(out(k).y))>0 
       error(sprintf('Polygon %d contains a NaN of Inf value',k));
   end %end if
   
   
    d=distance(out(k).x,out(k).y); 
	if isnumeric(OPT.d_step) & ~isnan(OPT.d_step)
		%distance between points is given
		di=unique([d(1):OPT.d_step:d(end),d]); 
		out(k).x=interp1(d,out(k).x,di); 
		out(k).y=interp1(d,out(k).y,di); 
    elseif isnan(OPT.d_step)
		%distance between points is 1
		[out(k).x out(k).y]=local_interpMN(out(k).x,out(k).y); 
	else
		error('d_step must be a double or NaN');		
	end
	
   
   
end %end for k

end %end function polyinterp

function out=local_seperate(x,y,seperator,flag_close)
%LOCAL_SEPERATE Sperate the lists of x,y-coordinates in different polygons.

out=[]; 
if strcmpi(seperator,'NaN')

    %NaN seperated input
    if ~isnan(x(1))
        x=[NaN; x];  y=[NaN; y]; 
    end
    if ~isnan(x(end))
        x=[x; NaN];  y=[y; NaN];
    end
    inan=find(isnan(x) & isnan(y)); 
    for k=1:length(inan)-1
        
        %extract vertices between NaNs
        out(k).x=x(inan(k)+1:inan(k+1)-1); 
        out(k).y=y(inan(k)+1:inan(k+1)-1); 
        
        %Close polygon if necessary 
        if ( out(k).x(1)~=out(k).x(end) | out(k).y(1)~=out(k).y(end) ) & flag_close
            out(k).x=[out(k).x;out(k).x(1)]; 
            out(k).y=[out(k).y;out(k).y(1)]; 
        end %end if
    end %end for 
    
elseif strcmpi(seperator,'equal')
    %Equal coordinates are seperator
    
    x=x(~isnan(x)); y=y(~isnan(y)); 
	if x(end)~=x(1) | y(end)~=y(1)
		x=[x;x(1)]; 
		y=[y;y(1)];
	end
	
    iout=1; 
    out(1).x=[]; out(1).y=[]; 
    for k=1:length(x)
        
        if isempty(find(out(iout).x==x(k) & out(iout).y==y(k))) 
            %add point to current polygon
            out(iout).x=[out(iout).x; x(k)]; 
            out(iout).y=[out(iout).y; y(k)]; 
        else
            %close polygon 
			if flag_close
				out(iout).x=[out(iout).x; out(iout).x(1)]; 
				out(iout).y=[out(iout).y; out(iout).y(1)];
			end
            %create new polygon
            iout=iout+1; 
            out(iout).x=[]; out(iout).y=[]; 
        end %end if isempty
        
    end %end or k
	
	%remove last output if it is empty
	if isempty(out(end).x)
		out=out(1:end-1);
	end %end if 
    
elseif strcmpi(seperator,'none')

    %Input consists of only 1 polygon
    out.x=x(~isnan(x) & ~isnan(y)); 
    out.y=y(~isnan(x) & ~isnan(y)); 
    
    %close if necessary
    if ( out.x(end)~=out.x(1) | out.y(end)~=out.y(1) ) & flag_close
        out.x=[out.x;out.x(1)]; 
        out.y=[out.y;out.y(1)]; 
    end %end if
else
    error(sprintf('%s is not a valid option for seperator',OPT.seperator)); 
end %end if strcmpi(seperator

end %end local_seperate

function [mout nout]=local_interpMN(m,n,flag_close)
%LOCAL_INTERPMN 

%check for NaN
if sum(isnan(m))>0 | sum(isnan(n))>0
	error('x or y contains NaN values'); 
end 

%differences
dm=sign(diff(m)); dn=sign(diff(n)); 

mout=m(1); nout=n(1); 
for k=1:length(dm)
	if dn(k)==0 & dm(k)~=0
		m_tmp=[m(k):dm(k):m(k+1)]; 
		n_tmp=ones(size(m_tmp))*n(k); 
	elseif dm(k)==0 & dn(k)~=0
		n_tmp=[n(k):dn(k):n(k+1)]; 
		m_tmp=ones(size(n_tmp))*m(k);
	elseif dm(k)~=0 & dn(k)~=0 
		m_tmp=[m(k):dm(k):m(k+1)];
		n_tmp=[n(k):dn(k):n(k+1)];
	else
		error('Invalid step size for enclosure'); 
	end
	
	if length(m_tmp)~=length(n_tmp)
		error('Invalid step size for enclosure. Consider not closing the polygon.'); 
	end
	
	mout=[mout,m_tmp(2:end)]; 
	nout=[nout,n_tmp(2:end)]; 
end

mout=mout'; nout=nout'; 

end %end local_interpMN