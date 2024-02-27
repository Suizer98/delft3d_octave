function detran_adjustTransect
%DETRAN_ADJUSTTRANSECT Detran GUI function to adjust a transect
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
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

[but,fig]=gcbo;

data=get(fig,'userdata');

if isempty(data.transects)
    return
end

if get(findobj(fig,'tag','detran_plotTransectBox'),'Value')==0
    return
end

ldb=data.transects;
templdb=[ldb(:,1:2);ldb(:,3:4)];
CS=data.transectData(:,1);
PlusCS=data.transectData(:,2);
MinCS=data.transectData(:,3);

[xClick, yClick,b]=ginput(1);
if b~=1
    return
end
dist=sqrt((templdb(:,1)-xClick).^2+(templdb(:,2)-yClick).^2);
[dum, id]=min(dist);
id2=mod(id,size(ldb,1));
if id2==0
    id2=size(ldb,1);
end

[xClick, yClick,b]=ginput(1);
if b~=1
    return
end

if b==1
    edit=data.edit;
    strucNames=fieldnames(edit);
    for ii=1:length(strucNames)
        eval([strucNames{ii} '=edit.' strucNames{ii} ';']);
    end
    templdb(id,:)=[xClick yClick];
    ldb=[templdb(1:size(ldb,1),:) templdb(size(ldb,1)+1:end,:)];
    [xt,yt]=detran_uvData2xyData(yatu,yatv,alfa);
    [CS(id2), PlusCS(id2), MinCS(id2)]=detran_TransArbCSEngine(xcor,ycor,xt,yt,ldb(id2,1:2),ldb(id2,3:4));
    data.transects=ldb;
    data.transectData=[CS PlusCS MinCS];
end
set(fig,'userdata',data);
detran_plotTransArbCS;
