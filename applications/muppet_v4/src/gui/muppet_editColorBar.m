function muppet_editColorBar(varargin)
handles=getHandles;
s=gui_getUserData;
if isempty(s.colorbar.position)
    plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
    pos(1)=plt.position(1)+1;
    pos(2)=plt.position(2)+1;
    pos(3)=0.5;
    pos(4)=plt.position(4)-2;
    s.colorbar.position=pos;
    s.colorbar.labelposition='left';
end
[s.colorbar,ok]=gui_newWindow(s.colorbar, 'xmldir', handles.xmlguidir, 'xmlfile', 'colorbar.xml','iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    gui_setUserData(s);
end
