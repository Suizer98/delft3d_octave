function simona2mdf_message(string,varargin)

% message: writes general information to screen
%
%% set the defaults
OPT.nesthd_path = getenv_np('nesthd_path');
OPT.Window      = 'SIMINP2MDF Message';
OPT.Logo        = '';
OPT.Logo2       = '';
OPT.n_sec       = 1;
OPT.Close       = false;

%% Override the defaults
OPT = setproperty(OPT,varargin);

%% No logo's specified but nesthd path set, set logo's depending on window name
if ~isempty(OPT.nesthd_path) && isempty(OPT.Logo)
    if ~isempty(strfind(lower(OPT.Window),'siminp')) 
        OPT.Logo        = imread([OPT.nesthd_path filesep 'bin' filesep 'simona_logo.jpg']);
    elseif ~isempty(strfind(lower(OPT.Window),'dflowfm')) || ~isempty(strfind(lower(OPT.Window),'nesthd'))
        OPT.Logo        = imread([OPT.nesthd_path filesep 'bin' filesep 'dflowfm.jpg']    );
    end
end

if ~isempty(OPT.nesthd_path) && isempty(OPT.Logo2)
    OPT.Logo2       =        [OPT.nesthd_path filesep 'bin' filesep 'deltares.gif'];
    if ~isempty(strfind(lower(OPT.Window),'nesthd'))
        OPT.Logo2       =        [OPT.nesthd_path filesep 'bin' filesep 'dflowfm.jpg'];
    end
end

%% Display the message/warning box

if ~isempty(OPT.Logo)
    h_warn   = msgbox(string,OPT.Window,'Custom',OPT.Logo,[],'replace');
else
    h_warn   = msgbox(string,OPT.Window,'replace');
end

if ~isempty(OPT.Logo2)
    simona2mdf_legalornot(h_warn,OPT.Logo2)
end

delete(findobj(h_warn,'string','OK'));
uiwait(h_warn,OPT.n_sec);

%% Close message box if requested
if OPT.Close
    close (h_warn);
    pause (1);
end
