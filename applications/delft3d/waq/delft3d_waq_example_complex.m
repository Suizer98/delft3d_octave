%DELFT3D_WAQ_EXAMPLE_COMPLEX  Example matlab script for batch-plotting delwaq map info
%
%See also: DELFT3D_WAQ_EXAMPLE_SIMPLE, DELWAQ (in 'C:\Delft3D\w32\matlab\')

% © TU Delft, G.J. de Boer <g.j.deboer@tudelft.nl> Dec. 2004 - Oct 2007

% $Id: delft3d_waq_example_complex.m 3207 2010-10-29 09:41:28Z boer_g $
% $Date: 2010-10-29 17:41:28 +0800 (Fri, 29 Oct 2010) $
% $Author: boer_g $
% $Revision: 3207 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_example_complex.m $

% Missing m-files can be obtained by running:
% >> addpath(genpath('C:\Delft3D\w32\matlab\'))

%% Initialize

   OPT.pause          = 1;
   OPT.export         = 0;
   
   OPT.waq.directory  = 'W:\bulletin\boer_g\PPT\WAQ\';
   OPT.waq.RUNIDs     = {'hydrobia_year_2'};
   
   OPT.flow.directory = 'W:\bulletin\boer_g\PPT\WAQ\';
   OPT.flow.RUNID     = 's02-2d';
   
   OPT.layer          = 1;
   read.subs_names    = {'hydrobia'               };
   read.subs_labels   = {'carbon biomass hydrobia'};
   read.subs_scales   = {[0 50]                   };
   read.subs_units    = {'[g/m3]'                 };


%% Loops over time and substances

for iRUNID = 1:length(OPT.waq.RUNIDs)

   OPT.waq.RUNID     = OPT.waq.RUNIDs{iRUNID};
   
   %% Open files

   GRID              = delwaq_meshgrid2dcorcen([OPT.flow.directory,filesep,OPT.flow.RUNID,'.lga']); % needs also *.cco
   
   %-try-% pcolorcorcen(GRID.cor.x,GRID.cor.y,GRID.cen.Index)

   WAQ.file          = delwaq('open',[OPT.waq.directory,filesep,OPT.waq.RUNID,'.map']);
   TIME              = delwaq_time(WAQ.file);

   %-try-% delwaq_disp(WAQ.file)
   
           % Nr.   SubsName:
           % ---   ------------->
           % 001 : 'hydrobia'
           % ---   ------------->
           % Reading times ...
           % Nr.   Date:
           % ---   ------------->
           % 001 : 01-Jan-1998 00:00:00
           % 042 : 05-Jan-1999 00:00:00
           % dt = 777600 s
           % ---   ------------->   
  
      %% Get index of substance names

      read.subs_index = delwaq_subsname2index(WAQ.file.SubsName,read.subs_names,'exact');
   
      %% Loops over time and substances

      for it=1:length(TIME.datenum)
      
         for isub=1:length(read.subs_names)
         
            subs_name = read.subs_names{isub};
            
            %% Read 1D WAQ vector

           [WAQ.datenum,...
            WAQ.(subs_name)] = delwaq('read',WAQ.file,read.subs_index(isub),0,it);
            
            %% Put 1D WAQ vector back into full FLOW array
            
            FLOW.(subs_name)    = waq2flow3d(WAQ.(subs_name),GRID.Index,'center');

            %% plot FLOW array

            pcolorcorcen(GRID.cor.x,GRID.cor.y,FLOW.(subs_name)(:,:,OPT.layer));
           
            hold on

            %% lay-out
            title([datestr(WAQ.datenum,0),'   layer:',num2str(OPT.layer)])

            caxis             (read.subs_scales{isub});
            colorbarwithtitle({read.subs_labels{isub},...
                               read.subs_units{isub}})
            grid on
            axis equal 
            axis ([100 215 535 625].*1e3)
            tickmap('xy')
            
            %% Export
	    
            if OPT.export
               fpath = [OPT.directory,RUNID,'_',read.subs_names{isub}];
               mkpath(fpath)
              %print([fpath,filesep,RUNID,'_',read.subs_names{isub},'_',num2str(it      ,'%0.4d')],'-dpng')
               print([fpath,filesep,RUNID,'_',read.subs_names{isub},'_',datestr(WAQ.datenum,'31')],'-dpng')
            end

         end

         %% Pause

         if OPT.pause
         disp('press key to continue')
         pause
         end
      
      end % for it=1:read.ntimes

end  % for iRUNID = 1:length(RUNIDS)

%% EOF