function gui_updateDependency(h)

% Updates element settings based on dependencies

element=getappdata(h,'element');

switch element.style
    case{'tabpanel'}
        for itab=1:length(element.tab)
            el=element.tab(itab).tab;
            if isfield(el,'dependency')
                el.handle=element.handle;
                el.style='tab';
                update(el);
            end
        end
    otherwise
        if isfield(element,'dependency')
            update(element);
        end
end

function update(element)

for iac=1:length(element.dependency);
    
    dependency=element.dependency(iac).dependency;
    
    ok=gui_checkDependency(dependency,element);
    
    switch lower(dependency.action)
        case{'enable'}
            if ok
                switch element.style
                    case{'table'}
                        gui_table(element.handle,'enable');
                    case{'tab'}
                        tabpanel('enabletab','handle',element.handle,'tabname',element.tabstring);
                    otherwise
                        enableElement(element);
                end
            else
                switch element.style
                    case{'table'}
                        gui_table(element.handle,'disable');
                    case{'tab'}
                        tabpanel('disabletab','handle',element.handle,'tabname',element.tabstring);
                    otherwise
                        disableElement(element);
                end
            end
        case{'on'}
            if ok
                turnOn(element);
            else
                turnOff(element);
            end
%         case{'update'}
%             setUIElement(element.handle,'dependencyupdate',0);
        case{'visible'}
            if ok
                setVisible(element);
            else
                setInvisible(element);
            end
            
    end
    
end
        
%%
function enableElement(element)
set(element.handle,'Enable','on');
if ~isempty(element.texthandle)
    set(element.texthandle,'Enable','on');
end

%%
function disableElement(element)
set(element.handle,'Enable','off');
if ~isempty(element.texthandle)
    set(element.texthandle,'Enable','off');
end

%%
function setVisible(element)
set(element.handle,'Visible','on');
if ~isempty(element.texthandle)
    set(element.texthandle,'Visible','on');
end

%%
function setInvisible(element)
set(element.handle,'Visible','off');
if ~isempty(element.texthandle)
    set(element.texthandle,'Visible','off');
end

%%
function turnOn(element)
set(element.handle,'Value',1);

%%
function turnOff(element)
set(element.handle,'Value',0);

%%

