function XBoutput
% Function to visualize XBeach output


%% Data structure
Data.GUI.create_date    = '19-Aug-2009 14:20:10';
Data.GUI.access_date    = datestr(now);
Data.XBdata_directory   = pwd;
Data.XBoutput.number_variables = 0;
Data.XBoutput.number_paths = 0;
Data.XBoutput.paths.collect = {};
Data.XBoutput.variable_names{1}='';
Data.GUI.show_variables_type = 1;
Data.GUI.number_plot_variables = 0;
Data.GUI.plot_variables_index = {};
Data.GUI.number_dir_read = 0;
Data.GUI.last_read_path = '';
Data.GUI.fighandles.fs1 = -1;
Data.GUI.readastype = 'double';

%% Set up figure
% GUI figure
Data.GUI.fighandles.F=figure('Visible','on','Name','XBeach output GUI','MenuBar','none',...
    'NumberTitle','off','Units','normalized','position',[0.2 0.4 0.4 0.5]);

Data.GUI.bgc=get(Data.GUI.fighandles.F,'color');

% Gui menus
fm = uimenu(Data.GUI.fighandles.F,'Label','File');
lm = uimenu(fm,'Label','Load data files','Callback',{@load_data_files});
sw = uimenu(fm,'Label','Save data to workspace','Callback',{@save_data_to_ws});
sw = uimenu(fm,'Label','Save data to file','Callback',{@save_data_to_file});
em = uimenu(fm,'Label','Save and exit GUI','Callback',{@save_exit_gui});
em = uimenu(fm,'Label','Exit GUI','Callback',{@exit_gui});
dm = uimenu(Data.GUI.fighandles.F,'Label','Set directory');
dms= uimenu(dm,'Label','Set directory','Callback',{@set_directory});
mm = uimenu(Data.GUI.fighandles.F,'Label','Memory options');
mmd= uimenu(mm,'Label','Store files as double precision','Callback',{@set_readtype},'Checked','on');
mms= uimenu(mm,'Label','Store files as single precision','Callback',{@set_readtype},'Checked','off');


%% Gui controls

% Loading files
dd = uicontrol(Data.GUI.fighandles.F,'style','popupmenu','units','normalized',...
    'position',[0.05 0.8 0.2 0.1],'string','No variables loaded',...
    'enable','off','min',1,'max',25,'BackgroundColor','w',...
    'Callback',{@show_variables});
%     'position',[0.1 0.55 0.2 0.1],'string','No variables loaded',...

rlb = uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.30 0.8 0.08 0.05],'string','>',...
    'TooltipString','Reload selected',...
    'enable','off','Callback',{@add_to_selection});
%     'position',[0.325 0.29 0.05 0.05],'string','>',...

dlb = uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.30 0.7 0.08 0.05],'string','<',...
    'enable','off','Callback',{@remove_from_selection});

lb1 = uicontrol(Data.GUI.fighandles.F,'style','listbox','units','normalized',...
    'position',[0.4 0.65 0.2 0.25],'string','',...
    'enable','off','min',1,'max',25,'BackgroundColor','w');
%     'position',[0.1 0.1 0.2 0.35],'string','',...

lb2 = uicontrol(Data.GUI.fighandles.F,'style','listbox','units','normalized',...
    'position',[0.7 0.65 0.2 0.25],'string','',...
    'enable','off','min',1,'max',25,'BackgroundColor','w');
%     'position',[0.4 0.1 0.2 0.35],'string','',...

pb1 = uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.625 0.8 0.05 0.05],'string','>',...
    'TooltipString','Add selected to plot selection',...
    'enable','off','Callback',{@add_to_selection});
%     'position',[0.325 0.29 0.05 0.05],'string','>',...

pb2 = uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.625 0.7 0.05 0.05],'string','<',...
    'TooltipString','Remove selected from plot selection',...
    'enable','off','Callback',{@remove_from_selection});
%     'position',[0.325 0.19 0.05 0.05],'string','<',...

uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.4 0.91 0.2 0.03],'string','Available variables');
%     'position',[0.1 0.46 0.2 0.03],'string','Available variables');
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.7 0.91 0.2 0.03],'string','Plot variables');
%     'position',[0.4 0.46 0.2 0.03],'string','Plot variables');




% X-panel
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.07 0.55 0.2 0.03],'string','Plot X-rows');
uipanel('units','normalized','position',[0.02 0.35 0.3 0.2],'BackgroundColor',Data.GUI.bgc);
cb1=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','All',...
    'value',1,'position',[0.03 0.455 0.05 0.04],'enable','off','Callback',{@checkbutton_function});
eb1=uicontrol(Data.GUI.fighandles.F,'style','edit','units','normalized','BackgroundColor','w',...
    'position',[0.087 0.455 0.165 0.04],'enable','off');
ok1=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','OK',...
    'position',[0.26 0.455 0.05 0.04],'enable','off','Callback',{@ok_function});
mint1=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.03 0.40 0.28 0.03],'string','Minimum x: ');
maxt1=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.03 0.36 0.28 0.03],'string','Maximum x: ');
% uicontrol(F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
%             'position',[0.03 0.5 0.05 0.03],'string','All');
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.12 0.5 0.1 0.03],'string','Selection');

% Y-panel
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.4 0.55 0.2 0.03],'string','Plot Y-rows');
uipanel('units','normalized','position',[0.35 0.35 0.3 0.2],'BackgroundColor',Data.GUI.bgc);
cb2=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','All',...
    'value',1,'position',[0.36 0.455 0.05 0.04],'enable','off','Callback',{@checkbutton_function});
eb2=uicontrol(Data.GUI.fighandles.F,'style','edit','units','normalized','BackgroundColor','w',...
    'position',[0.417 0.455 0.165 0.04],'enable','off');
% cb2=uicontrol(F,'style','checkbox','units','normalized','BackgroundColor',Data.GUI.bgc,...
%     'value',1,'position',[0.37 0.46 0.03 0.03],'enable','off','Callback',{@checkbutton_function});
% eb2=uicontrol(F,'style','edit','units','normalized','BackgroundColor','w',...
%     'position',[0.41 0.455 0.17 0.04],'enable','off');
ok2=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','OK',...
    'position',[0.59 0.455 0.05 0.04],'enable','off','Callback',{@ok_function});
mint2=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.36 0.40 0.28 0.03],'string','Minimum y: ');
maxt2=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.36 0.36 0.28 0.03],'string','Maximum y: ');
% uicontrol(F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
%     'position',[0.36 0.5 0.05 0.03],'string','All');
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.45 0.5 0.1 0.03],'string','Selection');


% Time-panel
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.73 0.55 0.2 0.03],'string','Plot time steps');
uipanel('units','normalized','position',[0.68 0.35 0.3 0.2],'BackgroundColor',Data.GUI.bgc);
cb3=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','All',...
    'value',1,'position',[0.69 0.455 0.05 0.04],'enable','off','Callback',{@checkbutton_function});
eb3=uicontrol(Data.GUI.fighandles.F,'style','edit','units','normalized','BackgroundColor','w',...
    'position',[0.747 0.455 0.165 0.04],'enable','off');
% cb3=uicontrol(F,'style','checkbox','units','normalized','BackgroundColor',Data.GUI.bgc,...
%     'value',1,'position',[0.70 0.46 0.03 0.03],'enable','off','Callback',{@checkbutton_function});
% eb3=uicontrol(F,'style','edit','units','normalized','BackgroundColor','w',...
%     'position',[0.74 0.455 0.17 0.04],'enable','off');
ok3=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized','string','OK',...
    'position',[0.92 0.455 0.05 0.04],'enable','off','Callback',{@ok_function});
mint3=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.69 0.40 0.28 0.03],'string','Minimum t: ');
maxt3=uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.69 0.36 0.28 0.03],'string','Maximum t: ');
% uicontrol(F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
%     'position',[0.69 0.5 0.05 0.03],'string','All');
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.78 0.5 0.1 0.03],'string','Selection');


% Plot options

% 1d plot

uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.07 0.305 0.2 0.03],'string','Plot 1D');
uipanel('units','normalized','position',[0.02 0.05 0.3 0.25],'BackgroundColor',Data.GUI.bgc);
uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.09 0.20 0.15 0.03],'string','plot limit');
plot1e=uicontrol(Data.GUI.fighandles.F,'style','edit','units','normalized',...
    'position',[0.09 0.15 0.15 0.04],'string','auto',...
    'enable','off','BackgroundColor','w');
plot1b=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.09 0.07 0.15 0.05],'string','Plot',...
    'enable','off','Callback',{@XBGUIplot1D});

% 2d plot


uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.40 0.305 0.2 0.03],'string','Plot 2D');
uipanel('units','normalized','position',[0.35 0.05 0.3 0.25],'BackgroundColor',Data.GUI.bgc);

plotaca=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.42 0.14 0.15 0.05],'string','Colors',...
    'enable','off','Callback',{@adjust_color_axis});

plot2b=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.42 0.07 0.15 0.05],'string','Plot',...
    'enable','off','Callback',{@XBGUIplot2D});

% 3d plot

uicontrol(Data.GUI.fighandles.F,'style','text','units','normalized','BackgroundColor',Data.GUI.bgc,...
    'position',[0.73 0.305 0.2 0.03],'string','Plot 3D');
uipanel('units','normalized','position',[0.68 0.05 0.3 0.25],'BackgroundColor',Data.GUI.bgc);
plot3b=uicontrol(Data.GUI.fighandles.F,'style','pushbutton','units','normalized',...
    'position',[0.75 0.07 0.15 0.05],'string','Plot',...
    'enable','off','Callback',{@XBGUIplot3D});


plothandlebuttons1D=[plot1b;plot1e];
plothandlebuttons23D=[plotaca;plot2b;plot3b];

OKclose=1;

%% Subfunctions calling functions
    function set_directory(hObject,eventdata)
        Data.XBdata_directory = uigetdir('','Select directory');
        cd(Data.XBdata_directory);
    end


    function load_data_files(hObject,eventdata)
        [fn, pathname ] = uigetfile('*.dat','Select data file(s)','multiselect','on');

        if (~iscell(fn) & fn==0)  % First test for non-cell
            return
        elseif ~iscell(fn)
            filename{1}=fn;
        else
            filename=fn;
        end
        cdir=pwd;
        
        if any(strcmpi(pathname,Data.XBoutput.paths.collect))
            % this direcory is already in memory, so where does it belong
            dirnum=find(strcmpi(pathname,Data.XBoutput.paths.collect)==1);
            if dirnum==1
                fext='';
            else
                fext=['_' num2str(dirnum)];
            end            
        else
            Data.XBoutput.number_paths=Data.XBoutput.number_paths+1;
            Data.XBoutput.paths.collect{Data.XBoutput.number_paths}=pathname;
            if Data.XBoutput.number_paths==1
                fext='';
            else
                fext=['_' num2str(Data.XBoutput.number_paths)];
            end  
        end
        
        wb=waitbar(0,'Reading input'); 
        for i=1:length(filename)
            waitbar((2*i-1)/(2*length(filename)),wb,['Reading input ' num2str(i) ' of ' num2str(length(filename))]);
            fileread = base_load_data(pathname,filename{i},fext,Data.XBoutput.number_variables);
            Data.XBoutput.number_variables=Data.XBoutput.number_variables+fileread;
            waitbar((2*i)/(2*length(filename)),wb,['Reading input ' num2str(i) ' of ' num2str(length(filename))]);
        end
        close(wb);

        %         cd(pathname);
        %         Data.XBoutput.XBdims=XBgetdimensions;
        %         %         no_read_now = length(filename);
        %         no_read_now=0;
        %         if ~strcmpi(Data.GUI.last_read_path,pathname)
        %             Data.GUI.number_dir_read=Data.GUI.number_dir_read+1;
        %             Data.GUI.last_read_path=pathname;
        %         end
        %         wb=waitbar(0,'Reading input');
        %         for i=1:length(filename)
        %             waitbar((2*i-1)/(2*length(filename)),wb,['Reading input ' num2str(i) ' of ' num2str(length(filename))]);
        %             fn=filename{i};
        %             if strcmpi(fn,'xy.dat')
        %                 wh = warndlg('Will not load xy.dat');
        %                 pause(.8);%if exist('wh','var');close(wh);end;
        %             elseif strcmpi(fn,'dims.dat')
        %                 wh = warndlg('Will not load dims.dat');
        %                 pause(.8);%if exist('wh','var');close(wh);end;
        %                 %             elseif any(strcmpi(Data.XBoutput.variable_names,fn(1:end-4)))
        %                 %                 wh = warndlg(['Will not load ' fn ' because it is already loaded']);
        %                 %                 pause(1.5);%if exist('wh','var');close(wh);end;
        %             else
        %                 fn=fn(1:end-4);
        %                 if Data.GUI.number_dir_read>1
        %                     fn=[fn '_' num2str(Data.GUI.number_dir_read)];
        %                 end
        %                 if any(strcmpi(Data.XBoutput.variable_names,fn))
        %                     % only update data, but nothing else
        %                     eval(['Data.XBoutput.' fn '=XBreadvar(filename{i},Data.XBoutput.XBdims);']);
        %                 else
        %                     no_read_now=no_read_now+1;
        %                     eval(['Data.XBoutput.' fn '=XBreadvar(filename{i},Data.XBoutput.XBdims);']);
        %                     eval(['Data.GUI.caxis.' fn '=''auto'';']);
        %                     eval(['Data.GUI.colormap.' fn '=''jet'';']);
        %                     Data.XBoutput.variable_names{Data.XBoutput.number_variables+no_read_now}=fn;
        %                     if length(fn)>5
        %                         if or(strcmpi(fn(1:5),'point'),strcmpi(fn(1:5),'rugau'))
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=4;
        %                         elseif strcmpi(fn(1:5),'cross')
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=3;
        %                         elseif strcmpi(fn(end-4:end),'_mean')
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=2;
        %                         else
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=1;
        %                         end
        %                     elseif length(fn)>4
        %                         if or(strcmpi(fn(end-3:end),'_var'),...
        %                                 or(strcmpi(fn(end-3:end),'_max'),strcmpi(fn(end-3:end),'_min')))
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=2;
        %                         else
        %                             Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=1;
        %                         end
        %                     else
        %                         Data.XBoutput.variables_type{Data.XBoutput.number_variables+no_read_now}=1;
        %                     end
        %                 end
        %             end
        %             waitbar((2*i)/(2*length(filename)),wb,['Reading input ' num2str(i) ' of ' num2str(length(filename))]);
        %         end
        %         close(wb);
        %         for i=Data.XBoutput.number_variables+1:Data.XBoutput.number_variables+no_read_now
        %             Data.GUI.plot_variables_index{i}=0;
        %         end
        %         OKclose=0;

%         Data.XBoutput.number_variables=Data.XBoutput.number_variables+no_read_now;
        set(dd,'string',{'2D spatial output','2D mean output','cross section output','point output'},'enable','on');
        update_show_variables_list(Data.GUI.show_variables_type)
        set(lb1,'enable','on');
        set(lb2,'enable','on');
        set(pb1,'enable','on');
        set(cb1,'enable','on');
        set(cb2,'enable','on');
        set(cb3,'enable','on');
        set(eb1,'string',['1:' num2str(Data.XBoutput.XBdims.nx+1)]);
        set(eb2,'string',['1:' num2str(Data.XBoutput.XBdims.ny+1)]);
        set(eb3,'string',['1:' num2str(Data.XBoutput.XBdims.nt)]);
        set(mint1,'string',['Minimum x: ' num2str(min(min(Data.XBoutput.XBdims.x))) ' m']);
        set(maxt1,'string',['Maximum x: ' num2str(max(max(Data.XBoutput.XBdims.x))) ' m']);
        set(mint2,'string',['Minimum y: ' num2str(min(min(Data.XBoutput.XBdims.y))) ' m']);
        set(maxt2,'string',['Maximum y: ' num2str(max(max(Data.XBoutput.XBdims.y))) ' m']);
        set(mint3,'string',['Minimum t: ' num2str(min(Data.XBoutput.XBdims.tsglobal)) ' s']);
        set(maxt3,'string',['Maximum t: ' num2str(max(Data.XBoutput.XBdims.tsglobal)) ' s']);
        Data.GUI.plot_xrange=1:Data.XBoutput.XBdims.nx+1;
        Data.GUI.plot_yrange=1:Data.XBoutput.XBdims.ny+1;
        Data.GUI.plot_trange=1:Data.XBoutput.XBdims.nt;
        set(eb1,'enable','on');
        set(ok1,'enable','on');
        set(eb2,'enable','on');
        set(ok2,'enable','on');
        set(eb3,'enable','on');
        set(ok3,'enable','on');
        cd(cdir);
    end


    function save_data_to_file(hObject,eventdata)
        [FileName,PathName,FilterIndex] = uiputfile('*.mat','Save as','project.mat');
        if all([FileName PathName FilterIndex])
            save([PathName FileName],'Data');
            OKclose=1;
        else
            ee = errordlg('Warning: settings not saved','Save error');
            OKclose=0;
        end
    end

    function save_data_to_ws(hObject,eventdata)
        assignin('base', 'Data', Data);
        msg = msgbox('Data saved in workspace','Saving') ;
        pause(1.5);%if exist('msg','var');delete(msg);end
        OKclose=1;
    end

    function show_variables(hObject,eventdata)
        Data.GUI.show_variables_type=get(hObject,'value');
        update_show_variables_list(Data.GUI.show_variables_type);
        dummy=0;
        checkbutton_function(cb3,dummy);
        if Data.GUI.show_variables_type==2
            Data.GUI.plot_trange=1:Data.XBoutput.XBdims.ntm;
        end
    end


    function add_to_selection(hObject,eventdata)
        % What is selected>
        vals=get(lb1,'value');
        name=get(lb1,'string');if ~iscell(name);cname{1}=name;else;cname=name;end;
        for i=1:length(vals)
            name=cname{vals(i)};
            for ii=1:Data.XBoutput.number_variables
                if strcmpi(name,Data.XBoutput.variable_names{ii})
                    Data.GUI.plot_variables_index{ii}=1;
                    Data.GUI.number_plot_variables=Data.GUI.number_plot_variables+1;
                end
            end
        end
        update_show_selected_variables;
        update_show_variables_list(Data.GUI.show_variables_type);
        set(lb1,'value',1);
        set(lb2,'value',1);
    end


    function remove_from_selection(hObject,eventdata)
        % What is selected>
        vals=get(lb2,'value');
        name=get(lb2,'string');if ~iscell(name);cname{1}=name;else;cname=name;end;
        for i=1:length(vals)
            name=cname{vals(i)};
            for ii=1:Data.XBoutput.number_variables
                if strcmpi(name,Data.XBoutput.variable_names{ii})
                    Data.GUI.plot_variables_index{ii}=0;
                    Data.GUI.number_plot_variables=Data.GUI.number_plot_variables-1;
                end
            end
        end
        update_show_selected_variables;
        update_show_variables_list(Data.GUI.show_variables_type);
        set(lb1,'value',1);
        set(lb2,'value',1);
    end


    function save_exit_gui(hObject,eventdata)
        QE = questdlg('Save and exit?','Quit','Yes','No','Cancel','No');
        if strcmpi(QE,'Yes')
            save_data_to_file(hObject,eventdata);
            if OKclose==1
                close(F);
            end
        end
    end

    function exit_gui(hObject,eventdata)
        if OKclose==0
            QE = questdlg('Really quit without saving?','Quit','Yes','No','Cancel','No');
            if strcmpi(QE,'Yes')
                close(F);
            end
        else
            close(F);
        end
    end

    function set_readtype(hObject,eventdata)
       if hObject==mmd
           Data.GUI.readastype = 'double';
           set(mmd,'Checked','on');
           set(mms,'Checked','off');
       elseif hObject==mms
           Data.GUI.readastype = 'single';
           set(mmd,'Checked','off');
           set(mms,'Checked','on');
       end        
    end

    function checkbutton_function(hObject,eventdata)

        switch hObject
            case cb1
                set(eb1,'string',['1:' num2str(Data.XBoutput.XBdims.nx)]);
            case cb2
                set(eb2,'string',['1:' num2str(Data.XBoutput.XBdims.ny)]);
            case cb3
                switch Data.GUI.show_variables_type
                    case 1
                        set(eb3,'string',['1:' num2str(Data.XBoutput.XBdims.nt)]);
                    case 2
                        set(eb3,'string',['1:' num2str(Data.XBoutput.XBdims.ntm)]);
                    otherwise
                end
        end

    end
    function ok_function(hObject,eventdata)
        switch hObject
            case ok1
                val=get(eb1,'string');
                eval(['val=[' val '];']);
                Data.GUI.plot_xrange=val;
                set(mint1,'string',['Minimum x: ' num2str(min(min(Data.XBoutput.XBdims.x(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(maxt1,'string',['Maximum x: ' num2str(max(max(Data.XBoutput.XBdims.x(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(mint2,'string',['Minimum y: ' num2str(min(min(Data.XBoutput.XBdims.y(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(maxt2,'string',['Maximum y: ' num2str(max(max(Data.XBoutput.XBdims.y(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                if or(length(Data.GUI.plot_xrange)<2,length(Data.GUI.plot_yrange)<2)
                    %                     set(plot1b,'enable','on');
                    set(plothandlebuttons1D,'enable','on');
                    set(plothandlebuttons23D,'enable','off');
                    %                     set(plot3b,'enable','off');
                else
                    set(plothandlebuttons1D,'enable','off');
                    %                     set(plot1e,'enable','off');
                    set(plothandlebuttons23D,'enable','on');
                    %                     set(plot3b,'enable','on');
                end

            case ok2
                val=get(eb2,'string');
                eval(['val=[' val '];']);
                Data.GUI.plot_yrange=val;
                set(mint1,'string',['Minimum x: ' num2str(min(min(Data.XBoutput.XBdims.x(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(maxt1,'string',['Maximum x: ' num2str(max(max(Data.XBoutput.XBdims.x(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(mint2,'string',['Minimum y: ' num2str(min(min(Data.XBoutput.XBdims.y(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                set(maxt2,'string',['Maximum y: ' num2str(max(max(Data.XBoutput.XBdims.y(Data.GUI.plot_xrange,Data.GUI.plot_yrange)))) ' m']);
                if or(length(Data.GUI.plot_xrange)<2,length(Data.GUI.plot_yrange)<2)
                    set(plothandlebuttons1D,'enable','on');
                    %                     set(plot1e,'enable','on');
                    set(plothandlebuttons23D,'enable','off');
                    %                     set(plot3b,'enable','off');
                else
                    set(plothandlebuttons1D,'enable','off');
                    %                     set(plot1e,'enable','off');
                    set(plothandlebuttons23D,'enable','on');
                    %                     set(plot3b,'enable','on');
                end
            case ok3
                val=get(eb3,'string');
                eval(['val=[' val '];']);
                Data.GUI.plot_trange=val;
                switch Data.GUI.show_variables_type
                    case 1
                        set(mint3,'string',['Minimum t: ' num2str(min(Data.XBoutput.XBdims.tsglobal(Data.GUI.plot_trange))) ' s']);
                        set(maxt3,'string',['Maximum t: ' num2str(max(Data.XBoutput.XBdims.tsglobal(Data.GUI.plot_trange))) ' s']);
                    case 2
                        set(mint3,'string',['Minimum t: ' num2str(min(Data.XBoutput.XBdims.tsmean(Data.GUI.plot_trange))) ' s']);
                        set(maxt3,'string',['Maximum t: ' num2str(max(Data.XBoutput.XBdims.tsmean(Data.GUI.plot_trange))) ' s']);
                    otherwise
                        display('Not ready for this yet');
                end
        end

    end

    function XBGUIplot1D(hObject,eventdata)

        [names,xdata,ydata,tdata,senddata]=collect_data_for_plot;

        if length(Data.GUI.plot_xrange)==1
            xdata=ydata;
        end

        F2=figure;
        ylimstr=get(plot1e,'string');
        if strcmpi(ylimstr,'auto')
            plotXB1D(F2,xdata,tdata,senddata,names)
        else
            ylim=str2num(ylimstr);
            plotXB1D(F2,xdata,tdata,senddata,names,ylim)
        end

    end

    function adjust_color_axis(hObject,eventdata)
        [names,xdata,ydata,tdata,senddata]=collect_data_for_plot;

        coloraxis2D(names);

    end

    function XBGUIplot2D(hObject,eventdata)

        [names,xdata,ydata,tdata,senddata]=collect_data_for_plot;
        F3=figure;
        climin={};
        colmap={};
        for i=1:length(names)
            eval(['climin{i}=Data.GUI.caxis.' names{i} ';'])
            eval(['colmap{i}=Data.GUI.colormap.' names{i} ';'])
        end

        plotXB2D(F3,xdata,ydata,tdata,senddata,names,climin,colmap);

    end

    function XBGUIplot3D(hObject,eventdata)

    end

    




%% Subfunctions used to manage data


    function fileread = base_load_data(pathname,filename,filext,noexistingvars)
        cd(pathname);
        Data.XBoutput.XBdims=XBgetdimensions;
        %         no_read_now = length(filename);
        fileread=0;
        if strcmpi(filename,'xy.dat')
            wh = warndlg('Will not load xy.dat');
            pause(.8);%if exist('wh','var');close(wh);end;
            stop=1;
        elseif strcmpi(filename,'dims.dat')
            wh = warndlg('Will not load dims.dat');
            pause(.8);
            stop=1;
        else
            stop=0;
        end
        
        if stop==0
            % This is a useful .dat file
            filenameGUI=[filename(1:end-4) filext];
            if any(strcmpi(Data.XBoutput.variable_names,filenameGUI))
                eval(['Data.XBoutput.' filenameGUI '=XBreadvar(filename,Data.XBoutput.XBdims,Data.GUI.readastype);']);
            else
                fileread=1;
                % Read data
                eval(['Data.XBoutput.' filenameGUI '=XBreadvar(filename,Data.XBoutput.XBdims,Data.GUI.readastype);']);
                eval(['Data.XBoutput.paths.' filenameGUI '=pathname;']);
                % Set default plotting values for this variable
                eval(['Data.GUI.caxis.' filenameGUI '=''auto'';']);
                eval(['Data.GUI.colormap.' filenameGUI '=''jet'';']);
                Data.XBoutput.variable_names{noexistingvars+1}=filenameGUI;
                if length(filename)>9
                    if or(strcmpi(filename(1:5),'point'),strcmpi(filename(1:5),'rugau'))
                        Data.XBoutput.variables_type{noexistingvars+1}=4;
                    elseif strcmpi(filename(1:5),'cross')
                        Data.XBoutput.variables_type{noexistingvars+1}=3;
                    elseif strcmpi(filename(end-8:end-4),'_mean')
                        Data.XBoutput.variables_type{noexistingvars+1}=2;
                    else
                        Data.XBoutput.variables_type{noexistingvars+1}=1;
                    end
                elseif length(filename)>8
                    if or(strcmpi(filename(end-7:end-4),'_var'),...
                            or(strcmpi(filename(end-7:end-4),'_max'),strcmpi(filename(end-7:end-4),'_min')))
                        Data.XBoutput.variables_type{noexistingvars+1}=2;
                    else
                        Data.XBoutput.variables_type{noexistingvars+1}=1;
                    end
                else
                    Data.XBoutput.variables_type{noexistingvars+1}=1;
                end
                Data.GUI.plot_variables_index{noexistingvars+1}=0;
                OKclose=0;
            end
        end
    end


    function update_show_selected_variables
        Data.GUI.plot_variables_list={};
        m=0;
        for i=1:Data.XBoutput.number_variables
            if Data.GUI.plot_variables_index{i}==1
                m=m+1;
                Data.GUI.plot_variables_list{m}=Data.XBoutput.variable_names{i};
            end
        end
        set(lb2,'string', Data.GUI.plot_variables_list);
        if Data.GUI.number_plot_variables>0
            set(dd,'enable','off');
            set(pb2,'enable','on');
            if or(length(Data.GUI.plot_xrange)<2,length(Data.GUI.plot_yrange)<2)
                set(plothandlebuttons1D,'enable','on');
                %                 set(plot1e,'enable','on');
                set(plothandlebuttons23D,'enable','off');
                %                 set(plot3b,'enable','off');
            else
                set(plothandlebuttons1D,'enable','off');
                %                 set(plot1e,'enable','off');
                set(plothandlebuttons23D,'enable','on');
                %                 set(plot3b,'enable','on');
            end
        else
            set(dd,'enable','on');
            set(pb2,'enable','off');
            set(plothandlebuttons1D,'enable','off');
            %             set(plot1e,'enable','off');
            set(plothandlebuttons23D,'enable','off');
            %             set(plot3b,'enable','off');
        end
    end

    function update_show_variables_list(type)
        set(lb1,'Value',1);
        Data.GUI.show_variables_list={};
        m=0;
        for i=1:Data.XBoutput.number_variables
            if and(Data.XBoutput.variables_type{i}==type,Data.GUI.plot_variables_index{i}==0)
                m=m+1;
                Data.GUI.show_variables_list{m}=Data.XBoutput.variable_names{i};
            end
        end
        set(lb1,'string',Data.GUI.show_variables_list);
        if m==0
            set(pb1,'enable','off');
        else
            set(pb1,'enable','on');
        end
    end

    function [names,xdata,ydata,tdata,senddata]=collect_data_for_plot
        m=0;
        for i=1:Data.XBoutput.number_variables
            if Data.GUI.plot_variables_index{i}==1
                m=m+1;
                names{m}=Data.XBoutput.variable_names{i};
            end
        end

        senddata=zeros(length(Data.GUI.plot_xrange),length(Data.GUI.plot_yrange),length(Data.GUI.plot_trange),Data.GUI.number_plot_variables);
        xdata=Data.XBoutput.XBdims.x(Data.GUI.plot_xrange,Data.GUI.plot_yrange);
        ydata=Data.XBoutput.XBdims.y(Data.GUI.plot_xrange,Data.GUI.plot_yrange);
        switch Data.GUI.show_variables_type
            case 1
                tdata=Data.XBoutput.XBdims.tsglobal(Data.GUI.plot_trange);
            case 2
                tdata=Data.XBoutput.XBdims.tsmean(Data.GUI.plot_trange);
        end
        for i=1:Data.GUI.number_plot_variables
            tempdata=[];
            tempdata=0;
            eval(['tempdata=Data.XBoutput.' names{i} ';']);
            senddata(:,:,:,i)=tempdata(Data.GUI.plot_xrange,Data.GUI.plot_yrange,Data.GUI.plot_trange);
        end
    end

    function coloraxis2D(names)

        defcolormaps={
            'do not fill, this is a dummy';
            'autumn';
            'bone';
            'colorcube';
            'cool';
            'copper';
            'flag';
            'gray';
            'hot';
            'hsv';
            'jet';
            'lines';
            'pink';
            'prism';
            'spring';
            'summer';
            'white';
            'winter';

            };



        if ishandle(Data.GUI.fighandles.fs1)
            close(Data.GUI.fighandles.fs1);
        end
        userowheightex=0.03;
        novars=length(names);
        figheight=min(4*userowheightex+userowheightex*novars,0.5);
        rowheight=1/(novars+4);
        Data.GUI.fighandles.fs1=figure('Visible','on','Name','Color limits options','MenuBar','none',...
            'NumberTitle','off','Units','normalized','position',[0.62 0.4 0.3 figheight]);

        uicontrol(Data.GUI.fighandles.fs1,...
            'style','text','units','normalized','string','Color limits and colormap options',...
            'position',[0.1 1-1.5*rowheight 0.7 rowheight],'BackgroundColor',Data.GUI.bgc);

        for i=1:novars
            th(i)= uicontrol(Data.GUI.fighandles.fs1,...
                'style','text','units','normalized','string',names{i},...
                'position',[0.1 (1-2*rowheight)-i*rowheight 0.25 0.7*rowheight],...
                'BackgroundColor',Data.GUI.bgc);
            writeval=[];
            eval(['writeval=Data.GUI.caxis.' names{i} ';']);
            if isnumeric(writeval)
                writeval=num2str(writeval);
            end
            eh(i)= uicontrol(Data.GUI.fighandles.fs1,...
                'style','edit','units','normalized','string',writeval,...
                'position',[0.4 (1-2*rowheight-0.025)-i*rowheight+0.25*rowheight 0.15 0.8*rowheight],...
                'BackgroundColor','w');

            chosenval='';
            eval(['chosenval=Data.GUI.colormap.' names{i} ';']);
            defcolormaps{1}=chosenval;

            dh(i)=uicontrol(Data.GUI.fighandles.fs1,...
                'style','popupmenu','units','normalized','string',defcolormaps,...
                'position',[0.6 (1-2*rowheight-0.025)-i*rowheight+0.25*rowheight 0.2 0.8*rowheight],...
                'BackgroundColor','w');


        end

        okb =  uicontrol(Data.GUI.fighandles.fs1,...
            'style','pushbutton','units','normalized','string','Accept',...
            'position',[0.35 0.1 0.3 0.9*rowheight],'Callback',{@accept_coloraxis});

        function accept_coloraxis(hObject,eventdata)

            for i=1:length(eh)
                readval = strtrim(get(eh(i),'string'));
                if ~strcmpi(readval,'auto')
                    readval=str2num(readval);
                    eval(['Data.GUI.caxis.' names{i} '=readval;']);
                end
                listcols=strtrim(get(dh(i),'string'));
                readval =listcols{get(dh(i),'value')};
                eval(['Data.GUI.colormap.' names{i} '=readval;']);

            end
            close(Data.GUI.fighandles.fs1);

        end

    end

end
