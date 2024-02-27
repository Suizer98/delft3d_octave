function outH=filledLDB(ldb,edgeColor,faceColor,maxDist,zLevel)
%FILLEDLDB Plot filled polygon or landboundary
%
% Syntax:
% filledLDB(ldb,edgeColor,faceColor,maxDist,zLevel)
%
% ldb:          Px2 array with [x, y] points of the landboundary
% edgecolor:    1x3 array with 0-1 values for [r g b]
% facecolor:    1x3 array with 0-1 values for [r g b]
% maxDist:      distance between ldb-points above which the landboundary is cut
%               (optional, leave empty [] to discard)
% zLevel:       z-level of patch (optional, leave empty [] to use the z=1000 default)
%
% R. Morelissen, 2004-2005
% Ben de Sonneville: increased speed with 30% for Matlab versions newer than 6.5 R13
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robin Morelissen
%
%       robin.morelissen@deltares.nl
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
outH=[];

%add nan to beginning and end if there are none
if ~isnan(ldb(1,1))
    ldb=[nan nan;ldb];
end
if ~isnan(ldb(end,1))
    ldb=[ldb;nan nan];
end

%If maxDist is given, cut ldb points further than maxDist apart
if nargin==4&~isempty(maxDist)
    dists=sqrt((ldb(2:end,1)-ldb(1:end-1,1)).^2+(ldb(2:end,2)-ldb(1:end-1,2)).^2);
    mID=find(dists>=maxDist);
    for ii=1:length(mID)
        ldb=[ldb(1:mID,:);nan nan;ldb(mID+1:end,:)];
    end
end

%Cater for other Z-level of patch
if nargin~=5|isempty(zLevel)
    zLevel=1000;
end

id=find(isnan(ldb(:,1)));

%plot all filled patches

%Remember hold setting
curHold=get(gca,'NextPlot');

hold on;

if strcmp(version, '6.5.0.180913a (R13)')

    for ii=1:length(id)-1
        %Try to account for the effect that a ldb is copied multiple times
        %behind eachother, resulting in a non-filled ldb
        %     doubleLDB=unique(ldb(id(ii)+1:id(ii+1)-1,:),'rows');
        %     multiLDB=round(length(ldb(id(ii)+1:id(ii+1)-1,1))/length(doubleLDB));
        %     if multiLDB>1
        %         %         fH=fill(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),1),ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2),faceColor);
        %         fH=patch(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),1),ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2),repmat(zLevel,length(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2)),1),'k');
        %     else
        %         fH=fill(ldb(id(ii)+1:id(ii+1)-1,1),ldb(id(ii)+1:id(ii+1)-1,2),faceColor);
        fH=patch(ldb(id(ii)+1:id(ii+1)-1,1),ldb(id(ii)+1:id(ii+1)-1,2),repmat(zLevel,length(ldb(id(ii)+1:id(ii+1)-1,2)),1),'k');
        %     end
        set(fH,'edgecolor',edgeColor,'facecolor',faceColor);

        outH=[outH fH];
    end

else

    % plot individual patches
    a = id+1; a = a(1:end-1);
    b = id-1; b = b(2:end);
    c          = repmat({0,0,0}, length(id)-1,1);
    edgeColor1 = repmat({'edgecolor'}, length(id)-1,1);
    edgeColor2 = repmat({edgeColor}, length(id)-1,1);
    faceColor1 = repmat({'facecolor'}, length(id)-1,1);
    faceColor2 = repmat({faceColor}, length(id)-1,1);

    for i = 1:length(id)-1
        c{i,1}=ldb([a(i): b(i)],1);
        c{i,2}=ldb([a(i): b(i)],2);
        c{i,3}= repmat(zLevel,size([a(i): b(i)]'));
    end

    outH = cellfun(@patch, c(:,1), c(:,2), c(:,3), edgeColor1, edgeColor2, faceColor1, faceColor2,'UniformOutput',false);

end

%Set original hold setting
set(gca,'NextPlot',curHold);