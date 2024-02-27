function varargout = load_ascii_data(varargin)
% Part of the input reduction tool
% free to be amended if helpfull in your application

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

% Check the matlab version (we use object oriented programming & the new graphics engine): 
mv = version('-release');
if str2num(mv(1,1:4))<2016; error('Please use a Matlab version of 2016 or later'); end

% There is a fixed window size, screen centered, which should fit over 95% of screens (as of 2016): 
fig_size    = [1264 644];
screen_size = get(0,'ScreenSize');
if screen_size(3) < fig_size(1)+16 || screen_size (4) < fig_size(2)+40+8+28
    error(['Screen resolution is not sufficient, it''s ' datestr(now,'yyyy') ', try hooking-up a better external screen'])
end

data.fig = figure('MenuBar','none','Name','Load ASCII data','NumberTitle','off','Position',[screen_size(3)./2-fig_size(1)./2 min(screen_size(4)-fig_size(2)-28 , 48 + (screen_size(4)-48-28)./2 - fig_size(2)./2) fig_size],'Resize','off','ToolBar','none');

button_spacing   = 20;
edge_spacing     = 40;
height           = 22;
txt_cor          = 3;

no_of_lines      = 3;

% line 1
txt_size  = [50 height];
data.file_txt  = uicontrol(data.fig,'style','text','String','File:','Position',[edge_spacing fig_size(2)-edge_spacing-height-txt_cor txt_size],'fontsize',10,'HorizontalAlignment','left');

select_size = [100 height];
data.file_but  = uicontrol(data.fig,'style','pushbutton','String','Select file','Position',[fig_size(1)-edge_spacing-select_size(1) fig_size(2)-edge_spacing-height select_size],'fontsize',10,'Callback',@select_file);

data.file_edit = uicontrol(data.fig,'style','edit','String','','Position',[edge_spacing+txt_size(1)+button_spacing fig_size(2)-edge_spacing-height fig_size(1)-2*edge_spacing-2*button_spacing-select_size(1)-txt_size(1) height],'fontsize',10,'Enable','inactive');


% line 2

line2_size       = [150 height];
data.header_txt  = uicontrol(data.fig,'style','text','String','Number of header lines:','Position',[edge_spacing fig_size(2)-edge_spacing-2.*button_spacing-height-txt_cor line2_size],'fontsize',10,'Enable','off','HorizontalAlignment','left');
data.number_header = 1;
data.header_edit = uicontrol(data.fig,'style','edit','String',num2str(data.number_header),'Position',[edge_spacing+button_spacing+line2_size(1) fig_size(2)-edge_spacing-2.*button_spacing-height line2_size],'fontsize',10,'Enable','off','Callback',@change_header_nums);

data.delim_txt  = uicontrol(data.fig,'style','text','String','Delimiter (1 symbol):','Position',[edge_spacing+2*line2_size(1)+2*button_spacing fig_size(2)-edge_spacing-2.*button_spacing-height-txt_cor line2_size],'fontsize',10,'Enable','off','HorizontalAlignment','left');
data.delim = ';';
data.delim_edit = uicontrol(data.fig,'style','edit','String',data.delim,'Position',[edge_spacing+3*line2_size(1)+3*button_spacing fig_size(2)-edge_spacing-2.*button_spacing-height line2_size],'fontsize',10,'Enable','off','Callback',@change_delim);


% line 3

max_num_of_vars = 10;
line3_size      = [150 height];
data.vars_txt   = uicontrol(data.fig,'style','text','String','Number of variables:','Position',[edge_spacing fig_size(2)-edge_spacing-3.*button_spacing-2.*height-txt_cor line3_size],'fontsize',10,'Enable','off','HorizontalAlignment','left');
data.vars_numb  = uicontrol(data.fig,'style','popupmenu','String',cellstr(num2str([1:max_num_of_vars]')),'Position',[edge_spacing+button_spacing+line3_size(1) fig_size(2)-edge_spacing-3.*button_spacing-2.*height 50 line3_size(2)],'fontsize',10,'Enable','off','Callback',@change_var_nums);

var_size        = [floor((fig_size(1)-2.*edge_spacing-2.*button_spacing-50-line3_size(1))./max_num_of_vars)-button_spacing height];

for var=1:max_num_of_vars
    data.var_edit(var) = uicontrol(data.fig,'style','edit','String',['varname_' num2str(var,'%02.0f')],'Position',[edge_spacing+button_spacing+line3_size(1)+50+(var*button_spacing)+((var-1)*var_size(1)) fig_size(2)-edge_spacing-3.*button_spacing-2.*height var_size],'fontsize',8,'Enable','off');
end

convert_button_size = [100 height];

data.ax_size   = [(fig_size(1)./2)-edge_spacing-button_spacing-convert_button_size(1)./2 fig_size(2)-(2.*edge_spacing)-(no_of_lines*(height+button_spacing))];

data.ax_handle = axes('parent',data.fig,'box','on','Layer','top','units','pixels','Position',[edge_spacing edge_spacing data.ax_size],'fontsize',8,'XTick',[],'YTick',[]);

data.tab_handle = uitable(data.fig,'Position',[edge_spacing+2.*button_spacing+data.ax_size(1)+convert_button_size(1) edge_spacing data.ax_size]);

data.extract_but = uicontrol(data.fig,'style','pushbutton','String','Extract data','Position',[fig_size(1)./2-convert_button_size(1)./2 edge_spacing+(data.ax_size(2)./2)+(button_spacing./2) convert_button_size],'fontsize',10,'Callback',@extract_data,'Enable','off');
data.accept_but  = uicontrol(data.fig,'style','pushbutton','String','Accept data','Position',[fig_size(1)./2-convert_button_size(1)./2 edge_spacing+(data.ax_size(2)./2)-(button_spacing./2)-convert_button_size(2) convert_button_size],'fontsize',10,'Callback',@accept_data,'Enable','off');

guidata(data.fig,data);

uiwait(data.fig);

if ishandle(data.fig)
    for ii=1:nargout
        if ii == 1
            varargout{ii} = data.tab_handle.Data;
        elseif ii == 2
            varargout{ii} = data.tab_handle.ColumnName';
        else
            varargout{ii} = [];
        end
    end
    close(data.fig);
else
    for ii=1:nargout
        varargout{ii} = [];
    end
end

end

function select_file(hObject,eventdata)

data = guidata(hObject.Parent);

[fname,path] = uigetfile({'*.txt;*.dat;*.csv','ASCII file (*.txt, *.dat, *.csv)'},'Select an ASCII file')

if ischar(fname)
    data.file_edit.String = [path fname];
else
    uiwait(warndlg('No file selected', 'Warning'));
    return
end

show_file_contents(hObject,eventdata)
end

function show_file_contents(hObject,eventdata)

data = guidata(hObject.Parent);

fid = fopen(data.file_edit.String);

txt_tmp = textscan(fid,'%s','Delimiter','\n','whitespace','');
fclose(fid);
data.file_txt = txt_tmp{:};
delete(findobj(get(data.ax_handle,'Children'),'type','text'));
if floor(data.ax_size(2)./20)<size(data.file_txt,1)
    text(0.01,1,[data.file_txt(1:floor(data.ax_size(2)./20),:);'...';'..';'.'],'verticalalignment','top');
else
    text(0.01,1,data.file_txt,'verticalalignment','top');
end

data.extract_but.Enable = 'on';

data.header_txt.Enable  = 'on';
data.header_edit.Enable = 'on';
data.delim_txt.Enable   = 'on';
data.delim_edit.Enable  = 'on';
data.vars_txt.Enable    = 'on';
data.vars_numb.Enable   = 'on';

last_line      = double(char(data.file_txt(end,:)));
possible_delim = char(unique(last_line(find(last_line~=32 & (last_line<46 | last_line>57)))));
if size(possible_delim,2)>0
    data.delim_edit.String = possible_delim(1,1);
    data.vars_numb.Value = length(strfind(char(last_line),data.delim_edit.String))+1;
    set(data.var_edit(1:min(size(data.var_edit,2),data.vars_numb.Value)),'Enable','on');
end

first_nums = char(data.file_txt); first_nums = first_nums(:,1);
data.header_edit.String = num2str(max([0; find(double(first_nums)<48 | double(first_nums)>57)]));

guidata(data.fig,data);

end


function extract_data(hObject,eventdata)

data = guidata(hObject.Parent);

header = str2num(data.header_edit.String);
delim  = data.delim_edit.String;

data.var_names = get(data.var_edit(1:data.vars_numb.Value),'String')';

if data.vars_numb.Value < 3
    uiwait(warndlg(['Number of variables is ' num2str(data.vars_numb.Value) ', but should at least include ''Hs'', ''Tp'' and ''Dir'''], 'Warning'))
    return
end

if isempty(find(cellfun(@isempty,strfind(lower(data.var_names),'dir'))==0))
    uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
    return
end
if isempty(find(cellfun(@isempty,strfind(lower(data.var_names),'hs'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.var_names),'h_s'))==0))
    uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
    return
end
if isempty(find(cellfun(@isempty,strfind(lower(data.var_names),'tp'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.var_names),'t_p'))==0))
    uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
    return
end

if header>0
    extract_txt = data.file_txt(1+header:end,:);
else
   extract_txt = data.file_txt;  
end
diff = 1;
while diff
    extract_txt_old = extract_txt;
    extract_txt = strrep(extract_txt_old,[delim delim],[delim]);
    if isempty(find(strcmp(extract_txt_old,extract_txt)==0))
        diff = 0;
        extract_txt = strrep(extract_txt,delim,' ');
    end
end

try
    data.extracted_data = str2num(char(extract_txt));
end

if isempty(data.extracted_data) || size(data.extracted_data,2)~=length(data.var_names)
    col = get(data.extract_but,'backgroundcolor');
    set(data.extract_but,'backgroundcolor','r');
    drawnow; pause(0.5);
    set(data.extract_but,'backgroundcolor',col);
    return
end

data.tab_handle.Data = data.extracted_data;

table_text_width = data.ax_size(1)-(52+11*max(0,(ceil(log10(1+size(data.tab_handle.Data,1)))-2)));
set(data.tab_handle,'ColumnEditable',logical([zeros(1,size(data.tab_handle.Data,2))]),'ColumnWidth',repmat({floor(table_text_width./size(data.tab_handle.Data,2))},1,size(size(data.tab_handle.Data,2),2)),'ColumnName',data.var_names,'FontSize',9);

data.accept_but.Enable = 'on';

guidata(data.fig,data);

end

function change_var_nums(hObject,eventdata)

data = guidata(hObject.Parent);

set(data.var_edit,'Enable','off');
set(data.var_edit(1:data.vars_numb.Value),'Enable','on');

end

function change_header_nums(hObject,eventdata)

data = guidata(hObject.Parent);

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) >= 0
        if str2num(hObject.String) == round(str2num(hObject.String))
            if str2num(hObject.String) < size(data.file_txt,1)
                data.number_header = str2num(hObject.String);
                guidata(data.fig,data);
                hObject.BackgroundColor = 'g';
                pause(0.2);
                hObject.BackgroundColor = 'w';
            else
                incor = 1;
                mess  = 'Too large!';
            end
        else
            incor = 1;
            mess  = 'Integer!';
        end
    else
        incor = 1;
        mess  = '0 and up!';
    end
else
    incor = 1;
    mess  = 'Number!';
end

if incor
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.number_header);
end

end



function change_delim(hObject,eventdata)

data = guidata(hObject.Parent);

incor = 0;
if size(hObject.String,2) == 1
    if double(hObject.String)<48 || double(hObject.String)>57
        data.delim = hObject.String;
        guidata(data.fig,data);
        hObject.BackgroundColor = 'g';
        pause(0.2);
        hObject.BackgroundColor = 'w';
    else
        incor = 1;
        mess  = 'No value!';
    end
else
    incor = 1;
    mess  = 'Single symbol!';
end

if incor
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        drawnow; pause(0.05);
    end
    hObject.String = data.delim;
end

end

function accept_data(hObject,eventdata)

uiresume

end


