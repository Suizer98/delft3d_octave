function ITHK_xml(h,xml)

% function outputKML =  UnibestInteractiveTool(lat,lon,mag,time,name,measure,implementation)
%UNIBESTINTERACTIVETOOL  Backbone function of Unibest Interactive Tool for the Holland Coast
%
%   The Unibest Interactive Tool for the Holland Coast is developed in the Building with Nature program
%   by the working packages HK4.1 and DM1.3. This function is the backbone of the tool in which simulates 
%   the effects of a number of (pre-defined) coastal measures on the coastline development of the Holland
%   Coast by means of a UNIBEST model. The Unibest Interactive Tool can only run, when the user has a
%   license of the UNIBEST software. The tool can be called either direclty from Matlab or from a web
%   application.
%
%   Syntax:
%   outputKML = UnibestInteractiveTool(lat,lon,mag,time,name,measure,implementation)
%
%   Input:
%   measure       = code indicating the type of coastal intervention:
%                   [0] Continuous triangular nourishment (from year of implementation to end)
%                   [1] Single triangular nourishment (only in year of implementation) 
%                   [2] Groyne
%                   [3] Revetment
%				    [4] Evenly distributed nourishment (from year of implementation to end)
%   lat           = 1xN array with the latitudes of coastal interventions
%   lon           = 1xN array with the longitudes of coastal interventions
%   impl          = 1xN array with the years of implementation of coastal intervention (measured from base year)
%   len           = 1xN array with the (spreading) length of coastal interventions (0.5*len = radius around lat,lon)
%   vol           = 1xN array with the nourishment volumes
%   fill          = 1xN array with the fillup behind revetments (0=no fillup, 1=fillup)
%   tin           = string specifying the timespan for the Unibest calculations in years
%   varNameIn     = string specifying the name of the scenario
%   coast         = string specifying whether coastline output will be generated
%   eco           = string specifying whether ecology output will be generated
%   dunes         = string specifying whether dunes output will be generated
%   slr           = string specifying whether sea level rise will be taken into account
%
%   Output:
%   outputKML = contents of the KML-file (filename = varNameIn.kml) containing the model results of the Unibest calculations
%
%   Example
%   measure = [1, 2, 2, 3, 4, 3];
%   lat = [52.0295, 52.0716, 52.1167, 52.2049, 52.1078, 52.2444];
%   lon = [4.1588, 4.2209, 4.2824, 4.3912, 4.2693, 4.4269];
%   impl = [10, 15, 5, 1, 5, 15];
%   len = [2500, 500, 500, 2500, 1000, 2500];
%   vol = [10000000, 0, 0, 0, 1000000, 0];
%   fill = [0, 0, 0, 0, 0, 0];
%   tin = '20';
%   varNameIn = 'example';
%   coast = '1';
%   eco = '0';
%   dunes = '0';
%   slr = '1';
%   outputKML = UnibestInteractiveTool(measure,lat,lon,impl,len,vol,fill,tin,varNameIn,coast,eco,dunes,slr)

%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Wiebe de Boer
%
%       wiebe.deboer@deltares.nl
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 22 Sep 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ITHK_xml.m 11018 2014-07-31 15:20:51Z boer_we $
% $Date: 2014-07-31 23:20:51 +0800 (Thu, 31 Jul 2014) $
% $Author: boer_we $
% $Revision: 11018 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/ITHK_xml.m $
% $Keywords: $

%% Unibest Interactive Tool
% find Tooldir
[toolpath] = fileparts(which('ITHK_xml'));
cd(toolpath);
ss = strfind(toolpath,'\');
baseDir = toolpath(1:ss(end));

% create global struct
global S
S = struct;
S.EPSG = load(which('EPSG.mat'));
S.xml = xml;
S.h = h;
if isfield(xml,'weburl')
    S.weburl=xml.weburl;
end

%Go up one dir
cd(S.h,'..');

%Go into status dir
cd(S.h,'status');

%Write status xml file
status='Interactive Design Tool activated';
try
    sendWebStatus(status,S.xml);
catch
    disp(status);
end
    
%% Process input

%Read settings
S.settings =xml2struct(which('ITHK_settings.xml'),'structuretype','supershort');
%S.settings = xml_load(which('ITHK_settings.xml'));
S.settings.basedir = baseDir;

% subdirectories
S.settings.inputdir            = [baseDir 'Matlab\preprocessing\input\'];
S.settings.rundir              = [baseDir 'UB model\' S.settings.model filesep 'input\'];
S.settings.CLRdata             = ITHK_io_readCLR([baseDir 'UB model\' S.settings.model filesep 'input\' S.settings.CLRfile]);

% Process user input
S.userinput = ITHK_process_webinput_xml(xml,S.settings.CLRdata);

% Set output dir
S.settings.outputdir           = [baseDir 'UB model\' S.settings.model filesep 'output\' S.userinput.name filesep]; 
if ~isdir(S.settings.outputdir)
    mkdir(S.settings.outputdir);
elseif ~isempty(dir(S.settings.outputdir))
    flist = dir(S.settings.outputdir);
    for ii=1:length(flist)
        switch lower(flist(ii).name)
            case{'.','..','.svn'}
            otherwise
                delete([S.settings.outputdir flist(ii).name]);
        end
    end
end
copyfile([S.settings.rundir],S.settings.outputdir);

%% Preprocessing Unibest Interactive Tool
for ii=1:1%length(sensitivities)
    ITHK_preprocessing(ii);
    status='preprocessing Interactive Design Tool completed';
    try
        sendWebStatus(status,S.xml);
    catch
        disp(status);
    end        

    %% Running Unibest Interactive Tool
    ITHK_runUB;
    status = 'running Unibest completed';
    try
        sendWebStatus(status,S.xml);
    catch
        disp(status);
    end

    %% Extract UB (PRN) results for current & reference scenario
    PRNfileName = [S.userinput.name,'.PRN']; 
    S.UB(ii).results.PRNdata = ITHK_io_readPRN([S.settings.outputdir PRNfileName]);
    %S.UB(ii).data_ref.PRNdata = ITHK_io_readPRN([S.settings.outputdir 'Natural_development.PRN']);%REFERENCE_IT.PRN

    %% Postprocessing Unibest Interactive Tool
    ITHK_postprocessing(ii);
%     ITHK_cleanup(ii);
end
save([S.settings.outputdir filesep S.userinput.name,'.mat'],'-struct','S')
outputKML=fileread(S.PP.output.kmlFileName);
status = 'postprocessing Interactive Design Tool completed';
try
    sendWebStatus(status,S.xml);
catch
    disp(status);
end

%% Output result to server
%Make output xml
outputFilename=['output_' xml.uniqueID '.xml'];
for jj=1:1%length(sensitivities)
    if length(S.PP(jj).output.kmlfiles)>1
        for ii=1:length(S.PP(jj).output.kmlfiles)
            root(ii).tool = xml.tool;
            root(ii).scenario = strrep(S.userinput.name,['_' xml.uniqueID],'');%xml.data.scenarioname;
            root(ii).kmlTitle=strrep(S.PP(jj).output.addtxt{ii}(2:end),'_','');
            root(ii).kmlFile=[S.userinput.name S.PP(jj).output.addtxt{ii} '.kml'];
        end
    else
        root.item.tool = xml.tool;
	    root.item.scenario = strrep(S.userinput.name,['_' xml.uniqueID],'');%xml.data.scenarioname;
        root.item.kmlFile=strrep(S.PP(jj).output.addtxt{ii}(2:end),'_','');
        root.item.kmlTitle=[S.userinput.name S.PP(jj).output.addtxt{ii} '.kml'];
    end
end
xml_write(outputFilename,root);

%First copy KML
status = 'Uploading output';
try
    sendWebStatus(status,S.xml);
catch
    disp(status);
end
%Go up one dir
cd(S.h,'..');
%Go into kml dir
cd(S.h,'kml');

for jj=1:1%length(sensitivities)
    if length(S.PP(jj).output.kmlfiles)>1
         for ii=1:length(S.PP(jj).output.kmlfiles)
            mput(S.h,[S.settings.outputdir root(ii).kmlFile]);
            %delete(root(ii).kmlFile);
        end
    else
        mput(S.h,[S.settings.outputdir root.item.kmlFile]);
        %delete(root.item.kmlFile);
    end
end

%Then write output xml to server
%Go up one dir
cd(h,'..');
%Go into output dir
cd(h,'output');

mput(h,outputFilename);
%Check if it is really there
d=dir(h,outputFilename);
if isempty(d)
    warning(['OUTPUT XML FILE: ' outputFilename ' could not be copied to FTP!']);
else
    %delete(outputFilename);
end

%Then go back to the input dir for listener
%Go up one dir
cd(h,'..');
%Go into output dir
cd(h,'input');

%% Copy all to cache under sessionID folder
% Create cachedir if necessary
cacheDir=[xml.cacheDir filesep xml.sessionID filesep 'ITHK'];
if ~exist(cacheDir,'dir')
    mkdir(cacheDir);
end

% Delete cached files if existing scenario is overwritten
D = dir(cacheDir);
for ii=1:length(D)
    [filedir,name,ext] = fileparts([cacheDir filesep D(ii).name]);
    %Check for xml containing same name
    if ~isempty(ext)
        if ~isempty(strmatch(ext,'.xml','exact')) && ~isempty(strfind(D(ii).name,strrep(S.userinput.name,['_' xml.uniqueID],'')))
            cachedxml = xml_load([filedir filesep name ext]);
            for kk=1:length(cachedxml);
                %Check for exact name
                if strmatch(strrep(S.userinput.name,['_' xml.uniqueID],''),cachedxml{kk}.scenario,'exact')
                   delete([cacheDir filesep cachedxml{kk}.kmlFile]);
                   deletexml = 1;
               end
            end
            if deletexml == 1;
                delete([cacheDir filesep D(ii).name]);
            end
        end
    end
end
   
%Store S, xml and kml-files
copyfile(outputFilename,[cacheDir filesep S.userinput.name '.xml']);%xml.data.scenarioname;
delete(outputFilename);
%movefile([S.settings.outputdir filesep S.userinput.name,'.mat'],cachedir)
%save([cacheDir filesep 'xml_' xml.uniqueID '.mat'],'xml');

if length(S.PP(jj).output.kmlfiles)>1
    for ii=1:length(S.PP(jj).output.kmlfiles)
         movefile([S.settings.outputdir filesep root(ii).kmlFile],cacheDir);
    end
else
     movefile([S.settings.outputdir filesep root.item.kmlFile],cacheDir);
    %delete(root.item.kmlFile);
end

%% Clean up
rmdir(S.settings.outputdir,'s')
clear
close all

%}