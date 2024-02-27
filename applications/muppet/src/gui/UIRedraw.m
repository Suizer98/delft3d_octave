function UIRedraw(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

SetPlotEdit(0);

data=Preview(data);
guidata(mpt,data);
