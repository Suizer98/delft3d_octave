clear all;

i=0;

%% Water Level

i=i+1;

% General
parameters(i).parameter.longname='Water level';
parameters(i).parameter.shortname='wl';
parameters(i).parameter.unit='m';
parameters(i).parameter.type='magnitude';

% Sources
j=0;

j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='water_level';
parameters(i).parameter.sources(j).source.dbname='WL';

j=j+1;
parameters(i).parameter.sources(j).source.type='co-ops';
parameters(i).parameter.sources(j).source.name='Water Level';
parameters(i).parameter.sources(j).source.dbname='WL';

j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='waterlevel';
parameters(i).parameter.sources(j).source.dbname='waterlevel';

%% Models
j=0;

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflow';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='water level';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='water level';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='water level';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='water level';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';

%% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Water level';
parameters(i).parameter.plots(j).plot.ylabel='water level';
parameters(i).parameter.plots(j).plot.ylimtype='sym';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Water level';
parameters(i).parameter.plots(j).plot.climtype='sym';

%% Significant wave height

i=i+1;

% General
parameters(i).parameter.longname='Significant wave height';
parameters(i).parameter.shortname='hs';
parameters(i).parameter.unit='m';
parameters(i).parameter.type='magnitude';

% Sources
j=0;
j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='wave_height';
parameters(i).parameter.sources(j).source.dbname='Hs';
% j=j+1;
% parameters(i).parameter.sources(j).source.type='co-ops';
% parameters(i).parameter.sources(j).source.name='wave_height';
j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='wave_height_hm0';
parameters(i).parameter.sources(j).source.dbname='wave_height_hm0';

% Models
j=0;
j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflow';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='wavm';

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='wavm';

j=j+1;

k=0;
k=k+1;
parameters(i).parameter.models(j).model.type='ww3';
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='tab33';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='significant wave height';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='grads';

% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Significant wave height';
parameters(i).parameter.plots(j).plot.ylabel='wave height (m)';
parameters(i).parameter.plots(j).plot.ylimtype='positive';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Significant wave height';
parameters(i).parameter.plots(j).plot.climtype='positive';


%% Peak wave period

i=i+1;

% General
parameters(i).parameter.longname='Peak wave period';
parameters(i).parameter.shortname='tp';
parameters(i).parameter.unit='s';
parameters(i).parameter.type='magnitude';

% Sources
j=0;
j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='dominant_wpd';
parameters(i).parameter.sources(j).source.dbname='Tp';
% j=j+1;
% parameters(i).parameter.sources(j).source.type='co-ops';
% parameters(i).parameter.sources(j).source.name='dominant_wpd';
j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='wave_period_tp';
parameters(i).parameter.sources(j).source.dbname='wave_period_tp';

% Models
j=0;

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='peak wave period';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='smoothed peak period';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='wavm';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='peak wave period'; % dummy
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='tab33';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='peak wave period'; % dummy
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='grads';

% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Peak wave period';
parameters(i).parameter.plots(j).plot.ylabel='wave period (s)';
parameters(i).parameter.plots(j).plot.ylimtype='positive';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Peak wave period';
parameters(i).parameter.plots(j).plot.climtype='positive';


%% Mean wave direction

i=i+1;

% General
parameters(i).parameter.longname='Mean wave direction';
parameters(i).parameter.shortname='wavdir';
parameters(i).parameter.unit='deg';
parameters(i).parameter.type='angle';

% Sources
j=0;
j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='mean_wave_dir';
parameters(i).parameter.sources(j).source.dbname='WavDir';
% j=j+1;
% parameters(i).parameter.sources(j).source.type='co-ops';
% parameters(i).parameter.sources(j).source.name='mean_wave_dir';
j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='mean_wave_dir';
parameters(i).parameter.sources(j).source.dbname='mean_wave_dir';

% Models
j=0;

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave direction';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='hsig wave vector (mean direction)';
parameters(i).parameter.models(j).model.datatypes(k).datatype.component='angle (degrees)';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='wavm';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave direction'; % dummy
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='tab33';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave direction'; % dummy
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='grads';

% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Mean wave direction';
parameters(i).parameter.plots(j).plot.ylabel='mean wave direction (deg)';
parameters(i).parameter.plots(j).plot.ylimtype='angle';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Mean wave direction';
parameters(i).parameter.plots(j).plot.climtype='angle';


%% Wave vector

i=i+1;

% General
parameters(i).parameter.longname='Wave vector';
parameters(i).parameter.shortname='wavvec';
parameters(i).parameter.unit='m';
parameters(i).parameter.type='vector';

% Sources
% j=0;
% j=j+1;
% parameters(i).parameter.sources(j).source.type='ndbc';
% parameters(i).parameter.sources(j).source.name='mean_wave_dir';
% j=j+1;
% parameters(i).parameter.sources(j).source.type='co-ops';
% parameters(i).parameter.sources(j).source.name='mean_wave_dir';
% j=j+1;
% parameters(i).parameter.sources(j).source.type='matroos';
% parameters(i).parameter.sources(j).source.name='mean_wave_dir';

% Models
j=0;
j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

% parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave direction';
% parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trih';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='hsig wave vector (mean direction)';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='wavm';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

% k=k+1;
% parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave vector'; % dummy
% parameters(i).parameter.models(j).model.datatypes(k).datatype.file='tab33';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wave vector'; % dummy
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='grads';

% Plots
j=0;

% j=j+1;
% parameters(i).parameter.plots(j).plot.type='timeseries';
% parameters(i).parameter.plots(j).plot.title='Mean wave direction';
% parameters(i).parameter.plots(j).plot.ylabel='mean wave direction (deg)';
% parameters(i).parameter.plots(j).plot.ylimtype='angle';
j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Wave vector (mean direction)';
%parameters(i).parameter.plots(j).plot.climtype='angle';


%% Wind speed

i=i+1;

% General
parameters(i).parameter.longname='Wind speed';
parameters(i).parameter.shortname='windvel';
parameters(i).parameter.unit='m/s';
parameters(i).parameter.type='magnitude';

% Sources
j=0;

j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='wind_spd';
parameters(i).parameter.sources(j).source.dbname='WndSpeed';

j=j+1;
parameters(i).parameter.sources(j).source.type='co-ops';
parameters(i).parameter.sources(j).source.name='wind_spd';
parameters(i).parameter.sources(j).source.dbname='Winds';

j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='wind_speed';
parameters(i).parameter.sources(j).source.dbname='wind_speed';

% Models
j=0;
j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflow';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wind velocity';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';
parameters(i).parameter.models(j).model.datatypes(k).datatype.component='magnitude';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wind speed';
parameters(i).parameter.models(j).model.datatypes(k).datatype.component='magnitude';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Wind speed';
parameters(i).parameter.plots(j).plot.ylabel='wind speed (m/s)';
parameters(i).parameter.plots(j).plot.ylimtype='positive';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Wind speed';
parameters(i).parameter.plots(j).plot.climtype='positive';


%% Wind direction

i=i+1;

% General
parameters(i).parameter.longname='Wind direction';
parameters(i).parameter.shortname='winddir';
parameters(i).parameter.unit='deg';
parameters(i).parameter.type='angle';

% Sources
j=0;

j=j+1;
parameters(i).parameter.sources(j).source.type='ndbc';
parameters(i).parameter.sources(j).source.name='wind_dir';
parameters(i).parameter.sources(j).source.dbname='WndDir';

j=j+1;
parameters(i).parameter.sources(j).source.type='co-ops';
parameters(i).parameter.sources(j).source.name='wind_dir';
parameters(i).parameter.sources(j).source.dbname='Winds';

j=j+1;
parameters(i).parameter.sources(j).source.type='matroos';
parameters(i).parameter.sources(j).source.name='wind_direction';
parameters(i).parameter.sources(j).source.dbname='wind_direction';

% Models
j=0;
j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflow';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wind velocity';
parameters(i).parameter.models(j).model.datatypes(k).datatype.component='angle (degrees)';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.name='wind speed';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='trim';
parameters(i).parameter.models(j).model.datatypes(k).datatype.component='magnitude';

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='timeseries';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';


k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

% Plots
j=0;

j=j+1;
parameters(i).parameter.plots(j).plot.type='timeseries';
parameters(i).parameter.plots(j).plot.title='Wind direction';
parameters(i).parameter.plots(j).plot.ylabel='wind direction (deg)';
parameters(i).parameter.plots(j).plot.ylimtype='angle';

j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Wind direction';
parameters(i).parameter.plots(j).plot.climtype='positive';


%% Wind vector

i=i+1;

% General
parameters(i).parameter.longname='Wind vector';
parameters(i).parameter.shortname='windvec';
parameters(i).parameter.unit='m/s';
parameters(i).parameter.type='vector';

% Models
j=0;

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflow';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='delft3dflowwave';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.type='map';
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

j=j+1;
parameters(i).parameter.models(j).model.type='ww3';

k=0;

k=k+1;
parameters(i).parameter.models(j).model.datatypes(k).datatype.file='meteo';
parameters(i).parameter.models(j).model.datatypes(k).datatype.ucomponent='u';
parameters(i).parameter.models(j).model.datatypes(k).datatype.vcomponent='v';

% Plots
j=0;

% j=j+1;
% parameters(i).parameter.plots(j).plot.type='timeseries';
% parameters(i).parameter.plots(j).plot.title='Wind vector';
% parameters(i).parameter.plots(j).plot.ylabel='wind vector (m/s)';
% parameters(i).parameter.plots(j).plot.ylimtype='positive';
j=j+1;
parameters(i).parameter.plots(j).plot.type='map';
parameters(i).parameter.plots(j).plot.title='Wind vector';
%parameters(i).parameter.plots(j).plot.climtype='positive';

xml_save('parameters.xml',parameters,'off');
