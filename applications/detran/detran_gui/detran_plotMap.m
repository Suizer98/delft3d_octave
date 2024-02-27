function detran_plotMap
%DETRAN_PLOTMAP Detran GUI function to plot transport field
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

if isempty(data.edit)
    set(findobj(fig,'tag','detran_plotMapBox'),'Value',0);
    return
end

axes(findobj(fig,'tag','axes1'));
hold on;
try
    delete(findobj(fig,'tag','mapplot'));
end

if get(findobj(fig,'tag','detran_plotMapBox'),'Value')==1
    edit=data.edit;
    strucNames=fieldnames(edit);
    %strucNames={'xcor'    'ycor'    'alfa'    'yatu'    'yatv'    'yatuPlus'    'yatuMin'    'yatvPlus'    'yatvMin'};
    for ii=1:length(strucNames)
        eval([strucNames{ii} '=edit.' strucNames{ii} ';']);
    end
    period=detran_getPeriod;
    pores=detran_getPoreVolume;
    vSc=str2num(get(findobj(fig,'tag','detran_vecScalingMap'),'String'));
    vSp=str2num(get(findobj(fig,'tag','detran_vecSpacing'),'String'));
    if isempty(vSc)
        vSc = 1;
    end
    if isempty(vSp)
        vSp = 1;
    end
    vSc = vSc(1);
    vSp = vSp(1);
    set(findobj(fig,'tag','detran_vecScalingMap'),'String',num2str(vSc));
    set(findobj(fig,'tag','detran_vecSpacing'),'String',num2str(vSp));
    
    spMode=get(findobj(fig,'tag','detran_spaceMode'),'Value');
    smallTr=1;
    
    tx = period.*(yatu .* cos(pi/180*alfa) - yatv .* sin(pi/180*alfa))./(1-pores);
    ty = period.*(yatu .* sin(pi/180*alfa) + yatv .* cos(pi/180*alfa))./(1-pores);
    idSmall=find(sqrt(tx.^2+ty.^2)<(smallTr/100).*mean(mean(sqrt(tx.^2+ty.^2))));
    
    switch spMode %uniform
        case 1
            xcor([find(xcor==0);find(tx==0&ty==0);idSmall])=nan; % nannen maken als xcor=0 of als transport=0 (anders plot ie puntjes...)
            ycor([find(ycor==0);find(tx==0&ty==0);idSmall])=nan;
            p=pcolor(xcor,ycor,sqrt(tx.^2 + ty.^2));set(p,'EdgeColor','none');
            q=quiver(xcor(1:vSp:end,1:vSp:end),ycor(1:vSp:end,1:vSp:end),...
                vSc*tx(1:vSp:end,1:vSp:end),vSc*ty(1:vSp:end,1:vSp:end),0,'k');
        case 2 %distance
            if length(vSp)==1
                vcSp=vSp(1);
            end
            idRed=reducepntsq(vSp,xcor,ycor);
            xcor([find(xcor==0);find(tx==0&ty==0);idSmall])=nan; % nannen maken als xcor=0 of als transport=0 (anders plot ie puntjes...)
            ycor([find(ycor==0);find(tx==0&ty==0);idSmall])=nan;
            p=pcolor(xcor,ycor,sqrt(tx.^2 + ty.^2));set(p,'EdgeColor','none');
            q=quiver(xcor(idRed),ycor(idRed),vSc*tx(idRed),vSc*ty(idRed),0,'k');
    end
    cm=detran_makeSedconcColMap;
    colormap(cm);
    colScale = sort(str2num(get(findobj(fig,'tag','detran_colScale'),'String')));
    if isempty(colScale) || length(unique(colScale))==1
        colScale = [0 1];
    end
    colScale = colScale(1:2);
    caxis(colScale);
    set(findobj(fig,'tag','detran_colScale'),'String',num2str(colScale));    
    set(q,'color',[0.4 0.4 0.4]);
    set([p;q],'tag','mapplot');
end

set(gca,'tag','axes1');