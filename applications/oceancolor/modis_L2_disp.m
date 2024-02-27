function varargout = seawifs_l2_read(fname,varargin);
%MODIS_L2_DISP   display contents of image from a SeaWiFS/MODIS (subscened) L2 HDF file
%
%   D = modis_L2_disp(filename,<keyword,value>)
%
% modis_L2_disp is a wrapper for seawifs_L2_disp
%
%See also: oceancolor, HDFINFO

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: modis_L2_disp.m 5128 2011-08-29 10:19:40Z boer_g $
% $Date: 2011-08-29 18:19:40 +0800 (Mon, 29 Aug 2011) $
% $Author: boer_g $
% $Revision: 5128 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/modis_L2_disp.m $
% $Keywords: $

%% Keywords

   OPT.debug   = 0;
   OPT.unzip   = 1; % unzip *.gz  and *.bz2 files
   OPT.delete  = 0; % cleanup unzipped files after any kind of unzip
   
   if odd(nargin)
      OPT        = setproperty(OPT,varargin{:});
   elseif nargin==0
      varargout = {OPT};
      return
   end
   
%% unzip (and clean up at end of function)

   if     OPT.unzip & strcmpi(fname(end-2:end),'.gz')
      gunzip(fname)
      zipname = fname;
      hdfname = fname(1:end-3);
      zipped  = 1;
   elseif OPT.unzip & strcmpi(fname(end-3:end),'.zip')
      unzip(fname)
      zipname = fname;
      hdfname = fname(1:end-4);
      zipped  = 1;
   elseif OPT.unzip & strcmpi(fname(end-3:end),'.bz2')
      uncompress(fname,'outpath',fileparts(fname));
      zipname = fname;
      hdfname = fname(1:end-4);
      zipped  = 1;
   else
      hdfname = fname;
      zipped  = 0;
   end
   
   D.fname = fname;

%% Variable selection

% TO DO; check  for existence of file

   I       = hdfinfo(hdfname);
   
   if ~isfield(I,'Vgroup')   ; % happens for instance when ancillary data was missing
   
      fprintf(2, '??? Warning using ==> seawifs_L2_read: skipped empty hdf file: %s \n', fname); % this gives red letters
      
      %varargout = {[],[],[]};
      %return; % thos does not clean up unzipped hdf !!
      
   else   
   
      %% find correct group
      
      % TO DO group_index = h4_group_find(I,'group_name')
      
      for group=1:length(I.Vgroup);if strcmpi(I.Vgroup(group).Name,'Geophysical Data');
         break;end
      end   
      
      if odd(nargin)
      
         H.varnames = {I.Vgroup(group).SDS.Name};
      
      end
      
%%    meta-info
      
      for ivar=1:length(H.varnames)
      
         for isds=1:length(I.Vgroup(group).SDS); 
         
            if strcmpi(I.Vgroup(group).SDS(isds).Name,H.varnames{ivar});
         
            M = I.Vgroup(group).SDS(isds);
         
            break;end;
            
         end   
      
         % TO DO D.(att_name) = h4_att_get(I,'sds_name','att_name')
      
         for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'long_name');
            H.long_names{ivar} = M.Attributes(iatt).Value(1:end-1);break;end % remove trailing char(0)
         end   
         
         for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'units');
            H.units{ivar}      = M.Attributes(iatt).Value(1:end-1);break;end % remove trailing char(0)
         end   
         
      end
      
%%    Data, coordinates, time
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'start time'      );break;end;end   
      D.datenum(1) = seawifs_datenum(I.Attributes(iatt).Value);
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'end time'        );break;end;end   
      D.datenum(2) = seawifs_datenum(I.Attributes(iatt).Value);
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'Input Parameters');break;end;end   
      val = I.Attributes(iatt).Value;
      
   end % empty file
   
      txt = [          addrowcol(char(H.varnames  ),0,-1,' '),...
                       addrowcol(char(H.long_names),0,-1,' - '), ...
             addrowcol(addrowcol(char(H.units     ),0,1 ,']'),0,-1,'[')];
             
      disp(repmat('_',[1 size(txt,2)]))
      disp(['Contents of ',I.Filename])
      disp([datestr(D.datenum)])
      for iatt=[1 2 3 6]
      disp([I.Attributes(iatt).Name,' = ',I.Attributes(iatt).Value])
      end
      disp(repmat('-',[1 size(txt,2)]))
      disp(txt)
      disp(repmat('_',[1 size(txt,2)]))

   if      OPT.delete & OPT.unzip & zipped
      delete(hdfname)
   elseif ~OPT.delete & OPT.unzip & zipped
      disp(['gunzipped ',zipname,': monitor diskspace or use seawifs_L2_read(...,''delete'',1).']);
   end
   
   if     nargout==1
        varargout = {H};
   end
   
%% EOF   