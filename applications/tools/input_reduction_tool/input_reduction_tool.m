function input_reduction_tool(varargin)
%
% Below a brief summary on how to work with the input reduction tool is
% provided. A more detailed user manual can be found in the pdf:
%
% Description_and_user_manual_input_reduction_tool.pdf
%
% Which can be found in the following OET folder:
%
% .\matlab\applications\tools\input_reduction_tool\
%
% The input reduction tool can be used to reduce wave input, primarily to
% reduce the computational burdon of numerical models. It supports the
% following input reduction methods:
%
%   - Fixed bins
%   - Maximum dissimilarity (MDA)
%   - K-means:
%       - Crisp         (initialization: random, MDA, fixed bins)
%       - Fuzzy         (initialization: random, MDA, fixed bins)
%       - Harmonic      (initialization: random, MDA, fixed bins)
%   - Sediment transport bins
%
% And can be applied with different weighting of the wave data:
%
%   - Hs
%   - Hs^m
%   - Wave energy E (1/8*c_g*H_s^2*g*Rho)
%   - Custom weighting (e.g. a sediment transport proxy, can be loaded in)
%
% In order to use the input reduction tool, simply call the function:
%
%    input_reduction_tool()
%
% This will open the interactive GUI (Matlab 2016a or later). The GUI
% consists of the following sections:
%
%    (1) Data import & data manipulation
%    (2) Input reduction method selection, specification & execution
%    (3) Export of output (visual and data)
%    (4) Visualization of input, output and intermediate results
%
% As shown below:
%    __________________________________________________
%   |  (1)           |  (2)           |  (3)           |
%   |      DATA      |     METHOD     |    EXPORT      |
%   |     IMPORT     |   SELECTION    |      OF        |
%   |       &        |       &        |    OUTPUT      |
%   |  MANIPULATION  | SPECIFICATION  |                |
%   |________________|________________|________________|
%   |  (4)                                             |
%   |          INPUT AND OUTPUT VISUALIZATION          |
%   |                                                  |   
%   |                                                  |
%   |__________________________________________________|
%
% The function can also be called as follows:
%
%     input_reduction_tool(wave_data);
%     input_reduction_tool(wave_data,variable_names);
% __________
% Example 1:
% 
% H_s    = 2.*(rand(10000,1).^2)+0.2.*(rand(10000,1)+0.5);
% T_p    = 2.*(H_s+3) + 2.*rand(10000,1);
% Dir    = (rand(10000,1)-0.5).*1000.*(1./T_p);
% weight = H_s.^2 .* T_p;
%
% input_reduction_tool([H_s T_p Dir weight],{'H_s','T_p','Dir','weight'});
% __________
% Example 2:
% 
% load([strrep(which('input_reduction_tool'),...
% [filesep 'input_reduction_tool.m'],'') filesep,...
% 'example_wave_input_data' filesep 'example_1_waves.mat']);
% input_reduction_tool(waves_noordwijk,{'H_s','T_p','Dir'});

% TO DO
%
% -  Shore normal for input redution method 'Sediment transport bins' only
%    works for 0 (value in the GUI is ignored, needs fixing).
% -  Create custom exporters (for specific model (setups)).
% -  Add additional input reduction routines
%

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
data.sizes.fig_size    = [1264 644];
screen_size = get(0,'ScreenSize');
if screen_size(3) < data.sizes.fig_size(1)+16 || screen_size (4) < data.sizes.fig_size(2)+40+8+28
    error(['Screen resolution is not sufficient, it''s ' datestr(now,'yyyy') ', try hooking-up a better external screen'])
end

% It is only possible to open 1 instance of the tool, will be changed in the future: 
if ishandle(findobj('Tag','IRT','type','figure'))
    % Run a sub-function call in an existing IRT if this is requested
    if isa(varargin{1},'function_handle')
        feval(varargin{:});
        return
    end
    close(findobj('Tag','IRT','type','figure'));
end
data.handles.fig = figure('MenuBar','none','Name','Input reduction toolbox','NumberTitle','off','Position',[screen_size(3)./2-data.sizes.fig_size(1)./2 min(screen_size(4)-data.sizes.fig_size(2)-28 , 48 + (screen_size(4)-48-28)./2 - data.sizes.fig_size(2)./2) data.sizes.fig_size],'Resize','off','Tag','IRT','ToolBar','none');

% We load all subfolders (if not done yet):
script_loc = mfilename('fullpath'); tmp_dirs = genpath(script_loc(1,1:max(strfind(script_loc,filesep))-1)); tmp_dirs = eval(['{''' strrep(tmp_dirs(1,1:end-1),';',''';''') '''}']);
for ii=1:length(tmp_dirs)
    if exist(tmp_dirs{ii},'dir') ~= 7 
        addpath(tmp_dirs{ii});
    end
end
% The interface has 4 sections:
%
%                         1264 pix.
%         421 pix.         421 pix.        421 pix.
%    __________________________________________________
%   |  (1)           |  (2)           |  (3)           |
%   |      DATA      |     METHOD     |    EXPORT      |
%   |     IMPORT     |   SELECTION    |      OF        |
%   |       &        |       &        |    OUTPUT      |
%   |  MANIPULATION  | SPECIFICATION  |                |
%   |________________|________________|________________|
%   |  (4)                                             |
%   |        INPUT AND OUTPUT VISUALIZATION            |
%   |                             ______    ______     |   
%   |                            |______|  |______|    |
%   |__________________________________________________|
%                                       :  :    :    :
%                                       >--<    >----<
%                             data.sizes.button_spacing (20)    data.sizes.edge_spacing (40)

data.sizes.button_spacing   = 20;
data.sizes.edge_spacing     = 40;
data.sizes.line_spacing     = 20;
data.sizes.xtra_txt_spacing = 10;
data.sizes.txt_height       = 15;

% Visuals section:

plot_ax_size = [400 300];

data.handles.visuals.plot_ax = axes('parent',data.handles.fig,'box','on','Layer','top','units','pixels','Position',[(data.sizes.fig_size(1)./2)-(plot_ax_size(1)./2)+data.sizes.button_spacing data.sizes.edge_spacing plot_ax_size-[data.sizes.edge_spacing data.sizes.edge_spacing]],'fontsize',8,'XGrid','on','YGrid','on','ZGrid','on','nextplot','add');
data.handles.visuals.plot_ax.XLabel.String='--'; data.handles.visuals.plot_ax.YLabel.String='--';

dd_plot_size = [150 30];
data.handles.visuals.plot_dropdown = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[(data.sizes.fig_size(1)./2)-dd_plot_size(1)./2 plot_ax_size(2) dd_plot_size],'String',{'...'},'Value',1);

xtra_space = 5;
data.sizes.table_size = [(data.sizes.fig_size(1)./2 - plot_ax_size(1)./2)-xtra_space plot_ax_size(2)];
data.handles.visuals.table_ori  = uitable(data.handles.fig,'Position',[data.sizes.edge_spacing data.sizes.edge_spacing data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing data.sizes.table_size(2)-data.sizes.edge_spacing]);
data.handles.visuals.table_new  = uitable(data.handles.fig,'Position',[data.sizes.button_spacing+data.sizes.table_size(1)+plot_ax_size(1)+2.*xtra_space data.sizes.edge_spacing data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing data.sizes.table_size(2)-data.sizes.edge_spacing]);

text_box_size = [200 20];
data.handles.visuals.table_ori_title = uicontrol(data.handles.fig,'style','text','String','','Position',[data.sizes.table_size(1)./2-text_box_size(1)./2+(data.sizes.edge_spacing./2 - data.sizes.button_spacing./2) data.sizes.table_size(2) text_box_size],'fontsize',10);
data.handles.visuals.table_new_title = uicontrol(data.handles.fig,'style','text','String','','Position',[data.sizes.button_spacing+data.sizes.table_size(1)+plot_ax_size(1)+data.sizes.table_size(1)./2-text_box_size(1)./2-data.sizes.button_spacing+(data.sizes.button_spacing./2 - data.sizes.edge_spacing./2) data.sizes.table_size(2) text_box_size],'fontsize',10);

% 'lines' to divide sections:
bottom_line_start = [data.sizes.line_spacing data.sizes.table_size(2)+dd_plot_size(2)+data.sizes.line_spacing];
hor_line_size     = [data.sizes.fig_size(1)-data.sizes.line_spacing-data.sizes.line_spacing 1];
uitable(data.handles.fig,'Position',[bottom_line_start hor_line_size]);
vert_line_size    = [data.sizes.fig_size(2)-data.sizes.table_size(2)-dd_plot_size(2)-data.sizes.line_spacing-data.sizes.line_spacing-data.sizes.line_spacing];
X_loc_vert_lines  = [data.sizes.table_size(1)-data.sizes.button_spacing data.sizes.button_spacing+data.sizes.table_size(1)+plot_ax_size(1)];
uitable(data.handles.fig,'Position',[X_loc_vert_lines(1) bottom_line_start(2)+data.sizes.line_spacing 1 vert_line_size]);
uitable(data.handles.fig,'Position',[X_loc_vert_lines(2) bottom_line_start(2)+data.sizes.line_spacing 1 vert_line_size]);

% Loading section:
start_end_x_1             = [data.sizes.edge_spacing X_loc_vert_lines(1)-data.sizes.line_spacing];
start_end_y_1             = [data.sizes.fig_size(2)-data.sizes.edge_spacing bottom_line_start(2)+data.sizes.line_spacing+data.sizes.edge_spacing];
load_data_button_size     = [(diff(start_end_x_1)-data.sizes.button_spacing)./2 25];
start_point               = [data.sizes.edge_spacing data.sizes.fig_size(2)-load_data_button_size(2)-data.sizes.edge_spacing];
data.handles.loading.load_data_button   = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point load_data_button_size],'string','Load data','fontsize',10,'CallBack',@load_data);
data.handles.loading.delete_data_button = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point+[data.sizes.button_spacing+load_data_button_size(1) 0] load_data_button_size],'string','Delete data','fontsize',10,'CallBack',@delete_data,'Enable','off');

start_point = start_point - [0 data.sizes.button_spacing+load_data_button_size(2)];

data.handles.loading.load_weight_button = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point load_data_button_size],'Enable','off','string','Load custom weighting','fontsize',10,'CallBack',@load_weighting);
data.handles.loading.delete_weight_button = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point+[data.sizes.button_spacing+load_data_button_size(1) 0] load_data_button_size],'Enable','off','string','Delete custom weighting','fontsize',10,'CallBack',@delete_weight);

data.data.rem_value = 0.5;
dd_rem_size = [75 20];
dd_ls_size  = [50 20];
start_point = start_point - [0 2.*(data.sizes.button_spacing+load_data_button_size(2))];
data.handles.loading.remove_dropdown    = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[start_point dd_rem_size],'String','--','Value',1);
data.handles.loading.remove_txt         = uicontrol(data.handles.fig,'style','text','Enable','off','fontsize',8,'Position',[start_point+[0 dd_rem_size(2)] dd_rem_size(1) data.sizes.txt_height],'String','Remove:');
data.handles.loading.ls_dropdown        = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[start_point+[dd_rem_size(1)+data.sizes.button_spacing 0] dd_ls_size],'String',{'<','>'},'Value',1);
data.handles.loading.rem_val            = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point+[dd_rem_size(1)+2.*data.sizes.button_spacing+dd_ls_size(1) -1] dd_rem_size],'String',num2str(data.data.rem_value),'callback',@edit_remove_value);

data.handles.loading.remove_data_button = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point+[2.*dd_rem_size(1)+3.*data.sizes.button_spacing+dd_ls_size(1) -3] diff(start_end_x_1) - (2.*dd_rem_size(1)+3.*data.sizes.button_spacing+dd_ls_size(1)) 25],'string','Remove data','fontsize',10,'CallBack',@remove_data,'Enable','off');

start_point = start_point - [0 2.*(data.sizes.button_spacing+dd_rem_size(2))];
raw_data_button_size = [150 25];
data.handles.loading.export_raw_data_button = uicontrol(data.handles.fig,'style','pushbutton','Enable','off','position',[start_point(1)+(diff(start_end_x_1)-raw_data_button_size(1))./2 start_point(2) raw_data_button_size],'string','Export raw data','fontsize',10,'CallBack',@export_raw_data);

% TO DO:
%
% Specify whether w.r.t. CL or nautical/cartesian
%

% Method section:

start_end_x_2            = [X_loc_vert_lines(1)+data.sizes.line_spacing X_loc_vert_lines(2)-data.sizes.line_spacing];
start_end_y_2            = [data.sizes.fig_size(2)-data.sizes.edge_spacing bottom_line_start(2)+data.sizes.edge_spacing];
data.data.method_names = {'Fixed bins method';'Maximum dissimilarity method';'Energy flux method';'Crisp K-means method';'Fuzzy K-means method';'Harmonic K-means method';'Sediment Transport Bins'};
dd_method_size         = [(diff(start_end_x_2)-data.sizes.button_spacing)./2 22];
start_point            = [start_end_x_2(1) start_end_y_2(1)-dd_method_size(2)];
data.handles.method.method_dropdown = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[start_point dd_method_size],'String',data.data.method_names,'Value',1,'callback',@selected_method);
data.handles.method.method_dropdown_txt = uicontrol(data.handles.fig,'style','text','Enable','off','fontsize',8,'Position',[start_point+[0 dd_method_size(2)] dd_method_size(1) data.sizes.txt_height],'String','Input reduction method:');
% Ini:
dd_ini_size            = [dd_method_size];
data.data.ini_names    = {'K-means++ (random)';'Fixed bins method';'Maximum dissimilarity method'};
data.handles.method.initial_dropdown = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[start_point(1)+data.sizes.button_spacing+dd_method_size(1) start_point(2) dd_ini_size],'String',data.data.ini_names,'Value',1,'Callback',@selected_method);
data.handles.method.initial_dropdown_txt = uicontrol(data.handles.fig,'style','text','Enable','off','fontsize',8,'Position',[start_point(1)+data.sizes.button_spacing+dd_method_size(1) start_point(2)+dd_method_size(2) dd_method_size(1) data.sizes.txt_height],'String','Initialization method:');

% Number of bins:
dd_bin_no_size = [round((diff(start_end_x_2)-(2.*data.sizes.button_spacing))./3) 20];
start_point    = start_point - [0 data.sizes.button_spacing+dd_bin_no_size(2)+data.sizes.xtra_txt_spacing];
start_point_1  = start_point;
start_point_2  = start_point_1 + [dd_bin_no_size(1)+data.sizes.button_spacing 0];
start_point_3  = start_point_2 + [dd_bin_no_size(1)+data.sizes.button_spacing 0];
data.data.bin_values.tot = 12;
data.data.bin_values.H_s = 3;
data.data.bin_values.dir = 4;
data.handles.method.num_bins_dir = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point_1 dd_bin_no_size],'String',num2str(data.data.bin_values.dir),'callback',@edit_bin_value,'tag','dir','TooltipString','Number of directional bins/classes');
data.handles.method.num_bins_H_s = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point_2 dd_bin_no_size],'String',num2str(data.data.bin_values.H_s),'callback',@edit_bin_value,'tag','H_s','TooltipString','Number of wave bins/classes');
data.handles.method.num_bins_tot = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point_3 dd_bin_no_size],'String',num2str(data.data.bin_values.tot),'callback',@edit_bin_value,'tag','tot','TooltipString','Total number of bins/classes');
data.handles.method.num_bins_dir_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','No. dir. bins:','Position',[start_point_1+[0 20] dd_bin_no_size(1) data.sizes.txt_height],'TooltipString','Number of directional bins/classes');
data.handles.method.num_bins_H_s_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','No. H_s bins:','Position',[start_point_2+[0 20] dd_bin_no_size(1) data.sizes.txt_height],'TooltipString','Number of wave bins/classes');
data.handles.method.num_bins_tot_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','Total no. clusters:','Position',[start_point_3+[0 20] dd_bin_no_size(1) data.sizes.txt_height],'TooltipString','Total number of bins/classes');

equi_bins_checkbox_size = [dd_method_size(1)-50 data.sizes.txt_height];
start_point = start_point + [0 -data.sizes.button_spacing-equi_bins_checkbox_size(2)+data.sizes.txt_height]; % +15 to make it tight
data.handles.method.equi_bins = uicontrol(data.handles.fig,'style','checkbox','Enable','off','Position',[start_point equi_bins_checkbox_size],'String','Equidistant bins','Value',0);

% Weighting:
dd_weight_size         = [dd_method_size];
start_point = start_point + [0 -data.sizes.button_spacing-dd_weight_size(2)-data.sizes.xtra_txt_spacing];
data.handles.method.weighting_dropdown = uicontrol(data.handles.fig,'style','popupmenu','Enable','off','fontsize',8,'Position',[start_point dd_weight_size],'Value',1,'String','--','callback',@set_weight_method);
data.handles.method.weighting_dropdown_txt = uicontrol(data.handles.fig,'style','text','Enable','off','fontsize',8,'Position',[start_point+[0 dd_weight_size(2)] dd_weight_size(1) data.sizes.txt_height],'String','Weighting method:');

data.data.var_m = 1; %2
data.data.var_o = 2.1;

m_o_size = [(dd_weight_size(1)-data.sizes.button_spacing)./2 20];
data.handles.method.var_m     = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point+[dd_weight_size(1)+data.sizes.button_spacing 0] m_o_size],'String',num2str(data.data.var_m),'callback',@edit_m_o_value,'tag','var_m','TooltipString','Power m: used for non-linear averaging and optionally as a weighting method');
data.handles.method.var_o     = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point+[dd_weight_size(1)+2.*data.sizes.button_spacing+m_o_size(1) 0] m_o_size],'String',num2str(data.data.var_o),'callback',@edit_m_o_value,'tag','var_o','TooltipString','Power o: used for inverse distance and dynamic weighting');
data.handles.method.var_m_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','Power m:','Position',[start_point+[dd_weight_size(1)+data.sizes.button_spacing +m_o_size(2)] m_o_size(1) data.sizes.txt_height],'TooltipString','Power m: used for non-linear averaging and optionally as a weighting method');
data.handles.method.var_o_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','Power o:','Position',[start_point+[dd_weight_size(1)+2.*data.sizes.button_spacing+m_o_size(1) +m_o_size(2)] m_o_size(1) data.sizes.txt_height],'TooltipString','Power o: used for inverse distance and dynamic weighting');

data.data.max_iter  = 100;
data.data.max_delta = 10^-5;
data.data.SN_angle = 0;

iter_box_size = [m_o_size];
start_point = start_point + [0 -data.sizes.button_spacing-iter_box_size(2)-data.sizes.xtra_txt_spacing];
data.handles.method.max_iter      = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point iter_box_size],'String',num2str(data.data.max_iter),'callback',@edit_iter_value,'tag','max_iter','TooltipString','Maximum number of iternations');
data.handles.method.max_delta     = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point+[m_o_size(1)+data.sizes.button_spacing 0] iter_box_size],'String',num2str(data.data.max_delta),'callback',@edit_delta_value,'tag','max_delta','TooltipString','Normalized iteration change, method stops when delta is smaller');
data.handles.method.max_iter_txt  = uicontrol(data.handles.fig,'style','text','Enable','off','String','Max. iterations:','Position',[start_point+[0 m_o_size(2)] iter_box_size(1) data.sizes.txt_height],'TooltipString','Maximum number of iternations');
data.handles.method.max_delta_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','Max. delta:','Position',[start_point+m_o_size+[data.sizes.button_spacing 0] iter_box_size(1) data.sizes.txt_height],'TooltipString','Normalized iteration change, method stops when delta is smaller');

data.handles.method.SN_angle     = uicontrol(data.handles.fig,'style','edit','Enable','off','fontsize',8,'Position',[start_point+([m_o_size(1)+data.sizes.button_spacing 0].*2) iter_box_size],'String',num2str(data.data.SN_angle),'callback',@edit_SN_angle_value,'tag','SN_angle','TooltipString','Shore-normal angle (nautical)');
data.handles.method.SN_angle_txt = uicontrol(data.handles.fig,'style','text','Enable','off','String','Shore-normal:','Position',[start_point(1)+((m_o_size(1)+data.sizes.button_spacing).*2) start_point(2)+m_o_size(2) iter_box_size(1) data.sizes.txt_height],'TooltipString','Shore-normal angle (nautical)');


run_method_button_size     = [150 25];
data.handles.method.run_method_button = uicontrol(data.handles.fig,'style','pushbutton','Enable','off','position',[start_end_x_2(1)+run_method_button_size(1)-data.sizes.button_spacing start_end_y_2(2)-m_o_size(2) run_method_button_size],'string','Run method','fontsize',10,'CallBack',@run_method);
% data.handles.method.run_method_button = uicontrol(data.handles.fig,'style','pushbutton','Enable','off','position',[start_end_x_2(2)-run_method_button_size(1) start_end_y_2(2) run_method_button_size],'string','Run method','fontsize',10,'CallBack',@run_method);

% Export section:

start_end_x_3            = [X_loc_vert_lines(2)+data.sizes.line_spacing data.sizes.fig_size(1)-data.sizes.line_spacing];
start_end_y_3            = [start_end_y_2];
export_button_size       = [(diff(start_end_x_3)-data.sizes.button_spacing)./2 25];
start_point              = [start_end_x_3(1) start_end_y_3(1)-export_button_size(2)];
data.handles.export.export_data_button = uicontrol(data.handles.fig,'style','pushbutton','position',[start_point export_button_size],'string','Export reduced data','fontsize',10,'CallBack',@export_data,'Enable','off');

data.handles.export.export_figure_button = uicontrol(data.handles.fig,'style','pushbutton','Position',[start_point(1)+data.sizes.button_spacing+export_button_size(1) start_point(2) export_button_size],'String','Export figure','fontsize',10,'CallBack',@export_figures,'Enable','off');


% Steps:
step_txt_size = [300 20];
data.handles.steps_txt.step_1_txt = uicontrol(data.handles.fig,'style','text','Enable','on','fontsize',8,'FontWeight','bold','Position',[mean(start_end_x_1)-step_txt_size(1)./2 start_end_y_1(1)+data.sizes.edge_spacing-step_txt_size(2) step_txt_size],'String','STEP 1 - LOADING DATA');
data.handles.steps_txt.step_2_txt = uicontrol(data.handles.fig,'style','text','Enable','on','fontsize',8,'FontWeight','bold','Position',[mean(start_end_x_2)-step_txt_size(1)./2 start_end_y_2(1)+data.sizes.edge_spacing-step_txt_size(2) step_txt_size],'String','STEP 2 - INPUT REDUCTION METHOD');
data.handles.steps_txt.step_3_txt = uicontrol(data.handles.fig,'style','text','Enable','on','fontsize',8,'FontWeight','bold','Position',[mean(start_end_x_3)-step_txt_size(1)./2 start_end_y_3(1)+data.sizes.edge_spacing-step_txt_size(2) step_txt_size],'String','STEP 3 - EXPORTING DATA');
data.handles.steps_txt.visual_txt = uicontrol(data.handles.fig,'style','text','Enable','on','fontsize',8,'FontWeight','bold','Position',[(data.sizes.fig_size(1)/2)-step_txt_size(1)./2 bottom_line_start(2)-step_txt_size(2) step_txt_size],'String','VISUALIZATION');

guidata(data.handles.fig,data);

if ~isempty(varargin)
    load_data(1,1,varargin);
end

end

%% STEP 1 - Loading section:

function load_data(hObject,eventdata,varargin)

data = guidata(findobj('Tag','IRT','type','figure'));

if isempty(varargin)
    
    FileTypes = {'ASCII-data (*.txt, *.dat, *.csv, etc.)','Matlab data file (*.mat)'};

    FileType = questdlg('What type of file would you like to load?','Type of file?',FileTypes{1},FileTypes{2},FileTypes{1});
    switch FileType
        case FileTypes{1}
            datatype = 1;
        case FileTypes{2}
            datatype = 2;
        otherwise
            return
    end
    
    if datatype == 1
        [data.handles.visuals.table_ori.Data data.data.var_names] = load_ascii_data;
    else
        % Select a *.mat file
        [filename, pathname] = uigetfile({'*.mat','MAT-files (*.mat)'},'Pick a *.mat file','MultiSelect', 'off');
        if ~ischar(filename)
            return
        else
            loaded_data = load([pathname,filename]);
            % OK, let's see if the format is something we expect:
            num_count = []; cellstr_count = [];
            fns = fieldnames(loaded_data)';
            if length(fns) == 1 && isstruct(loaded_data.(fns{1}))
                loaded_data = loaded_data.(fns{1});
                fns = fieldnames(loaded_data)';
            end
            for ii=1:length(fns)
                if isnumeric(loaded_data.(fns{ii}))
                    num_count = [num_count ii];
                elseif iscellstr(loaded_data.(fns{ii}))
                    cellstr_count = [cellstr_count ii];
                end
            end
            % Check the data:
            try
                tmp_wave_data = {};
                if length(num_count) == 1
                    tmp_wave_data = loaded_data.(fns{num_count});
                elseif length(num_count) > 1
                    for ii=1:length(num_count)
                        tmp_wave_data{1,ii} = loaded_data.(fns{num_count(ii)})(:);
                    end
                    tmp_wave_data = cell2mat(tmp_wave_data);
                else
                    uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
                    return
                end
            catch
                uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
                return
            end
            
            tmp_names_data = [];
            if size(tmp_wave_data,2) == 3
                tmp_names_data = {'H_s','T_p','Dir'};
            elseif size(tmp_wave_data,2) == 4
                tmp_names_data = {'H_s','T_p','Dir','weight'};
            elseif size(tmp_wave_data,1) == 3
                tmp_wave_data = tmp_wave_data';
                tmp_names_data = {'H_s','T_p','Dir'};
            elseif size(tmp_wave_data,1) == 4
                tmp_wave_data = tmp_wave_data';
                tmp_names_data = {'H_s','T_p','Dir','weight'};
            end
            
            if length(cellstr_count) == 1
                tmp_names_data = loaded_data.(fns{cellstr_count});
                if length(tmp_names_data) == size(tmp_wave_data,2)
                    % Good!
                elseif length(tmp_names_data) ~= size(tmp_wave_data,2)
                    % Flip it:
                    tmp_wave_data = tmp_wave_data';
                else
                    uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
                    return
                end 
            end
            if isempty(tmp_names_data)
                uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
                return
            end
            
            data.handles.visuals.table_ori.Data = tmp_wave_data;
            data.data.var_names                 = tmp_names_data;
            
        end
    end
    
    if isempty(data.handles.visuals.table_ori.Data) && isempty(data.data.var_names)
%         load('wave_data\waves_model_noordwijk.mat');
%         data.data.var_names    = {'Hs','Tp','Dir'}; %{'H_s ','T_p (s)','dir (°)'};
%         data.data.vars_to_plot = {'Dir','Hs','Tp'}; %{'dir (°)','H_s (m)','T_p (s)'}; % Dir (x), H_s (y) & T (z)
%         data.data.var_names_label={'Dir [°]','H_s [m]','T_p [s]'};
%         data.handles.visuals.table_ori.Data = waves_noordwijk;
        return;
    else
        if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'dir'))==0))
            uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
            return
        else
            var_dir = data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'dir'))==0)};
        end
        if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'hs'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'h_s'))==0))
            uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
            return
        else
            var_Hs = [data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'hs'))==0)} data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'h_s'))==0)}];
        end
        if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'tp'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'t_p'))==0))
            uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
            return
        else
            var_Tp = [data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'tp'))==0)} data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'t_p'))==0)}];
        end
        data.data.vars_to_plot = {var_dir,var_Hs,var_Tp};
    end
else
    if isnumeric(varargin{1}{1})
        data.handles.visuals.table_ori.Data = varargin{1}{1};
    elseif ischar(varargin{1}{1})
        if exist(varargin{1}{1},'file') == 2
            uiwait(warndlg({['Try loading the following file by clicking the ''Load data'' button instead:'];' ';[varargin{1}{1}]}, 'Warning'))
            return
        else
            uiwait(warndlg({['Unknown variable input:'];' ';[varargin{1}{1}]}, 'Warning'))
            return
        end
    else
        uiwait(warndlg('Unknown variable input', 'Warning'))
        return
    end
    if length(varargin{1}) == 1
        if size(data.handles.visuals.table_ori.Data,2) == 4
            data.data.var_names = {'H_s','T_p','Dir','weight'};
        elseif size(data.handles.visuals.table_ori.Data,2) == 3
            data.data.var_names = {'H_s','T_p','Dir'};
        else
            uiwait(warndlg('Unknown input without variable names', 'Warning'))
            return
        end
    else
        data.data.var_names = varargin{1}{2}(:)';
    end
    if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'dir'))==0))
        uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
        return
    else
        var_dir = data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'dir'))==0)};
    end
    if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'hs'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'h_s'))==0))
        uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
        return
    else
        var_Hs = [data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'hs'))==0)} data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'h_s'))==0)}];
    end
    if isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'tp'))==0)) && isempty(find(cellfun(@isempty,strfind(lower(data.data.var_names),'t_p'))==0))
        uiwait(warndlg('Include at least the variables ''Hs'', ''Tp'' and ''Dir''', 'Warning'))
        return
     else
        var_Tp = [data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'tp'))==0)} data.data.var_names{find(cellfun(@isempty,strfind(lower(data.data.var_names),'t_p'))==0)}];
    end
    data.data.vars_to_plot = {var_dir,var_Hs,var_Tp};
end

for ii=1:length(data.data.vars_to_plot)
    if max(strcmp(data.data.var_names,data.data.vars_to_plot{ii})) == 0
        warndlg(['Variable ' data.data.vars_to_plot{ii} ' not found'],'Warning');
        data.handles.visuals.table_ori.Data = [];
        return
    end
end


for jj=1:length(data.data.vars_to_plot)
    if jj==1
        data.data.var_names_label{jj}=strcat(data.data.vars_to_plot{jj},' [°]');
    elseif jj==2
        data.data.var_names_label{jj}=strcat(data.data.vars_to_plot{jj},' [m]');
    elseif jj==3
        data.data.var_names_label{jj}=strcat(data.data.vars_to_plot{jj},' [s]');
    end
end

data.data.weight_names = {data.data.vars_to_plot{2};[data.data.vars_to_plot{2} '^m'];['Wave energy E (1/8*c_g*' data.data.vars_to_plot{2} '^2*g*Rho)']};

table_text_width = data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing-(52+11*max(0,(ceil(log10(1+size(data.handles.visuals.table_ori.Data,1)))-2)));
if size(data.handles.visuals.table_ori.Data,2) == 3
    set(data.handles.visuals.table_ori,'ColumnEditable',logical([0 0 0]),'ColumnWidth',repmat({floor(table_text_width./size(data.handles.visuals.table_ori.Data,2))},1,size(data.handles.visuals.table_ori.Data,2)),'ColumnName',data.data.var_names,'FontSize',9);
elseif size(data.handles.visuals.table_ori.Data,2) == 4
    set(data.handles.visuals.table_ori,'ColumnEditable',logical([0 0 0 0]),'ColumnWidth',repmat({floor(table_text_width./size(data.handles.visuals.table_ori.Data,2))},1,size(data.handles.visuals.table_ori.Data,2)),'ColumnName',data.data.var_names,'FontSize',9);
    data.data.stored_raw_data.weight = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight')));
    data.handles.loading.delete_weight_button.Enable = 'on';
    if ~isempty(find(strcmp(data.data.var_names,'weight')))
        if sum(strcmp(data.data.weight_names,'Custom weighting'))==0
            data.data.weight_names = [data.data.weight_names; 'Custom weighting'];
            set(data.handles.method.weighting_dropdown,'String',data.data.weight_names);
        end
    else
        disp(['You''ve added a variable called "' data.data.var_names{4} '", if you want to use this variable as custom weighting, simply call it ''weight'' instead']);
    end
else
    error('Wrong number of columns loaded, should be 3 or 4! (Hs, Tp and Dir, latter option (4) incl. weight)')
end

data.data.stored_raw_data.H_s = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,data.data.vars_to_plot{2})));
data.data.stored_raw_data.T_p = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,data.data.vars_to_plot{3})));
data.data.stored_raw_data.dir = data.handles.visuals.table_ori.Data(:,strcmp(data.data.var_names,data.data.vars_to_plot{1}));

if ~isempty(find(strcmp(data.data.var_names,'weight')))
    if sum(strcmp(data.data.weight_names,'Custom weighting'))==0
        data.data.weight_names = [data.data.weight_names; 'Custom weighting'];
        set(data.handles.method.weighting_dropdown,'String',data.data.weight_names);
    end
    data.data.stored_raw_data.weight = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight')));
    data.handles.loading.delete_weight_button.Enable = 'on';
end

guidata(findobj('Tag','IRT','type','figure'),data);

plot_new_raw_data;

data.handles.method.num_bins_dir_txt.String        = ['No. ' data.data.vars_to_plot{1} ' bins:'];
data.handles.method.num_bins_H_s_txt.String        = ['No. ' data.data.vars_to_plot{2} ' bins:'];

data.handles.method.method_dropdown.Enable         = 'on';
data.handles.visuals.table_ori_title.String        = 'Raw data';
data.handles.loading.delete_data_button.Enable     = 'on';
data.handles.loading.load_data_button.Enable       = 'off';
data.handles.loading.load_weight_button.Enable     = 'on';
data.handles.method.weighting_dropdown.String      = data.data.weight_names;

data.handles.loading.remove_dropdown.Enable        = 'on';
data.handles.loading.remove_dropdown.String        = data.data.vars_to_plot([2 3 1]);
data.handles.loading.remove_txt.Enable             = 'on';
data.handles.loading.ls_dropdown.Enable            = 'on';
data.handles.loading.rem_val.Enable                = 'on';
data.handles.loading.remove_data_button.Enable     = 'on';
data.handles.loading.export_raw_data_button.Enable = 'on';

selected_method;

end

function load_weighting(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

% load('wave_data\y_sed_transp_model_noordwijk.mat');
% load('wave_data\y_sed_transp_model_anmok.mat');

FileTypes = {'ASCII-data (*.txt, *.dat, *.csv, etc.)','Matlab data file (*.mat)'};

FileType = questdlg('What type of file would you like to load?','Type of file?',FileTypes{1},FileTypes{2},FileTypes{1});
switch FileType
    case FileTypes{1}
        datatype = 1;
    case FileTypes{2}
        datatype = 2;
    otherwise
        return
end

if datatype == 1
    [fname,path] = uigetfile({'*.txt;*.dat;*.csv','ASCII file (*.txt, *.dat, *.csv)'},'Select an ASCII file');
    try
        y_sed_transp=load([path fname]);
        fclose('all');
        if min(size(y_sed_transp)) == 1
            y_sed_transp=y_sed_transp(:);
        else
            uiwait(warndlg('You''ve provided a matrix in an ASCII file, this should be a single vector!','Warning'));
            return
        end
    catch err
        uiwait(warndlg(err.message,'Warning'));
        disp('The format of your provided ASCII file seems inconsistent, aborting');
        return
    end
elseif datatype == 2
    % Select a *.mat file
    [filename, pathname] = uigetfile({'*.mat','MAT-files (*.mat)'},'Pick a *.mat file','MultiSelect', 'off');
    if ~ischar(filename)
        return
    else
        loaded_data = load([pathname,filename]);
        % OK, let's see if the format is something we expect:
        num_count = [];
        fns = fieldnames(loaded_data)';
        if length(fns) == 1 && isstruct(loaded_data.(fns{1}))
            loaded_data = loaded_data.(fns{1});
            fns = fieldnames(loaded_data)';
        end
        for ii=1:length(fns)
            if isnumeric(loaded_data.(fns{ii}))
                num_count = [num_count ii];
            end
        end
        % Check the data:
        try
            if length(num_count) == 1
                y_sed_transp = loaded_data.(fns{num_count});
            elseif length(num_count) == 0
                uiwait(warndlg('No numeric data found within the mat file', 'Warning'));
                return
            else
                uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
                return
            end
        catch
            uiwait(warndlg('Contents of the *.mat file were not handled successfully', 'Warning'));
            return
        end
        if min(size(y_sed_transp)) == 1
            y_sed_transp=y_sed_transp(:);
        else
            uiwait(warndlg('You''ve provided a matrix in a *.mat file, this should be a single vector!','Warning'));
            return
        end
    end
end

if isempty(find(strcmp(data.data.var_names,'weight')))
    data.data.var_names = [data.data.var_names,'weight'];
end

if size(y_sed_transp,1)==size(data.handles.visuals.table_ori.Data,1)
    data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight'))) = y_sed_transp;
else
    warndlg({'Weighting data does not seem to fit the original data';' ';['The length of the provided weighting is ' num2str(size(y_sed_transp,1)) ', while that of the original data is ' length(size(data.handles.visuals.table_ori.Data,1))]},'Warning');
    return
end

table_text_width = data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing-(52+11*max(0,(ceil(log10(1+size(data.handles.visuals.table_ori.Data,1)))-2)));
set(data.handles.visuals.table_ori,'ColumnEditable',logical([0 0 0 0]),'ColumnWidth',repmat({floor(table_text_width./size(data.handles.visuals.table_ori.Data,2))},1,size(data.handles.visuals.table_ori.Data,2)),'ColumnName',data.data.var_names,'FontSize',9);

data.data.stored_raw_data.weight = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight')));

if sum(strcmp(data.data.weight_names,'Custom weighting'))==0
    data.data.weight_names = [data.data.weight_names; 'Custom weighting'];
    set(data.handles.method.weighting_dropdown,'String',data.data.weight_names);
end

data.handles.loading.delete_weight_button.Enable = 'on';

guidata(findobj('Tag','IRT','type','figure'),data);

end

function delete_data(hObject,eventdata)

% TO DO:
%
% - Allow for other variable to be associated as well

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.table_ori.Data     = [];
data.handles.visuals.table_new.UserData = [];

clear_plot;
clear_output;

data.handles.loading.delete_data_button.Enable     = 'off';
data.handles.loading.load_data_button.Enable       = 'on';
data.handles.loading.load_weight_button.Enable     = 'off';
data.handles.loading.delete_weight_button.Enable   = 'off';
data.handles.export.export_data_button.Enable      = 'off';

data.handles.loading.remove_dropdown.Enable        = 'off';
data.handles.loading.remove_txt.Enable             = 'off';
data.handles.loading.ls_dropdown.Enable            = 'off';
data.handles.loading.rem_val.Enable                = 'off';
data.handles.loading.remove_data_button.Enable     = 'off';
data.handles.loading.export_raw_data_button.Enable = 'off';

data.handles.visuals.table_ori_title.String    = '';
set(data.handles.visuals.table_ori,'ColumnName','');
set(data.handles.visuals.plot_dropdown,'Enable','off','String',{'...'},'Value',1);

data.data.weight_names = data.data.weight_names(find(strcmp(data.data.weight_names,'Custom weighting')==0));
set(data.handles.method.weighting_dropdown,'String',data.data.weight_names,'Value',1);

for h = fieldnames(data.handles.method)'
    set(data.handles.method.(h{:}),'enable','off');
end

data.data.stored_raw_data.H_s = [];
data.data.stored_raw_data.T_p = [];
data.data.stored_raw_data.dir = [];

axes(data.handles.visuals.plot_ax);
view(0,90);
xlabel('--'); ylabel('--');

guidata(findobj('Tag','IRT','type','figure'),data);

end

function remove_data(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

if isempty(str2num(data.handles.loading.rem_val.String))
    return
end

ind = find(strcmp(data.handles.loading.remove_dropdown.String{data.handles.loading.remove_dropdown.Value},data.data.var_names));

eval(['inds_to_rem = find(~[data.handles.visuals.table_ori.Data(:,ind)' data.handles.loading.ls_dropdown.String{data.handles.loading.ls_dropdown.Value} data.handles.loading.rem_val.String ']);']);

data.handles.visuals.table_ori.Data = data.handles.visuals.table_ori.Data(inds_to_rem,:);
guidata(findobj('Tag','IRT','type','figure'),data);

plot_new_raw_data;
data = guidata(findobj('Tag','IRT','type','figure'));

data.data.stored_raw_data.H_s = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,data.data.vars_to_plot{2})));
data.data.stored_raw_data.T_p = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,data.data.vars_to_plot{3})));
data.data.stored_raw_data.dir = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,data.data.vars_to_plot{1})));

if isfield(data.data.stored_raw_data,'weight') && ~isempty(data.data.stored_raw_data.weight)
    data.data.stored_raw_data.weight = data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight')));
end

guidata(findobj('Tag','IRT','type','figure'),data);

% Everything was removed with some loop-hole
if isempty(data.handles.visuals.table_ori.Data)
    delete_data(1,1);
end

end

function delete_weight(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.table_ori.Data(:,find(strcmp(data.data.var_names,'weight'))) = [];
data.data.var_names = data.data.var_names(find(strcmp(data.data.var_names,'weight')==0));

table_text_width = data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing-(52+11*max(0,(ceil(log10(1+size(data.handles.visuals.table_ori.Data,1)))-2)));
set(data.handles.visuals.table_ori,'ColumnEditable',logical([0 0 0]),'ColumnWidth',repmat({floor(table_text_width./size(data.handles.visuals.table_ori.Data,2))},1,size(data.handles.visuals.table_ori.Data,2)),'ColumnName',data.data.var_names,'FontSize',9);

data.data.stored_raw_data.weight = [];

data.data.weight_names = data.data.weight_names(find(strcmp(data.data.weight_names,'Custom weighting')==0));
set(data.handles.method.weighting_dropdown,'String',data.data.weight_names,'Value',min(size(data.data.weight_names,1),data.handles.method.weighting_dropdown.Value));

data.handles.loading.delete_weight_button.Enable = 'off';

guidata(findobj('Tag','IRT','type','figure'),data);

end

function export_raw_data(hObject,eventdata)

[filename, pathname] = uiputfile({'*.mat'},'Save raw data as...');

if ischar(filename)
    
    data = guidata(findobj('Tag','IRT','type','figure'));
    
    raw_data  = data.handles.visuals.table_ori.Data;
    var_names = data.data.var_names;
    
    save([pathname filename],'raw_data','var_names','-v7.3');
    
else
    return
end

end

%% STEP 2 - Method section:

function selected_method(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

% Turn everything off:
for h = fieldnames(data.handles.method)'
    set(data.handles.method.(h{:}),'enable','off');
end

data.handles.method.method_dropdown.Enable            = 'on';
data.handles.method.method_dropdown_txt.Enable        = 'on';
if ~isempty(data.handles.visuals.table_ori.Data)
    data.handles.method.run_method_button.Enable      = 'on';
end

ori_str = cellstr(data.handles.method.weighting_dropdown.String);
set(data.handles.method.weighting_dropdown,'enable','off','Value',find(strcmp(data.data.weight_names,ori_str{data.handles.method.weighting_dropdown.Value})),'String',data.data.weight_names);

% Now set everything per tool:
if strcmp(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'Fixed bins method')
    data.handles.method.num_bins_dir.Enable           = 'on';
    data.handles.method.num_bins_dir_txt.Enable       = 'on';
    data.handles.method.num_bins_H_s.Enable           = 'on';
    data.handles.method.num_bins_H_s_txt.Enable       = 'on';
    data.handles.method.equi_bins.Enable              = 'on';
    data.handles.method.weighting_dropdown.Enable     = 'on';
    data.handles.method.weighting_dropdown_txt.Enable = 'on';
    if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
        data.handles.method.var_m.Enable                  = 'on';
        data.handles.method.var_m_txt.Enable              = 'on';
    end
elseif ~isempty(strfind(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'K-means method'))
    data.handles.method.weighting_dropdown.Enable     = 'on';
    data.handles.method.weighting_dropdown_txt.Enable = 'on';
    data.handles.method.initial_dropdown.Enable       = 'on';
    data.handles.method.initial_dropdown_txt.Enable   = 'on';
    set_initial_method;
    data.handles.method.max_delta.Enable              = 'on';
    data.handles.method.max_delta_txt.Enable          = 'on';
    data.handles.method.max_iter.Enable               = 'on';
    data.handles.method.max_iter_txt.Enable           = 'on';
    if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
        data.handles.method.var_m.Enable                  = 'on';
        data.handles.method.var_m_txt.Enable              = 'on';
    end
    if isempty(strfind(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'Crisp'))
        data.handles.method.var_o.Enable                  = 'on';
        data.handles.method.var_o_txt.Enable              = 'on';
    end
elseif strcmp(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'Energy flux method')
    set(data.handles.method.weighting_dropdown,'enable','on','Value',1,'String',data.data.weight_names{find(cellfun(@isempty,strfind(data.data.weight_names,'Wave energy'))==0)});
    data.handles.method.weighting_dropdown_txt.Enable = 'on';
    data.handles.method.num_bins_dir.Enable           = 'on';
    data.handles.method.num_bins_dir_txt.Enable       = 'on';
    data.handles.method.num_bins_H_s.Enable           = 'on';
    data.handles.method.num_bins_H_s_txt.Enable       = 'on';
elseif strcmp(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'Maximum dissimilarity method')
    data.handles.method.num_bins_tot.Enable           = 'on';
    data.handles.method.num_bins_tot_txt.Enable       = 'on';
elseif strcmp(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'Sediment Transport Bins')
    data.handles.method.num_bins_dir.Enable           = 'on';
    data.handles.method.num_bins_dir_txt.Enable       = 'on';
    data.handles.method.num_bins_H_s.Enable           = 'on';
    data.handles.method.num_bins_H_s_txt.Enable       = 'on';
    data.handles.method.SN_angle.Enable           = 'on';
    data.handles.method.SN_angle_txt.Enable       = 'on';
end

end

function set_initial_method(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

    if strcmp('K-means++ (random)',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value}) || strcmp('Maximum dissimilarity method',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value})
        data.handles.method.num_bins_tot.Enable           = 'on';
        data.handles.method.num_bins_tot_txt.Enable       = 'on';
    elseif strcmp('Fixed bins method',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value})
        data.handles.method.num_bins_dir.Enable           = 'on';
        data.handles.method.num_bins_dir_txt.Enable       = 'on';
        data.handles.method.num_bins_H_s.Enable           = 'on';
        data.handles.method.num_bins_H_s_txt.Enable       = 'on';
    end

end

function run_method(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));
set(data.handles.method.run_method_button,'String','Running...','BackgroundColor','r','Enable','off'); drawnow;

if min(data.data.stored_raw_data.dir) < 0
    info_dir = 0;
else
    info_dir = 1;
end

% TO DO
%
% Implement method 1 and 2
% Implement a 3-dimensional fixed binning method
 
if strcmp('Fixed bins method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})

    ndir = data.data.bin_values.dir;
    nhs  = data.data.bin_values.H_s;

    equi = data.handles.method.equi_bins.Value;
    
    m = data.data.var_m; 
    
    input_data   = [data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir ones(length(data.data.stored_raw_data.H_s),1)];
    
    if ~strcmp(data.data.vars_to_plot{2},data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
        if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir data.data.stored_raw_data.H_s.^m];
        elseif strcmp(['Wave energy E (1/8*c_g*' data.data.vars_to_plot{2} '^2*g*Rho)'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir data.data.stored_raw_data.H_s.^2.*9.81.*1000.*(1/8).*(1/2).*(9.81/(2*pi)).*data.data.stored_raw_data.T_p];
        elseif strcmp('Custom weighting',data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir abs(data.data.stored_raw_data.weight)];
        end
        
        [inds_f,v,bin_limits] = fixed_bins(input_data_w,ndir,nhs,equi,info_dir);

        % This is all no longer needed:
        
%         if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
%             % Inverse function power:
%             v(:,1) = v(:,1).^(1./m);
%             bin_limits(:,1:2)=bin_limits(:,1:2).^(1./m);
%         elseif strcmp(['Wave energy E (1/8*c_g*' data.data.vars_to_plot{2} '^2*g*Rho)'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
%             % Inverse function wave energy:
%             v(:,1)        = (v(:,1)./v(:,2)./(9.81.*1000.*(1/8).*(1/2).*(9.81/(2*pi)))).^(1/2);
%             bin_limits=[];
%         elseif strcmp('Custom weighting',data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
%             % no inverse function available, get the nearest point:
%             for ii=1:max(inds_f)
%                 input_data_bin=input_data(inds_f==ii,1);   
%                 [value,ind]=findnearest(input_data_w(inds_f==ii,1),v(ii,1));
%                 v(ii,1)=input_data_bin(ind,1);  
%             end
%             %                 % No inverse function available, use mean of the indices:
%             %         for ii = 1:max(inds_f)
%             %             v(ii,1) = mean(input_data((find(inds_f == ii)),1));
%             %         end
%             bin_limits=[];
%         end
    
    else
        [inds_f,v,bin_limits] = fixed_bins(input_data,ndir,nhs,equi,info_dir);
    end
    
    [v,ind_sort] = sortrows(v,4); v = flipud(v); ind_sort = flipud(ind_sort);
    tabs=array2table(v,'VariableNames',{'Hs','Tp','Dir','P'});
    data.data.output.v=tabs;
    data.data.output.bin_limits(ind_sort,1) = [1:size(bin_limits,1)]';
    data.data.output.bin_limits(:,2:5)      = bin_limits;
    inds_axis = [1:size(bin_limits,1)]';
    data.data.output.cluster=inds_f;
    guidata(findobj('Tag','IRT','type','figure'),data);

    plot_fixed_bins_method(inds_f,v,bin_limits);
   
    
elseif ~isempty(strfind(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},'K-means method'))
    
    k = data.data.bin_values.tot;
    
    ndir = data.data.bin_values.dir;
    nhs  = data.data.bin_values.H_s;
    
    ita = data.data.max_iter; % advanced user input
    Del_eps_min = data.data.max_delta; % advanced user input 
    
    o = data.data.var_o; % <1 - 10?];
    m = data.data.var_m;
    
    type = 1; % FIXED
       
%     Type = 1: 3D Euclidean distance (Hs Tp Dir)
%     Type = 2: 3D Mahler Distance
%     Type = 3: 3D Euclidean distance (Hs Dir [Day of the year])
%     Type = 4: 4D Euclidean distance (Hs Tp Dir [Day of the year])
    
    if strcmp('K-means++ (random)',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value})
        ini = 1;
    elseif strcmp('Maximum dissimilarity method',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value})
        ini = 2;
    elseif strcmp('Fixed bins method',data.handles.method.initial_dropdown.String{data.handles.method.initial_dropdown.Value})
        ini = 3;
    end
    % How to determine the first centroid - 1 K-means++ (random), 2 - mda, 3 - fixed bins

    type_of_k_means = data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value}(1,1:strfind(data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value},' K-means method')-1);
    
    input_data   = [data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir];
    if ~strcmp(data.data.vars_to_plot{2},data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
        if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [data.data.stored_raw_data.H_s.^m data.data.stored_raw_data.T_p data.data.stored_raw_data.dir];
        elseif strcmp(['Wave energy E (1/8*c_g*' data.data.vars_to_plot{2} '^2*g*Rho)'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [data.data.stored_raw_data.H_s.^2.*9.81.*1000.*(1/8).*(1/2).*(9.81/(2*pi)).*data.data.stored_raw_data.T_p data.data.stored_raw_data.T_p data.data.stored_raw_data.dir];
        elseif strcmp('Custom weighting',data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            input_data_w = [abs(data.data.stored_raw_data.weight) data.data.stored_raw_data.T_p data.data.stored_raw_data.dir];
        end
        
        [inds_f,v,v_iter] = k_means(input_data_w,k,ita,Del_eps_min,o,type,ini,ndir,nhs,m,info_dir,type_of_k_means);
        
        if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            % Inverse function power:
            v(:,1) = v(:,1).^(1./m);
            v_iter(:,1,:) = v_iter(:,1,:).^(1./m);
        elseif strcmp(['Wave energy E (1/8*c_g*' data.data.vars_to_plot{2} '^2*g*Rho)'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            % Inverse function wave energy:
            v(:,1)        = (v(:,1)./v(:,2)./(9.81.*1000.*(1/8).*(1/2).*(9.81/(2*pi)))).^(1/2);
            v_iter(:,1,:) = (v_iter(:,1,:)./v_iter(:,2,:)./(9.81.*1000.*(1/8).*(1/2).*(9.81/(2*pi)))).^(1/2);
        elseif strcmp('Custom weighting',data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value})
            if strcmp('Crisp K-means method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})==1
                % No inverse function available, use mean of the indices:
                for ii = 1:max(inds_f)
                    v(ii,1) = mean(input_data(find(inds_f == ii),1));
                end
            else
                % No inverse function available, get the nearest obs point:
                v_norm=Norma_3D(v(:,1:3),type,input_data_w);
                input_data_w_norm=Norma_3D(input_data_w,type,input_data_w);
                d=Dist_3D(input_data_w_norm,v_norm);
                [min_d,ind] = min(d,[],1);
                vv=input_data(ind',:);
                v=[vv v(:,4)];
            end
            v_iter = [];
        end
    else
        [inds_f,v,v_iter] = k_means(input_data,k,ita,Del_eps_min,o,type,ini,ndir,nhs,m,info_dir,type_of_k_means);
    end
    
    [v,ind_sort] = sortrows(v,4); v = flipud(v); ind_sort = flipud(ind_sort);
    tabs=array2table(v,'VariableNames',{'Hs','Tp','Dir','P'});
    data.data.output.v=tabs;
    data.data.output.v_iter=v_iter;
    data.data.output.cluster=inds_f;
    guidata(findobj('Tag','IRT','type','figure'),data);

    plot_k_means_method(inds_f,v,v_iter);
       
    
elseif strcmp('Energy flux method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})
    
    ndir = data.data.bin_values.dir;
    nhs  = data.data.bin_values.H_s;
    
    % check for discontinuity in the angles, if range is discontinuos
    % (eg. 225 to 5) disc=0 if range is continuos, if discontinious, disc=1
    
    [v,inds_f,bin_limits] = energy_flux_method([data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir],nhs,ndir);
    
    [v,ind_sort] = sortrows(v,4); v = flipud(v); ind_sort = flipud(ind_sort);
    tabs=array2table(v,'VariableNames',{'Hs','Tp','Dir','P'});
    data.data.output.v=tabs;
    data.data.output.bin_limits(ind_sort,1) = [1:size(bin_limits,1)]';
    data.data.output.bin_limits(:,2:5)      = bin_limits;
    data.data.output.cluster=inds_f;
    guidata(findobj('Tag','IRT','type','figure'),data);

    
    plot_Energy_flux_method(v,inds_f,bin_limits);
    
    
elseif strcmp('Maximum dissimilarity method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})
    
    k = data.data.bin_values.tot;
    
    type = 1; % FIXED

%     Type = 1: 3D Euclidean distance (Hs Tp Dir)
%     Type = 2: 3D Mahler Distance
%     Type = 3: 3D Euclidean distance (Hs Dir [Day of the year])
%     Type = 4: 4D Euclidean distance (Hs Tp Dir [Day of the year])

    [v,inds_f,data_new] = MDA([data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir],k,type);
    
    [v,ind_sort] = sortrows(v,4); v = flipud(v); ind_sort = flipud(ind_sort);
    tabs=array2table(v,'VariableNames',{'Hs','Tp','Dir','P'});
    data.data.output.v=tabs;
    data.data.output.cluster=inds_f;
    data.data.output.data_new=data_new;
    guidata(findobj('Tag','IRT','type','figure'),data);


    plot_MDA_method(inds_f,v,data_new);
 
elseif strcmp('Sediment Transport Bins',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})
    
    ndir = data.data.bin_values.dir;
    nhs  = data.data.bin_values.H_s;
    SN_angle = data.data.SN_angle;
    
    if length(fieldnames(data.data.stored_raw_data))<4
        uiwait(warndlg('Missing sediment transport data, please load as custom weighting!', 'Warning'));
        set(data.handles.method.run_method_button,'String','Run method','BackgroundColor',[0.9400 0.9400 0.9400],'Enable','on');
        return
    else
        if ~mod(ndir,2)==0
            uiwait(warndlg('Number of direction bins should be even for this method!', 'Warning'));
            set(data.handles.method.run_method_button,'String','Run method','BackgroundColor',[0.9400 0.9400 0.9400],'Enable','on');
            return
        end
        % CONTINUE HERE: Check the shore normal!
        [v,inds_f,bin_limits]=sediment_transport_method([data.data.stored_raw_data.H_s data.data.stored_raw_data.T_p data.data.stored_raw_data.dir data.data.stored_raw_data.weight],nhs,ndir,SN_angle);
    end
    
    [v,ind_sort] = sortrows(v,4); v = flipud(v); ind_sort = flipud(ind_sort);
    tabs=array2table(v,'VariableNames',{'Hs','Tp','Dir','P'});
    data.data.output.v=tabs;
    data.data.output.bin_limits(ind_sort,1) = [1:size(bin_limits,1)]';
    data.data.output.bin_limits(:,2:5)      = bin_limits;
    data.data.output.cluster=inds_f;
    guidata(findobj('Tag','IRT','type','figure'),data);

    plot_Sediment_Transport_method(v,inds_f,bin_limits);

end

v = v(~isnan(v(:,1)),:);
show_output_data(v);

data.handles.visuals.table_new_title.String = 'Reduced data (copy-ready)';

set(data.handles.method.run_method_button,'String','Run method','BackgroundColor',[0.9400 0.9400 0.9400],'Enable','on');

end

function edit_remove_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

ind = find(strcmp(data.handles.loading.remove_dropdown.String{data.handles.loading.remove_dropdown.Value},data.handles.visuals.table_ori.ColumnName));

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) < max(data.handles.visuals.table_ori.Data(:,ind))
        if str2num(hObject.String) > min(data.handles.visuals.table_ori.Data(:,ind))
            data.data.rem_value = str2num(hObject.String);
            guidata(findobj('Tag','IRT','type','figure'),data);
            hObject.BackgroundColor = 'g';
            pause(0.2);
            hObject.BackgroundColor = 'w';
        else
            incor = 1;
            mess  = 'Too small!';
        end
    else
        incor = 1;
        mess  = 'Too high!';
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
    hObject.String = num2str(data.data.rem_value);
end

end

function edit_iter_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) > 1
        if round(str2num(hObject.String)) == str2num(hObject.String)
            if str2num(hObject.String) <= 1000
                data.data.(hObject.Tag) = str2num(hObject.String);
                guidata(findobj('Tag','IRT','type','figure'),data);
                hObject.BackgroundColor = 'g';
                pause(0.2);
                hObject.BackgroundColor = 'w';
            else
                incor = 1;
                mess  = 'Too high!';
            end
        else
            incor = 1;
            mess  = 'Integer!';
        end
    else
        incor = 1;
        mess  = '2 or up!';
    end
else
    incor = 1;
    mess  = 'Number!';
end

prev_state = data.handles.method.run_method_button.Enable;
if incor
    data.handles.method.run_method_button.Enable = 'off';
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.data.(hObject.Tag));
end

data.handles.method.run_method_button.Enable = prev_state;

end

function edit_delta_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) > 0
        if str2num(hObject.String) < 1
            data.data.(hObject.Tag) = str2num(hObject.String);
            guidata(findobj('Tag','IRT','type','figure'),data);
            hObject.BackgroundColor = 'g';
            pause(0.2);
            hObject.BackgroundColor = 'w';
        else
            incor = 1;
            mess  = 'Below 1!';
        end
    else
        incor = 1;
        mess  = 'Pos. value!';
    end
else
    incor = 1;
    mess  = 'Number!';
end

prev_state = data.handles.method.run_method_button.Enable;
if incor
    data.handles.method.run_method_button.Enable = 'off';
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.data.(hObject.Tag));
end

data.handles.method.run_method_button.Enable = prev_state;

end

function edit_SN_angle_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) >= 0
        if str2num(hObject.String) <= 360
            data.data.(hObject.Tag) = str2num(hObject.String);
            guidata(findobj('Tag','IRT','type','figure'),data);
            hObject.BackgroundColor = 'g';
            pause(0.2);
            hObject.BackgroundColor = 'w';
        else
            incor = 1;
            mess  = 'Outside 0-360 range!';
        end
    else
        incor = 1;
        mess  = 'Neg. value!';
    end
else
    incor = 1;
    mess  = 'Number!';
end

prev_state = data.handles.method.run_method_button.Enable;
if incor
    data.handles.method.run_method_button.Enable = 'off';
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.data.(hObject.Tag));
end

data.handles.method.run_method_button.Enable = prev_state;

end

function edit_bin_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

incor = 0;
if ~isempty(str2num(hObject.String))
    if str2num(hObject.String) > 0
        if round(str2num(hObject.String)) == str2num(hObject.String)
            ok = 0;
            if strcmp(hObject.Tag,'tot')
                if str2num(data.handles.method.num_bins_tot.String) < size(data.data.stored_raw_data.H_s,1)
                    ok = 1;
                end
            else
                if (str2num(data.handles.method.num_bins_dir.String) .* str2num(data.handles.method.num_bins_H_s.String)) < size(data.data.stored_raw_data.H_s,1)
                    ok = 1;
                end
            end
            if ok
                data.data.bin_values.(hObject.Tag) = str2num(hObject.String);
                guidata(findobj('Tag','IRT','type','figure'),data);
                hObject.BackgroundColor = 'g';
                pause(0.2);
                hObject.BackgroundColor = 'w';
            else
                incor = 1;
                mess  = 'Too high!';
            end
        else
            incor = 1;
            mess  = 'Integer!';
        end
    else
        incor = 1;
        mess  = 'Pos. value!';
    end
else
    incor = 1;
    mess  = 'Number!';
end

prev_state = data.handles.method.run_method_button.Enable;
if incor
    data.handles.method.run_method_button.Enable = 'off';
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.data.bin_values.(hObject.Tag));
end

data.handles.method.run_method_button.Enable = prev_state;

end

function edit_m_o_value(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

if strcmp('Harmonic K-means method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})==1
    
    incor = 0;
    if ~isempty(str2num(hObject.String))
        if str2num(hObject.String) >= 0
            if str2num(hObject.String) <= 10
                data.data.(hObject.Tag) = str2num(hObject.String);
                guidata(findobj('Tag','IRT','type','figure'),data);
                hObject.BackgroundColor = 'g';
                pause(0.2);
                hObject.BackgroundColor = 'w';
            else
                incor = 1;
                mess  = 'Too high!';
            end
        else
            incor = 1;
            mess  = 'Negative!';
        end
    else
        incor = 1;
        mess  = 'Number!';
    end
    
else
    % elseif strcmp('Fuzzy K-means method',data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value})==1
    incor = 0;
    if ~isempty(str2num(hObject.String))
        if str2num(hObject.String) >= 1
            if str2num(hObject.String) <= 10
                data.data.(hObject.Tag) = str2num(hObject.String);
                guidata(findobj('Tag','IRT','type','figure'),data);
                hObject.BackgroundColor = 'g';
                pause(0.2);
                hObject.BackgroundColor = 'w';
            else
                incor = 1;
                mess  = 'Too high!';
            end
        else
            incor = 1;
            mess  = 'Above or = 1!';
        end
    else
        incor = 1;
        mess  = 'Number!';
    end
end

prev_state = data.handles.method.run_method_button.Enable;
if incor
    data.handles.method.run_method_button.Enable = 'off';
    hObject.String = mess;
    for ii=1:10
        if odd(ii)
            hObject.BackgroundColor = 'r';
        else
            hObject.BackgroundColor = 'w';
        end
        pause(0.05);
    end
    hObject.String = num2str(data.data.(hObject.Tag));
end

data.handles.method.run_method_button.Enable = prev_state;

end

function set_weight_method(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

if strcmp([data.data.vars_to_plot{2} '^m'],data.handles.method.weighting_dropdown.String{data.handles.method.weighting_dropdown.Value});
    data.handles.method.var_m.Enable                  = 'on';
    data.handles.method.var_m_txt.Enable              = 'on';
else
    data.handles.method.var_m.Enable                  = 'off';
    data.handles.method.var_m_txt.Enable              = 'off';
end

end

%% Visuals section:

function plot_new_raw_data

clear_plot;
clear_output;

data = guidata(findobj('Tag','IRT','type','figure'));

axes(data.handles.visuals.plot_ax);

cur_data = data.handles.visuals.table_ori.Data;

x_dim = find(strcmp(data.data.var_names,data.data.vars_to_plot{1}));
y_dim = find(strcmp(data.data.var_names,data.data.vars_to_plot{2}));
z_dim = find(strcmp(data.data.var_names,data.data.vars_to_plot{3}));

data.handles.visuals.raw_data_pointcloud_handle = plot3(cur_data(:,x_dim),cur_data(:,y_dim),cur_data(:,z_dim),'k.');
xlabel(data.data.var_names_label(1)); ylabel(data.data.var_names_label(2)); zlabel(data.data.var_names_label(3));
% xlabel(data.data.var_names(x_dim)); ylabel(data.data.var_names(y_dim)); zlabel(data.data.var_names(z_dim));

set(data.handles.visuals.plot_dropdown,'String',{[data.data.vars_to_plot{1} ' vs. ' data.data.vars_to_plot{2}],[data.data.vars_to_plot{1} ' vs. ' data.data.vars_to_plot{3}],[data.data.vars_to_plot{2} ' vs. ' data.data.vars_to_plot{3}],'3D-view'},'enable','on','Callback',@rotate_plot);

rotate_plot;

%     view(0,90); % dir vs. H_s

guidata(findobj('Tag','IRT','type','figure'),data);

end
 
function rotate_plot(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

axes(data.handles.visuals.plot_ax);

rt=rotate3d(data.handles.visuals.plot_ax);
if get(data.handles.visuals.plot_dropdown,'Value') == 1
    view(0,90); % dir vs. H_s
    rt.Enable = 'off';
elseif get(data.handles.visuals.plot_dropdown,'Value') == 2
    view(0,0); % dir vs. T_p
    rt.Enable = 'off';
elseif get(data.handles.visuals.plot_dropdown,'Value') == 3
    view(90,0); % H_s vs. T_p
    rt.Enable = 'off';
elseif get(data.handles.visuals.plot_dropdown,'Value') == 4
    [AZ,AL]=view;
    if min([AZ,AL] == [0 90]) == 1 || min([AZ,AL] == [0 0]) == 1 || min([AZ,AL] == [90 0]) == 1;
        view(-37.5,30); % 3D-view
    end
    rt.Enable = 'on';
end

delete(findobj(get(data.handles.visuals.plot_ax,'Children'),'Tag','test'));

on_off = {'off','on'};

if isfield(data.handles.visuals,'method_specific_plot_dir_vs_H_s') && ~isempty(data.handles.visuals.method_specific_plot_dir_vs_H_s) && min(ishandle(data.handles.visuals.method_specific_plot_dir_vs_H_s)) == 1
    set(data.handles.visuals.method_specific_plot_dir_vs_H_s,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 1)});
end
if isfield(data.handles.visuals,'method_specific_plot_dir_vs_T_p') && ~isempty(data.handles.visuals.method_specific_plot_dir_vs_T_p) && min(ishandle(data.handles.visuals.method_specific_plot_dir_vs_T_p)) == 1
    set(data.handles.visuals.method_specific_plot_dir_vs_T_p,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 2)});
end
if isfield(data.handles.visuals,'method_specific_plot_H_s_vs_T_p') && ~isempty(data.handles.visuals.method_specific_plot_H_s_vs_T_p) && min(ishandle(data.handles.visuals.method_specific_plot_H_s_vs_T_p)) == 1
    set(data.handles.visuals.method_specific_plot_H_s_vs_T_p,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 3)});
end
if isfield(data.handles.visuals,'method_specific_plot_3D_view') && ~isempty(data.handles.visuals.method_specific_plot_3D_view) && min(ishandle(data.handles.visuals.method_specific_plot_3D_view)) == 1
    set(data.handles.visuals.method_specific_plot_3D_view,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 4)});
end
if isfield(data.handles.visuals,'method_bin_centre_handle_dir_vs_H_s') && ~isempty(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s) && min(ishandle(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s))
    set(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 1)});
end
if isfield(data.handles.visuals,'method_bin_centre_handle_dir_vs_T_p') && ~isempty(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p) && min(ishandle(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p))
    set(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 2)});
end
if isfield(data.handles.visuals,'method_bin_centre_handle_H_s_vs_T_p') && ~isempty(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p) && min(ishandle(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p))
    set(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 3)});
end
if isfield(data.handles.visuals,'method_bin_centre_handle_3D_view') && ~isempty(data.handles.visuals.method_bin_centre_handle_3D_view) && min(ishandle(data.handles.visuals.method_bin_centre_handle_3D_view))
    set(data.handles.visuals.method_bin_centre_handle_3D_view,'Visible',on_off{1+(get(data.handles.visuals.plot_dropdown,'Value') == 4)});
end

if ~isempty(data.handles.visuals.table_new.UserData)
    plot_selected_pts(data.handles.visuals.table_new);
end

end

function plot_fixed_bins_method(inds_f,v,bin_limits)

% Make sure the old data is removed:
clear_plot;

data = guidata(findobj('Tag','IRT','type','figure'));

% Now plot the actual fixed-bins method results:

plot_colored_points(inds_f);
plot_fixed_bins_only(bin_limits);
plot_bin_centers(v);

rotate_plot; % To make sure bins and centers are not shown at certain angles

end

function plot_MDA_method(inds_f,v,data_new)
% Make sure the old data is removed:
clear_plot;

data = guidata(findobj('Tag','IRT','type','figure'));

% Now plot the actual fixed-bins method results:

plot_colored_points_MDA(inds_f,data_new)
plot_bin_centers(v);

rotate_plot; % To make sure bins and centers are not shown at certain angles

end

function plot_k_means_method(inds_f,v,v_iter)

% Make sure the old data is removed:
clear_plot;

data = guidata(findobj('Tag','IRT','type','figure'));

% Now plot the actual k-harmonic means method results:

plot_colored_points(inds_f);
plot_iterations(v_iter);
plot_bin_centers(v);

rotate_plot; % To make sure bins and centers are not shown at certain angles

end

function plot_Energy_flux_method(v,inds_f,bin_limits)

% Make sure the old data is removed:
clear_plot;

data = guidata(findobj('Tag','IRT','type','figure'));

% Now plot the actual Energy flux method results:

plot_colored_points(inds_f);
plot_fixed_bins_only(bin_limits);
plot_bin_centers(v);

rotate_plot; % To make sure bins and centers are not shown at certain angles

end

function plot_Sediment_Transport_method(v,inds_f,bin_limits)

% Make sure the old data is removed:
clear_plot;

data = guidata(findobj('Tag','IRT','type','figure'));

% Now plot the actual Energy flux method results:

plot_colored_points(inds_f);
plot_fixed_bins_only(bin_limits);
plot_bin_centers(v);

rotate_plot; % To make sure bins and centers are not shown at certain angles

end

function plot_iterations(v_iter)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.method_specific_plot_dir_vs_H_s = [];
data.handles.visuals.method_specific_plot_dir_vs_T_p = [];
data.handles.visuals.method_specific_plot_H_s_vs_T_p = [];
data.handles.visuals.method_specific_plot_3D_view = [];

tel = 0;
for ii=1:size(v_iter,1)
    tel = tel + 1;
    data.handles.visuals.method_specific_plot_dir_vs_H_s(tel,1) = plot3(squeeze(v_iter(ii,3,:)),squeeze(v_iter(ii,1,:)),repmat(max(data.data.stored_raw_data.T_p)+0.01,size(squeeze(v_iter(ii,2,:)),1),size(squeeze(v_iter(ii,2,:)),2)),'k.-','linewidth',1);
    data.handles.visuals.method_specific_plot_dir_vs_T_p(tel,1) = plot3(squeeze(v_iter(ii,3,:)),repmat(min(data.data.stored_raw_data.H_s)-0.01,size(squeeze(v_iter(ii,2,:)),1),size(squeeze(v_iter(ii,2,:)),2)),squeeze(v_iter(ii,2,:)),'k.-','linewidth',1);
    data.handles.visuals.method_specific_plot_H_s_vs_T_p(tel,1) = plot3(repmat(max(data.data.stored_raw_data.dir)+0.01,size(squeeze(v_iter(ii,2,:)),1),size(squeeze(v_iter(ii,2,:)),2)),squeeze(v_iter(ii,1,:)),squeeze(v_iter(ii,2,:)),'k.-','linewidth',1);
    data.handles.visuals.method_specific_plot_3D_view(tel,1)    = plot3(squeeze(v_iter(ii,3,:)),squeeze(v_iter(ii,1,:)),squeeze(v_iter(ii,2,:)),'k.-','linewidth',1);
end

guidata(findobj('Tag','IRT','type','figure'),data);

end

function plot_fixed_bins_only(bin_limits)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.method_specific_plot_dir_vs_H_s = [];
data.handles.visuals.method_specific_plot_dir_vs_T_p = [];
data.handles.visuals.method_specific_plot_H_s_vs_T_p = [];

tel = 0;
for ii=1:size(bin_limits,1)
    tel = tel + 1;
    data.handles.visuals.method_specific_plot_dir_vs_H_s(tel,1) = plot3(bin_limits(ii,[3 4 4 3 3]),bin_limits(ii,[1 1 2 2 1]),repmat(max(data.data.stored_raw_data.T_p)+0.02,5,1),'k','linewidth',1);
end

guidata(findobj('Tag','IRT','type','figure'),data);

end

function plot_colored_points(inds_f)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.method_plot_handles = [];

cols = parula(max(inds_f));
for ii = 1:max(inds_f)
    if ~isempty(find(inds_f==ii))
            data.handles.visuals.method_plot_handles(ii,1) = plot3(data.data.stored_raw_data.dir(find(inds_f==ii),1),data.data.stored_raw_data.H_s(find(inds_f==ii),1),data.data.stored_raw_data.T_p(find(inds_f==ii),1),'.','color',cols(ii,:));
    end
end

guidata(findobj('Tag','IRT','type','figure'),data);

end

function plot_colored_points_MDA(inds_f,data_new)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.method_plot_handles = [];

cols = parula(max(inds_f));
for ii = 1:max(inds_f)
    if ~isempty(find(inds_f==ii))
            data.handles.visuals.method_plot_handles(ii,1) = plot3(data_new(find(inds_f==ii),3),data_new(find(inds_f==ii),1),data_new(find(inds_f==ii),2),'.','color',cols(ii,:));
    end
end

guidata(findobj('Tag','IRT','type','figure'),data);

end

function clear_plot

data = guidata(findobj('Tag','IRT','type','figure'));

% Make sure the old data is removed:
% - Raw plot:
if isfield(data.handles.visuals,'raw_data_pointcloud_handle')
    delete(data.handles.visuals.raw_data_pointcloud_handle);
end

% - Method plot:
if isfield(data.handles.visuals,'method_plot_handles') && ~isempty(data.handles.visuals.method_plot_handles) && min(ishandle(data.handles.visuals.method_plot_handles))==1
    delete(data.handles.visuals.method_plot_handles);
end
if isfield(data.handles.visuals,'method_specific_plot_dir_vs_H_s') && ~isempty(data.handles.visuals.method_specific_plot_dir_vs_H_s) && min(ishandle(data.handles.visuals.method_specific_plot_dir_vs_H_s))==1
    delete(data.handles.visuals.method_specific_plot_dir_vs_H_s)
end
if isfield(data.handles.visuals,'method_specific_plot_dir_vs_T_p') && ~isempty(data.handles.visuals.method_specific_plot_dir_vs_T_p) && min(ishandle(data.handles.visuals.method_specific_plot_dir_vs_T_p))==1
    delete(data.handles.visuals.method_specific_plot_dir_vs_T_p)
end
if isfield(data.handles.visuals,'method_specific_plot_H_s_vs_T_p') && ~isempty(data.handles.visuals.method_specific_plot_H_s_vs_T_p) && min(ishandle(data.handles.visuals.method_specific_plot_H_s_vs_T_p))==1
    delete(data.handles.visuals.method_specific_plot_H_s_vs_T_p)
end
if isfield(data.handles.visuals,'method_specific_plot_3D_view') && ~isempty(data.handles.visuals.method_specific_plot_3D_view) && min(ishandle(data.handles.visuals.method_specific_plot_3D_view))==1
    delete(data.handles.visuals.method_specific_plot_3D_view)
end
if isfield(data.handles.visuals,'method_bin_centre_handle_dir_vs_H_s') && ~isempty(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s) && min(ishandle(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s))==1
    delete(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s)
end
if isfield(data.handles.visuals,'method_bin_centre_handle_dir_vs_T_p') && ~isempty(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p) && min(ishandle(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p))==1
    delete(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p)
end
if isfield(data.handles.visuals,'method_bin_centre_handle_H_s_vs_T_p') && ~isempty(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p) && min(ishandle(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p))==1
    delete(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p)
end
if isfield(data.handles.visuals,'method_bin_centre_handle_3D_view') && ~isempty(data.handles.visuals.method_bin_centre_handle_3D_view) && min(ishandle(data.handles.visuals.method_bin_centre_handle_3D_view))==1
    delete(data.handles.visuals.method_bin_centre_handle_3D_view)
end

delete(findobj(get(data.handles.visuals.plot_ax,'Children'),'Tag','test'));
data.handles.visuals.table_new.UserData = [];

if ~isempty(data.handles.visuals.plot_ax.Children)
    warn_state = warning;
    if strcmp(warn_state.state,'off')
        warndlg({'Plot is not correctly cleared, please contact the developer!';' ';'This tool is now trying to overcome this issue automatically..'},'Warning code 35451');
    else
        warning('Code 35451: Plot is not correctly cleared, please contact the developer with this code!')
        disp('This tool is now forced to overcome this issue automatically..')
    end
    delete(data.handles.visuals.plot_ax.Children);
end

end

function plot_bin_centers(v)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.method_bin_centre_handle_dir_vs_H_s = plot3(v(:,3),v(:,1),repmat(max(data.data.stored_raw_data.T_p)+0.03,size(v,1),1),'rx','linewidth',3,'markersize',10);
data.handles.visuals.method_bin_centre_handle_dir_vs_T_p = plot3(v(:,3),repmat(min(data.data.stored_raw_data.H_s)-0.03,size(v,1),1),v(:,2),'rx','linewidth',3,'markersize',10);
data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p = plot3(repmat(max(data.data.stored_raw_data.dir)+0.03,size(v,1),1),v(:,1),v(:,2),'rx','linewidth',3,'markersize',10);
data.handles.visuals.method_bin_centre_handle_3D_view    = plot3(v(:,3),v(:,1),v(:,2),'rx','linewidth',3,'markersize',10);

guidata(findobj('Tag','IRT','type','figure'),data);

end

function show_output_data(v)

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.table_new.Data = v;

table_text_width = data.sizes.table_size(1)-data.sizes.edge_spacing-data.sizes.button_spacing-(52+11*max(0,(ceil(log10(1+size(v,1)))-2)));
set(data.handles.visuals.table_new,'ColumnEditable',logical([0 0 0 0]),'ColumnWidth',repmat({floor(table_text_width./4)},1,4),'ColumnName',{data.data.vars_to_plot{2}; data.data.vars_to_plot{3}; data.data.vars_to_plot{1}; 'P'},'FontSize',9,'CellSelectionCallback',@select_output_pts);

data.handles.export.export_data_button.Enable = 'on';
data.handles.export.export_figure_button.Enable = 'on';

end

function clear_output

data = guidata(findobj('Tag','IRT','type','figure'));

data.handles.visuals.table_new.Data = [];
data.handles.visuals.table_new.ColumnName = [];
data.handles.visuals.table_new_title.String = [''];

end



%% Export section

function export_data(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

[FILENAME,PATHNAME] = uiputfile('*.mat','Export to file');

if ischar(PATHNAME)
%     input_reduction_output.Data      = data.handles.visuals.table_new.Data;
%     input_reduction_output.Variables = data.handles.visuals.table_new.ColumnName';
    
    input_reduction_output      = data.data.output;
    
    save([PATHNAME FILENAME],'input_reduction_output');
    
    col_ori = data.handles.export.export_data_button.BackgroundColor;
    str_ori = data.handles.export.export_data_button.String;
    data.handles.export.export_data_button.String = 'Data succesfully exported';
    data.handles.export.export_data_button.BackgroundColor = 'g';
    pause(1.5);
    data.handles.export.export_data_button.BackgroundColor = col_ori;
    data.handles.export.export_data_button.String          = str_ori;
else
    warndlg('Exporting cancelled by user','Warning');
end

guidata(findobj('Tag','IRT','type','figure'),data);

end

function export_figures(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

[filename_fig,pathname_fig] = uiputfile('*.png','Export figure');

if ischar(pathname_fig)
    
%Create a new figure
screen_size = get(0,'ScreenSize');
data.sizes.fig2_size=[900 684];

data.handles.fig2=figure('Position',[screen_size(3)./2-data.sizes.fig2_size(1)./2 min(screen_size(4)-data.sizes.fig2_size(2)-28 , 48 + (screen_size(4)-48-28)./2 - data.sizes.fig2_size(2)./2) data.sizes.fig2_size],'Resize','off'); %'visible','off'
data.handles.visuals.plot_ax_fig2 = axes('parent',data.handles.fig2,'box','on','Layer','top','units','pixels','Position',[data.sizes.fig2_size(1)/8 data.sizes.fig2_size(2)/8 (data.sizes.fig2_size(1)/8)*6 (data.sizes.fig2_size(2)/8)*6],'visible','off');

%Create a copy of the axes
data.handles.visuals.new_axis_fig2 = copyobj(data.handles.visuals.plot_ax,data.handles.fig2);
set(data.handles.visuals.new_axis_fig2,'Position',[data.sizes.fig2_size(1)/8 data.sizes.fig2_size(2)/8 (data.sizes.fig2_size(1)/8)*6 (data.sizes.fig2_size(2)/8)*6],'fontsize',10)
title(data.handles.visuals.new_axis_fig2,{[data.handles.method.method_dropdown.String{data.handles.method.method_dropdown.Value}];['    ']},'fontsize',12);

 print(data.handles.fig2,'-dpng',[pathname_fig filename_fig]);
 close(data.handles.fig2)
           
    col_ori = data.handles.export.export_figure_button.BackgroundColor;
    str_ori = data.handles.export.export_figure_button.String;
    data.handles.export.export_figure_button.String = 'Figure succesfully exported';
    data.handles.export.export_figure_button.BackgroundColor = 'g';
    pause(1.5);
    data.handles.export.export_figure_button.BackgroundColor = col_ori;
    data.handles.export.export_figure_button.String          = str_ori;
else
    warndlg('Exporting cancelled by user','Warning');
end
   
end

function select_output_pts(hObject,eventdata)

data = guidata(findobj('Tag','IRT','type','figure'));

hObject.UserData = unique(eventdata.Indices(:,1));

guidata(findobj('Tag','IRT','type','figure'),data);

if ~isempty(hObject.UserData)
    plot_selected_pts(hObject);
end

end

function plot_selected_pts(hObject)

data = guidata(findobj('Tag','IRT','type','figure'));

if strcmp(data.handles.visuals.method_bin_centre_handle_3D_view.Visible,'on')
    d_h = data.handles.visuals.method_bin_centre_handle_3D_view;
elseif strcmp(data.handles.visuals.method_bin_centre_handle_dir_vs_H_s.Visible,'on')
    d_h = data.handles.visuals.method_bin_centre_handle_dir_vs_H_s;
elseif strcmp(data.handles.visuals.method_bin_centre_handle_dir_vs_T_p.Visible,'on')
    d_h = data.handles.visuals.method_bin_centre_handle_dir_vs_T_p;
elseif strcmp(data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p.Visible,'on')
    d_h = data.handles.visuals.method_bin_centre_handle_H_s_vs_T_p;
end

delete(findobj(get(data.handles.visuals.plot_ax,'Children'),'Tag','test'));
plot3(d_h.XData(hObject.UserData),d_h.YData(hObject.UserData),d_h.ZData(hObject.UserData),'k.','markersize',20,'Tag','test');

end
