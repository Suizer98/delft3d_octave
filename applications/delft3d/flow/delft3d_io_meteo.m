function varargout = delft3d_io_meteo(cmd,varargin)
%DELFT3D_IO_METEO    Read/write meteo files defined on curvi-linear grid (IN PROGRESS)
%
% D = DELFT3D_IO_METEO('read',fname) reads Delftd3D flow meteo file into struct D.
%
% D = DELFT3D_IO_METEO('read',fname,<keyword,value>) 
%
% D = DELFT3D_IO_METEO('write',fname,D.data,<keyword,value>)
%
% Where the following keyword,value have been implemented for the read mode
% * latlon    : call grid variables (lat,lon) instead of (x,y)
%               in case of spherical grid (default 0)
% * timestep  : [1xn double] timestep(s) to be read. Default is timestep 1. 
% * timeperiod: [1x2 datenum] data will be read when time falls between these limits. 
%               Overrules timestep. 
% Where the following keyword,value have been implemented for the write mode
% * reftime  : reference time (as datenum) used for the record TIME (default: the same as in 
%              D.data.time). 
% * timezone : timezone in which the times are given (default: time zone in D.data.time)
% * fmt	     : precision used to write data  (default: '%.2f'). See also fprintf.
%
% See also: DELFT3D_IO_BND, DELFT3D_IO_BCA, DELFT3D_IO_BCH,  
%           DELFT3D_IO_CRS, DELFT3D_IO_DEP, DELFT3D_IO_DRY,, DELFT3D_IO_EVA 
%           DELFT3D_IO_GRD, DELFT3D_IO_INI, DELFT3D_IO_OBS,  
%           DELFT3D_IO_SRC, DELFT3D_IO_THD, DELFT3D_IO_RESTART
%           DELFT3D_IO_WND, DELFT3D_IO_TEM, DELFT3D_IO_MDF, 
%           KNMIHYDRA, HMCZ_WIND_READ
% DELFT3D_IO_METEO_WRITE


%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delft3d_io_meteo.m 15180 2019-02-21 17:10:55Z scheel $
% $Date: 2019-02-22 01:10:55 +0800 (Fri, 22 Feb 2019) $
% $Author: scheel $
% $Revision: 15180 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_meteo.m $

if nargin ==1
   error(['At least 2 input arguments required: ',mfilename,'(''read''/''write'',filename)'])
end

%% Switch read/write
%--------------------

switch lower(cmd)

    case 'read'

        [DAT,iostat] = Local_read(varargin{1:end});

        if     nargout <2

            varargout  = {DAT};

            if iostat<1
                error('Error reading.')
            end

        elseif nargout  == 2

            varargout  = {DAT,iostat};

        elseif nargout >2

            error('too much output parameters: 1 or 2')

        end

    case 'write'

        iostat = Local_write(varargin{1:end});

        if nargout ==1

            varargout = {iostat};

        elseif nargout >1

            error('too much output parameters: 0 or 1')

        end

end


%%------------------------------------
% --READ------------------------------
% ------------------------------------

function varargout=Local_read(fname,varargin),


   D.filename       = fname;
   D.read.iostat    = -1;

   %% Keywords
   %-------------------
   
   OPT.timestep         = 1;
   OPT.latlon           = 0;
   OPT.timeperiod	    = []; 
   OPT.numeric_keywords = {'NODATA_value',...
                                 'n_cols',...
                                 'n_rows',...
                             'x_llcorner',...
                             'y_llcorner',...
                                     'dx',...
                                     'dy',...
                             'n_quantity'};
   
   OPT = setproperty(OPT,varargin{:});
   
   %% Locate
   %--------------------------
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      D.read.iostat = -1;
      disp (['??? Error using ==> ',mfilename,''])
      disp (['Error finding meteo file: ',fname])
      
   elseif length(tmp)>1
      
      D.read.iostat = -1;
      disp (['??? Error using ==> ',mfilename,''])
      disp (['Please specify only 1 file rather than directory: ',fname])

   else
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
      %% Read
      %--------------------------
	  
	     fid           = fopen(fname,'r');
         [keyword,value,rec] = fgetl_key_val(fid,'#');

         %% Read header
         %------------------------------

         while ~feof(fid) & ~strcmpi(keyword,'TIME')
            
            D.data.keywords.(keyword)   = value;
            [keyword,value,rec] = fgetl_key_val(fid,'#');
			
			if feof(fid)
				display('No data in file'); 
				break; 
			end
         
         end

         
         %% Process header
         %------------------------------

         keywords = fieldnames(D.data.keywords);
         for inum=1:length(OPT.numeric_keywords)
         for ikey=1:length(keywords)
            if strcmpi(OPT.numeric_keywords(inum),keywords(ikey))
               D.data.keywords.(keywords{ikey}) = str2num(D.data.keywords.(keywords{ikey}));
            end
         end
         end

         %% Meteo types
         %------------------------------
         
         if ~isempty(OPT.timestep)
         if strcmpi(D.data.keywords.filetype,'meteo_on_equidistant_grid')

            if OPT.latlon & strcmpi(D.data.keywords.grid_unit,'degrees')
            
               D.data.cen.lonSticks   = D.data.keywords.x_llcorner + [0.5:1:(D.data.keywords.n_cols-0.5)].*D.data.keywords.dx;
               D.data.cen.latSticks   = D.data.keywords.y_llcorner + [0.5:1:(D.data.keywords.n_rows-0.5)].*D.data.keywords.dy;
               
               D.data.cor.lonSticks   = D.data.keywords.x_llcorner + [0  :1:(D.data.keywords.n_cols    )].*D.data.keywords.dx;
               D.data.cor.latSticks   = D.data.keywords.y_llcorner + [0  :1:(D.data.keywords.n_rows    )].*D.data.keywords.dy;
	      
              [D.data.cen.lon,...
               D.data.cen.lat]        = meshgrid(D.data.cen.lonSticks,D.data.cen.latSticks);
	      
              [D.data.cor.lon,...
               D.data.cor.lat]        = meshgrid(D.data.cor.lonSticks,D.data.cor.latSticks);
	      
            else
          
               D.data.cen.xSticks     = D.data.keywords.x_llcorner + [0.5:1:(D.data.keywords.n_cols-0.5)].*D.data.keywords.dx;
               D.data.cen.ySticks     = D.data.keywords.y_llcorner + [0.5:1:(D.data.keywords.n_rows-0.5)].*D.data.keywords.dy;
               
               D.data.cor.xSticks     = D.data.keywords.x_llcorner + [0  :1:(D.data.keywords.n_cols    )].*D.data.keywords.dx;
               D.data.cor.ySticks     = D.data.keywords.y_llcorner + [0  :1:(D.data.keywords.n_rows    )].*D.data.keywords.dy;
	    
              [D.data.cen.x  ,...
               D.data.cen.y  ]        = meshgrid(D.data.cen.xSticks ,D.data.cen.ySticks   );
	    
              [D.data.cor.x  ,...
               D.data.cor.y  ]        = meshgrid(D.data.cor.xSticks ,D.data.cor.ySticks   );
	    
            end
               
         elseif strcmpi(D.data.keywords.filetype,'meteo_on_curvilinear_grid')
         
            if exist('wlgrid')==0
               error('function wlgrid missing.')
            end
            
            if ~exist(D.data.keywords.grid_file)
               new = [fileparts(fname),filesep,D.data.keywords.grid_file];
               if exist(new)
                  D.data.keywords.grid_file = new;
                  disp('delft3d_io_meteo: found grid file in directory of meteo file, note that Deft3D-flow needs it as as an the absolute path, or relative to the active working directory.')
               else
                  error(['cannot find grid file:',D.data.keywords.grid_file])
               end
            end
            
            G = wlgrid('read',D.data.keywords.grid_file);
               
            if OPT.latlon & strcmpi(G.CoordinateSystem,'Spherical')
               D.data.cen.lon = G.X;
               D.data.cen.lat = G.Y;
            else
               D.data.cen.x   = G.X;
               D.data.cen.y   = G.Y;
            end
            
            if     strcmpi(D.data.keywords.data_row,'grid_row')
               D.data.keywords.n_cols = size(G.X,1);
               D.data.keywords.n_rows = size(G.Y,2);
            elseif strcmpi(D.data.keywords.data_row,'grid_column')
               D.data.keywords.n_cols = size(G.X,2);
               D.data.keywords.n_rows = size(G.Y,1);
            else
            error(['Unknown meteo data_row: ''',D.data.keywords.data_row,''''])
            end
            
         elseif strcmpi(D.data.keywords.filetype,'meteo_on_spiderweb_grid')
         
            error('Not implemented yet, give it a try yourselves?')
            
         else

            error(['Unknown meteo filetype: ''',D.data.keywords.filetype,''''])

         end
         end         	
		
		
         if ~strcmpi(keyword,'time') & ~isempty(OPT.timestep)
            disp('No data in file')
         else
         	
			display('Reading file. Please wait.'); 
			
			%initiate
			timestep=1; cOut=1; 
		    D.data.time=[]; 
			D.data.datenum=[]; 
			D.data.cen.(D.data.keywords.quantity1)=[]; 
            while ~feof(fid)
			
			if isempty(OPT.timeperiod) & timestep>max(OPT.timestep)
				break; 
		    end
			if ~isempty(OPT.timeperiod) & udunits2datenum(value)>max(OPT.timeperiod)
				break; 
		    end
			
			if length(OPT.timeperiod)~=2
				doRead=sum(timestep==OPT.timestep)>0 | isinf(OPT.timestep) ; 
			else
				doRead=udunits2datenum(value)>=OPT.timeperiod(1) & udunits2datenum(value)<=OPT.timeperiod(2);
			end
			
			if doRead
				display(sprintf('Reading field for time %s.',datestr(udunits2datenum(value),'dd-mm-yyyy HH:MM') )); 
				
				% Load block
               rawblock = fscanf(fid,'%f',[D.data.keywords.n_cols D.data.keywords.n_rows]);
			   
			   % The upper left numer of the ASCII file belongs to index
               % (1,1), so swap in y-direction
               rawblock = fliplr(rawblock);
			   
			    % NaNs
               rawblock(rawblock==D.data.keywords.NODATA_value) = NaN;
			   
			   D.data.time{cOut}=[value,' ',rec]; 
			   D.data.datenum(cOut)=udunits2datenum(value);
			   D.data.cen.(D.data.keywords.quantity1)(:,:,cOut) = rawblock;
			   
			   %search for next block
			   cOut=cOut+1; 
			   keyword=[]; 
			   while ~feof(fid) & ~strcmpi(keyword,'time')
					[keyword,value,rec] = fgetl_key_val(fid,'#');
			   end
			   timestep=timestep+1; 
			   
			   
			else
			
				% Load block
               rawblock = fscanf(fid,'*%f',[D.data.keywords.n_cols D.data.keywords.n_rows]);
			 
			    keyword=[]; 
			    while ~feof(fid) & ~strcmpi(keyword,'time')
					[keyword,value,rec] = fgetl_key_val(fid,'#');
			   end
			   timestep=timestep+1; 
			
			end
			
            end
            

         end
         
         %% Finished succesfully
         %----------------------------------------
   
	    if length(D.data.time)==1
			D.data.time=D.data.time{1}; 
		end
         fclose(fid);

         D.read.with     = '$Id: delft3d_io_meteo.m 15180 2019-02-21 17:10:55Z scheel $'; % SVN keyword, will insert name of this function
         D.read.at       = datestr(now);
         D.read.iostat   = 1;
	
         
      %catch
      %
      %   D.iostat = -3;
      %   disp (['??? Error using ==> ',mfilename,''])
      %   disp (['Error reading meteo file: ',fname])
      %
      %end % catch
   
   end %elseif length(tmp)>0
   
   
if nargout==1
   varargout = {D};   
else
   varargout = {D,D(:).read.iostat};   
end

end % function varargout=Local_read(fname,varargin),

%%------------------------------------
% --WRITE-----------------------------
%-------------------------------------

function iostat=Local_write(fname,DAT,varargin),

   iostat       = 0;
   OPT.reftime  = []; 
   OPT.timezone = [];
   OPT.fmt='%.2f';
   % ADDED FREEK SCHEEL (DOENS'NT DO MUCH?):
   OPT.userfieldnames = [];
   OPT=setproperty(OPT,varargin); 


   %% Keywords
   %-------------------

   % REMOVED FREEK SCHEEL:
   
%       H.userfieldnames = false;
% 
%       if nargin>2
%          if isstruct(varargin{2})
%             H = mergestructs('overwrite',H,varargin{2});
%          else
%             iargin = 2;
%             %% remaining number of arguments is always even now
%             while iargin<=nargin-1,
%                 switch lower ( varargin{iargin})
%                 % all keywords lower case
%                 case 'userfieldnames';iargin=iargin+1;H.parameternames = varargin{iargin};
%                 otherwise
%                   error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
%                 end
%                 iargin=iargin+1;
%             end
%          end  
%       end

   %% Locate
   %--------------------------
   
   tmp       = dir(fname);
   writefile = [];
   
   if length(tmp)==0
      
      writefile = true;
      
   else

      while ~islogical(writefile)
         disp(['Meteo file already exists: ''',fname,'''']);
         writefile    = input('o<verwrite> / c<ancel>: ','s');
         if strcmpi(writefile(1),'o')
            writefile = true;
         elseif strcmpi(writefile(1),'c')
            writefile = false;
            iostat    = 0;
         end
      end

   end % length(tmp)==0
   
   if writefile
   
     switch length(DAT.datenum)
       case 0
        error('Input does not contain data.'); 
       case 1
        DAT.time={DAT.time}; 
     end
   
     %find reference time and timezone
     if isempty(OPT.reftime) 
     	entry=regexp(DAT.time{1},'since\s*(\d+)-(\d+)-(\d+)\s*(\d+):(\d+):(\d+)','tokens');
     	if length(entry)~=1 | length(entry{1})~=6
     	   error('Cannot read reference time from block 1.'); 
     	end
     	entry=entry{1}; 
     	entry=str2double(entry); 
     	OPT.reftime=datenum([entry]); 
     end
     
     if isempty(OPT.timezone)
     	entry=regexp(DAT.time{1},'(\d+):(\d+)','tokens'); 
     	disp('It is hard to determine the time zone due to different formats');
     	disp('Advised to provide the timezone as a keyword,value pair:');
     	disp('E.g. ,''timezone'',2/24 for a case with 2 hours +UTC');
     	entry=entry{end}; entry=str2double(entry); 
     	OPT.timezone=entry(1)+entry(2)/60; 
     end
     
     %write data
     local_meteo_curv_write(fname,DAT,OPT.reftime,OPT.timezone,OPT.fmt); 
      
   end % writefile
   
end % function iostat=Local_write(fname,DAT,varargin),

function local_meteo_curv_write(fname,DAT,reftime,timezone,fmt)

%open stream
fid=fopen(fname,'w+'); 

DAT.keywords.grid_file = 'tst.grd'; 
[dummy fname_grid fext_grid]=fileparts(DAT.keywords.grid_file); 
fname_grid=[fname_grid,fext_grid]; 

if length(DAT.datenum)==1
	DAT.time={DAT.time}; 
end

%write header
fprintf(fid,'### START OF HEADER\n',DAT.keywords.unit1); 
fprintf(fid,'FileVersion      = %s\n',DAT.keywords.FileVersion); 
fprintf(fid,'filetype         = %s\n',DAT.keywords.filetype); 
fprintf(fid,'NODATA_value     = %.6f\n',DAT.keywords.NODATA_value); 
fprintf(fid,'n_cols        = %.0f\n',DAT.keywords.n_cols); 
fprintf(fid,'n_rows        = %.0f\n',DAT.keywords.n_rows); 
fprintf(fid,'grid_unit        = %s\n',DAT.keywords.grid_unit); 
fprintf(fid,'x_llcorner        = %.4f\n',DAT.keywords.x_llcorner); 
fprintf(fid,'y_llcorner        = %.4f\n',DAT.keywords.y_llcorner); 
fprintf(fid,'dx             = %.4f\n',DAT.keywords.dx); 
fprintf(fid,'dy             = %.4f\n',DAT.keywords.dy); 
fprintf(fid,'n_quantity       = %d\n',DAT.keywords.n_quantity); 
fprintf(fid,'quantity1        = %s\n',DAT.keywords.quantity1); 
fprintf(fid,'unit1            = %s\n',DAT.keywords.unit1); 
fprintf(fid,'### END OF HEADER\n',DAT.keywords.unit1); 

%write different time steps
for k=1:length(DAT.datenum)
    display( sprintf('Writing field for time %s.',datestr(DAT.datenum(k),'dd-mm-yyyy HH:MM')) ); 
     
        relativeTime=(DAT.datenum(k)-reftime)*24;
        if sign(timezone)>=0
          fprintf(fid,'TIME = %.6f hours since %s +%s\n',relativeTime,datestr(reftime,'yyyy-mm-dd HH:MM:SS'),datestr(mod(timezone/24,1),'HH:MM'));
        else
          fprintf(fid,'TIME = %.6f hours since %s -%s\n',relativeTime,datestr(reftime,'yyyy-mm-dd HH:MM:SS'),datestr(mod(-timezone/24,1),'HH:MM'));
        end
	rawblock=squeeze(DAT.cen.(DAT.keywords.quantity1)(:,:,k)); 
	rawblock=fliplr(rawblock);
	rawblock(isnan(rawblock))=DAT.keywords.NODATA_value; 
	for l=1:size(rawblock,2)
           fprintf(fid,[fmt,' '],rawblock(:,l));
	   fprintf(fid,'\n'); 
	end
end %end for k


%close stream
fclose(fid); 

end %end local_meteo_curv_write

end % function varargout=delft3d_io_meteo_curv(cmd,varargin),
   
%% EOF   

