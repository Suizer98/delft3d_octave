function varargout = detran_selectInputSettings

h1 = detran_selectInputSettingsFigure;
uiwait(h1);
varargout = get(h1,'UserData');
close(h1);