function varargout = numerical_integration(varargin)
%NUMERICAL_INTEGRATION can be used to setup generic numerical integration
%input and output structures through both scripting and a GUI. The output
%structure (generated from the input structure) can be used to perform a
%probabilistic numerical integration analysis
%
%The generic numerical intergration input (nii) structures can be used to
%construct numerical integration output (nio) structures, which contain
%both a matrix and tree approach.
%
%When simply calling numerical_integration, the GUI is launched. Below, a
%list is provided describing all available syntax options:
%
%  numerical_integration('example');
%      Provides an example numerical integration input (nii) structure, for
%      reference (e.g. for when setting up an input structure through code)
%
%  numerical_integration('gui');
%      Start the GUI, identical to the call "numerical_integration"
%
%  numerical_integration('numerical_integration_input_file.nii');
%      Loads the contents of the earlier saved *.nii file into the GUI
%
%  numerical_integration(numerical_integration_structure);
%      Loads the contents of the specified input structure into the GUI
%
%  numerical_integration('generate','numerical_integration_input_file.nii');
%      Converts the specified numerical integration input file into a
%      numerical integration output structure within the workspace
%
%  numerical_integration('execute',numerical_integration_structure);
%      Converts the specified numerical integration input structure into a
%      numerical integration output structure within the workspace
%
%      The keywords 'generate', 'execute' and 'output' can be mixed and all
%      generate a numerical integration output structure from the input
%
%  If a numerical integration output structure was saved to a *.nio file
%  earlier (instead to the workspace) it can be (re)loaded using:
%      output_struct = load('output_file.nio','-mat');
%          Or simply rename it to a *.mat file and load it:
%      output_struct = load('output_file.mat');
%
%  The generated output matrix and/or tree can subsequently be used to loop
%  through all the different variable sets within a computation.

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%
%       Freek.Scheel@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

if isempty(varargin)
    % open GUI
    numerical_integration_GUI
    call = 'numerical_integration';
elseif length(varargin) == 1
    if isstruct(varargin{1})
        check_input_struct(varargin{1})
        numerical_integration_GUI(varargin{1})
        call = 'numerical_integration(numerical_integration_input_structure)';
    elseif isstr(varargin{1})
        if (~isempty(strfind(varargin{1},'example')))
            varargout{1}(1).Name    = 'variable name #1';
            varargout{1}(1).Default = 2;
            varargout{1}(1).Data    = [1 0.4; 2 0.4; 3 0.2];
            varargout{1}(2).Name    = 'variable name #2';
            varargout{1}(2).Default = 3;
            varargout{1}(2).Data    = [1 0.3; 2 0.4; 3 0.2; 4 0.1];
            call = ['numerical_integration(''' varargin{1} ''')'];
        elseif (~isempty(strfind(varargin{1},'gui')))
            % start the gui
            numerical_integration_GUI
            call = ['numerical_integration(''' varargin{1} ''')'];
        elseif exist(varargin{1}) == 2
            input_struct_new = check_and_load_file(varargin{1});
            check_input_struct(input_struct_new,varargin{1});
            numerical_integration_GUI(input_struct_new);
            call = ['numerical_integration(''' varargin{1} ''')'];
        else
            disp(['Unknown command ''' varargin{1} ''', the GUI has been opened though']);
            numerical_integration_GUI
            call = ['numerical_integration(''' varargin{1} ''')'];
        end
    else
        numerical_integration_GUI
        error('Unknown input specified, please resort to the help, the GUI has been opened though');
    end
elseif length(varargin) == 2
    if isstr(varargin{1}) && (isstruct(varargin{2}) || isstr(varargin{2}))
        if (~isempty(strfind(varargin{1},'generate'))) || (~isempty(strfind(varargin{1},'execute'))) || (~isempty(strfind(varargin{1},'output')))
            if isstruct(varargin{2}) == 1
                check_input_struct(varargin{2});
                varargout{1} = gen_ni_tree_matrix(varargin{2},'scripting');
                call = ['numerical_integration(''' varargin{1} ''',numerical_integration_input_structure)'];
            elseif isstr(varargin{2}) == 1
                input_struct_new = check_and_load_file(varargin{2});
                check_input_struct(input_struct_new,varargin{2});
                varargout{1} = gen_ni_tree_matrix(input_struct_new,'scripting');
                call = ['numerical_integration(''' varargin{1} ''',''' varargin{2} ''')'];
            end
        else
            error(['Unknown command ''' varargin{1} ''' for function numerical_integration when using 2 input parameters'])
        end
    else
        error('Unknown input specified, please resort to the help');
    end
else
    error('Unknown input specified, please resort to the help');
end

if nargout==1
    if exist('varargout','var')~=1
        varargout{1} = ['No data generated for specified output variable #1 during call: output = ' call];
    end
elseif nargout>1
    disp('Please, do not use more than 1 output variable');
    if exist('varargout','var')~=1
        varargout{1} = ['No data generated for specified output variable #1 during call: ' call];
    end
    for ii=2:nargout
        varargout{ii} = ['No data generated for specified output variable #' num2str(ii) ' during call: ' call];
    end
end

end

function numerical_integration_GUI(varargin)

if ~isempty(findobj('type','figure','tag','nis_GUI'))
    close(findobj('type','figure','tag','nis_GUI'))
end

figure
set(gcf,'MenuBar','none','Name','Numerical Integration input generator','tag','nis_GUI','NumberTitle','off','Resize','off','units','pixels','position',get(gcf,'position').*[1 1 0 0] + [0 0 700 200],'color',[244 248 255]/255,'DockControls','off');
menu_handle = uimenu('Label','File');
uimenu(menu_handle,'Label','New Numerical Integration Input structure','Callback',@restart_ni_GUI,'Accelerator','N');
uimenu(menu_handle,'Label','Open Numerical Integration Input file (*.nii)','Callback',@load_input_struct,'Accelerator','O','Separator','on');
uimenu(menu_handle,'Label','Save Numerical Integration Input file (*.nii)','Callback',@save_input_struct,'Accelerator','S');
uimenu(menu_handle,'Label','Quit','Callback','close(findobj(''type'',''figure'',''tag'',''nis_GUI''))','Separator','on','Accelerator','Q');

default_struct(1).Name    = 'variable name #1';
default_struct(1).Default = 2;
default_struct(1).Data    = [1 0.4; 2 0.4; 3 0.2];
default_struct(2).Name    = 'variable name #2';
default_struct(2).Default = 3;
default_struct(2).Data    = [1 0.3; 2 0.4; 3 0.2; 4 0.1];

if isempty(varargin)
    input_struct = default_struct;
else
    if length(varargin)>1
        if isnumeric(varargin{1}) && isempty(varargin{2})
            % Re-loaded through GUI:
            input_struct = default_struct;
        end
    else
        if isstruct(varargin{1})
            input_struct = varargin{1};
            check_input_struct(input_struct);
        elseif isstr(varargin{1})
            if exist(varargin{1}) == 2
                % we're deadling with a filename here:
                input_struct = check_and_load_file(varargin{1});
                check_input_struct(input_struct,varargin{1}(1,(max([0 strfind(varargin{1},filesep)])+1):end));
            elseif 0
                % keyword value pairs could be used here
            else
                error(['Unknown input specification for ' varargin{1}])
            end
        else
            error('Unknown function input');
        end
    end
end

data.input_struct = input_struct;

data.fig_prop.column_width      = 40;
data.fig_prop.column_height     = 40;
data.fig_prop.column_in_between = 20;

data.fig_prop.header_height = 70;
data.fig_prop.footer_height = 100;

data.fig_prop.left_space    = 200;
data.fig_prop.right_space   = 340;

guidata(gcf,data);

replot_figure('startup')

end

function replot_figure(varargin)

gui_handle   = findobj('type','figure','tag','nis_GUI');

delete(findobj(get(gui_handle,'children'),'-not','type','uimenu'));
delete(findobj('type','figure','tag','run_tree'));

% not edited here, only used:
data = guidata(gui_handle);

figure_size  = [((max(cellfun(@length,{data.input_struct.Data})) * data.fig_prop.column_width * 2) + data.fig_prop.left_space + data.fig_prop.right_space)   ((data.fig_prop.column_height*(size(data.input_struct,2))) + (data.fig_prop.column_in_between*((size(data.input_struct,2))-1)) + data.fig_prop.header_height + data.fig_prop.footer_height)];

if isempty(varargin)
    fig_ud = 0;
else
    if isnumeric(varargin{1})
        fig_ud = varargin{1} * (data.fig_prop.column_height + data.fig_prop.column_in_between);
    elseif isstr(varargin{1})
        if strcmp(varargin{1},'startup')
            fig_ud = -(size(data.input_struct,2) - 2) * (data.fig_prop.column_height + data.fig_prop.column_in_between);
        end
    end
end

set(gui_handle,'position',get(gui_handle,'position').*[1 1 0 0] + [0 fig_ud figure_size]);

uicontrol('Style','text','Position',[10 figure_size(2)-data.fig_prop.header_height+5 120 13],'String','Variable name:','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'));
uicontrol('Style','text','Position',[140 figure_size(2)-data.fig_prop.header_height+5 50 13],'String','Default:','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'));
uicontrol('Style','text','Position',[data.fig_prop.left_space figure_size(2)-data.fig_prop.header_height+5 300 13],'String','Values and associated probabilities:','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'));

sum_p_err = 0; def_err = 0;
for ii = 1:size(data.input_struct,2)
    uicontrol(gui_handle,'Style','edit','tag',num2str(ii),'String',data.input_struct(ii).Name,'Position',[10 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+10 120 20],'callback',@var_name_edit);
    e = uicontrol(gui_handle,'Style','edit','tag',num2str(ii),'String',data.input_struct(ii).Default,'Position',[140 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+10 50 20],'callback',@default_edit);
    if isempty(find(data.input_struct(ii).Data(:,1)==data.input_struct(ii).Default))
        set(e,'BackgroundColor',[255 165 0]/255);
        def_err = 1;
    else
        set(e,'BackgroundColor',[193 255 193]/255)
    end
    t = uitable(gui_handle,'Data',strrep(cellstr(num2str([reshape(data.input_struct(ii).Data',1,prod(size(data.input_struct(ii).Data)))]'))',' ',''),'tag',num2str(ii),'Position',[data.fig_prop.left_space figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height (data.fig_prop.column_width*2*size(data.input_struct(ii).Data,1))+2 data.fig_prop.column_height],'columnName',reshape([cellstr(char([1:size(data.input_struct(ii).Data,1)]'+'A'-1)) cellstr([repmat('P(',size(data.input_struct(ii).Data,1),1) char([1:size(data.input_struct(ii).Data,1)]'+'A'-1) repmat(')',size(data.input_struct(ii).Data,1),1)])]',1,2*size(data.input_struct(ii).Data,1)),'ColumnWidth',repmat({data.fig_prop.column_width},1,2*size(data.input_struct(ii).Data,1)),'RowName','','ColumnEditable',true,'CellEditCallback',@table_edit);
    if ((round(sum(data.input_struct(ii).Data(:,2))*10^6))/10^6) ~= 1
        set(t,'BackgroundColor',[[1 0 0]; 1 1 1])
        sum_p_err = 1;
    else
        set(t,'BackgroundColor',[[193 255 193]/255; 1 1 1])
    end
    tot = uicontrol('Style','text','Position',[(data.fig_prop.column_width*2*length(data.input_struct(ii).Data))+data.fig_prop.left_space+5 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+4 55 13],'String',['P = ' num2str(sum(data.input_struct(ii).Data(:,2)),'%0.4f')],'HorizontalAlignment','left','BackGroundColor',get(gcf,'color'));
    if ((round(sum(data.input_struct(ii).Data(:,2)).*10^12)).*10^(-12))~=1
        set(tot,'Foregroundcolor','r');
    end
    if size(data.input_struct(ii).Data,1)>2
        uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Remove point','Position',[(data.fig_prop.column_width*2*max(cellfun(@length,{data.input_struct.Data})))+data.fig_prop.left_space+60 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height 80 20],'callback',@remove_point);
    end
    uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Add point','Position',[(data.fig_prop.column_width*2*max(cellfun(@length,{data.input_struct.Data})))+data.fig_prop.left_space+60 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+20 80 20],'callback',@add_point);
    if ii~=1
        uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Move up','Position',[(data.fig_prop.column_width*2*max(cellfun(@length,{data.input_struct.Data})))+data.fig_prop.left_space+150 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+20 70 20],'callback',@move_up);
    end
    if ii~=size(data.input_struct,2)
        uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Move down','Position',[(data.fig_prop.column_width*2*max(cellfun(@length,{data.input_struct.Data})))+data.fig_prop.left_space+150 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height 70 20],'callback',@move_down);
    end
    if size(data.input_struct,2)>1
        uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Delete variable','Position',[(data.fig_prop.column_width*2*max(cellfun(@length,{data.input_struct.Data})))+data.fig_prop.left_space+230 figure_size(2)-(ii*data.fig_prop.column_height)-((ii-1)*data.fig_prop.column_in_between)-data.fig_prop.header_height+10 100 20],'callback',@remove_variable);
    end
end

% header:

uicontrol('Style','text','Position',[10 figure_size(2)-13 500 13],'String','- Order of variables according to their relative importance (for tree approach)','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'),'FontWeight','bold');
uicontrol('Style','text','Position',[10 figure_size(2)-26 500 13],'String','- Sum of probabilities (P) should always be 1 for each variable','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'),'FontWeight','bold','ForeGroundColor',[0 0 0] + ([1 0 0].*sum_p_err));
uicontrol('Style','text','Position',[10 figure_size(2)-39 500 13],'String','- It is advised to include the default value when using a levelled tree approach','HorizontalAlignment','left','BackGroundColor',get(gcf,'color'),'FontWeight','bold','ForeGroundColor',[0 0 0] + ([[255 128 0]/255].*def_err));

% footer:
uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Add a variable','Position',[10 data.fig_prop.footer_height-30 120 20],'callback',@add_variable);

uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Load input structure','Position',[figure_size(1)-280 50 130 30],'callback',@load_input_struct,'FontWeight','bold');
uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Save input structure','Position',[figure_size(1)-140 50 130 30],'callback',@save_input_struct,'FontWeight','bold');
on_off = {'on' 'off'};
uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String','Generate a Numerical Integration Tree/Matrix','Position',[figure_size(1)-280 10 270 30],'callback',@gen_ni_tree_matrix,'FontWeight','bold','Enable',on_off{1,sum_p_err+1});
v_rt = uicontrol(gcf,'Style','pushbutton','tag',num2str(ii),'String',['<html><center>View run tree </center><center><b>(' num2str(prod(cellfun(@length,{data.input_struct.Data}))) ' runs)</b></center>'],'Position',[10 10 120 35],'callback',@view_tree,'HorizontalAlignment','right');
if prod(cellfun(@length,{data.input_struct.Data}))>100000
    set(v_rt,'enable','off')
end

end

function add_variable(varargin)

gui_handle   = findobj('type','figure','tag','nis_GUI');
data         = guidata(gui_handle);

old_size = size(data.input_struct,2);

tel = 1; param_name = ['variable name #' num2str(tel)];
while sum(strcmp({data.input_struct.Name}',param_name))>0
    tel = tel+1;
    param_name = ['variable name #' num2str(tel)];
end

data.input_struct(old_size+1).Name    = param_name;
data.input_struct(old_size+1).Default = 2;
data.input_struct(old_size+1).Data    = [1 0.3; 2 0.4; 3 0.3];

guidata(gcf,data);

replot_figure(-1)

end

function remove_variable(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

data.input_struct(ind) = [];

guidata(gcf,data);
replot_figure(1)

end

function move_up(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

for ii = [1:size(data.input_struct,2)]
    if ii == ind-1
        input_struct_new(ii) = data.input_struct(ii+1);
    elseif ii == ind
        input_struct_new(ii) = data.input_struct(ii-1);
    else
        input_struct_new(ii) = data.input_struct(ii);
    end
end

data.input_struct = input_struct_new;

guidata(gcf,data);
replot_figure

end

function move_down(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

for ii = [1:size(data.input_struct,2)]
    if ii == ind+1
        input_struct_new(ii) = data.input_struct(ii-1);
    elseif ii == ind
        input_struct_new(ii) = data.input_struct(ii+1);
    else
        input_struct_new(ii) = data.input_struct(ii);
    end
end

data.input_struct = input_struct_new;

guidata(gcf,data);
replot_figure

end

function add_point(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

data.input_struct(ind).Data(end+1,:) = [1 0.1];

guidata(gcf,data);
replot_figure

end

function remove_point(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

data.input_struct(ind).Data(end,:) = [];

guidata(gcf,data);
replot_figure

end

function var_name_edit(varargin)
gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

data.input_struct(ind).Name = get(varargin{1},'string');

guidata(gcf,data);
end

function default_edit(varargin)
gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

val_old = data.input_struct(ind).Default;

if isempty(str2num(get(varargin{1},'string')))
    for ii=1:5
        if (ii/2) == round(ii/2)
            set(varargin{1},'BackgroundColor',[1 1 1])
            pause(0.05)
        else
            set(varargin{1},'BackgroundColor',[1 0 0])
            pause(0.05)
        end
    end
    set(varargin{1},'string',val_old);
else
    data.input_struct(ind).Default = str2num(get(varargin{1},'string'));
    if isempty(find(data.input_struct(ind).Data(:,1) == data.input_struct(ind).Default))
        set(varargin{1},'BackgroundColor',[255 140 0]/255);
    else
        set(varargin{1},'BackgroundColor',[0.941176 0.941176 0.941176]);
    end
end

guidata(gcf,data);

replot_figure;
end

function table_edit(varargin)
gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

ind = str2num(get(varargin{1},'tag'));

vals_old = reshape(data.input_struct(ind).Data',1,prod(size(data.input_struct(ind).Data)));
vals_new = get(varargin{1},'Data');

err = 0;
for ii=1:size(vals_new,2)
    if isempty(str2num(char(vals_new(ii))))
        vals_new_final{1,ii} = 'NaN';
        vals_new_num(1,ii)   = NaN;
        err = 1;
    elseif ((ii/2)==round(ii/2)) && ( (str2num(char(vals_new(ii))) <= 0) | (str2num(char(vals_new(ii))) >= 1) )
        vals_new_final{1,ii} = 'NaN';
        vals_new_num(1,ii)   = NaN;
        err = 1;
    else
        vals_new_final{1,ii} = vals_new{ii};
        vals_new_num(1,ii)   = str2num(char(vals_new(ii)));
    end
end

if err == 1
    for ii=1:5
        if (ii/2) == round(ii/2)
            set(varargin{1},'BackgroundColor',[1 1 1; 1 1 1])
            pause(0.05)
        else
            set(varargin{1},'BackgroundColor',[1 0 0; 1 1 1])
            pause(0.05)
        end
    end
    set(varargin{1},'Data',strrep(cellstr(num2str(vals_old'))',' ',''))
else
    set(varargin{1},'Data',strrep(cellstr(num2str(vals_new_num'))',' ',''))
    data.input_struct(ind).Data = reshape(vals_new_num,2,size(vals_new_num,2)/2)';
end

guidata(gcf,data);

replot_figure

end

function load_input_struct(varargin)

gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

[file_name path_name] = uigetfile({'*.nii','Numerical Integration Input file (*.nii)';'*.mat','Matlab data file (*.mat)'},'test');

if isequal(file_name,0) || isequal(path_name,0)
    msgbox({'Aborted by user';' ';'No data was loaded'},'Loading aborted','warn')
    return
end

input_struct_new = check_and_load_file([path_name file_name]);

check_input_struct(input_struct_new,file_name);

% Everything is OK:
size_old = size(data.input_struct,2);
data.input_struct = input_struct_new;

guidata(gcf,data);

replot_figure(size_old - size(data.input_struct,2))

end

function ok = save_input_struct(varargin)
gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

if length(varargin) == 1
    if isstr(varargin{1})
        if strcmp(varargin{1},'restart')
            save_i_f = 1;
        end
    end
elseif (ishandle(varargin{1}) && isempty(varargin{2})) | length(varargin) == 0
    quest_1 = questdlg({'How would you like to save the input structure?'},'How to save the input?','Save to file','Place it in the Workspace','Cancel','Save to file');
    switch quest_1
        case 'Save to file'
            save_i_f = 1;
            save_i_w = 0;
        case 'Place it in the Workspace'
            save_i_f = 0;
            save_i_w = 1;
        otherwise
            save_i_f = 0;
            save_i_w = 0;
            msgbox({'Aborted by user';' ';'No data was saved'},'Saving aborted','warn')
            ok = 0;
    end
end


if save_i_f == 1
    [file_name path_name] = uiputfile({'*.nii' 'Numerical Integration Input file (*.nii)'},'Specify numerical integration input file');
    if isequal(file_name,0) || isequal(path_name,0)
       msgbox({'Aborted by user';' ';'No data was saved'},'Saving aborted','warn')
       ok = 0;
    else
       input_struct = data.input_struct;
       save([path_name file_name],'input_struct');
       ok = 1;
    end
elseif save_i_w
    input_struct = data.input_struct;
    assignin('base','input_struct',input_struct);
    ok = 1;
end

end

function input_struct_new = check_and_load_file(varargin)

data_loaded = load(varargin{1},'-mat');

if sum(strcmp(fieldnames(data_loaded),'input_struct'))
    input_struct_new = data_loaded.input_struct;
else
    % try to find a unique (other named) struct:
    loaded_fieldnames = fieldnames(data_loaded);
    for ii=1:size(loaded_fieldnames,1)
        list_of_structs(ii,1) = isstruct(data_loaded.(loaded_fieldnames{ii,1}));
    end
    if sum(list_of_structs) == 1
        input_struct_new = data_loaded.(loaded_fieldnames{find(list_of_structs==1),1});
    else
        % multiple or no structures in the mat file:
        if strcmp(file_name(1,end-3:end),'.nii')
            add_text = ', was this nii-file saved using the GUI?';
        else
            add_text = '';
        end
        error(['Unexpected format of file: ''' varargin{1}(1,(max([0 strfind(varargin{1},filesep)])+1):end) '''' add_text]);
    end
end

end

function check_input_struct(varargin)

input_struct_new = varargin{1};
if length(varargin)>1
    file_name = varargin{2};
else
    file_name = 'input structure';
end

% Lets check the struct for consistency:
if (size(fieldnames(input_struct_new),1)==3) && sum(strcmp(fieldnames(input_struct_new),'Name')) && sum(strcmp(fieldnames(input_struct_new),'Default')) && sum(strcmp(fieldnames(input_struct_new),'Data'))
    % good, lets check a bit deeper:
    if min(cellfun(@isstr,{input_struct_new.Name}')) && min(cellfun(@isnumeric,{input_struct_new.Default}')) && min(cellfun(@ismatrix,{input_struct_new.Data}'))
        % Everything is OK:
    else
        if strcmp(file_name(1,end-3:end),'.nii')
            add_text = ', was this nii-file saved using the GUI?';
        else
            add_text = '';
        end
        error(['Unexpected format of ' file_name add_text]);
    end
else
    if strcmp(file_name(1,end-3:end),'.nii')
        add_text = ', was this nii-file saved using the GUI?';
    else
        add_text = '';
    end
    error(['Unexpected format of ' file_name add_text]);
end

end

function restart_ni_GUI(varargin)

user_resp = questdlg({'Creating a new input structure will erase all current data';'';'What would you like to do?'},'Erase old input structure?','Erase and continue','Continue after saving','Cancel','Erase and continue');

switch user_resp
    case 'Erase and continue'
        numerical_integration_GUI;
    case 'Continue after saving'
        ok = save_input_struct('restart');
        if ok == 1
            numerical_integration_GUI;
        end
end

end

function view_tree(varargin)
gui_handle = findobj('type','figure','tag','nis_GUI');
data       = guidata(gui_handle);

wait_fig = figure; ax = axes('position',[0 0 1 1],'xtick',[],'ytick',[]);
set(wait_fig,'menu','none','NumberTitle','off','name','Please wait...','position',(get(wait_fig,'position') .* [1 1 0 0]) + [0 0 200 100],'tag','wait_fig');
text(0.5,0.6,'Generating run tree figure...','horizontalalignment','center');
t_w = text(0.5,0.4,'0%','horizontalalignment','center');

facts = cellfun(@length,{data.input_struct.Data});

x_num = size(data.input_struct,2);
y_num = prod(facts);

x_levs = [(1/(x_num+2)):(1/(x_num+2)):(1-(1/(x_num+2)))];
y_levs(:,(size(facts,2)+1)) = flipud([(1/(y_num+1)):(1/(y_num+1)):(1-(1/(y_num+1)))]');

for ii=size(facts,2):-1:1
    for jj=1:prod(facts(1,ii:size(facts,2))):size(y_levs,1)
        y_levs(jj:(jj+prod(facts(1,ii:size(facts,2)))-1),ii) = mean(y_levs(jj:(jj+prod(facts(1,ii:size(facts,2)))-1),ii+1));
    end
end

perc = 0;
delete(findobj('type','figure','tag','run_tree'));

fig = figure; ax = axes('position',[0.05 0.15 0.9 0.7]); hold on; box on; grid on; set(fig,'visible','off','color',[244 248 255]/255,'menu','none','Name','Run tree overview','tag','run_tree','NumberTitle','off','position',get(fig,'position') + [-200 -400 200 400]);
for ii=1:size(y_levs,1)
    if ~ishandle(wait_fig)
        close(fig)
        msgbox({'Generating figure was aborted by the user'},'Aborted by user','warn')
        return
    else
        p = plot(ax,x_levs,y_levs(ii,:),'ko-','markersize',6,'MarkerFaceColor','y','MarkerEdgeColor','k');
    end
    if round(100*ii/size(y_levs,1)) ~= perc
        perc = round(100*ii/size(y_levs,1));
        set(t_w,'string',[num2str(perc,'%2.0f') '%']); drawnow;
    end
end
axes(ax);

axis equal; xlim([0 1]); ylim([0 1]);
set(ax,'xtick',x_levs,'ytick',[],'xticklabel',[]);

x_labels = ['Start' {data.input_struct.Name}];
for ii=1:size(x_levs,2)
    t_l(ii) = text(x_levs(1,ii),0,[x_labels{1,ii} '  ']);
    t_u(ii) = text(x_levs(1,ii),1,['  ' x_labels{1,ii}]);
end
set(t_l,'rotation',45,'horizontalalignment','right');
set(t_u,'rotation',45,'horizontalalignment','left');

close(findobj('tag','wait_fig'));
set(fig,'visible','on');

end

function varargout = gen_ni_tree_matrix(varargin)

if length(varargin)==2 && min(ishandle(varargin{1})) && isempty(varargin{2})
    % via GUI:
    gui_handle   = findobj('type','figure','tag','nis_GUI');
    data         = guidata(gui_handle);
    input_struct = data.input_struct;
    via_gui      = 1;
elseif length(varargin)==2 && isstruct(varargin{1}) && isstr(varargin{2})
    if strcmp('scripting',varargin{2})
        % Via scripting call
        input_struct = varargin{1};
        via_gui = 0;
    end
else
    error('Unknown internal call, contact developer using code 4320561')
end

check_input_struct(input_struct);

wait_fig = figure; ax = axes('position',[0 0 1 1],'xtick',[],'ytick',[]);
set(wait_fig,'menu','none','NumberTitle','off','name','Please wait...','position',(get(wait_fig,'position') .* [1 1 0 0]) + [0 0 300 100],'tag','wait_fig');
text(0.5,0.6,'Generating Numerical Integration Tree/Matrix...','horizontalalignment','center');
t_w = text(0.5,0.4,'0%','horizontalalignment','center');
perc = 0; tel = 0;

cur_factors = [cellfun(@length,{input_struct.Data})];

[sorted_names,sorted_inds] = sortrows({input_struct.Name}',1);

for ii = 1:size(cur_factors,2) % level of tree: ii
    for jj = 1:prod(cur_factors(1:ii)) % total number of runs in level: jj
        tel = tel+1;
        if ~ishandle(wait_fig)
            msgbox({'Generating Numerical Integration Tree/Matrix was aborted by the user'},'Aborted by user','warn')
            return
        end
        if round(100*tel/sum(cumprod(cur_factors))) ~= perc
            perc = round(100*tel/sum(cumprod(cur_factors)));
            set(t_w,'string',[num2str(perc,'%2.0f') '%']); drawnow;
        end
        for kk = 1:size(cur_factors,2) % considered variable ind: kk
            % tree stuff here:
            if kk > ii
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Variable    = input_struct(kk).Name;
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Value       = input_struct(kk).Default;
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Probability = ['Not used in level ' num2str(ii) ' (default value is used)'];
            else
                ind_s{ii}(jj,kk) = (mod((ceil(jj./prod(cur_factors(kk+1:ii))))-1,cur_factors(kk))+1);
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Variable    = input_struct(kk).Name;
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Value       = input_struct(kk).Data(ind_s{ii}(jj,kk),1);
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(1,kk).Probability = input_struct(kk).Data(ind_s{ii}(jj,kk),2);
                if kk==ii
                    output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Probability = prod([output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data.Probability]);
                end
            end
            if kk==size(cur_factors,2)
                output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Variable_set_ID = strjoin(reshape(([sorted_names'; repmat({'='},1,size(sorted_names,1)); cellfun(@num2str,num2cell([output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Data(sorted_inds).Value]),'uniformoutput',false); strrep([repmat({' <> '},1,size(sorted_names,1)-1) 'empty_cell'],'empty_cell','')]),1,4*size(sorted_names,1)),'');
            end
        end
        % matrix stuff here:
        if ii==size(cur_factors,2) % only final level
            for kk = 1:size(cur_factors,2) % considered variable ind: kk
                cur_ind = num2cell(ind_s{ii}(jj,:));
                if jj==1
                    output_struct.matrix(1,1).Variable = 'Probability for each set of variables';
                    output_struct.matrix(1,kk+1).Variable = input_struct(kk).Name;
                end
                output_struct.matrix(1,1).Values(cur_ind{:}) = output_struct.tree.(['level_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f'])]).(['set_' num2str(ii,['%0' num2str(floor(log10(size(cur_factors,2))+1)) '.0f']) '_' num2str(jj,['%0' num2str(floor(log10(prod(cur_factors))+1)) '.0f'])]).Probability;
                output_struct.matrix(1,kk+1).Values(cur_ind{:}) = input_struct(kk).Data(ind_s{ii}(jj,kk),1);
            end
        end
    end
end

output_struct.information.original_input_struct = input_struct;
output_struct.information.matrix                = {['Each dimension in the generated matrices (size = [' strrep(num2str(cur_factors),'  ',',') ']) resembles a variable'];['The size of each dimension resembles the number of specified values per variable']};
output_struct.information.tree                  = {['Each of the levels (number of levels = ' num2str(size(cur_factors,2)) ') in the tree includes another variable (else default values are used)'];['Each set in a tree level has a unique ID (Variable_set_ID) though can be repeated through the levels'];['When looping through each level, this unique ID can be used to avoid double runs.'];['Though this is required when only considering the last level (identical approach as to using the  matrix)']};

close(findobj('tag','wait_fig'));

if via_gui == 1
    quest_1 = questdlg({'The Numerical Integration Tree/Matrix';'structure was succesfully generated.';' ';'What would you like to do with it?'},'Tree/Matrix constructed','Save to file','Place it in the Workspace','Cancel','Save to file');
    switch quest_1
        case 'Save to file'
            save_tm_f = 1;
            save_tm_w = 0;
        case 'Place it in the Workspace'
            save_tm_f = 0;
            save_tm_w = 1;
        otherwise
            quest_2 = questdlg({'Output Tree/Matrix will be deleted';' ';'Are you sure about this?'},'Are you sure?','Yes','No, save to file','No, place it in the Workspace','Yes');
            switch quest_2
                case 'No, save to file'
                    save_tm_f = 1;
                    save_tm_w = 0;
                case 'No, place it in the Workspace'
                    save_tm_f = 0;
                    save_tm_w = 1;
                otherwise
                    msgbox({'Saving the output Tree/Matrix to file was aborted by the user'},'Aborted by user','warn')
                    save_tm_f = 0;
                    save_tm_w = 0;
            end
    end
    if save_tm_f == 1
        ok = save_output_struct(output_struct);
    end
    if save_tm_w == 1
        assignin('base','output_struct',output_struct);
    end
else
    varargout{1} = output_struct;
end

end

function ok = save_output_struct(varargin)

% gui_handle = findobj('type','figure','tag','nis_GUI');
% data       = guidata(gui_handle);

[file_name path_name] = uiputfile({'*.nio' 'Numerical Integration Output file (*.nio)'},'Specify numerical integration Output file');
if isequal(file_name,0) || isequal(path_name,0)
    msgbox({'Aborted by user';' ';'No output data was saved'},'Saving aborted','warn')
    ok = 0;
else
    output_struct = varargin{1};
    save([path_name file_name],'output_struct');
    ok = 1;
end

end
