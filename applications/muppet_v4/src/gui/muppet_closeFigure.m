function muppet_closeFigure(varargin)

muppet_setPlotEdit(0);

try
    plotedit off;
    changed=muppet_checkForChanges;
    if changed==1
        button = questdlg(strvcat('The figure has changed','Keep new settings?'),'','Cancel','No','Yes','Yes');
        switch(button),
            case{'Cancel'}
            case{'No'}
                closereq;
            case{'Yes'}
                muppet_fixAxes;
                delete(gcf);
        end
    else
        delete(gcf);
    end
catch
    err=lasterror;
    str{1}=['An error occured in function: '  err.stack(1).name];
    str{2}=['Error: '  err.message];
    str{3}=['File: ' err.stack(1).file];
    str{4}=['Line: ' num2str(err.stack(1).line)];
    strv=strvcat(str{1},str{2},str{3},str{4});
    muppet_writeErrorLog(err);
    fig=getappdata(gcf,'figure');
    figh=fig.handle;
    delete(figh);
    errordlg(strv,'Error');
end
