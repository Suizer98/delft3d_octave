function EHY
%% EHY
%
% Run this function (or 'ehy' or 'EHF') to open the GUI and interactively use the EHY_Tools
%
% created by Julien Groenenboom, 2017
%% Check if lastest version is used
try
    [~,out1]=system(['svn info -r HEAD ' fileparts(which('EHY.m'))]);
    rev1 = str2num(char(regexp(out1, 'Last Changed Rev: (\d+)', 'tokens', 'once')));
    [~,out2]=system(['svn info ' fileparts(which('EHY.m'))]);
    rev2 = str2num(char(regexp(out2, 'Last Changed Rev: (\d+)', 'tokens', 'once')));
    pathOfThisScript = which(mfilename);
    if isempty(rev1) || isempty(rev2)
        disp('Automatic check (and update) failed. Please update the folder yourself. Location on your pc:')
        disp([fileparts(which('EHY.m')) filesep])
    elseif ~any(ismember(lower(pathOfThisScript(1:2)),'cd'))
        disp(['EHY_tools located on ' pathOfThisScript(1:3) '-drive are used and are therefore not automatically updated.'])
    elseif rev2<rev1
        disp('Your EHY_tools are not up-to-date.')
        disp('Status: Updating the EHY_tools folder in your OET.')
        try
            system(['svn update ' fileparts(which('EHY.m'))]);
            disp('Status: <strong>Succesfully updated the EHY_tools folder in your OET.</strong>')
        catch
            disp('Automatic update failed. Please update the folder yourself. Location on your pc:')
            disp([fileparts(which('EHY.m')) filesep])
        end
    else
        % Your EHY_tools are up-to-date
    end
end
%%
functions={};
functions{end+1,1}='EHY_convert';
functions{end  ,2}='Conversion from and to model input files. Including coordinate conversion';
functions{end+1,1}='EHY_getmodeldata';
functions{end  ,2}='Interactive retrieval of model data in stations using EHY_getmodeldata';
functions{end+1,1}='EHY_plotmodeldata';
functions{end  ,2}='Interactive plotting of model data in stations using EHY_getmodeldata';
functions{end+1,1}='EHY_getMapModelData';
functions{end  ,2}='Interactive retrieval of top-view model data using EHY_getMapModelData';
functions{end+1,1}='EHY_plotMapModelData';
functions{end  ,2}='Interactive plotting of top-view model data using EHY_plotMapModelData';
functions{end+1,1}='EHY_getGridInfo';
functions{end  ,2}='Get grid info from a grid file, model inputfile or model outputfile';
functions{end+1,1}='EHY_model2GoogleEarth';
functions{end  ,2}='Visualize your model in GoogleEarth';
functions{end+1,1}='EHY_simulationStatus';
functions{end  ,2}='Check the status of a simulation';
functions{end+1,1}='EHY_runTimeInfo';
functions{end  ,2}='Check the simulation period, run time, number of partitions, etc.';
functions{end+1,1}='EHY_findLimitingCells';
functions{end  ,2}='Get the time step limiting cells and max. flow velocities from a Delft3D-FM run';
functions{end+1,1}='EHY_movieMaker';
functions{end  ,2}='Create animations out of multiple PNG''s or JPG''s';
functions{end+1,1}='EHY_simulationInputTimes';
functions{end  ,2}='A tool to help using the correct model input times';
functions{end+1,1}='EHY_crop';
functions{end  ,2}='This function crops the surrounding area of a figure based on the background color';
functions{end+1,1}='EHY_wait';
functions{end  ,2}='Run a selected MATLAB-script once a certain date and time is reached';
functions{end+1,1}='EHY_geoReference';
functions{end  ,2}='Interactively georeference a figure (create world file)';
functions{end+1,1}='EHY_snake';
functions{end  ,2}='Who needs a Nokia 3210 when you''ve got the EHY_tools?';

h=findall(0,'type','figure','name','EHY_TOOLS  - Everbody Helps You');
height=15.6;
if ~isempty(h)
    uistack(h,'top');
    figure(h);
    movegui(h,'center');
    disp('The EHY_TOOLS GUI was already open')
else
    EHYfig=figure('units','centimeters','position',[12.0227 6.4982 16.8 height],'name','EHY_TOOLS  - Everbody Helps You','color',[0.94 0.94 0.94]);
    movegui(EHYfig,'center');
end

for iF=1:length(functions)
    button=uicontrol('Style', 'pushbutton', 'String',functions{iF,1},...
        'units','centimeters','Position',[0.5027 height-iF*0.7938 5.2917 0.5292],...
        'Callback', @runEHYscript);
    uicontrol('Style','text',...
        'units','centimeters','Position',[6 height-iF*0.7938-0.1 12 0.5292],...
        'String',functions{iF,2},'horizontalalignment','left');
end

EHY_infoFile = 'n:\Deltabox\Bulletin\groenenb\EHY_INFO\EHY_INFO.pdf';
if exist(EHY_infoFile,'file')
    % EHY_info
    button=uicontrol('Style', 'pushbutton', 'String','EHY_info',...
        'units','centimeters','Position',[0.5027 height-(iF+1)*0.7938 5.2917 0.5292],...
        'Callback', @EHY_info);
    uicontrol('Style','text',...
        'units','centimeters','Position',[6 height-(iF+1)*0.7938-0.1 12 0.5292],...
        'String','Collection of notes, tips and tricks for Deltares modellers','horizontalalignment','left');
end

% aboutEHY
button=uicontrol('Style', 'pushbutton', 'String','About EHY_tools',...
    'units','centimeters','Position',[0.5027 height-(iF+2)*0.7938 5.2917 0.5292],...
    'Callback', @aboutEHY);

% close button
button=uicontrol('Style', 'pushbutton', 'String','Close',...
    'units','centimeters','Position',[0.5027 height-(iF+3)*0.7938 5.2917 0.5292],...
    'Callback', @closeFig);

% status
hStatusText=uicontrol('Style','text',...
    'units','centimeters','Position',[6 height-(iF+3)*0.7938 12 0.5292],...
    'String','Status:  Please select a function','horizontalalignment','left',...
    'FontWeight','bold','foregroundcolor',[0 0.5 0],'fontSize',12);

    function runEHYscript(hObject,event)
        h=findall(0,'type','figure','name','EHY_TOOLS');
        set(h, 'pointer', 'watch')
        set(hStatusText,'String',...
            ['Status:  BUSY running ''' get(hObject,'String') ''''],'foregroundcolor',[1 0 0],'fontSize',12);
        run(get(hObject,'String'))
        set(h, 'pointer', 'arrow')
        set(hStatusText,'String',...
            'Status:  Please select a function','foregroundcolor',[0 0.5 0],'fontSize',12);
    end

    function closeFig(hObject,event)
        close(get(hObject,'Parent'))
    end

    function aboutEHY(hObject,event)
        msgbox({'This toolbox aims to help users of Delft3D-FM, Delft3D 4 and SIMONA',...
            'software in pre- and post-processing of simulations. The toolbox was',...
            'initially set-up and used within the group of Environmental',...
            'Hydrodynamics of Deltares, but is now a tool where other modellers can',...
            'benefit from and contribute to as well (OpenEarthTools philosophy).',...
            '',...
            'The scripts are created in such a way that they can be used interactively.',...
            'More experienced MATLAB-users can use the functions with input and output',...
            'arguments to adopt the functions in their scripts.',...
            '',...
            'Please check the outcomes carefully. Please use at your own risk.',...
            '',...
            'In case of questions/suggestions for improvements. Please contact:',...
            'Julien.Groenenboom@Deltares.nl'},'About EHY_tools');
    end

    function EHY_info(hObject,event)
        open(EHY_infoFile);
    end

end