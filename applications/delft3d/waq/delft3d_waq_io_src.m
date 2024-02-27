function varargout = DELFT3D_WAQ_IO_SRC(varargin)
%Beta version of DELFT3D_WAQ_IO_SRC   Reads Delft3D-WAQ *.src file into struct
%
% DAT = DELFT3D_WAQ_IO_SRC        % launches file load GUI
% DAT = DELFT3D_WAQ_IO_SRC(fname)
% [DAT,status] = DELFT3D_WAQ_IO_SRC(fname)
%
% Returns status = 1 /0     /-1                  /-2                     /-3
%                  OK/cancel/file cannot be found/file cannot be openened/file cannot be read
%
% Beta version, G.J. de Boer, 2008
%
% See also: FLOW2WAQ3D, FLOW2WAQ3D_COUPLING, WAQ2FLOW2D, WAQ2FLOWD3D,
%           DELFT3D_PART_IO_INP

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl (also: gerben.deboer@wldelft.nl)
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
%   USA
%   --------------------------------------------------------------------

% $Id: delft3d_waq_io_src.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_io_src.m $

mfile_version = '1.0, Mar. 2008, beta';

   %% 0 - command line file name or 
   %%     Launch file open GUI
   %% ------------------------------------------

   %% No file name specified if even number of arguments
   %% i.e. 2 or 4 input parameters
   % -----------------------------
   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'*.src' ,'Delft3d-WAQ sources file (*.src)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'Delft3d-WAQ sources file (*.src)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         DAT.filename   = [];
         iostat         = 0;
      else
         DAT.filename   = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(DAT.filename)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

   %% No file name specified if odd number of arguments
   % -----------------------------
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      DAT.filename   = varargin{1};
      iostat         = 1;
   end
   
   %% I - Check if file exists (actually redundant after file GUI)
   %% ------------------------------------------

   tmp = dir(DAT.filename);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',DAT.filename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      DAT.filedate     = tmp.date;
      DAT.filebytes    = tmp.bytes;
   
      fid              = fopen   (DAT.filename,'r');
      
      %% II - Check if can be opened (locked etc.)
      %% ------------------------------------------

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',DAT.filename])
         else
            iostat = -2;
         end
      
      elseif fid > 2

         %% II - Check if can be read (format etc.)
         %% ------------------------------------------

      %   try
      %   catch
         
         %% Example file
         %% ------------------------------
         %%
         %% +---------------------------------------------+
         %% |   SECONDS    				  |
         %% |      3    ; time dependent sources	  |
         %% |      1    ; block function		  |
         %% |      4    ; no. of sources in this block	  |
         %% |     1    2    3    4			  |
         %% |        2  ; number of breakpoints		  |
         %% |  1.0 1.0  ; scale factors      		  |
         %% |           0          ; breakpoint time	  |
         %% |        0.119151E+00    1.0  ; SOURCE:   1	  |
         %% |        0.293616E+00    1.0  ; SOURCE:   2	  |
         %% |        0.293616E+00    1.0  ; SOURCE:   3	  |
         %% |        0.293616E+00    1.0  ; SOURCE:   4	  |
         %% |        3600          ; breakpoint time	  |
         %% |        0.122630E+00    1.0  ; SOURCE:   1	  |
         %% |        0.292480E+00    1.0  ; SOURCE:   2	  |
         %% |        0.292410E+00    1.0  ; SOURCE:   3	  |
         %% |        0.292480E+00    1.0  ; SOURCE:   4	  |
         %% +---------------------------------------------+
      
         %% Open
         %% ------------------------------

         fid = fopen(DAT.filename,'r');

         %% Read header
         %% ------------------------------
         DAT.data.time_units              = strtrim(fgetl(fid));
         DAT.data.time_dependent_source   = waq_fgetl_number(fid);
         DAT.data.block_function          = waq_fgetl_number(fid);
         DAT.data.n_sources               = waq_fgetl_number(fid);
         DAT.data.sources                 = waq_fgetl_number(fid);
         DAT.data.n_breakpoints           = waq_fgetl_number(fid);
         DAT.data.scale_factors           = waq_fgetl_number(fid);
         
         %% Read data
         %% ------------------------------

         DAT.data.sources = repmat(nan,[DAT.data.n_breakpoints DAT.data.n_sources ]);
         DAT.data.time    = repmat(nan,[DAT.data.n_breakpoints 1]);
         
         for it   = 1:DAT.data.n_breakpoints

            nmbr = waq_fgetl_number(fid);
            
            DAT.data.time(it) = nmbr(1);

         for isrc = 1:DAT.data.n_sources
         
            nmbr = waq_fgetl_number(fid);
         
            DAT.data.sources(it,isrc) = nmbr(1);
            
            %% What is 2nd column?
            
         end
         end

         %% Close
         %% ------------------------------

         fclose(fid);
      
      %   
      %      if nargout==1
      %         error(['Error reading file: ',DAT.filename])
      %      else
      %         iostat = -3;
      %      end      
      %   
      %   end % try
      
      end %  if fid <0

   end % if length(tmp)==0
   
   DAT.iomethod = ['© delft3d_waq_io_src.m  by G.J. de Boer (TU Delft), g.j.deboer@tudelft.nl,',mfile_version]; 
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;
   
   %% Function output
   %% -----------------------------

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end
   
end % delft3d_waq_io_src   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = waq_fgetl_number(fid,nbefore,varargin)

   if nargin==3
      commentcharacter = [varargin{1},'#'];
   else
      commentcharacter = ';#';
   end
   
   [rec,n]            = fgetl_no_comment_line(fid,commentcharacter,0); % 0 = allow no empty lines
   start_of_comment   = Inf;
   for ic = 1:length(commentcharacter)
      index = strfind(rec,commentcharacter(ic));
      if ~isempty(index)
      start_of_comment   = min(index,start_of_comment);
      end
   end
   
   if isempty(start_of_comment) | ...
        isinf(start_of_comment)
      number          = str2num(rec);
   else   
      number          = str2num(rec(1:start_of_comment-1));
   end   
   
   if nargin>1
      n = n + nbefore;
   end
   
   if nargout==1
      varargout = {number};
   else
      varargout = {number,n};
   end

end % waq_fgetl_number

% EOF