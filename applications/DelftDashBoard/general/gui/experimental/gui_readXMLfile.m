function xml=gui_readXMLfile(xmlfile,dr,varargin)
% Read UI xml file and store elements in structure xml

lowerlevel=0;
fillguivalues=1;
readlowerlevel=1;

variableprefix=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'variableprefix'}
                variableprefix=varargin{ii+1};
            case{'lowerlevel'}
                lowerlevel=varargin{ii+1};
            case{'fillguivalues'}
                fillguivalues=varargin{ii+1};
            case{'readlowerlevel'}
                readlowerlevel=varargin{ii+1};
        end
    end
end

xml=[];

try
    xml=xml2struct([dr filesep xmlfile],'structuretype','short');
%    xml=xml2struct([dr xmlfile],'structuretype','short');
%    xml=xml2struct(xmlfile,'structuretype','short');
catch
    error(['Error in readGUIElementsXML. Could not load xml file ' dr xmlfile]);
end

% Convert to new format !!!
xml=convertalltonewformat(xml);

if isfield(xml,'element')

  element=xml.element;
  
  for k=1:length(element)
    
    switch element(k).element.style
      
      case{'tabpanel'}
        for j=1:length(element(k).element.tab)
          if isfield(element(k).element.tab(j).tab,'element')
            if ischar(element(k).element.tab(j).tab.element)
              % Elements in separate xml file
              if readlowerlevel
                  xmlfile2=element(k).element.tab(j).tab.element;
                  newelement=gui_readXMLfile(xmlfile2,dr,'lowerlevel',3);
                  element(k).element.tab(j).tab.element = newelement;
              end
            else
              element(k).element.tab(j).tab=convertalltonewformat(element(k).element.tab(j).tab);
            end
          end
        end
    end
    
  end
  
end

if lowerlevel
    xml=element;
else
  if isfield(xml,'element')
    xml.element=element;
  end
    % And now finish off xml structure
    if fillguivalues
        xml=gui_fillXMLvalues(xml,'variableprefix',variableprefix);
    end
end

%%
function s=converttonewformat(s,v1,v2)
if isfield(s,v1)
%    for ii=1:length(s.(v1))
    for ii=1:length(s.(v1).(v1).(v2))
        s.(v2)(ii).(v2)=s.(v1).(v1).(v2)(ii).(v2);
    end
    s=rmfield(s,v1);
end

%%
function xml=convertalltonewformat(xml)

xml=converttonewformat(xml,'elements','element');
xml=converttonewformat(xml,'options','option');

if isfield(xml,'element')
    
    for ielm=1:length(xml.element)
        
        % Columns
        xml.element(ielm).element=converttonewformat(xml.element(ielm).element,'columns','column');
        
        % Tabs
        switch xml.element(ielm).element.style
          case{'tabpanel'}
            xml.element(ielm).element=converttonewformat(xml.element(ielm).element,'tabs','tab');
            for j=1:length(xml.element(ielm).element.tab)
              xml.element(ielm).element.tab(j).tab=renamefield(xml.element(ielm).element.tab(j).tab,'elements','element');
            end
        end

        % List
        if isfield(xml.element(ielm).element,'list')
          xml.element(ielm).element=convertlist(xml.element(ielm).element);
        end
        if strcmpi(xml.element(ielm).element.style,'table')
          for jj=1:length(xml.element(ielm).element.column)
            if isfield(xml.element(ielm).element.column(jj).column,'list')
              xml.element(ielm).element.column(jj).column=convertlist(xml.element(ielm).element.column(jj).column);
            end
          end
        end

        % Dependencies
        xml.element(ielm).element=converttonewformat(xml.element(ielm).element,'dependencies','dependency');
        if isfield(xml.element(ielm).element,'dependency')
            for ii=1:length(xml.element(ielm).element.dependency)
                xml.element(ielm).element.dependency(ii).dependency=converttonewformat(xml.element(ielm).element.dependency(ii).dependency,'checks','check');
            end
            if isfield(xml.element(ielm).element.dependency(ii).dependency,'tags')
                xml.element(ielm).element.dependency(ii).dependency=rmfield(xml.element(ielm).element.dependency(ii).dependency,'tags');
            end
        end
        

    end
end

%
function el=convertlist(el)
if isfield(el.list.list,'texts')
    if isfield(el.list.list.texts.texts,'variable')
        el.listtext.listtext.variable=el.list.list.texts.texts.variable;
    else
        if isstruct(el.list.list.texts.texts.text)
            for ii=1:length(el.list.list.texts.texts.text)
                el.listtext(ii).listtext=el.list.list.texts.texts.text(ii).text;
            end
        else
            el.listtext(1).listtext=el.list.list.texts.texts.text;
        end
    end
end
if isfield(el.list.list,'values')
    if isfield(el.list.list.values.values,'variable')
        el.listvalue.listvalue.variable=el.list.list.values.values.variable;
    else
        if isstruct(el.list.list.values.values.value)
            for ii=1:length(el.list.list.values.values.value)
                el.listvalue(ii).listvalue=el.list.list.values.values.value(ii).value;
            end
        else
            el.listvalue(1).listvalue=el.list.list.values.values.value;
        end
    end
end
el=rmfield(el,'list');
