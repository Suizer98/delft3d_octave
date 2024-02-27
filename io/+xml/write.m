function varargout = write( s, varargin )
%Convert a MATLAB structure into a xml file 
% Reads xml file into a MATLAB structure
%
%   Function is modified to a namespace function.
%   Plus in 20191209 the options are added. 
%   The original function was hosted in Matlab File Exchange: 
%       struct2xml.m
%
%   A structure containing:
%       s.XMLname.Attributes.attrib1 = "Some value";
%       s.XMLname.Element.Text = "Some text";
%       s.XMLname.DifferentElement{1}.Attributes.attrib2 = "2";
%       s.XMLname.DifferentElement{1}.Text = "Some more text";
%       s.XMLname.DifferentElement{2}.Attributes.attrib3 = "2";
%       s.XMLname.DifferentElement{2}.Attributes.attrib4 = "1";
%       s.XMLname.DifferentElement{2}.Text = "Even more text";
%
%   Will produce:
%       <XMLname attrib1="Some value">
%           <Element>Some text</Element>
%           <DifferentElement attrib2="2">Some more text</Element>
%           <DifferentElement attrib3="2" attrib4="1">Even more text</DifferentElement>
%       </XMLname>
%
%   Please note that the following strings are substituted
%   '_dash_' by '-', '_colon_' by ':' and '_dot_' by '.'
%
%   Syntax:  [ ] = xml.write( s, file )
%            [ ] = xml.write( s, file, OPT)
%            xml = xml.write( s )
%            xml = xml.write( s, '', OPT)
%
%   Input:      s    = structure with data
%               file = output filename of xml file
%
%   Output:     xmlfile when given  
%               xml  = xml text

% --------------------------------------------------------------------
%   $Id: votemplate.m 5290 2015-12-08 11:33:47Z rho@vanoord.com $
%   $HeadURL: svn://10.12.184.200/votools/trunk/matlab/general/vo_template/votemplate.m $
%   $Keywords:
% --------------------------------------------------------------------

% --------------------------------------------------------------------
%   Copyright (C) and credits: See below code
% --------------------------------------------------------------------
    % Default options
    defaultOPT.remove_multiple_white_spaces = true;
    defaultOPT.onExtraField = 'silentIgnore';
    
    if (nargin <2)  % (nargin ~= 2)
        if(nargout ~= 1 || nargin ~= 1)
            error(['Supported function calls:' sprintf('\n')...
                   '[ ] = struct2xml( s, file )' sprintf('\n')...
                   'xml = struct2xml( s )']);
        end
    end

    if (nargin >=2)  % (nargin == 2)
        file = varargin{1};

%         if (isempty(file))
%             error('Filename can not be empty');
%         end

        if ~isempty(file)
            if (isempty(strfind(file,'.xml')))
                file = [file '.xml'];
            end
        end
    end
    if (nargin >2)
        OPT = varargin{2:end};
        % overrule default settings by property pairs, given in varargin
        OPT = setproperty(defaultOPT, OPT); % ,'onExtraField', 'silentIgnore');
    else
        OPT = defaultOPT;
    end
    
    if (~isstruct(s))
        error([inputname(1) ' is not a structure']);
    end
    
    if (length(fieldnames(s)) > 1)
        error(['Error processing the structure:' sprintf('\n') 'There should be a single field in the main structure.']);
    end
    xmlname = fieldnames(s);
    xmlname = xmlname{1};
    
    %substitute special characters
    xmlname_sc = xmlname;
    xmlname_sc = strrep(xmlname_sc,'_dash_','-');
    xmlname_sc = strrep(xmlname_sc,'_colon_',':');
    xmlname_sc = strrep(xmlname_sc,'_dot_','.');

    %create xml structure
    docNode = com.mathworks.xml.XMLUtils.createDocument(xmlname_sc);

    %process the rootnode
    docRootNode = docNode.getDocumentElement;

    %append childs
    parseStruct(s.(xmlname),docNode,docRootNode,[inputname(1) '.' xmlname '.'],OPT);

    if(nargout == 0)
        %save xml file
        if ~isempty(file)
            xmlwrite(file,docNode);
        end
    else
        varargout{1} = xmlwrite(docNode);
    end  
end

% ----- Subfunction parseStruct -----
function [] = parseStruct(s,docNode,curNode,pName,OPT)
    
    fnames = fieldnames(s);
    for i = 1:length(fnames)
        curfield = fnames{i};
        
        %substitute special characters
        curfield_sc = curfield;
        curfield_sc = strrep(curfield_sc,'_dash_','-');
        curfield_sc = strrep(curfield_sc,'_colon_',':');
        curfield_sc = strrep(curfield_sc,'_dot_','.');
        
        if (strcmp(curfield,'Attributes'))
            %Attribute data
            if (isstruct(s.(curfield)))
                attr_names = fieldnames(s.Attributes);
                for a = 1:length(attr_names)
                    cur_attr = attr_names{a};
                    
                    %substitute special characters
                    cur_attr_sc = cur_attr;
                    cur_attr_sc = strrep(cur_attr_sc,'_dash_','-');
                    cur_attr_sc = strrep(cur_attr_sc,'_colon_',':');
                    cur_attr_sc = strrep(cur_attr_sc,'_dot_','.');
                    
                    [cur_str,succes] = val2str(s.Attributes.(cur_attr),OPT);
                    if (succes)
                        curNode.setAttribute(cur_attr_sc,cur_str);
                    else
                        disp(['Warning. The text in ' pName curfield '.' cur_attr ' could not be processed.']);
                    end
                end
            else
                disp(['Warning. The attributes in ' pName curfield ' could not be processed.']);
                disp(['The correct syntax is: ' pName curfield '.attribute_name = ''Some text''.']);
            end
        elseif (strcmp(curfield,'Text'))
            %Text data
            [txt,succes] = val2str(s.Text,OPT);
            if (succes)
                curNode.appendChild(docNode.createTextNode(txt));
            else
                disp(['Warning. The text in ' pName curfield ' could not be processed.']);
            end
        else
            %Sub-element
            if (isstruct(s.(curfield)))
                %single element
                curElement = docNode.createElement(curfield_sc);
                curNode.appendChild(curElement);
                parseStruct(s.(curfield),docNode,curElement,[pName curfield '.'],OPT)
            elseif (iscell(s.(curfield)))
                %multiple elements
                for c = 1:length(s.(curfield))
                    curElement = docNode.createElement(curfield_sc);
                    curNode.appendChild(curElement);
                    if (isstruct(s.(curfield){c}))
                        parseStruct(s.(curfield){c},docNode,curElement,[pName curfield '{' num2str(c) '}.'],OPT)
                    else
                        disp(['Warning. The cell ' pName curfield '{' num2str(c) '} could not be processed, since it contains no structure.']);
                    end
                end
            else
                %eventhough the fieldname is not text, the field could
                %contain text. Create a new element and use this text
                curElement = docNode.createElement(curfield_sc);
                curNode.appendChild(curElement);
                [txt,succes] = val2str(s.(curfield),OPT);
                if (succes)
                    curElement.appendChild(docNode.createTextNode(txt));
                else
                    disp(['Warning. The text in ' pName curfield ' could not be processed.']);
                end
            end
        end
    end
end

%----- Subfunction val2str -----
function [str,succes] = val2str(val,OPT)
    
    succes = true;
    str = [];
    
    if (isempty(val))
        return; %bugfix from H. Gsenger
    elseif (ischar(val))
        %do nothing
    elseif (isnumeric(val) || islogical(val))
        val = num2str(val);
    else
        succes = false;
    end
    
    if (ischar(val))
        %add line breaks to all lines except the last (for multiline strings)
        lines = size(val,1);
        val = [val char(sprintf('\n')*[ones(lines-1,1);0])];
        
        %transpose is required since indexing (i.e., val(nonspace) or val(:)) produces a 1-D vector. 
        %This should be row based (line based) and not column based.
        valt = val';
        
        %remove_multiple_white_spaces = true;
        if (OPT.remove_multiple_white_spaces)
            %remove multiple white spaces using isspace, suggestion of T. Lohuis
            whitespace = isspace(val);
            nonspace = (whitespace + [zeros(lines,1) whitespace(:,1:end-1)])~=2;
            nonspace(:,end) = [ones(lines-1,1);0]; %make sure line breaks stay intact
            str = valt(nonspace');
        else
            str = valt(:);
        end
    end
end


% ------------------------------------------------------------------------
% Original code:
%   Written by W. Falkena, ASTI, TUDelft, 27-08-2010
%   On-screen output functionality added by P. Orth, 01-12-2010
%   Multiple space to single space conversion adapted for speed by T. Lohuis, 11-04-2011
%   Val2str subfunction bugfix by H. Gsenger, 19-9-2011
% ------------------------------------------------------------------------

% --------------------------------------------------------------------
%   Copyright (C) 2017 Van Oord, RHO@vanoord.com
%
%   This library is copyrighted Van Oord software intended for internal
%   use only: you cannot redistribute it outside of Van Oord.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. In case of
%   errors or suggestions, refer to the central HeadURL address below.
% --------------------------------------------------------------------
