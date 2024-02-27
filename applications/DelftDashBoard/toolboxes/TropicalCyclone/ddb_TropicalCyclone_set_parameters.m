function ddb_TropicalCyclone_set_parameters(varargin)
%DDB_TROPICALCYCLONETOOLBOX_SETPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCycloneToolbox_setParameters(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TropicalCycloneToolbox_setParameters
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_TropicalCycloneToolbox_setParameters.m 11511 2014-12-04 21:34:18Z ormondt $
% $Date: 2014-12-04 22:34:18 +0100 (Thu, 04 Dec 2014) $
% $Author: ormondt $
% $Revision: 11511 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_TropicalCycloneToolbox_setParameters.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
    h=findobj(gca,'Tag','rawensemble');
    if ~isempty(h)
        set(h,'Visible','off');
    end
    h=findobj(gca,'Tag','finalensemble');
    if ~isempty(h)
        set(h,'Visible','off');
    end
    handles=getHandles;
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        ddb_giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
    end
else
    %Options selected
    opt=lower(varargin{1});

    handles=getHandles;
    if handles.toolbox.tropicalcyclone.drawingtrack
        % The user was drawing a track but did not finish it with a
        % right-click.
        set(gcf, 'windowbuttondownfcn',[]);
        set(gcf, 'windowbuttonmotionfcn',[]);
        hg=findobj(gcf,'tag','cyclonetrack');
        x=getappdata(hg,'x');
        y=getappdata(hg,'y');
        ddb_TropicalCyclone_change_cyclone_track(hg,x,y);
    end
    
    switch opt
        case{'computecyclone'}
            computeCyclone;
        case{'drawtrack'}
            drawTrack;
        case{'deletetrack'}
            deleteTrack;
        case{'edittracktable'}
            editTrackTable;
        case{'loaddata'}
            loadDataFile;
        case{'savedata'}
            saveDataFile;
        case{'importtrack'}
            importTrack;
        case{'selectbasinoption'}
            selectBasinOption;
        case{'downloadtrack'}
            downloadTrackData;
    end
end

%%
function drawTrack
handles=getHandles;

xmldir=handles.toolbox.tropicalcyclone.xmlDir;
xmlfile='toolbox.tropicalcyclone.initialtrackparameters.xml';

%h=handles.toolbox.tropicalcyclone;
h=handles;
[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles=h;
    
    setInstructions({'','Click on map to draw cyclone track','Use right-click to end cyclone track'});
    
    handles=ddb_TropicalCyclone_delete_cyclone_track(handles);
    
    ddb_zoomOff;
    
    gui_polyline('draw','Tag','cyclonetrack','Marker','o','createcallback',@ddb_TropicalCyclone_change_cyclone_track,'changecallback',@ddb_TropicalCyclone_change_cyclone_track, ...
        'rightclickcallback',@ddb_selectCyclonePoint,'closed',0);
    
    handles.toolbox.tropicalcyclone.drawingtrack=1;
    
    setHandles(handles);
    
end

%%
function deleteTrack

handles=getHandles;
handles.toolbox.tropicalcyclone.track=ddb_TropicalCyclone_set_dummy_track_values(1);
handles.toolbox.tropicalcyclone.nrTrackPoints=0;
handles=ddb_TropicalCyclone_delete_cyclone_track(handles);
setHandles(handles);

%%
function selectBasinOption

%  Retrieve the current handles data structure.
handles = getHandles;

%  Retrieve the handles of the TC radio buttons.
hall = findobj(gcf,'Tag','radioallbasins');   % All
hnear = findobj(gcf,'Tag','radionearbasin');  % Nearest

%  Check which basin option was selected.
if (handles.toolbox.tropicalcyclone.whichTCBasinOption == 1)
    %  All basins -- unset Nearest 
    set(hnear, 'Value', 0);
else
    %  Nearest basin -- unset All
    set(hall, 'Value', 0);
end

%  Check whether the TC basins are to be displayed.
if (handles.toolbox.tropicalcyclone.showTCBasins == 1)
    %  One or more basins will be displayed, so load polygon data.
    handles = ddb_TropicalCyclone_select_tropical_cyclone_basins(handles);
else
    %  One or more basins will be turned off, so "turn off" the polygon data.
    handles = ddb_TropicalCyclone_select_tropical_cyclone_basins(handles);
end

%  Update the TC widgets within the GUI.

%  Store the current handles data structure.
setHandles(handles);

%%
function loadDataFile

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.cyc', 'Select Cyclone File','');

if filename==0
    return
end;

filename=[pathname filename];

handles.toolbox.tropicalcyclone.cycloneFile=[pathname filename];
handles=ddb_TropicalCyclone_read_cyclone_file(handles,filename);

% Ensemble parameters
handles.toolbox.tropicalcyclone.ensemble.t0=handles.toolbox.tropicalcyclone.track.time(1);
handles.toolbox.tropicalcyclone.ensemble.t0_spw=handles.toolbox.tropicalcyclone.track.time(1);
handles.toolbox.tropicalcyclone.ensemble.length=handles.toolbox.tropicalcyclone.track.time(end)-handles.toolbox.tropicalcyclone.track.time(1);

handles=ddb_TropicalCyclone_delete_cyclone_track(handles);

setHandles(handles);

ddb_TropicalCyclone_plot_cyclone_track;

%%
function saveDataFile

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.cyc', 'Select Cyclone File','');
if filename==0
    return
end
filename=[pathname filename];
handles.toolbox.tropicalcyclone.cycloneFile=filename;
setHandles(handles);
ddb_TropicalCyclone_save_cyclone_file(filename,handles.toolbox.tropicalcyclone,'version',handles.delftDashBoardVersion);

%%
function downloadTrackData

handles=getHandles;

switch lower(handles.toolbox.tropicalcyclone.downloadLocation)
    case('recent')
        wb = waitbox('Recent hurricanes are being downloaded');
        succes = ddb_read_FTP_NHC(handles.toolbox.tropicalcyclone.dataDir)
        if succes == 0
            close(wb);
            db_giveWarning('text',['Something went wrong downloading recent hurricanes']);
        end
        close(wb);
    case{'unisysbesttracks'}
        web http://weather.unisys.com/hurricane -browser
    case{'jtwcbesttracks'}
        web http://www.usno.navy.mil/NOOC/nmfc-ph/RSS/jtwc/best_tracks/ -browser
    case{'jtwccurrentcyclones'}
        web http://www.usno.navy.mil/JTWC/ -browser
    case{'jtwccurrenttracks', 'nhccurrenttracks'}
        %  JTWC current TC warning file(s) or NHC current forecast/advisory
        %  file(s):
        
        %  Check whether the user wants to check certain basins.
        %  First, check whether the user has chosen to display basin
        %  polygons.
        if (isempty(handles.toolbox.tropicalcyclone.TCBasinName))
            %  The user has not chosen to display basins, so prompt for
            %  whether to select one or more basins.
            [indx,isok] = listdlg('PromptString',char('Select one or more TC basin(s)', 'to check for warnings:'),...
                'ListSize',[160,70],'Name','TC Basins','ListString',handles.toolbox.tropicalcyclone.knownTCBasinName);
            
            %  Check the user's response.
            if (isok ~= 0)
                %  The user responded with a selection, so update the
                %  pertinent parameters.
                handles.toolbox.tropicalcyclone.TCBasinName = handles.toolbox.tropicalcyclone.knownTCBasinName(indx);
                handles.toolbox.tropicalcyclone.TCBasinNameAbbrev = handles.toolbox.tropicalcyclone.knownTCBasinNameAbbrev(indx);
            end
        end
        
        %  Now, build the '--region' option to the download scripts.
        region_option = get_basin_option(handles.toolbox.tropicalcyclone.TCBasinNameAbbrev);
        
        %  Prompt for a storm name if so desired.
        iflag = 1;
        m_t = '';  % Empty string
        storm_name = get_user_storm_name(iflag, handles.toolbox.tropicalcyclone.TCStormName,m_t,m_t);
        
        %  Store the storm name if one was entered.
        if (~isempty(storm_name))
            handles.toolbox.tropicalcyclone.TCStormName = storm_name;
            %  Build a Perl script command to download the file by name
            cmd = ['perl ' which('check_tc_files.pl') ' --name ' storm_name ...
                ' ' region_option ' --data_dir ' handles.tropicalCycloneDir];
        else
            %  Build a Perl script command to download all available files
            cmd = ['perl ' which('check_tc_files.pl') ' ' region_option ' --data_dir ' handles.tropicalCycloneDir ' --best'];
        end
        
        %  Invoke the download command using a system() call.
        [status,result] = system(cmd);
        
        %  Check the status of the command.
        if (status == 0)
            %  The command was successful, so continue.
            %  Determine the name of the track file(s) based on data type (i.e., TC center).
            if (strcmpi(handles.toolbox.tropicalcyclone.downloadLocation, 'jtwccurrenttracks'))
                %  JTWC
                [~, ~, ~, ~, tokenStr, ~, ~] = ...
                regexp(result,'web\.txt was moved to ([A-Z]{3,4})[\/\\]([a-z]{2}[0-9]{4}web_[0-9]{12}\.txt*)');
                %  Define the file format conversion script name.
                sname = 'parse_jtwc_warning.pl';  % Script name
                prog = which(sname);              % Full path name of script
            else
                %  NHC
                %                 [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = ...
                %                 regexp(result,'[acew][tp][0-9]\.txt was moved to ([A-Z]{3,4})\/(wt[a-z]{2}[0-9]{2}\.[a-z]{4}\.tcm\.[ace][tp][0-9]_[0-9]{12}\.txt*)');
                [~, ~, ~, ~, tokenStr, ~, ~] = ...
                regexp(result,'[acew][tp][0-9]\.txt was moved to ([A-Z]{3,4})[\/\\](wt[a-z]{2}[0-9]{2}\.[a-z]{4}\.tcm\.[ace][tp][0-9]_[0-9]{12}\.txt*)');
                %  Define the file format conversion script name.
                sname = 'read_fcst_advisory.pl';  % Script name
                prog = which(sname);              % Full path name of script
            end
                
            %  Check whether the file format conversion script was located.
            if (isempty(prog))
                %  Script was not found, so issue a warning message and
                %  return to calling routine.
                ddb_giveWarning('text',['ERROR: Cannot find the TC file conversion script ' sname '.']);
                return;
            end
            
            %  Determine the number of track files.
            nf = size(tokenStr,2);
            
            %  Loop over track files to reformat.
            for k = 1:nf
                %  Define the present file name from the output of the download script.
                txtfile = [handles.tropicalCycloneDir filesep char(tokenStr{k}{1}) filesep char(tokenStr{k}{2})];
                trkfile = strrep(txtfile, '.txt', '.trk');
                
                %  Invoke another Perl script to convert to .trk format.
                %  First, create the command string using the correct
                %  script and current file names.
                cmd = ['perl ' prog ' ' txtfile ' wes.inp ' trkfile ' ' int2str(handles.toolbox.tropicalcyclone.nrRadialBins) ...
                    ' ' int2str(handles.toolbox.tropicalcyclone.nrDirectionalBins) ' ' ...
                    int2str(handles.toolbox.tropicalcyclone.radius)];
                
                %  Execute the command with a system() call.
                [status2,result] = system(cmd);

                %  Check the status of this last command.
                if (status2 == 0)
                    %  The command was successful, so continue.
                    %  Store the present track file name.
                    handles.toolbox.tropicalcyclone.TCTrackFile{k} = trkfile;
                    
                else
                    disp([' WARNING: Unable to convert the format of the TC file:' 10 txtfile 10 ...
                    '; the command was:' 10 cmd 10]);
                end
            end  % for k...
        else
            %  The download command was unsuccessful, so issue a warning
            %  message.
            ddb_giveWarning('text', ['ERROR: The TC warning file download command failed: ' result]);
        end  % if (status....
%end  % switch lower(handles....

end

%%
function importTrack

handles=getHandles;

iflag=0;

switch lower(handles.toolbox.tropicalcyclone.importFormat)
    case('recent');
        wb = waitbox('Recent hurricanes are being imported');
        [fname] = ddb_read_recent_hurricanes(handles.toolbox.tropicalcyclone.dataDir);
        iflag = 1; filename= fname; pathname = pwd;
        close(wb);
    case('database_btd')
        wb = waitbox('NHC & JTWC best track data (BTD) archived data are being imported');
        [fname] = ddb_selectNOAAstorm;  
        iflag = 1; filename= fname; pathname = pwd;
        close(wb);
    case{'unisysbesttrack'}
        ext='dat';
        prefix = '';
    case{'bom'}
        ext='xml';
        prefix = '';
    case{'jtwccurrenttrack', 'nhccurrenttrack'}
        %  This assumes that JTWC or NHC current track(s) have been 'JTWCCurrentTrack','NHCCurrentTrack'
        %  converted from their native format; cf. subfunc. downloadTrackData.
        ext = 'trk';
        prefix = handles.tropicalCycloneDir;
        %  Prompt for a storm name if so desired.
        iflag = 2;
        %storm_name = get_user_storm_name(iflag, handles.toolbox.tropicalcyclone.TCTrackFileStormName);
        storm_name = get_user_storm_name(iflag, handles.toolbox.tropicalcyclone.TCTrackFileStormName,...
            lower(handles.toolbox.tropicalcyclone.importFormat),handles.tropicalCycloneDir);
        iflag = 0;
        filename = 0;
            
        %  Set the basin(s) to check based on which data set was
        %  selected.
        if (strcmpi(handles.toolbox.tropicalcyclone.importFormat, 'jtwccurrenttrack'))
            %  JTWC -- currently, this data set is from the Western
            %  Pacific.
            region = '--region sh,wp';
            %  Define the file format conversion script name.
            sname = 'parse_jtwc_warning.pl';  % Script name
            cprog = which(sname);             % Full path name of script
            prefix = [prefix 'JTWC' filesep];
        elseif (strcmp(lower(handles.toolbox.tropicalcyclone.importFormat), 'nhccurrenttrack'))
            %  NHC -- Atlantic, Central Pacific, Eastern Pac.
            %  Define the file format conversion script name.
            sname = 'read_fcst_advisory.pl';  % Script name
            cprog = which(sname);              % Full path name of script
            region = '--region at,cp,ep';
            prefix = [prefix 'NHC' filesep];
        end
        
        %  Store the storm name if one was entered, and get a list of files for storms of that name.
        if (~isempty(storm_name))
            handles.toolbox.tropicalcyclone.TCStormName = storm_name;
            handles.toolbox.tropicalcyclone.TCTrackFileStormName = storm_name;
            
            %  Here, run something such as find_tc_files_byname.pl
            sname1 = 'find_tc_files_byname.pl';
            prog = which(sname1);
                
            %  Check whether the file find & format conversion scripts were located.
            if (isempty(prog))
                ddb_giveWarning('text',['ERROR: Cannot find the TC storm name script ' sname1 '.']);
                return;
            end
            if (isempty(cprog))
                ddb_giveWarning('text',['ERROR: Cannot find the TC format conversion script ' sname '.']);
                return;
            end
            
            %  Create the name finding command.
            cmd = ['perl ' prog ' ' storm_name ' --data_dir '  handles.tropicalCycloneDir ' ' region];
            %  Execute the command using a system() call.
            [status,result] = system(cmd);
            %  Evaluate the results.
            if (~isempty(regexp(result, 'ERROR', 'match')))
                %  No files for the given storm name were found; issue a
                %  message and continue to browse for files.
                giveWarning('text',['No files were found for the storm ' upper(storm_name) '.'])
            else
                %  At least one file was found, so continue processing the
                %  file name search results.
                %  Split the standard output into separate lines.
                lines = regexp(result, '\n', 'split');
                nl = size(lines,2);  %  Number of lines
                fname = {};
                j = 0;
                %  Loop over lines in the program output...
                for ii = 1:nl
                    %  Find a string that ends in ".txt".
                    m = regexp(lines{ii}, '.*_[0-9]{12}\.txt', 'match');
                    %  If such a string has been found, then it corresponds
                    %  to a file name; process this file name.
                    if (~isempty(m))
                          %  Check whether the .trk file corresponding to this
                        %  .txt file exists.
                        if (exist(strrep(char(m),'.txt','.trk'),'file'))
                            j = j + 1;
                            fname(j) = strrep(m,'.txt','.trk');
                        else
                            %  The .trk file corresponding to this .txt
                            %  file has not been created; do so now.
                            %  Invoke another Perl script to convert to .trk format.
                            %  First, create the command string using the correct
                            %  script and current file names.
                            cmd2 = ['perl ' cprog ' ' char(m) ' wes.inp ' strrep(char(m),'.txt','.trk') ' '...
                                int2str(handles.toolbox.tropicalcyclone.nrRadialBins) ...
                            ' ' int2str(handles.toolbox.tropicalcyclone.nrDirectionalBins) ' '...
                            int2str(handles.toolbox.tropicalcyclone.radius)];
                        
                            %  Execute the command with a system() call.
                            disp([' NOTE: Performing a format conversion on the TC warning file ' char(m)]);
                            [status2,result2] = system(cmd2);
                        
                            %  Check the status of this last command.
                            if (status2 == 0)
                                %  The command was successful, so continue.
                                %  Store the present track file name.
                                j = j + 1;
                                fname(j) = strrep(m,'.txt','.trk');
                            else
                                disp([' WARNING: Unable to convert the format of the TC file:' 10 char(m) 10 ...
                                'the command was:' 10 cmd2 10]);
                            end
                        end
                    end
                end
                %  Check whether any track files were found for the
                %  selected storm name.
                if (~isempty(fname))
                    %  Track files were found, so prompt the user to select
                    %  one to import.
                    [indx,isok] = listdlg('PromptString',['Select a file for the storm ' upper(storm_name) ':'],...
                        'Name','TC File','ListString',fname,'listsize',[400,200],'selectionmode','single');
                    if (~isempty(indx) && isok == 1)
                        %  The user made a selection, so break the full
                        %  path name into path and file name.
                        iflag = size(fname,2);
                        [pathname,filename,extn] = fileparts(fname{indx});
                        pathname = [pathname filesep];  % Append the file separator character.
                        filename = [filename extn];     % Append the file extension.
                        handles.toolbox.tropicalcyclone.TCTrackFile = fname{indx};  % Store the file name.
                        %  Update the data structure & the text box
                        setHandles(handles);
                        % setUIElement('tropicalcyclonepanel.parameters.selectedtrackfile');
                    end
                else
                    %  No files for the given storm name were found; issue a
                    %  message and continue to browse for files.
                    giveWarning('text',['No existing track (.trk) files were found by the storm name program for the storm ' upper(storm_name) '.'])
                end
            end
        end
        
    otherwise
        ext='*';
        prefix = '';
end

%  Browse for a file if one hadn't been selected.

if (iflag == 0)
    [filename, pathname, filterindex] = uigetfile([prefix '*.' ext], 'Select Data File','');
end
if filename==0
    return
else
    %  Store the file name.
    handles.toolbox.tropicalcyclone.TCTrackFile = fullfile(pathname, filename);
    %  Update the data structure.
    setHandles(handles);
    %  Update the text box.
	% setUIElement('tropicalcyclonepanel.parameters.selectedtrackfile');
end

%  Format type flag.
itype = 0;  % Default = 0; set to 1 for JTWC or NHC current tracks.

%  Default background pressure (millibars); cf. NAVO SP-68, Table 29, p.
%  402, or Pond & Pickard (1981), Introductory Dynamic Oceanography (2nd ed.),
%  Appendix 2, p. 229.
BG_Pres = 1013.25;
bg_press_Pa = BG_Pres * 100;  % Same, in Pa
try
    
    switch lower(handles.toolbox.tropicalcyclone.importFormat)
        case{'jtwcbesttrack'}
            tc=tc_read_jtwc_best_track([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
        case{'unisysbesttrack'}
            tc=tc_read_unisys_best_track([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
        case{'jtwccurrenttrack', 'nhccurrenttrack'}
            %  JTWC, NHC current tracks in generic .trk format:
            tc=ddb_readGenericTrackFile([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
            itype = 1;
        case{'jmv30'}
            tc=tc_read_jmv30([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
            handles.toolbox.tropicalcyclone.wind_profile='holland2010';
            handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';
        case{'bom'}
            tc=tc_read_bom_xml([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=1.0;
            handles.toolbox.tropicalcyclone.wind_profile='holland2010';
            handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';
        case{'hurdat2besttrack'}
            tc=tc_read_hurdat2_best_track([pathname filename]);
            handles.toolbox.tropicalcyclone.cyclonename=tc.name;
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
        case{'pagasa'}
            tc=read_pagasa_cyclone_track([pathname filename]);
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
            handles.toolbox.tropicalcyclone.wind_profile='holland2010';
            handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';       
        case('database_btd')
            load([handles.toolbox.tropicalcyclone.dataDir 'hurricanes.mat']);
            for ii = 1:length(tc)
                years    = year(tc(ii).time(1));
                basin    = tc(ii).basin;
                storm    = tc(ii).storm_number(1);
                hurricane_names{ii} = [num2str(years), '_', basin,num2str(storm),'_', tc(ii).name];
                hurricane_numbers(ii) = ii;
            end
            it = find(strcmp(hurricane_names, fname));
            tc = tc(it(1));
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
            handles.toolbox.tropicalcyclone.wind_profile='holland2010';
            handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';   
        case('recent')
            load([handles.toolbox.tropicalcyclone.dataDir 'atcf/btk/hurricanes.mat']);
            for ii = 1:length(tc);
                years    = year(tc(ii).time(1));
                basin    = tc(ii).basin;
                storm    = tc(ii).storm_number(1);
                hurricane_names{ii} = [num2str(years), '_', basin,num2str(storm),'_', tc(ii).name];
                hurricane_numbers(ii) = ii;
            end
            it = find(strcmp(hurricane_names, fname));
            tc = tc(it(1));
            handles.toolbox.tropicalcyclone.windconversionfactor=0.93;
            handles.toolbox.tropicalcyclone.wind_profile='holland2010';
            handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';   
        otherwise
            giveWarning('text','Sorry, present import format not supported!');
            return
    end
    
    nt=length(tc.time);
    
    % Set dummy values
    track=ddb_TropicalCyclone_set_dummy_track_values(nt);

    handles.toolbox.tropicalcyclone.cyclonename=tc.name;

    % Copy values from tc structure to track structure
    fldnames=fieldnames(tc);
    for ifld=1:length(fldnames)
        track.(fldnames{ifld})=tc.(fldnames{ifld});
    end
    if isfield(track,'lon')
       track.x = track.lon;
    end
    if isfield(track,'lat')
      track.y = track.lat;
    end
    handles.toolbox.tropicalcyclone.track=track;
    
    % Ensemble parameters
    handles.toolbox.tropicalcyclone.ensemble.t0=tc.time(1);
    handles.toolbox.tropicalcyclone.ensemble.t0_spw=tc.time(1);
    handles.toolbox.tropicalcyclone.ensemble.length=tc.time(end)-tc.time(1);
        
    if nt>1
        
        handles.toolbox.tropicalcyclone.nrTrackPoints=nt;
        handles.toolbox.tropicalcyclone.name=tc.name;

        % Delete existing cyclone track
        handles=ddb_TropicalCyclone_delete_cyclone_track(handles);
        
        setHandles(handles);
        
        % Plot new cyclone track
        ddb_TropicalCyclone_plot_cyclone_track;
        
    end
    
catch
    ddb_giveWarning('text','An error occured while reading cyclone data');
end

%%
function computeCyclone

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.spw', 'Select Spiderweb File','');

if filename==0
    return
else
    try
        wb = waitbox('Generating Spiderweb Wind Field ...');
        
        wesopt='matlab';

        [path,name,ext]=fileparts(filename);
        
        model=handles.activeModel.name;
        
        switch lower(model)
            case{'delft3dflow'}
                reftime=handles.model.(model).domain(ad).itDate;
                tstart=handles.model.(model).domain(ad).startTime;
                tstop=handles.model.(model).domain(ad).stopTime;
            case{'dflowfm'}
                reftime=handles.model.(model).domain(ad).refdate;
                tstart=handles.model.(model).domain(ad).tstart;
                tstop=handles.model.(model).domain(ad).tstop;
            case{'ww3'}
                reftime=floor(handles.toolbox.tropicalcyclone.track.time(1));
                tstart=handles.model.(model).domain(ad).start_time;
                tstop=handles.model.(model).domain(ad).stop_time;
            otherwise
                reftime=floor(handles.toolbox.tropicalcyclone.track.time(1));
%                tstart=handles.model.(model).domain(ad).start_time;
%                tstop=handles.model.(model).domain(ad).stop_time;
        end
        
        tdummy=[];
        if tstart<handles.toolbox.tropicalcyclone.track.time(1) || ...
                tstop>handles.toolbox.tropicalcyclone.track.time(end)
            ButtonName = questdlg('Add dummy blocks for missing times at start/end of simulation?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes'
                    tdummy=[tstart tstop 0.25];
                case 'No'
                    tdummy=[];
            end
        end
        
        
        
        switch lower(wesopt)
            case{'exe'}
                
                create_spw_file(filename, handles.toolbox.tropicalcyclone, handles.toolbox.tropicalcyclone.dataDir);
                
            case{'matlab'}
                
                inp=handles.toolbox.tropicalcyclone;
                
                % Create SPW file
                
                % First spw grid stuff
                spw.radius=inp.radius*1000; % km
                spw.nr_directional_bins=inp.nrDirectionalBins;
                spw.nr_radial_bins=inp.nrRadialBins;
                spw.reference_time=reftime;
                spw.cs.name='WGS 84';
                spw.cs.type='geographic';
                spw.phi_spiral=inp.phi_spiral;
                spw.rhoa=1.15;
                spw.wind_conversion_factor=inp.windconversionfactor;
                spw.wind_profile=inp.wind_profile;
                spw.wind_pressure_relation=inp.wind_pressure_relation;
                spw.rmax_relation=inp.rmax_relation;
                spw.cut_off_speed=30/1.85;  
                spw.cut_off_speed=30/1.85;  
                spw.cut_off_speed=5;  
                spw.pn=inp.pn;
                
                spw.asymmetry_magnitude='schwerdt1979';
%                spw.asymmetry_magnitude='user_defined';
                spw.asymmetry_magnitude='factor';
                spw.asymmetry_factor=0.60;
                spw.asymmetry_related_to_storm_motion=1;
%                spw.asymmetry_radial_distribution='v/vmax';
                spw.asymmetry_radial_distribution='constant';
                spw.tdummy=tdummy;
                spw.r35estimate = handles.toolbox.tropicalcyclone.r35estimate;

                
                % And now the actual tropical cyclone data                
                tc.radius_velocity=[34 50 64 100];
                tc.wind_speed_unit='kts';
                tc.radius_unit='NM';
                
%                tc.cs.name='WGS 84';
%                tc.cs.type='geographic';
                tc.cs=handles.screenParameters.coordinateSystem;
%                tc.cs.type='geographic';

                tc.track=handles.toolbox.tropicalcyclone.track;
                
%                if handles.toolbox.tropicalcyclone.rainfall>0.0
                    spw.rainfall=handles.toolbox.tropicalcyclone.rainfall;
%                end
                
                % Run WES
                tc=wes4(tc,'tcstructure',spw,[name '.spw']);
 
                % Create polygon file for visualization
                fid=fopen([name '.pol'],'wt');
                fprintf(fid,'%s\n',name);
                fprintf(fid,'%i %i\n',handles.toolbox.tropicalcyclone.nrTrackPoints,2);
                for j=1:handles.toolbox.tropicalcyclone.nrTrackPoints
                    fprintf(fid,'%6.3f %6.3f\n',handles.toolbox.tropicalcyclone.track.x(j),handles.toolbox.tropicalcyclone.track.y(j));
                end
                fclose(fid);
                
        end
        
        switch lower(model)
            case{'delft3dflow'}
                % Adjust Delft3D-FLOW model inputs
                handles.model.(model).domain(ad).spwFile=[name '.spw'];
                handles.model.(model).domain(ad).wind=1;
                handles.model.(model).domain(ad).windType='spiderweb';
                handles.model.(model).domain(ad).airOut=1;
                if handles.model.(model).domain(ad).pAvBnd<0
                    ButtonName = questdlg('Apply correction to account for inverse barometer effect at open boundaries?','','No', 'Yes', 'Yes');
                    switch ButtonName,
                        case 'Yes'                            
                            handles.model.(model).domain(ad).pAvBnd=inp.pn*100;
                    end
                end
            case{'ww3'}
                spwfile=[name '.spw'];
                meteodir='';
                meteoname='';
                parameter='';
                rundir='.\';
                fname='ww3.wnd';
                nx=handles.model.(model).domain.nx;
                ny=handles.model.(model).domain.ny;
                dx=handles.model.(model).domain.dx;
                dy=handles.model.(model).domain.dy;
                xlim(1)=handles.model.(model).domain.x0;
                xlim(2)=xlim(1)+(nx-1)*dx;
                ylim(1)=handles.model.(model).domain.y0;
                ylim(2)=ylim(1)+(ny-1)*dy;
                tstart=tc.track(1).time;
                tstop=tc.track(end).time;
                dt=60;                
                write_meteo_file(meteodir, meteoname, parameter, rundir, fname, xlim, ylim, tstart, tstop, 'model',model,'spwfile',spwfile,'dx',dx,'dy',dy,'dt',dt);                
                write_meteo_file(meteodir, meteoname, {'u','v','p'}, rundir, [name '.mat'], xlim, ylim, tstart, tstop, 'model','mat','spwfile',spwfile,'dx',dx,'dy',dy,'dt',dt);                
        end
        
        close(wb);
        setHandles(handles);
    catch
        close(wb);
        ddb_giveWarning('text','An error occured while generating spiderweb wind file');
    end
end

%%
function storm_name = get_user_storm_name(iflag,current_name,region_code,tc_dir)
%*******************************************************************************
%
%  get_user_storm_name
%
%  This Matlab function interactively prompts the user for whether to
%  obtain tropical cyclone (TC) files for all available storms or for a
%  specific storm.  If the user chooses to obtain files for a specific
%  storm, the user is interactively prompted to enter the storm name.  The
%  name (or an empty string) is returned to the calling routine.  This
%  function is used to prompt for either file downloads or browsing local
%  files.  It is (initially, at least) intended for use with the NRL TC
%  scripts for accessing and extracting NHC and JTWC TC bulletins.
%
%  Syntax: storm_name = get_user_storm_name(iflag,current_name,region_code,tc_dir)
%  where:  storm_name is the returned text string,
%          iflag is a flag indicating which type of action: 1 for
%          downloading or 2 for browsing local files,
%          current_name is the current storm name (initially blank),
%          region_code is a string denoting with import option was chosen, and
%          tc_dir is the TC warning file local directory.
%
%  Calls: [No external routines are used.]
%
%  Called by: downloadTrackData (subfunction), importTrack (subfunction)
%
%  Revision History:
%  17 Jan 2012  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  18 Jan 2012  Added help content & comments; changed the inner IF block
%               checking for whether the user entered a name, from a nested
%               IF block to a single block.  (RSL)
%  20 Jan 2012  Changed the storm name prompt to indicate case
%               insensitivity, and changed the title of the storm name
%               prompt; added new input parameter, 'current_name', and
%               modified the inputdlg() call to use this new parameter.
%               (RSL)
%  25 Jan 2012  Added code to provide a list of all known storm names from
%               the presently available local warning files, and to prompt
%               the user to chose from that list of known storm names;
%               added 'region_code' and 'tc_dir' to the input parameter
%               list to support the new known name list prompt code;
%               updated the help content.  (RSL)
%
%*******************************************************************************

%  Initialize the output parameter (storm name text string).
storm_name = '';

%  Determine which prompt is to be issued.
if (iflag == 1)
    %  Downloading from the web.
    resp = questdlg('Download all files or those for a specific storm?', 'TC Files to Download', ...
        'All', 'Specific', 'Cancel', 'Specific');
elseif (iflag == 2)
    %  Browse local (already downloaded) files. 
    resp = questdlg('Browse downloaded files or search for a specific storm?', 'TC Files to Import', ...
        'Browse', 'Specific', 'Cancel', 'Specific');
    
    %  Check whether the user wants to specify a storm name.
    if (strcmp(resp, 'Specific'))
        %  This is the case, so attempt to get a list of storm names from
        %  the current local files.
        if (~isempty(region_code) && ~isempty(tc_dir))
            if (strcmp(region_code, 'jtwccurrenttrack'))
                %  JTWC
                %  Build the storm names file name.
                storm_file_name = [tc_dir filesep 'JTWC' filesep 'storm_names_jtwc.txt'];
            elseif (strcmp(region_code, 'nhccurrenttrack'))
                %  NHC
                %  Build the storm names file name.
                storm_file_name = [tc_dir filesep 'NHC' filesep 'storm_names_nhc.txt'];
            end
            
            %  Check whether the storm name file exists.
            if (exist(storm_file_name,'file'))
                %  It does exist, so open & read it.
                fid = fopen(storm_file_name, 'r');
                data = textscan(fid, '%s');  %  Read the text fields
                fclose(fid);
                %  Convert from a cell array to a char array.
                snames = char(data{:});
                %  Check whether the data were present & correctly read.
                if (~isempty(snames))
                    %  They were, so prompt the user to select a name.
                    [indx,isok] = listdlg('liststring',[data{:};{'None of the Above'}],...
                        'SelectionMode','single','promptstring',...
                        char('Select a storm name from the','currently available local files:'),...
                        'name','Storm Name Selection');
                    %  Check whether a valid selection was made.
                    if (isok == 1)
                        %  A selection was made, so check which name was
                        %  selected.  If "None of the Above" was chosen,
                        %  the user will be prompted to enter a name below.
                        if (indx <= length(snames))
                            %  A valid name selection was made.  Store the chosen
                            %  name and return to the caller.
                            storm_info = textscan(strtrim(snames(indx,:)),'%s','delimiter',',');
                            storm_name = strtrim(char(storm_info{1}(1)));
                            return;
                        end
                    else
                        %  The user canceled, so return with the blank name
                        return;
                    end
                end
            end
        end
    end
end

%  Check whether the user wants to specify a storm name.
if (strcmp(resp, 'Specific'))
    %  The user does want to specify a storm name, so prompt for one.
    resp2 = inputdlg('Enter the storm name (upper, lower, or mixed case):', 'Enter Storm Name',1,{current_name});
    %  Check whether the user entered a string.
    if (~isempty(resp2) && ~isempty(char(resp2)))
        %  The user did enter something, so convert from a cell array to a
        %  character array.
        storm_name = char(resp2);
    end
end

return;

%%
function tc_basin_str = get_basin_option(basin_list)
%*******************************************************************************
%
%  get_basin_option
%
%  This Matlab function builds a text string consisting of tropical cyclone (TC)
%  basin abbreviations.  It is (initially, at least) intended for use with
%  the NRL TC scripts for accessing and extracting NHC and JTWC TC bulletins.
%
%  Syntax: tc_basin_str = get_basin_option(basin_list)
%  where:  tc_basin_str is the returned text string, and
%          basin_list is a cell array of TC basin abbreviations.
%
%  Calls: [No external routines are used.]
%
%  Called by: downloadTrackData (subfunction)
%
%  Revision History:
%  18 Jan 2012  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%
%*******************************************************************************

%  Initialize the output parameter (basin list text string).
tc_basin_str = '';

%  Check whether the basin list is not empty and contains fewer than four
%  elements.  If this is NOT the case, then all basins are to be checked,
%  and the text string would be empty.
if (~isempty(basin_list) && length(basin_list) < 4)
	%  User selected 1 to 3 basins, so build a basin option string.
    tc_basin_str = ['--region ' char(basin_list{1})];  % 1st basin
    %  Loop over the remaining basin abbreviations to build the basin
    %  option string.
	for k = 2:length(basin_list)
        tc_basin_str = [tc_basin_str ',' char(basin_list{k})];
    end
end

return;

