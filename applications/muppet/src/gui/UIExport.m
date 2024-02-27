function UIExport(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

SetPlotEdit(0);

ifig=get(gcf,'UserData');
ExportFigure(data,ifig,'guiexport');
delete(['curvecpos.*.dat']);
%for i=1:5
%    if exist(['pos' num2str(i) '.dat'],'file')
%        delete(['pos' num2str(i) '.dat']);
%    end
%end

figure(ifig);
