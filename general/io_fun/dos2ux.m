function dos2ux(files_in,varargin)
%DOS2UX   Change all end-of-line characters of ASCII files to UX-type
%
% DOS2UX(files_in,files_out)
% where files_in and files_out are a cell or character 
% str of the filenames to be processed.
%
% DOS2UX(files_in)
% where files_out is set to files_in, and files_in
% are backup-ed to files_in.bak
%
%See also: FPRINTEOL, UX2DOS, PATH2OS.

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl (g.j.deboer@tudelft.nl)
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherland
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: dos2ux.m 2101 2009-12-21 12:49:01Z boer_g $
% $Date: 2009-12-21 20:49:01 +0800 (Mon, 21 Dec 2009) $
% $Author: boer_g $
% $Revision: 2101 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/dos2ux.m $
% $Keywords$

%% TO DO: remove CTRL-Z characters.

   %% Input
   %---------------------------

   if ischar(files_in)
      files_in  = cellstr(files_in);
   end

   if nargin==1
      files_out = files_in;
      backup    = 1;
      disp('Files are overwritten with different end-of-line characters.')
   else
      files_out = varargin{1};
      backup    = 0;
      if ischar(files_out)
         files_out = cellstr(files_out);
      end
      if ~(length(files_in)==length(files_out))
         error('files_in has not same size as files_out')
      end
   end

   %% READ file
   %---------------------------
   for ifile=1:length(files_in)
      file_in  = files_in{ifile};
      fid      = fopen(file_in,'r');
      nline    = 0;
      while 1
         rec                 = fgetl(fid);
         if ~ischar(rec)
            break
         else
            nline            = nline + 1;
            textlines{nline} = rec;
         end
      end
      fclose(fid);
      
   end

   %% WRITE file
   %---------------------------
      
   for ifile=1:length(files_in)
      file_in  = files_in {ifile};
      file_out = files_out{ifile};

      if backup
         copyfile(file_in,[file_in,'.bak']);
      end
      
      fid      = fopen(file_out,'w');
      for iline=1:length(textlines)
         fprintf  (fid,textlines{iline});
         fprinteol(fid,'u')
      end
      fclose(fid);

   end

%% EOF