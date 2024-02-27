function configuration=ddb_read_configuration_xml(config_file)

% Read in delftdashboard xml file to determine which models,
% toolboxes etc. to include. Store data in handles.configuration

% Read xml file
xml=xml2struct(config_file,'structuretype','long');

% First check which models to include
configuration.include_models={'all'};
if isfield(xml,'include_models')
    for j=1:length(xml.include_models.include_models.model)
        configuration.include_models{j}=xml.include_models.include_models.model(j).model.value;
    end
end

% First check which toolboxes to include
configuration.include_toolboxes={'all'};
if isfield(xml,'include_toolboxes')
    for j=1:length(xml.include_toolboxes.include_toolboxes.toolbox)
        configuration.include_toolboxes{j}=xml.include_toolboxes.include_toolboxes.toolbox(j).toolbox.value;
    end
end

configuration.include_toolboxes_no_gui=[];
if isfield(xml,'include_toolboxes')
    for j=1:length(xml.include_toolboxes_no_gui.include_toolboxes_no_gui.toolbox)
        configuration.include_toolboxes_no_gui{j}=xml.include_toolboxes_no_gui.include_toolboxes_no_gui.toolbox(j).toolbox.value;
    end
end

% First check which toolboxes to include
configuration.include_bathymetry={'all'};
if isfield(xml,'include_bathymetry')
    for j=1:length(xml.include_bathymetry.include_bathymetry.bathymetry)
        configuration.include_bathymetry{j}=xml.include_bathymetry.include_bathymetry.bathymetry(j).bathymetry.value;
    end
end

% Default coordinate system
configuration.cs.name='WGS 84';
configuration.cs.type='geographic';
if isfield(xml,'coordinate_system')
    configuration.cs.name=xml.coordinate_system.coordinate_system.name.name.value;
    tp=xml.coordinate_system.coordinate_system.type.type.value;
    switch lower(tp(1:3))
        case{'pro','car'}
            configuration.cs.type='cartesian';
        otherwise
            configuration.cs.type='geographic';
    end
end

% Default background map
configuration.background_image='bathymetry';
if isfield(xml,'background_image')
    configuration.background_image=xml.background_image.background_image.value;
end


if isfield(xml,'xlim') && isfield(xml,'ylim')
    configuration.xlim=str2num(xml.xlim.xlim.value);
    configuration.ylim=str2num(xml.ylim.ylim.value);   
else
    configuration.xlim=[];
    configuration.ylim=[];
end


% Default bathymetry
configuration.bathymetry='';
if isfield(xml,'bathymetry')
    configuration.bathymetry=xml.bathymetry.bathymetry.value;
end

configuration.include_tide_models=1;
if isfield(xml,'include_tide_models')
    if lower(xml.include_tide_models.include_tide_models.value(1))=='n'
        configuration.include_tide_models=0;
    end
end

% Title
configuration.title='Delft Dashboard';
if isfield(xml,'title')
    configuration.title = xml.title.title.value;
end

% Splash screen
configuration.splash_screen='delftdashboard.jpg';
if isfield(xml,'splashscreen')
    configuration.splash_screen = xml.splashscreen.splashscreen.value;
end

configuration.include_menu_shoreline=1;
configuration.include_menu_coordinate_system=1;
configuration.include_menu_options=1;

if isfield(xml,'include_menu_coordinate_system')
    if strcmpi(xml.include_menu_coordinate_system.include_menu_coordinate_system.value.value.value(1),'n')
        configuration.include_menu_coordinate_system=0;
    end    
end

if isfield(xml,'include_menu_options')
    if strcmpi(xml.include_menu_options.include_menu_options.value.value.value(1),'n')
        configuration.include_menu_options=0;
    end    
end

if isfield(xml,'include_menu_shoreline')
    if strcmpi(xml.include_menu_shoreline.include_menu_shoreline.value.value.value(1),'n')
        configuration.include_menu_shoreline=0;
    end    
end

% Help menu
if isfield(xml,'menu_help')
    for j=1:length(xml.menu_help)
        configuration.menu_help(j).menu_help.text      = xml.menu_help(j).menu_help.text.text.value;
        if isfield(xml.menu_help(j).menu_help,'url')
            configuration.menu_help(j).menu_help.url      = xml.menu_help(j).menu_help.url.url.value;
        else
            configuration.menu_help(j).menu_help.callback = str2func(xml.menu_help(j).menu_help.callback.callback.value);
        end
    end
else
    configuration.menu_help(1).menu_help.text      = 'Deltares Online';
    configuration.menu_help(1).menu_help.url       = 'https://www.deltares.nl/en/';
    configuration.menu_help(2).menu_help.text      = 'Delft Dashboard Online';
    configuration.menu_help(2).menu_help.url       = 'http://public.deltares.nl/display/OET/DelftDashboard';
    configuration.menu_help(3).menu_help.text      = 'About Delft Dashboard';
    configuration.menu_help(3).menu_help.callback  = str2func('ddb_aboutDelftDashBoard');
end
