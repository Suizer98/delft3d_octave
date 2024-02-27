function varargout = ITHK_KMLtextballoon(lon,lat,varargin)

%% keyword,value
OPT.name = ''; 
OPT.icon = '';
OPT.timeIn = [];
OPT.timeOut = [];
OPT.lookAt = 0;         % lookAt option disabled by default. Enable lookat by using keyword value option : 'lookAt',1
OPT.logo = 'http://www.ecoshape.nl/eco-logo.jpg';
OPT.text_array = '';
OPT = setproperty(OPT,varargin);
        
%% Pre-process
name = ['<name>' OPT.name '</name>'];
icon = ['<href>' OPT.icon '</href>'];
longitude = ['<longitude>' num2str(lon) '</longitude>'];
latitude  = ['<latitude>' num2str(lat) '</latitude>']; 
coordinates = ['<coordinates>' num2str(lon) ',' num2str(lat) ',0</coordinates>'];

%% Set TimeSpan
timespan = KML_timespan('timeIn',OPT.timeIn,'timeOut',OPT.timeOut);

%% Set Icon & Balloon
style  = sprintf([...
    '<Style id="icon_style">\n'...
    '<IconStyle>\n'...
    '<Icon>\n'...
    '%s\n'...                       
    '</Icon>\n'...
    '</IconStyle>\n'...
    '<BalloonStyle>\n'...
    '<text></text>\n'...                       
    '</BalloonStyle>\n'...
    '</Style>\n'],...
    icon);


%% Set description
description_1  = sprintf([...
    '<Placemark>\n'...
    '%s\n'...   %name
    '%s\n'...   %timespan
	'<Snippet maxLines="0"></Snippet>\n'...
	'<description><![CDATA[\n'],...
    name,timespan);

input_text = '';
for ii=1:length(OPT.text_array)
    input_text = sprintf([input_text OPT.text_array{ii} '\n']);
end

if OPT.lookAt == 1
    description_2 = sprintf([']]></description>\n'...
        '<LookAt>\n'...
        '%s\n'...  %lon
        '%s\n'...  %lat
        '<altitude>0</altitude>\n'...
        '<heading>0</heading>\n'...
        '<tilt>0</tilt>\n'...
        '<range>24000</range>\n'...
        '</LookAt>\n'...
        '<styleUrl>#icon_style</styleUrl>\n'...
        '<Point>\n'...
        '%s\n'...    %coordinates
        '</Point>\n'...
        '</Placemark>\n'],...
        longitude,latitude,coordinates);
else
    description_2 = sprintf([']]></description>\n'...
        '<styleUrl>#icon_style</styleUrl>\n'...
        '<Point>\n'...
        '%s\n'...    %coordinates
        '</Point>\n'...
        '</Placemark>\n'],...
        coordinates);
end

%% generate output

   output = sprintf([...
    '%s'... 
    '%s'...    
    '%s'...                        
    '%s'],...
    style,description_1,input_text,description_2);  
    varargout = {output};

%% EOF