function EHY_stamp(genInp,varargin)
%  Adds a small "stamp" with the location indication (whith Thalweg and where exactly measured, name of the Location) to the current axes
%  After execution, contral is given back to the original (current) axes.
%
%  First beta version
%
%  General information is profided through the first input argument of the functiom ("genInp"). It can eithet be:
%
%  A structure containing the Fields:
%  - Position: a four vector array with the position [x0,y0,lenx, leny] of the location figure within the current axes
%              Positions are given in relative coordinates! You wil have to experiment a bit with contents of Position 
%              to get the desired location figure.
%  - Xlim    : start and ending x-coordinate of the location figure
%  - Ylim    : start and ending y-coordinate of the location figure (the end coordinate is recomputed internally to ensure
%              equidistant x and y axis. TODO: ensure that that also works in case of geographical coordinates)
%  - fileLdb : Cell array with ldb file(s). The first one is considered the "master" and is plotted in black. 
%              The following ones are "slaves" and plotted in red.
%
%  Or, much better because plotting should be steered by an input file, the name of a windows ini file with the same information:
% [Location]
% Position = [0.80 0.500 0.19 0.48]
% Xlim     = [ 62000   68000]
% Ylim     = [424000     NaN]
% [Landboundary]
% fileLdb = p:\11205256-haringvliet2020\ldb\2017-10_31b_gp3.ldb
% putA    = p:\11205256-haringvliet2020\berekeningen_2020\initialSalinity\PutA_adjusted.pol
% putB    = p:\11205256-haringvliet2020\berekeningen_2020\initialSalinity\PutB_adjusted.pol
% putC    = p:\11205256-haringvliet2020\berekeningen_2020\initialSalinity\PutC_adjusted.pol
% putD    = p:\11205256-haringvliet2020\berekeningen_2020\initialSalinity\PutD_adjusted.pol
% 
% The following <keyword/value pairs are implemented (TODO: allow for more Locations to be plotted in one go):
%
% For "station information:
% Location - Name of the Location (station)
% measLoc  - Structure with fields x and y with the coordinates of the location (station)
%
% For cross section plots:
% thalweg  = ldb file withthe saide track (basically a normal ldb, however big dots plotted at begin and end point)
%
% Examples:
% from BP_ztplot     : EHY_stamp(USER.Stamp,'measLoc',measLoc,'location',stationname); 
% from BP_crossection: EHY_stamp(USER.Stamp,'measLoc',measLoc,'thalweg',USER.thalweg); 
%
%% Initialise
fileCrs      = '';
OPT.measLoc  = '';
OPT.thalweg  = '';
OPT.location = '';
OPT.rescaleLatLonAxis = 1;
OPT          = setproperty(OPT,varargin);
if ~isempty(OPT.thalweg); fileCrs = OPT.thalweg; end

%% General settings
if isstruct(genInp)
     %  from a user supplied structure    
     pos_stamp = genInp.Position;
     Xlim      = genInp.Xlim;
     Ylim      = genInp.Ylim;
     fileLdb   = genInp.fileLdb;
elseif exist(genInp,'file')
    %  or from a user supplied windows ini file
    Info        = inifile('open'    ,fileInp);
    chapters    = inifile('chapters',Info   );
    
    %  Location information
    pos_stamp   = eval(inifile('get',Info   ,'Location','Position'));
    Xlim        = eval(inifile('get',Info   ,'Location','Xlim'));
    Ylim        = eval(inifile('get',Info   ,'Location','Ylim'));
    
    %  Landboundary
    keyWords    = inifile('keywords',Info,'Landboundary');
    for i_ldb = 1: length(keyWords)
        fileLdb{i_ldb}     = inifile('get',Info,'Landboundary',keyWords{i_ldb});
    end
    
    %  Measurement section (thalweg, sailed track) if defined
    if ~isempty(get_nr(chapters,'Thalweg')) && isempty(fileCrs)
        fileCrs = inifile('get',Info,'Thalweg','fileCrs');
    end
end

%% Begin location plot: Start with setting original axes to normalized
originalAxes = gca;
set(gca,'Units','normalized');

%% Define new axis in the existing axes (for some reason retrieving 'Position' directly from gca doe not always work??????)
tmp      = get(gca);
position = tmp.Position;
newAxes  = axes('Units','normalized','Position',[position(1) + pos_stamp(1)*position(3)   position(2) + pos_stamp(2)*position(4)  pos_stamp(3)*position(3)  pos_stamp(4)*position(4)]);

%% Read the landboundaries to plot
no_ldb = length(fileLdb);
for i_ldb = 1: no_ldb
    LDB(i_ldb)     = readldb(fileLdb{i_ldb});
    LDB(i_ldb).y(LDB(i_ldb).x == 999.999) = NaN;
    LDB(i_ldb).x(LDB(i_ldb).x == 999.999) = NaN;
end

%% First, the sailed path
if ~isempty(fileCrs)
    CRS     = readldb(fileCrs);
    CRS.y(CRS.x == 999.999) = NaN;
    CRS.x(CRS.x == 999.999) = NaN;
    plot(CRS.x     ,CRS.y     ,'r' ,'LineWidth',1.0);hold on
    plot(CRS.x(  1),CRS.y(  1),'r.','MarkerSize',25);hold on
    plot(CRS.x(end),CRS.y(end),'r.','MarkerSize',15);hold on
end

%% Next: Plot the landboundaries (several ldb's first one is the "boss")
for i_ldb = 1: no_ldb
    if i_ldb == 1 plot(LDB(i_ldb).x,LDB(i_ldb).y,'k'); hold on; end
    if i_ldb >= 2 plot(LDB(i_ldb).x,LDB(i_ldb).y,'r'); hold on; end
end

%% Plot the measurement locations
if ~isempty(OPT.measLoc.x) && isempty(OPT.location)
    plot(OPT.measLoc.x,OPT.measLoc.y,'k.','MarkerSize',7.5);hold on
end

%% Add annotation with the location
if ~isempty (OPT.measLoc.x) && ~isempty(OPT.location)  
    plot(OPT.measLoc.x,OPT.measLoc.y,'r.'              ,'MarkerSize',20   );hold on;
    text(OPT.measLoc.x,OPT.measLoc.y,[' ' OPT.location],'Color'     ,'red');hold on;
end

%% Set axis etc
set(gca,'Units','centimeters');
position = get(gca,'Position');
Ylim(2)   = Ylim(1) + (position(4)/position(3))*(Xlim(2) - Xlim(1));
set(gca,'Xlim' ,Xlim,'Ylim' ,Ylim);
set(gca,'Xtick',  [],'Ytick',  [],'Box','on');
% scale axes
if OPT.rescaleLatLonAxis && max(abs(Xlim))<=180 && max(abs(Ylim))<=90
	disp('Scaling axes for WGS84')
	EHY_plot_satellite_map('plot_map',0);
end

%% Restore to original axes
set(gcf,'CurrentAxes',originalAxes);

end
