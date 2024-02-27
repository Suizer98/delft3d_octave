function CloseFigure(varargin)

try,
    plotedit off;
    mpt=findobj('Name','Muppet');
    data=guidata(mpt);
    ifig=get(gcf,'UserData');
    data.ActiveFigure=ifig;
    Changed=CheckForChanges(data);
    if Changed==1
        button = questdlg(strvcat('The figure has changed','Keep new settings?'),'','Cancel','No','Yes','Yes');
        switch(button),
            case{'Cancel'}
            case{'No'}
                closereq;
            case{'Yes'}
                data=AdjustAxes(data);
                data=RefreshSubplots(data);
                data=RefreshDatasetsInSubplot(data);
                data=RefreshAxes(data);
                guidata(mpt,data);
                delete(data.Figure(ifig).Handle);
        end
    else
        delete(ifig);
    end
catch
    err=lasterror;
    str{1}=['An error occured in function: '  err.stack(1).name];
    str{2}=['Error: '  err.message];
    str{3}=['File: ' err.stack(1).file];
    str{4}=['Line: ' num2str(err.stack(1).line)];
    strv=strvcat(str{1},str{2},str{3},str{4});
    errordlg(strv,'Error');
    WriteErrorLog(err);
    delete(ifig);
end
