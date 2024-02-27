function handles = ini_ui(handles)

% ini_ui : Initializes nesthd ui

handles.progdir           = pwd;
handles.filedir           = '';
handles.files_hd1         = {'' '' '' '' '' ''};
handles.files_hd2         = {'' '' '' '' ''};
handles.run_nesthd1_onoff = 'off';
handles.run_nesthd2_onoff = 'off';
handles.bcc_onoff         = 'off';
handles.wlev              = false;
handles.vel               = false;
handles.conc              = false;
handles.add_inf.timeZone  = 0;
handles.add_inf.a0        = 0.0;

