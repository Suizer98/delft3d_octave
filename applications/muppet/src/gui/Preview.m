function handles=Preview(handles)

if handles.Mode==1
    wb = waitbox('Preparing figure...');
    try
        handles=MakeFigure(handles,handles.ActiveFigure,'preview');
        set(gcf,'Visible','on');
    catch
        h=findobj('Tag','waitbox');
        close(h);
        err=lasterror;
        str{1}=['An error occured in function: '  err.stack(1).name];
        str{2}=['Error: '  err.message];
        str{3}=['File: ' err.stack(1).file];
        str{4}=['Line: ' num2str(err.stack(1).line)];
        str{5}=['See muppet.err for more information'];
        strv=strvcat(str{1},str{2},str{3},str{4},str{5});
        uiwait(errordlg(strv,'Error','modal'));
        WriteErrorLog(err);
    end
    if ishandle(wb)
        close(wb);
    end
    figure(handles.ActiveFigure);
    delete(['curvecpos.*.dat']);
%    for i=1:5
%        if exist(['pos' num2str(i) '.dat'],'file')
%            delete(['pos' num2str(i) '.dat']);
%        end
%    end
    SetPlotEdit(0);
else
    handles.Figure(888)=handles.Figure(handles.ActiveFigure);
    handles.Figure(888).Axis(1)=handles.Figure(handles.ActiveFigure).Axis(1);
    handles.Figure(888).Axis(1).Plot=handles.Figure(handles.ActiveFigure).Axis(1).Plot;
%     handles.ActiveFigure=888;
%     handles.ActiveFigure=888;
    handles=GUI_DataProcessing('handles',handles);
end
