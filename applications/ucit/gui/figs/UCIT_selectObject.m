function selection = UCIT_selectObject(rayH, command, polyselect, polygon)
%UCIT_SELECTOBJECT  gets handle of selected object
%
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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
if ~exist('polyselect','var')
    polyselect = 0;
    polygon = [];
end
if ~isempty(polygon)
    uo = [polygon(:,1);polygon(1,1)];
    vo = [polygon(:,2);polygon(1,2)];
end

if strcmp(get(findobj('tag','UCIT_batchCommand'),'checked'),'on')|polyselect==1
    %Draw polygon (from Argus IBM)
    % pick some boundaries
    if isempty(polygon)
        uo = []; vo = []; button = [];

        [uo,vo,lfrt] = ginput(1);
        button = lfrt;
        hold on; hp = plot(uo,vo,'+m');

        while lfrt == 1
            [u,v,lfrt] = ginput(1);
            uo=[uo;u]; vo=[vo;v]; button=[button;lfrt];
            delete(hp);
            hp = plot(uo,vo,'m');
        end

        % Bail out at ESCAPE = ascii character 27
        if lfrt == 27
            delete(hp)
            if exist('bp')
                set(bp,'linestyle','-')
            end
            return
        end

        % connect
        if(exist('hp'))
            uo = [uo(:);uo(1)];
            vo = [vo(:);vo(1)];
            %    set(hp,'tag',guiGetROI);
        end
        hold off
    end
    %Find all rays with at least one point in the polygon
    tx=get(rayH,'xdata');
    ty=get(rayH,'ydata');
    x=cat(1,tx{:});
    y=cat(1,ty{:});
    
    clear xadd yadd
    for i = 1:size(x,1)
        xadd(i,:)=linspace(x(i,1),x(i,2),50);
    end
    for i = 1:size(y,1)
        yadd(i,:)=linspace(y(i,1),y(i,2),50);
    end
    selection=[];
    for i = 1:size(xadd,1)
        tryselection=rayH(inpolygon(xadd(i,:),yadd(i,:),uo,vo));
        if ~isempty(tryselection)
            selection = [selection; rayH(i)];
        end
    end

%     selection=rayH(inpolygon(x(:,1),y(:,1),uo,vo));
%     try
%         selection=[selection ;rayH(inpolygon(x(:,2),y(:,2),uo,vo))];
%     end
%     
%     selection=unique(selection);

    try
        delete(hp); %Delete poly
    end
    switch command

        case 'new'
            %First make all rayH's red
            set(rayH,'color',[1 0 0]);

            %Then yellow up the selection
            set(selection,'color',[1 1 0]);

        case 'extend'

            %Just yellow up the selection
            set(selection,'color',[1 1 0]);

        case 'unselect'

            %Just make selection red
            set(selection,'color',[1 0 0]);

    end
    selection = get(findobj(selection),'tag');
else
    %Interactively select ray from Jarkus overzicht (figure mapWindow)
    plotedit on;

    while ~ismember(rayH,gco)
        pause(0.1);
    end

    set(rayH,'color',[1 0 0],'markeredgecolor',[1 0 0],'markerfacecolor',[1 0 0],'linewidth',0.15);
    set(gco,'color',[0 1 0],'markeredgecolor',[0 1 0],'markerfacecolor',[0 1 0],'linewidth',1.5);
    refresh;

    plotedit off;

    selection{1} = get(gco,'tag');
end