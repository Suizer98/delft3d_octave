function optiGUI_plots

[but,fig]=gcbo;

this=get(fig,'userdata');
sliderValue=round(get(findobj(fig,'tag','conditionSlider'),'value'));
nodg=length(this.input);
vecScal=str2num(char(get(findobj(fig,'tag','vecScal'),'string')));
if isempty(vecScal);
    vecScal=1000;
end
vecScalTransect=str2num(char(get(findobj(fig,'tag','vecScalTransect'),'string')));
if isempty(vecScalTransect);
    vecScal=0.001;
end
vecSpac=max([1 round(str2num(char(get(findobj(fig,'tag','vecSpac'),'string'))))]);
if isempty(vecSpac);
    vecSpac=1;
end

for dg=1:nodg
    hF=figure;
    hA1=subplot(1,2,1);hold on;axis equal;
    hA2=subplot(1,2,2);hold on;axis equal;
    switch this.input(dg).dataType
        case 'sedero'
            load('N:\morelis\matlabTools\colmaps\blueWhiteRed.mat');
            if ~isempty(this.input(dg).dataPolygon)
                axes(hA1);
                plot(this.input(dg).dataPolygon(:,1),this.input(dg).dataPolygon(:,2),'k');
                axes(hA2);
                plot(this.input(dg).dataPolygon(:,1),this.input(dg).dataPolygon(:,2),'k');
            end
            data=optiGUI_getGriddedData(this,sliderValue,dg);
            target=optiGUI_getGriddedData(this,[],dg);
            maxVal=max([target.Val(:); data.Val(:)]);
            minVal=min([target.Val(:); data.Val(:)]);
            absVal=max(abs([maxVal minVal]));
            axes(hA1);
            pcolor(target.X,target.Y,target.Val);
            shading flat;
            caxis([-absVal absVal]);
            title(['Target bed level changes (with all conditions)']);
            axes(hA2);
            pcolor(data.X,data.Y,data.Val);
            shading flat;
            caxis([-absVal absVal]);
            title(['Computed bed level changes with ' num2str(sliderValue) ' conditions']);
            hC=colorbar('vertical');
            colormap(cm);
        case 'transport'
            if isempty(this.input(dg).dataTransect) % then transport field plotting
                if ~isempty(this.input(dg).dataPolygon)
                    axes(hA1);
                    plot(this.input(dg).dataPolygon(:,1),this.input(dg).dataPolygon(:,2),'k');
                    axes(hA2);
                    plot(this.input(dg).dataPolygon(:,1),this.input(dg).dataPolygon(:,2),'k');
                end
                data=optiGUI_getGriddedData(this,sliderValue,dg);
                target=optiGUI_getGriddedData(this,[],dg);
                maxVal=max([target.Val(:); data.Val(:)]);
                minVal=min([target.Val(:); data.Val(:)]);
                axes(hA1);
                pcolor(target.X,target.Y,target.Val);
                shading flat;
                caxis([minVal maxVal]);
                quiver(target.X(1:vecSpac:end,1:vecSpac:end),target.Y(1:vecSpac:end,1:vecSpac:end),vecScal.*target.XComp(1:vecSpac:end,1:vecSpac:end),vecScal.*target.YComp(1:vecSpac:end,1:vecSpac:end),0,'k');
                title(['Target transports (with all conditions)']);
                axes(hA2);
                pcolor(data.X,data.Y,data.Val);
                shading flat;
                caxis([minVal maxVal]);
                quiver(data.X(1:vecSpac:end,1:vecSpac:end),data.Y(1:vecSpac:end,1:vecSpac:end),vecScal.*data.XComp(1:vecSpac:end,1:vecSpac:end),vecScal.*data.YComp(1:vecSpac:end,1:vecSpac:end),0,'k');
                title(['Computed transports with ' num2str(sliderValue) ' conditions']);
                hC=colorbar('vertical');
            else % now transport through transects
                transects=this.input(dg).dataTransect;
                data=this.input.data*this.iteration(length(this.iteration)+1-sliderValue).weights';
                target=this.input(dg).target;
                % check if transportMode field exists, if not set it to
                % nett (default)
                if ~isfield(this.input,'transportMode')
                    this.input.transportMode='nett';
                end
                if strcmp(this.input.transportMode,'gross')
                    % bewerking uitvoeren zodat nett er bij staat (ofwel 3
                    % transporten per transect)
                    data=reshape(data,[size(transects,3) 2]);
                    data=[sum(data,2) data];
                    target=reshape(target,[size(transects,3) 2]);
                    target=[sum(target,2) target];
                end
                axes(hA1);hold on;
                for it=1:size(transects,3)
                    [p,h1,t1]=plotTransArbCSEngine(transects(1,:,it),transects(2,:,it),target(it,:),vecScalTransect);
                end
                title(['Target transports (with all conditions)']);
                axes(hA2);hold on;
                for it=1:size(transects,3)
                    [p,h1,t1]=plotTransArbCSEngine(transects(1,:,it),transects(2,:,it),data(it,:),vecScalTransect);
                end
                title(['Computed transports with ' num2str(sliderValue) ' conditions']);
            end
    end
    axes(hA1);box on;
    try
        xlim([str2num(char(get(findobj(fig,'tag','xL'),'string')))]);
        ylim([str2num(char(get(findobj(fig,'tag','yL'),'string')))]);
    end
    axes(hA2);;box on;
    try
        xlim([str2num(char(get(findobj(fig,'tag','xL'),'string')))]);
        ylim([str2num(char(get(findobj(fig,'tag','yL'),'string')))]);
    end
    md_paper('a4l','wl');
    set(hA1,'pos',[0.18 0.1 0.3 0.8]);
    set(hA2,'pos',[0.54 0.1 0.3 0.8]);
    try
        set(hC,'pos',[0.9 0.1 0.02 0.8]);
    end
    set(gcf,'r','p');
end

function y = nansum(x,dim)
%NANSUM Sum, ignoring NaNs.
%   Y = NANSUM(X) returns the sum of X, treating NaNs as missing values.
%   For vector input, Y is the sum of the non-NaN elements in X.  For
%   matrix input, Y is a row vector containing the sum of non-NaN elements
%   in each column.  For N-D arrays, NANSUM operates along the first
%   non-singleton dimension.
%
%   Y = NANSUM(X,DIM) takes the sum along dimension DIM of X.
%
%   See also SUM, NANMEAN, NANVAR, NANSTD, NANMIN, NANMAX, NANMEDIAN.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 12403 $  $Date: 2015-12-02 03:01:58 +0800 (Wed, 02 Dec 2015) $

% Find NaNs and set them to zero.  Then sum up non-NaNs.  Cols of all NaNs
% will return zero.
x(isnan(x)) = 0;
if nargin == 1 % let sum figure out which dimension to work along
    y = sum(x);
else           % work along the explicitly given dimension
    y = sum(x,dim);
end