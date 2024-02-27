function gui_setElement(h)
% Sets correct value for GUI element

% Check whether input is handle or tag
if ischar(h)
    h=findobj(gcf,'Tag',h);
end

if isempty(h)
    warning(['Error setting element ' h]);
    return
end

el=getappdata(h,'element');

switch lower(el.style)
    
    %% Standard elements
    
    case{'edit'}

        val=gui_getValue(el,el.variable);
        tp=lower(el.type);

        switch tp
            case{'string'}
            case{'datetime'}
                val=datestr(val,'yyyy mm dd HH MM SS');
            case{'date'}
                val=datestr(val,'yyyy mm dd');
            case{'time'}
                val=datestr(val,'HH MM SS');
            otherwise
                if isnan(val)
                    val='';
                else
                    if ~isempty(el.format)
                        val=num2str(val,el.format);
                    else
                        val=num2str(val);
                    end
                end
        end
        set(el.handle,'String',val);

        % Set text
        if ~isempty(el.text)
            if isfield(el.text,'text')
                val=gui_getValue(el,el.text.text.variable);
                % Text
                set(el.texthandle,'String',val);
                setTextPosition(el.texthandle,el.position,el.textposition);
            end
        end
        
    case{'checkbox'}

        val=gui_getValue(el,el.variable);
        set(el.handle,'Value',val);
        % Set text
        if ~isempty(el.text)
            if isfield(el.text,'text')
                val=gui_getValue(el,el.text.text.variable);
                % Text
                set(el.handle,'String',val);
                % Length of string is known
                pos=get(el.handle,'Position');
                ext=get(el.handle,'Extent');
                pos(3)=ext(3)+20;
                pos(4)=20;                
                set(el.handle,'Position',pos);
            end
        end
        
    case{'togglebutton'}

        val=gui_getValue(el,el.variable);
        set(el.handle,'Value',val);

    case{'radiobutton'}

        val=gui_getValue(el,el.variable);        
        tp=lower(el.type);

        switch lower(tp)
            case{'string'}
                if strcmpi(deblank(el.value),deblank(val))
                    set(el.handle,'Value',1);
                else
                    set(el.handle,'Value',0);
                end
            otherwise
                if str2double(el.value)==val
                    set(el.handle,'Value',1);
                else
                    set(el.handle,'Value',0);
                end
        end
        
        if isfield(el.text,'text')
            val=gui_getValue(el,el.text.text.variable);
            % Text
            set(el.handle,'String',val);
        end

    case{'listbox','popupmenu'}

        % Texts
        if isstruct(el.listtext)
            if isfield(el.listtext(1).listtext,'variable')
                stringlist=gui_getValue(el,el.listtext(1).listtext.variable);
            else
                for jj=1:length(el.listtext)
                    stringlist{jj}=el.listtext(jj).listtext;
                end
            end
        else
            stringlist=gui_getValue(el,el.listtext);
        end
        
        ii=1;
        if isempty(stringlist)
            ii=1;
        elseif isempty(stringlist{1})
            ii=1;
        else           
            if ~isempty(el.type)
                tp=lower(el.type);
            else
                tp=lower(el.variable.type);
            end
            switch tp
                case{'string'}

                    % Values
                    if ~isempty(el.listvalue)
                        % Values prescribed in xml file
                        if isstruct(el.listvalue)
                            if isfield(el.listvalue(1).listvalue,'variable')
                                values=gui_getValue(el,el.listvalue.listvalue.variable);
                            else
                                for jj=1:length(el.listvalue)
                                    values{jj}=el.listvalue(jj).listvalue;
                                end
                            end
                        else
                            values{1}=gui_getValue(el,el.listvalue);
                        end
                    else
                        % Values are the same as the string list
                        values=stringlist;
                    end
                    
                    if isfield(el,'variable')
                        if ~isempty(el.variable)
                            str=gui_getValue(el,el.variable);
                            if isempty(str)
                              if isfield(el,'defaultvalue')
                                str=el.defaultvalue;
                              end
                            end                            
                            if ~isempty(str)
                                ii=strmatch(lower(str),lower(values),'exact');
                            else
                                ii=1;
                            end
                        end
                    end
                    
                otherwise
                    
                    if ~isempty(el.multivariable)
                        % Not sure anymore what this multivariable is
                        % supposed to do ...
                        ii=gui_getValue(el,el.multivariable);
                    else                        
                        % Values
                        if ~isempty(el.listvalue)
                            % Values prescribed in xml file
                            if isstruct(el.listvalue)
                                if isfield(el.listvalue(1).listvalue,'variable')
                                    values=gui_getValue(el,el.listvalue.listvalue.variable);
                                else
                                    for jj=1:length(el.listvalue)
                                        values(jj)=str2double(el.listvalue(jj).listvalue);
                                    end
                                end
                            else
                                values=str2double(el,el.listvalue);
                            end
                            val=gui_getValue(el,el.variable);
                            ii=find(values==val,1,'first');
                        else
                            ii=gui_getValue(el,el.variable);
                        end
                    end
            end
        end
        set(el.handle,'Value',ii);
        set(el.handle,'String',stringlist);

    case{'selectcolor'}
        % For colorlists etc
        values=get(el.handle,'String');
        str=gui_getValue(el,el.variable);
        ii=strmatch(lower(str),lower(values),'exact');
        set(el.handle,'Value',ii);

    case{'selectmarker'}
        % For colorlists etc
        values={'.','o','x','+','*','s','d','v','^','<','>','p','h','none'};
        str=gui_getValue(el,el.variable);
        ii=strmatch(lower(str),lower(values),'exact');
        set(el.handle,'Value',ii);

    case{'selectmarkersize'}
        ii=gui_getValue(el,el.variable);
        set(el.handle,'Value',ii);

    case{'selectheadstyle'}
        % For colorlists etc
        values=get(el.handle,'String');
        str=gui_getValue(el,el.variable);
        ii=strmatch(lower(str),lower(values),'exact');
        set(el.handle,'Value',ii);
        
    case{'selectlinestyle'}
        % For colorlists etc
        values={'-','--','-.',':','none'};
        str=gui_getValue(el,el.variable);
        ii=strmatch(lower(str),lower(values),'exact');
        set(el.handle,'Value',ii);
        
    case{'text'}
        
        if isfield(el,'variable')

            if ~isempty(el.variable)

                pos=el.position;
                set(el.handle,'Position',[pos(1) pos(2) 1000 15]);

                val=gui_getValue(el,el.variable);

                tp=lower(el.type);

                switch tp
                    case{'string'}
                    otherwise
                        val=num2str(val);
                end
                
                if iscell(val)
                    str=val;
                else
                    str=[el.prefix ' ' val ' ' el.suffix];
                end
                set(el.handle,'String',str);
                
                ext=get(el.handle,'Extent');
                if iscell(val)
                    pos(2)=pos(2)+pos(4)-ext(4);
                end
                pos(3)=min(pos(3),ext(3));
                pos(4)=15;
                set(el.handle,'Position',pos);
            end
        end

    case{'panel'}

        if ~isempty(el.text)
            if isfield(el.text,'text')
                val=gui_getValue(el,el.text.text.variable);
                % Text
                set(el.handle,'Title',val);
            end
        end
        
    %% Custom elements
        
    case{'pushselectfile'}
        if el.showfilename
           if el.fullpath 
               val=gui_getValue(el,el.variable);
           else
               val=gui_getValue(el,el.variable);
               [filepath,name,ext] = fileparts(val);
               val=[name ext];
           end
           set(el.texthandle,'enable','on','String',['File : ' val]);
           pos=get(el.texthandle,'position');
           ext=get(el.texthandle,'Extent');
           pos(3)=ext(3);
           pos(4)=15;
           set(el.texthandle,'Position',pos);
        end
                      
    case{'pushsavefile'}
        if el.showfilename
            val=gui_getValue(el,el.variable);
            set(el.texthandle,'enable','on','String',['File : ' val]);
            pos=get(el.texthandle,'position');
            ext=get(el.texthandle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(el.texthandle,'Position',pos);
        end

    case{'selectcoordinatesystem'}
        val=gui_getValue(el,el.variable);
        str=[val.name];
        set(el.texthandle,'String',str);
        switch lower(val.type)
            case{'projected'}
                set(el.prjhandle,'Value',1);
                set(el.geohandle,'Value',0);
            case{'geographic'}
                set(el.prjhandle,'Value',0);
                set(el.geohandle,'Value',1);
        end
        
    case{'table'}
        % Determine number of rows in table
        for j=1:length(el.column)
            val=gui_getValue(el,el.column(j).column.variable);
            switch lower(el.column(j).column.style)
                case{'editreal','checkbox','edittime'}
                    % Reals must be a vector
                    sz=size(val);
                    nrrows=max(sz);
                case{'editstring','text','popupmenu'}
                    % Strings must be cell array
                    nrrows=length(val);
            end
        end
        
        nrrows=max(nrrows,1);
        
        % Determine string list in case of popup menu
        ipopup=0;
        for j=1:length(el.column)
            popupText{j}={' '};
            switch lower(el.column(j).column.style)
                case{'popupmenu'}
                    ipopup=1;
                    popupText{j}=gui_getValue(el,el.column(j).column.listtext(1).listtext.variable);
            end
        end
        
        % Now set the data
        for j=1:length(el.column)
            val=gui_getValue(el,el.column(j).column.variable);
            for k=1:nrrows
                switch lower(el.column(j).column.style)
                    case{'editreal'}
                        data{k,j}=val(k);
                    case{'edittime'}
                        data{k,j}=val(k);
                    case{'editstring'}
                        data{k,j}=val{k};
                    case{'popupmenu'}
                        data{k,j}=val(k);
                    case{'checkbox'}
                        data{k,j}=val(k);
                    case{'pushbutton'}
                        data{k,j}=[];
                    case{'text'}
                        data{k,j}=val{k};
                end
            end
        end
        if ipopup
            gui_table(el.handle,'refresh','popuptext',popupText);
        end
        gui_table(el.handle,'setdata',data);
end

% And now update the dependency of this element
gui_updateDependency(h);
