function [handles] = read_ini(handles,varargin)

   % read_ini : reads the session file for nesthd


   %
   % Get filename ini file
   %

   if isempty(varargin)
      if ~isempty(handles.filedir); cd(handles.filedir); end
      [fin,pin] = uigetfile('*.ini','Name of Session file');
      cd (handles.progdir);

      if pin~=0
         handles.filedir = pin;
      end

      if fin ~= 0
         filename = [pin fin];
      else
         filename = '';
      end
   else
      filename = varargin{1};
   end

   %
   % Read Info structure from the nesthd_inifile
   %

   if ~isempty(filename)

      Info = inifile('open',filename);

      %
      % Which subsystem was active when saving the file?
      %

      handles.active = inifile('get',Info,'Subsystem','Active');

      switch handles.active
         case 'Nesthd1'
            handles.files_hd1{1}=inifile('get',Info,handles.active,'Overall model grid  ');
            handles.files_hd1{2}=inifile('get',Info,handles.active,'Detailed model grid ');
            handles.files_hd1{3}=inifile('get',Info,handles.active,'Boundary Definition ');
            handles.files_hd1{4}=inifile('get',Info,handles.active,'Observation Points  ');
            handles.files_hd1{5}=inifile('get',Info,handles.active,'Nest Administration ');
            handles.files_hd1{6}=inifile('get',Info,handles.active,'Enclosure           ');
            for i_file = 1: 6
                if isempty(handles.files_hd1{i_file}) handles.files_hd1{i_file} = ''; end
            end

         case 'Nesthd2'
            handles.files_hd2{1}=inifile('get',Info,handles.active,'Boundary definition             ');
            handles.files_hd2{2}=inifile('get',Info,handles.active,'Nest administration             ');
            handles.files_hd2{3}=inifile('get',Info,handles.active,'Overall result file             ');
            handles.files_hd2{4}=inifile('get',Info,handles.active,'Hydrodynamic Boundary conditions');
            handles.files_hd2{5}=inifile('get',Info,handles.active,'Transport Boundary Conditions   ');

            if ~isempty(handles.files_hd2{3}) && ~isempty(handles.files_hd2{1})
               handles.nfs_inf = nesthd_geninf (handles.files_hd2{3});
               [handles]       = nesthd_set_add_inf(handles);

               %
               % Get additional information
               %

               handles.add_inf.timeZone = 0;

               Chapter = 'Additional';
               try
                   handles.add_inf.timeZone = inifile('get',Info,Chapter,'Timezone                       ');
               end
               
               try
                   handles.add_inf.t_start = datenum(inifile('getstring',Info,Chapter,'TStart'),'yyyymmdd  HHMMSS');
                   handles.add_inf.t_stop  = datenum(inifile('getstring',Info,Chapter,'TStop' ),'yyyymmdd  HHMMSS');
               catch
                   handles.add_inf.t_start = NaN;
                   handles.add_inf.t_stop  = NaN;
               end
                   

               if handles.wlev
                  handles.add_inf.a0=inifile('get',Info,Chapter,'A0                             ');
               end
               if handles.conc
                  handles.add_inf.l_act=inifile('get',Info,Chapter,'Active                       ');
                  for l = 1: handles.nfs_inf.lstci
                     handles.add_inf.genconc(l)=inifile('get',Info,Chapter,['Genconc' num2str(l)]);
                     handles.add_inf.add(l)    =inifile('get',Info,Chapter,['Add' num2str(l)]    );
                     handles.add_inf.max(l)    =inifile('get',Info,Chapter,['Max' num2str(l)]    );
                     handles.add_inf.min(l)    =inifile('get',Info,Chapter,['Min' num2str(l)]    );
                  end
               end
               if handles.vel || (handles.nfs_inf.lstci >= 1 && sum(handles.add_inf.genconc) > 0)
                   try
                       handles.add_inf.profile=inifile('get',Info,Chapter,'Profile                   ');
                   catch
                       handles.add_inf.profile='uniform';
                   end
               end
            end
      end
   end


