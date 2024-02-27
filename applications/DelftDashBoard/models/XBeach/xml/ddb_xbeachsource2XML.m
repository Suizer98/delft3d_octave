function ddb_xbeachsource2XML
%DDB_XBEACHSOURCE2XML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_xbeachsource2XML
%
%   Input:

%
%
%
%
%   Example
%   ddb_xbeachsource2XML
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl
%
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Dec 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: ddb_xbeachsource2XML.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/XBeach/xml/ddb_xbeachsource2XML.m $
% $Keywords: $

%% Options
XMLmat='off';

%% XML directory
xmlp=[fileparts(mfilename('fullpath')) filesep];

%% Remove old xmls
delete([xmlp '*.xml']);

%% Read XBeach source code
% normal input
[par params_array] = xb_get_params;

% rearrange to format for DDB
Par=struct('Physics',struct,...
    'Domain',struct',...
    'Time',struct,...
    'Waves',struct,...
    'Flow',struct,...
    'Sediment',struct,...
    'Morphology',struct,...
    'Output',struct,...
    'Advanced',struct);
Par.Physics.longname='Model physics';
Par.Domain.longname='Model domain';
Par.Time.longname='Time input';
Par.Waves.longname='Wave input';
Par.Flow.longname='Flow input';
Par.Sediment.longname='Sediment input';
Par.Morphology.longname='Morphology input';
Par.Output.longname='Output options';
Par.Advanced.longname='Advanced input';

for i=1:length(params_array)
    ptype=params_array(i).partype;
    ptypevar=genvarname(ptype,{'ptype','ptypevar','Par','params_array','i'});
    if ~isempty(regexpi(ptype,'physical'))
        chapter='Physics';
    elseif ~isempty(regexpi(ptype,'(grid|initial)'))
        chapter='Domain';
    elseif ~isempty(regexpi(ptype,'time'))
        chapter='Time';
    elseif ~isempty(regexpi(ptype,'(wave|roller)'))
        chapter='Waves';
    elseif ~isempty(regexpi(ptype,'(flow|coriolis|wind|tide|discharge)'))
        chapter='Flow';
    elseif ~isempty(regexpi(ptype,'sediment')) && isempty(regexpi(ptype,'q3d'))
        chapter='Sediment';
    elseif ~isempty(regexpi(ptype,'(morphology|bed\s)'))
        chapter='Morphology';
    elseif ~isempty(regexpi(ptype,'(output|drifter)'))
        chapter='Output';
    else
        chapter='Advanced';
    end
    if ~isfield(Par.(chapter),ptypevar);
        temp=struct('longname',ptype,'variables',struct());
        Par.(chapter).(ptypevar)=temp;
    end
    vname = genvarname(params_array(i).name,{'vname','ptypevar','Par','params_array','i','chapter'});
    Par.(chapter).(ptypevar).variables.(vname)=params_array(i);
end

% remove useless information from Par
fields=fieldnames(Par.Advanced);
for i=1:length(fields)
    if isfield(Par.Advanced.(fields{i}),'longname') & ...
            regexpi(Par.Advanced.(fields{i}).longname,'not read in params.txt')
        Par.Advanced=rmfield(Par.Advanced,fields{i});
    end
end

%% write XML master file

HS = struct;
HS.model='XBeach';
HS.longname='XBeach';
HS.elements.element.style='tabpanel';
HS.elements.element.tag='XBeach';
HS.elements.element.position=[10 10 1200 700];
HS.elements.element.tabs(1).tab.tag='Toolbox';
HS.elements.element.tabs(1).tab.tabstring='Toolbox';
HS.elements.element.tabs(1).tab.callback='ddb_selectToolbox';
HS.elements.element.tabs(2).tab.tag='Description';
HS.elements.element.tabs(2).tab.tabstring='Description';
% HS.elements.element.tabs(2).tab.callback='ddb_editXBeachDescription';
HS.elements.element.tabs(2).tab.elements='XBeach.description.xml';
fields=fieldnames(Par);
for i=1:length(fields)
    HS.elements.element.tabs(i+2).tab.tag=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.tabstring=Par.(fields{i}).longname;
    HS.elements.element.tabs(i+2).tab.elements=['XBeach.' fields{i} '.xml'];
end
HS.menu.menuopenfile.menuitem.string='Open Params File';
HS.menu.menuopenfile.menuitem.callback='ddb_editXBeachDescription';
HS.menu.menuopenfile.menuitem.option='open';
HS.menu.menusavefile(1).menuitem.string='Save Params File';
HS.menu.menusavefile(1).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(1).menuitem.option='save';
HS.menu.menusavefile(2).menuitem.string='Save Params File As ...';
HS.menu.menusavefile(2).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(2).menuitem.option='save';
HS.menu.menusavefile(3).menuitem.string='Save All';
HS.menu.menusavefile(3).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(3).menuitem.option='save';
HS.menu.menusavefile(4).menuitem.string='Save All As ...';
HS.menu.menusavefile(4).menuitem.callback='ddb_editXBeachDescription';
HS.menu.menusavefile(4).menuitem.option='save';

% save to file
xml_save([xmlp 'XBeach.xml'],HS,XMLmat);

%% Write XML Toolbox file


%% Write XML description file
DES=struct;
DES.element.tag='editdescription';
DES.element.style='edit';
DES.element.position=[45 10 500 140];
DES.element.variable.name='Description';
DES.element.variable.type='string';
DES.element.tooltipstring='Project description (optional)';
DES.element.nrlines=10;
DES.element.text='Description (max. 10 lines)';
DES.element.textposition='above-left';

xml_save([xmlp 'XBeach.description.xml'],DES,XMLmat);

%% Write XML Physics etc. files (all but advanced)
index=fieldnames(Par);
for i=1:length(index)
    if ~strcmpi(index{i},'Advanced')
        S=struct;
        S.longname=Par.(index{i}).longname;
        S.element.style='tabpanel';
        S.element.tag=Par.(index{i}).longname;
        S.element.position=[10 10 1200 140];
%         pospanel = [2 2 S.element.position(3)-2 S.element.position(4)-10];
        % generate positions for elements
        % height and free space height factor
        he=20;hefac=1.2;
        % width and free space width factor
        we=80;wefac=2.0;
        % space around the edge of the tab
        xedge=60;yedge=15;
        % available height and width
%         ah = pospanel(4);
%         aw = pospanel(3);
        ah = S.element.position(4);
        aw = S.element.position(3);
%         nr=floor((S.element.position(4)-2*yedge)/(he*hefac));
%         nc=floor((S.element.position(3)-2*xedge)/(we*wefac));
        nr=floor((ah-2*yedge)/(he*hefac));
        nc=floor((aw-2*xedge)/(we*wefac));
        hefac=(ah-2*yedge)/nr/he;
        POS=cell(nr*nc,1);
        for ic=1:nc
            for ir=1:nr
                POS{(ic-1)*nr+ir}=[S.element.position(1)+xedge+(ic-1)*(we*wefac) ...
                    S.element.position(2)+S.element.position(4)-yedge-ir*(he*hefac) ...
                    we ...
                    he];
            end
        end
        index2=fieldnames(Par.(index{i}));count=0;
        for ii=1:length(index2)
            if ~strcmpi(index2{ii},'longname')
                % make internal for this part
                index3=fieldnames(Par.(index{i}).(index2{ii}).variables);
                count2=0;
                Sub=struct;
                Sub(1).element.tag='bogus';% fill with bogus
                Sub(1).element.style='text';
                Sub(1).element.text='empty';
                Sub(1).element.position=POS{1}(1:2);
                for iii=1:length(index3)
                    % is this not an advanced and is it read in XBeach and is it not deprecated?
                    if (Par.(index{i}).(index2{ii}).variables.(index3{iii}).advanced==0 && ...
                            Par.(index{i}).(index2{ii}).variables.(index3{iii}).noinstances>0) && ...
                            Par.(index{i}).(index2{ii}).variables.(index3{iii}).deprecated==0
                        % element number
                        count2=count2+1;
                        % element tag
                        Sub(count2).element.tag=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                        % element tooltip
                        Sub(count2).element.tooltipstring=[Par.(index{i}).(index2{ii}).variables.(index3{iii}).comment ' [' ...
                            Par.(index{i}).(index2{ii}).variables.(index3{iii}).units ']'];
                        % element type
                        makeElementType;  % nested subfunction
                        %
                    end
                end
                if ~strcmpi(Sub(1).element.tag,'bogus')
                    % save xml subtab
                    xml_save([xmlp 'XBeach.' index{i} '.' index2{ii} '.xml'],Sub,XMLmat);
                    % Make tabs in supertab
                    count=count+1;
                    S.element.tabs(count).tab.tag=Par.(index{i}).(index2{ii}).longname;
                    tstring = Par.(index{i}).(index2{ii}).longname;
                    if length(tstring)>23
                        tabstring=[tstring(1:20) '...'];
                    else
                        tabstring=tstring;
                    end
                    S.element.tabs(count).tab.tabstring=tabstring;
                    S.element.tabs(count).tab.tooltipstring=tstring;
                    S.element.tabs(count).tab.elements=['XBeach.' index{i} '.' index2{ii} '.xml'];
                end
            end
        end
        % Now we make one or more "advanced" tabs
        % how many advanced parameters are there?
        advanceparams={};
        for ii=1:length(index2)
            if ~strcmpi(index2{ii},'longname')
                index3=fieldnames(Par.(index{i}).(index2{ii}).variables);
                for iii=1:length(index3)
                    % is this an advanced and used?
                    if Par.(index{i}).(index2{ii}).variables.(index3{iii}).advanced==1 && ...
                        Par.(index{i}).(index2{ii}).variables.(index3{iii}).noinstances>0
                            advanceparams{end+1}=[i ii iii];
                    end
                end
            end
        end
        nrtabs=ceil(length(advanceparams)/length(POS));
        pstart=1;
        for itabs=1:nrtabs
            % make internal for this part
            count2=0;
            Sub=struct;
            Sub(1).element.tag='bogus';% fill with bogus
            Sub(1).element.style='text';
            Sub(1).element.text='empty';
            Sub(1).element.position=POS{1}(1:2);
            count2=0;
            for ip=pstart:min(pstart+length(POS)-1,length(advanceparams))
                ii=advanceparams{ip}(2);
                index3=fieldnames(Par.(index{i}).(index2{ii}).variables);
                iii=advanceparams{ip}(3);
                % element number
                count2=count2+1;
                % element tag
                Sub(count2).element.tag=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                % element tooltip
                Sub(count2).element.tooltipstring=[Par.(index{i}).(index2{ii}).variables.(index3{iii}).comment ' [' ...
                                                   Par.(index{i}).(index2{ii}).variables.(index3{iii}).units ']'];
                % element type
                makeElementType;
            end
            % save advanced tab
            xml_save([xmlp 'XBeach.' index{i} '.Advanced_' num2str(itabs) '.xml'],Sub,XMLmat);
            % Make tabs in supertab
            count=count+1;
            S.element.tabs(count).tab.tag=[index{i} '_advanced_options' num2str(itabs)];
            tstring = [index{i} ' advanced options'];
            if length(tstring)>23
                tabstring=[tstring(1:20) '...'];
            else
                tabstring=tstring;
            end
            S.element.tabs(count).tab.tabstring=tabstring;
            S.element.tabs(count).tab.tooltipstring=tstring;
            S.element.tabs(count).tab.elements=['XBeach.' index{i} '.Advanced_' num2str(itabs) '.xml'];
            pstart=pstart+length(POS);
        end
        % save process tab
        xml_save([xmlp 'XBeach.' index{i} '.xml'],S,XMLmat);
    end
end

%% Generate advanced tab
for i=1:length(index)
    if strcmpi(index{i},'Advanced')
        S=struct;
        S.longname=Par.(index{i}).longname;
        S.element.style='tabpanel';
        S.element.tag=Par.(index{i}).longname;
        S.element.position=[10 10 1200 140];
        index2=fieldnames(Par.(index{i}));count=0;
        for ii=1:length(index2)
            if ~strcmpi(index2{ii},'longname')
                % make internal for this part
                index3=fieldnames(Par.(index{i}).(index2{ii}).variables);
                count2=0;
                Sub=struct;
                Sub(1).element.tag='bogus';% fill with bogus
                Sub(1).element.style='text';
                Sub(1).element.text='empty';
                Sub(1).element.position=POS{1}(1:2);
                for iii=1:length(index3)
                    % is this read in XBeach and is it not deprecated?
                    if  Par.(index{i}).(index2{ii}).variables.(index3{iii}).noinstances>0 && ...
                            Par.(index{i}).(index2{ii}).variables.(index3{iii}).deprecated==0
                        % element number
                        count2=count2+1;
                        % element tag
                        Sub(count2).element.tag=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                        % element tooltip
                        Sub(count2).element.tooltipstring=[Par.(index{i}).(index2{ii}).variables.(index3{iii}).comment ' [' ...
                            Par.(index{i}).(index2{ii}).variables.(index3{iii}).units ']'];
                        % element type
                        makeElementType;  % nested subfunction
                        %
                    end
                end
                if ~strcmpi(Sub(1).element.tag,'bogus')
                    % save xml subtab
                    xml_save([xmlp 'XBeach.' index{i} '.' index2{ii} '.xml'],Sub,XMLmat);
                    % Make tabs in supertab
                    count=count+1;
                    S.element.tabs(count).tab.tag=Par.(index{i}).(index2{ii}).longname;
                    tstring = Par.(index{i}).(index2{ii}).longname;
                    if length(tstring)>23
                        tabstring=[tstring(1:20) '...'];
                    else
                        tabstring=tstring;
                    end
                    S.element.tabs(count).tab.tabstring=tabstring;
                    S.element.tabs(count).tab.tooltipstring=tstring;
                    S.element.tabs(count).tab.elements=['XBeach.' index{i} '.' index2{ii} '.xml'];
                end
            end
        end
        % save process tab
        xml_save([xmlp 'XBeach.' index{i} '.xml'],S,XMLmat);
    end
end


%% Generate initialization function for DDB-XBeach

fname = which('ddb_initializeXBeachInput.m');
if isempty(fname)
    fname = [oetroot fileparts('applications\DelftDashBoard\models\XBeach\initialize\') 'ddb_initializeXBeachInput.m'];
end

fid = fopen (fname,'w');
% add non-variable information:
% function name
fprintf(fid,'%s\n','function handles=ddb_initializeXBeachInput(handles,id,runid,varargin)');
% H1 line and help comments
fprintf(fid,'%s\n','% Initialization function for DelftDashboard-XBeach');
fprintf(fid,'%s\n',['% This function is generated automatically by ' mfilename]);
fprintf(fid,'%s\n',['% Last update was on ' datestr(now)]);
fprintf(fid,'%s\n','% Do not edit this file manually !');
fprintf(fid,'%s\n',['% Change generation in ' mfilename]);
% Fix some default parameters requires callback to subfunction (made
% further on in this script
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','% pick up defaults from autogen subfunction');
fprintf(fid,'%s\n','par=getdefaultpars;');
fprintf(fid,'%s\n','');
% Initial commands (are all these necessary?)
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).Description={''''};');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).Runid=runid;');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).AttName=handles.model.xbeach.domain(id).Runid;');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).ItDate=floor(now);');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).StartTime=floor(now);');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).StopTime=floor(now)+2;');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).TimeStep=1;');
fprintf(fid,'%s\n','handles.model.xbeach.domain(id).ParamsFile=[lower(cd) ''\\''];');
% now we go through all the parameters we have in XBeach params.F90 file
defaultsneeded={};
for i=1:length(params_array)
    if params_array(i).noinstances>0
        def = params_array(i).default{1};
        if isempty(def)
            def = 'file';
        end
        if ~isnumeric(def)
            % Check if the default reference is to variable of par, rather
            % than fixed value:
            match  = regexp(def,'par\.\w*','match');
            if ~isempty(match)
                for j=1:length(match)
                    defaultsneeded{end+1}=match{j};
                end
                fprintf(fid,'%s\n',['handles.model.xbeach.domain(id).' params_array(i).name '= ' def ';']);
            else
                fprintf(fid,'%s\n',['handles.model.xbeach.domain(id).' params_array(i).name '= ''' def ''';']);
            end
        else
            fprintf(fid,'%s\n',['handles.model.xbeach.domain(id).' params_array(i).name '=' num2str(def) ';']);
        end
    end
end
% generate subfunction
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','function par=getdefaultpars');
fprintf(fid,'%s\n','% Pick up defaults of base variables, used for defaults of other variables');
fprintf(fid,'%s\n','% Some variables may occur more than once');
fprintf(fid,'%s\n',['% This function is generated automatically by ' mfilename]);
fprintf(fid,'%s\n',['% Last update was on ' datestr(now)]);
fprintf(fid,'%s\n','% Do not edit this file manually !');
fprintf(fid,'%s\n',['% Change generation in ' mfilename]);
fprintf(fid,'%s\n','');
for j=1:length(defaultsneeded);
    eval(['def = ' defaultsneeded{j} '.default{1};']);
    if isnumeric(def)
        fprintf(fid,'%s\n',[defaultsneeded{j} '=' num2str(def) ';']);
    else
        % stop circular references
        if strcmpi(def,defaultsneeded{j})
            fprintf(fid,'%s\n',[defaultsneeded{j} '=0;']);
        else
            fprintf(fid,'%s\n',[defaultsneeded{j} '=''' def ''';']);
        end
    end
end


fclose(fid);



%% subfunctions, but all nested, so share variables

    function makeElementType
        switch Par.(index{i}).(index2{ii}).variables.(index3{iii}).type(1:4)
            case 'real'
                % easy: always an edit field
                Sub(count2).element.style='edit';
                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                Sub(count2).element.position=POS{count2};
                Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                Sub(count2).element.variable.type='real';
            case 'inte'
                % is this an on/off switch, or an integer
                % number?
                minval=Par.(index{i}).(index2{ii}).variables.(index3{iii}).minval{1};
                maxval=Par.(index{i}).(index2{ii}).variables.(index3{iii}).maxval{1};
                if minval==0 && maxval==1
                    Sub(count2).element.style='checkbox';
                    Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.position=POS{count2}(1:2);
                else
                    Sub(count2).element.style='edit';
                    Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.position=POS{count2};
                end
                Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                Sub(count2).element.variable.type='integer';
            case 'char'
                % is this a file select option, or a popupbar
                % option?
                if isempty(Par.(index{i}).(index2{ii}).variables.(index3{iii}).allowed{1})
                    % file
                    Sub(count2).element.style='pushselectfile';
                    Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.position=POS{count2};
                    Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.variable.type='character';
                    Sub(count2).element.extension='*.*';
                    Sub(count2).element.selectiontext='Select file';
                else
                    % popupbar option
                    Sub(count2).element.style='popupmenu';
                    Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.position=POS{count2};
                    Sub(count2).element.variable.name=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                    Sub(count2).element.variable.type='string';
                    for in=1:length(Par.(index{i}).(index2{ii}).variables.(index3{iii}).allowed{1})
                        Sub(count2).element.list.texts(in)=Par.(index{i}).(index2{ii}).variables.(index3{iii}).allowed{1}(in);
                    end
                    %Sub(count2).element.list=Par.(index{i}).(index2{ii}).variables.(index3{iii}).allowed(1);
                end
                
            otherwise
                Sub(count2).element.style='text';
                Sub(count2).element.text=Par.(index{i}).(index2{ii}).variables.(index3{iii}).name;
                Sub(count2).element.position=POS{count2}(1:2);
        end
        % does this parameter depend on other paramters?
%        if ~isempty(Par.(index{i}).(index2{ii}).variables.(index3{iii}).condition{1})
%            ncon = length(Par.(index{i}).(index2{ii}).variables.(index3{iii}).condition);
%            Sub(count2).element.dependencies.dependency.action = 'enable';
%            Sub(count2).element.dependencies.dependency.checkfor = 'any';
%            Sub(count2).element.dependencies.dependency.tags.tag = 'selecttype';
%            for icon=1:ncon
%                % dependency should be something like:
%                % Model(md).Input(ad).''parname''
%                % where parname = par.nx, minus the par.
%                % so we isolate the par.nx from the condition phrase and replace with Model(md) etc. 
%                dependency = 4;
%                
%                Sub(count2).element.dependencies.dependency.checks(icon).check.variable = tag;
%                Sub(count2).element.dependencies.dependency.checks(icon).check.value = value;
%                Sub(count2).element.dependencies.dependency.checks(icon).check.operator = 'eq';
%            end
%            
%        end
    end


end








