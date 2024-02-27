function detran_plotTransArbCS;
%DETRAN_PLOTTRANSARBCS Detran GUI function to plot transport through transects
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
    set(findobj(fig,'tag','detran_plotTransectBox'),'Value',0);
    return
end

axes(findobj(fig,'tag','axes1'));
hold on;
try
    delete(data.transectHandles{:});
end


if get(findobj(fig,'tag','detran_plotTransectBox'),'Value')==1
    period=detran_getPeriod;
    pores=detran_getPoreVolume;
    ldb=data.transects;
    gross=get(findobj(fig,'tag','detran_plotGrossBox'),'Value');
    vecSc=str2num(get(findobj(fig,'tag','detran_vecScaling'),'String'));
    labelFac=str2num(get(findobj(fig,'tag','detran_transLabelFactor'),'String'));
    if isempty(vecSc)
        vecSc = 1;
    end
    if isempty(labelFac)
        labelFac = 1;
    end
    vecSc = vecSc(1);
    labelFac = labelFac(1);
    set(findobj(fig,'tag','detran_vecScaling'),'String',num2str(vecSc));
    set(findobj(fig,'tag','detran_transLabelFactor'),'String',num2str(labelFac));
    
    for ii=1:size(ldb,1)
        CS=labelFac.*period.*data.transectData(ii,:)./(1-pores);
        if gross==0
            [p(:,ii),h1(:,ii),t1(:,ii)]=detran_plotTransportThroughTransect(ldb(ii,1:2),ldb(ii,3:4),CS(1),vecSc);
            h1Plus=[];
            t1Plus=[];
            h1Min=[];
            t1Min=[];            
        else
            [p(:,ii),h1(:,ii),t1(:,ii),h1Plus(:,ii),t1Plus(:,ii),h1Min(:,ii),t1Min(:,ii)]=detran_plotTransportThroughTransect(ldb(ii,1:2),ldb(ii,3:4),CS,vecSc);
        end
    end
    data.transectHandles={p,h1,t1,h1Plus,t1Plus,h1Min,t1Min};
end
set(fig,'userdata',data);
