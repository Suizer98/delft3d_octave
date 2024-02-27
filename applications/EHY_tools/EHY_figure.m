function [fh,ah,a_aspect] = EHY_figure(varargin)
%% [fh,ah,a_aspect] = EHY_figure(varargin)

%% Default settings

% figure settings
OPT.Visible          = 'on';
OPT.Color            = 'w';
OPT.units            = 'centimeters';
OPT.PaperType        = 'A4';
OPT.PaperUnits       = 'Centimeters';
OPT.PaperOrientation = 'Portrait';
OPT.Renderer         = 'zbuffer';

fig_props = fieldnames(OPT);

OPT.width   = 14.5; % in OPT.units (cm)
OPT.height  = 5.25; % in OPT.units (cm)

% axes settings
OPT.no_sub   = 1;   % number of subplots
OPT.left     = 1.3; % left margin in OPT.units (cm)
OPT.right    = 0.9; % right margin in OPT.units (cm)
OPT.upper    = 0.3; % upper margin in OPT.units (cm)
OPT.lower    = 0.5; % lower margin in OPT.units (cm)
OPT.box      = 'on';
OPT.grid     = 'on';
OPT.hold     = 'on';
OPT.fontsize = 8;
OPT.subOrientation = 'vert';

% setproperty
if nargin > 0
    OPT = setproperty(OPT,varargin);
end

%% Create figure and set properties
fh = figure('Visible',OPT.Visible); % create figure

for iP = 1:length(fig_props)
    set(fh,fig_props{iP},OPT.(fig_props{iP})); % set properties
end

set(0,'units',OPT.units); % get screen size in OPT.units (cm)
scr = get(0,'ScreenSize'); % [left,bottom,width,height] in OPT.units (cm)

Left   = (scr(3) - OPT.width) / 2;
Bottom = min(((scr(4) - OPT.height) / 2), (scr(4) - OPT.height - 1.8));

set(fh,'Position',[Left Bottom OPT.width OPT.height]);

%% Creates subplots and set properties
for i_sub = 1:OPT.no_sub
    fig_pos = get(fh,'Position');
    
    switch lower(OPT.subOrientation(1))
        case 'v' % vertical
            height = (fig_pos(4) - (OPT.no_sub * (OPT.upper + OPT.lower))) / OPT.no_sub;
            width  = fig_pos(3) - (OPT.left + OPT.right);
            bottom = (OPT.no_sub - i_sub) * (OPT.lower + OPT.upper + height) + OPT.lower;
            left   = OPT.left;
        case 'h' % horizontal
            height = fig_pos(4) - (OPT.upper + OPT.lower);
            width  = (fig_pos(3) - (OPT.no_sub * (OPT.left  + OPT.right))) / OPT.no_sub;
            bottom = OPT.lower;
            left   = (i_sub - 1) * (OPT.left + OPT.right + width) + OPT.left;
    end
    
    a_aspect = width / height;
    
    height = height / fig_pos(4);
    width  = width / fig_pos(3);
    bottom = bottom / fig_pos(4);
    left   = left / fig_pos(3);
    
    ah(i_sub) = axes('position',[left bottom  width  height]);
    set(ah(i_sub),'fontsize',OPT.fontsize);
    if strcmpi(OPT.box,'on');   box on; end
    if strcmpi(OPT.grid,'on'); grid on; end
    if strcmpi(OPT.hold,'on'); hold on; end
end

%% Set PaperPosition
set(fh,'PaperPosition',[0 0 OPT.width OPT.height]);
