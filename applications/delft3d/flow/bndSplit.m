function bndSplit(bndIn,bndOut,step,varargin)
%BNDSPLIT Split boundary into smaller boundaries with length given
%in step.
%
%Syntax:
%	bndSplit(bndIn,bndOut,step)
%
%Input:
%bndIn		=[string] filepath .bnd-file containing boundary that has to be split.
%bndOut		=[string] filepath to .bnd-file with new boundary.
%step		=[double/nx1 double] each boundary is step cell faces long. If only a boundary
%			  with one face can be created it will be merged with previous boundary. If step
%			  is a vector its length must be equal to the number of boundary sections in bndIn.
%			  In that case the ith entry is the stepsize for the ith boundary section in bndIn
%
%Example:
%	cd('c:\mysim'); 
%   bndSplit('proto_boundary.bnd','split_boundary.bnd',[3 5 3],'alfa',200); 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis Zwolle
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Feb 2013
% Created with Matlab version: 7.5.0

% $Id: bndSplit.m 9175 2013-09-04 15:15:47Z ivo.pasmans.x $
% $Date: 2013-09-04 23:15:47 +0800 (Wed, 04 Sep 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 9175 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/bndSplit.m $
% $Keywords$

%% PREPROCESSING

%Keywords
OPT.alfa=0;
OPT.bndtype={''};
OPT.datatype={''}; 
OPT=setproperty(OPT,varargin); 

%check input file
if ~exist(bndIn,'file')
	error(sprintf('Cannot find file %s',bndIn)); 
else
	bnd=delft3d_io_bnd('read',bndIn); 
end %end if

%number of boundary sections
nData=length(bnd.DATA); 

%check size step
if sum(step<2)>0
	error('Boundary section must consist of at least 2 faces.'); 
end

%check dimension step
if length(step)~=1 & length(step)~=nData
	error('The number of entries in step must be 1 or equal to the number of boundary sections in bndIn.');
end
%check dimension alfa
if length(OPT.alfa)~=1 & length(OPT.alfa)~=nData
	error('The number of entries in alfa must be 1 or equal to the number of boundary sections in bndIn.');
end
%check dimension bndtype
if length(OPT.bndtype)~=1 & length(OPT.bndtype)~=nData
	error('The number of entries in bndType must be 1 or equal to the number of boundary sections in bndIn.');
end
%check dimension datatype
if length(OPT.datatype)~=1 & length(OPT.datatype)~=nData
	error('The number of entries in datatype must be 1 or equal to the number of boundary sections in bndIn.');
end

%Calculate stepsize for each boundary section
if length(step)==1
	step=step*ones(1,nData); 
end
%Calculate alfa for each boundary section
if length(OPT.alfa)==1
	OPT.alfa=OPT.alfa*ones(1,nData); 
end
%Calculate bndtype for each boundary section
if length(OPT.bndtype)==1
	bndtype1=OPT.bndtype;
	OPT.bndtype=cell(1,nData); 
	OPT.bndtype=cellfun(@(x) bndtype1,OPT.bndtype); 
end
%Calculate datatype for each boundary section
if length(OPT.datatype)==1
	datatype1=OPT.datatype;
	OPT.datatype=cell(1,nData); 
	OPT.datatype=cellfun(@(x) datatype1,OPT.datatype); 
end

%% CREATING BOUNDARIES

DATA=[]; 
for k=1:length(bnd.DATA)


	%parameters
	alfa1=OPT.alfa(k); 
	if ~isempty(OPT.bndtype{k})
		bndtype1=OPT.bndtype{k};
	else
		bndtype1=bnd.DATA(k).bndtype;
	end
	if ~isempty(OPT.datatype{k})
		datatype1=OPT.datatype{k};
	else
		datatype1=bnd.DATA(k).datatype;
	end
	name1=bnd.DATA(k).name; 
	name1=name1( 1:min(length(name1),17) ); 
	
	%format: [m_A m_B; n_A n_B]
	mn=reshape(bnd.DATA(k).mn,[2 2]); 
	dmn=diff(mn,[],2);
	dmn=sign(dmn); 
	
	%check boundary section
	if sum(dmn~=0)==2
		error('Boundary section must be along row or column'); 
	end
	
	if dmn(1)<0 | dmn(2)<0
		mn=flipdim(mn,2); 
	end
	
	mnA=mn(:,1); 
	while mnA(1,end)*abs(dmn(1))<mn(1,2) & abs(dmn(2))*mnA(2,end)<mn(2,2)
		mnA=[mnA,mnA(:,end)+step(k)*abs(dmn)]; 
	end %end while
	
	mnA=mnA(:,1:end-1); 
	mnB=mnA(:,2:end)-repmat(abs(dmn),[1 size(mnA,2)-1]); 
	mnB=[mnB,mn(:,2)];
	
	if dmn(1)<0 | dmn(2)<0
		mnA=flipdim(mnA,2);
		mnB=flipdim(mnB,2);
		mn=flipdim(mn,2); 
	end 
	
	for l=1:size(mnA,2)
		DATA1=bnd.DATA(k); 
		DATA1.name=sprintf('%s_%-.2d',name1,l);
		DATA1.alfa=alfa1;
		DATA1.bndtype=bndtype1;
		DATA1.datatype=datatype1;
		DATA1.mn=[mnA(:,l),mnB(:,l)]; 

		DATA=[DATA,DATA1]; 
	end
	
end %end for k bnd.DATA

%% WRITE OUTPUT

bnd.DATA=DATA; 
bnd.NTables=length(DATA); 
bnd.DATA(:).mn; 
delft3d_io_bnd('write',bndOut,bnd); 


end %end function bndSplit