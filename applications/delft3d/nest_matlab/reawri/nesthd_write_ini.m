function [handles] = write_ini(handles)

% write_ini : Writes session file for nesthd

%
% Open Info structure to write to nesthd_inifile
%

Info = inifile('new');

%
% Fill Info
%

Chapter = 'Subsystem';

active = '';

if strcmpi(get(handles.files_nesthd1,'Visible'),'on')
    active = 'Nesthd1';
elseif strcmpi(get(handles.files_nesthd2,'Visible'),'on')
    active = 'Nesthd2';
end

Info=inifile('set',Info,Chapter,'Active',active);

for ifile = 1: 6
    if isempty(handles.files_hd1{ifile})
        handles.files_hd1{ifile} = '';
    end
    if ifile < 6
       if isempty(handles.files_hd2{ifile})
          handles.files_hd2{ifile} = '';
       end
    end
end

Chapter = 'Nesthd1';
Info=inifile('set',Info,Chapter,'Overall model grid  ',handles.files_hd1{1});
Info=inifile('set',Info,Chapter,'Detailed model grid ',handles.files_hd1{2});
Info=inifile('set',Info,Chapter,'Boundary Definition ',handles.files_hd1{3});
Info=inifile('set',Info,Chapter,'Observation Points  ',handles.files_hd1{4});
Info=inifile('set',Info,Chapter,'Nest Administration ',handles.files_hd1{5});
Info=inifile('set',Info,Chapter,'Enclosure           ',handles.files_hd1{6});

Chapter = 'Nesthd2';
Info=inifile('set',Info,Chapter,'Boundary definition             ',handles.files_hd2{1});
Info=inifile('set',Info,Chapter,'Nest administration             ',handles.files_hd2{2});
Info=inifile('set',Info,Chapter,'Overall result file             ',handles.files_hd2{3});
Info=inifile('set',Info,Chapter,'Hydrodynamic Boundary conditions',handles.files_hd2{4});
Info=inifile('set',Info,Chapter,'Transport Boundary Conditions   ',handles.files_hd2{5});

Chapter = 'Additional';
if isfield(handles,'add_inf') && strcmpi(active,'nesthd2')
    Info    = inifile('set',Info,Chapter,'Timezone                        ',handles.add_inf.timeZone);
    Info    = inifile('set',Info,Chapter,'TStart                          ',datestr(handles.add_inf.t_start,'yyyymmdd  HHMMSS'));
    Info    = inifile('set',Info,Chapter,'TStop                           ',datestr(handles.add_inf.t_stop ,'yyyymmdd  HHMMSS'));
    
    if handles.wlev
        Info=inifile('set',Info,Chapter,'A0                              ',handles.add_inf.a0);
    end
    if handles.vel
        Info=inifile('set',Info,Chapter,'Profile                         ',handles.add_inf.profile);
    end
    if handles.conc
        if sum(handles.add_inf.genconc > 0)
            Info=inifile('set',Info,Chapter,'Profile                         ',handles.add_inf.profile);
        end

        Info=inifile('set',Info,Chapter,'Active                          ',handles.l_act);
        for l = 1: handles.nfs_inf.lstci
            Info=inifile('set',Info,Chapter,['Genconc' num2str(l)]        ,handles.add_inf.genconc(l));
            Info=inifile('set',Info,Chapter,['Add' num2str(l)]            ,handles.add_inf.add(l));
            Info=inifile('set',Info,Chapter,['Max' num2str(l)]            ,handles.add_inf.max(l));
            Info=inifile('set',Info,Chapter,['Min' num2str(l)]            ,handles.add_inf.min(l));
        end
    end
end

%
% Get the name of the ini file
%

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uiputfile('*.ini','Name of Session file');
cd (handles.progdir);

if pin~= 0
    handles.filedir = pin;

   %
   % Write to file
   %

   inifile('write',[pin fin],Info);
end
