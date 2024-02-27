function h=mp_plotGrid(data,plt)

% Plt=handles.Figure(i).Axis(j).Plot(k);
% Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
% z=zeros(size(data.x));
% z=z+500;

if isfield(data,'XDam')
    if size(data.XDam,1)>0
        h=thindam(data.x,data.y,data.XDam,data.YDam);
        set(h,'LineStyle',plt.LineStyle,'LineWidth',plt.LineWidth,'Color',FindColor(plt.LineColor));
    else
        XDam=zeros(size(data.x));
        XDam=XDam+1;
        YDam=XDam;
        h=thindam(data.x,data.y,XDam,YDam);
        set(h,'LineStyle',plt.LineStyle,'LineWidth',plt.LineWidth,'Color',FindColor(plt.LineColor));
    end
%     SetObjectData(h,i,j,k,'marker');
else
    XDam=zeros(size(data.x));
    XDam=XDam+1;
    YDam=XDam;
    h=thindam(data.x,data.y,XDam,YDam);
    set(h,'LineStyle',plt.LineStyle,'LineWidth',plt.LineWidth,'Color',FindColor(plt.LineColor));
%     SetObjectData(h,i,j,k,'marker');
end

hold on;
