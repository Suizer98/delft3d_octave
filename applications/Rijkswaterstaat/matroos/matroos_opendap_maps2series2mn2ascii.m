function matroos_opendap_maps2series2mn2ascii(R,varargin)
%MATROOS_OPENDAP_MAPS2SERIES2MN2ASCII subsidiary of matroos_opendap_maps2series2mn
%
% You can reload the netCDF file written by MATROOS_OPENDAP_MAPS2SERIES2MN
% and save the ascii files again, with another refdate for instance.
%
% fname = 'hmcn_kustfijn_m1,n1_m2,n2_m3,n3.nc';
% R = nc2struct(fname)
% matroos_opendap_maps2series2mn2ascii(R,'filename','hmcn_kustfijn',...
%                                       'timselect',[5:10:552 552],...
%                                      'timrelpath','tim')
%
%See also: MATROOS_OPENDAP_MAPS2SERIES2MN, DFLOWFM, NOOS_WRITE

warning('beta version')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: matroos_opendap_maps2series2mn2ascii.m 7698 2012-11-16 14:50:34Z boer_g $
% $Date: 2012-11-16 22:50:34 +0800 (Fri, 16 Nov 2012) $
% $Author: boer_g $
% $Revision: 7698 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2mn2ascii.m $
% $Keywords: $

   OPT.RefDate     = datenum(2009,12,1); % if not 'NOOS' or datenum(), else ISO8601 'yyyy-mm-dd HH:MM:SS'
   OPT.filename    = '';
   OPT.timrelpath  = '';
   OPT.path        = '';
   OPT.header      = 0; % not sure whether can Dflow-FM handle comments ....
   OPT.only_future = 1; % chop all dates before RefDate (no negative times), not sure whether can Dflow-FM handle negs ....
   OPT.timselect   = ':';
   OPT.source      = ''; % CF keyword
   OPT.mcor        = [];
   OPT.ncor        = [];
   OPT.varname     = 'elev';
   
   
   if nargin==0
      varargout = {OPT};return
   end

   OPT = setproperty(OPT,varargin)
   
   if ~isempty(OPT.path)
      OPT.path = path2os([OPT.path,filesep]);
   else
      OPT.path = [pwd,filesep];
   end
   
   if isempty(OPT.filename)
      error('filename is a required keyword')
   else
      OPT.filename = [filename(OPT.filename),'.pli'];
   end
   
   if strcmpi(OPT.timselect,':')
      OPT.timselect = 1:length(R.x);
   else
      OPT.timselect(isinf(OPT.timselect)) = length(R.x);
   end

%% split 2D array into polygon (*.pli) with ascii time series at corners (*.tim)

   fid = fopen([OPT.path,OPT.filename],'w');
   fprintf(fid,'* %s\n',char(OPT.source));
   fprintf(fid,'* created at %s\n',datestr(now));
   fprintf(fid,'* created by %s\n','$Id');
   fprintf(fid,'* m=%s\n',num2str(OPT.mcor));
   fprintf(fid,'* n=%s\n',num2str(OPT.ncor));
   fprintf(fid,'%s\n','BLOCK');
   fprintf(fid,'%d %d\n',length(R.x),2);
   
   nr = 0;
   for j=1:length(R.x)

      timname = [filepathstrname(OPT.filename),'_',num2str(j,'%0.4d'),'.tim'];
      
      if ~any(intersect(j,OPT.timselect))
         fprintf(fid,'%f %f\n',R.x(j),R.y(j)); % x,y
      else
         fprintf(fid,'%f %f %s\n',R.x(j),R.y(j),['''',timname,'''']); % x,y, <yet unused name of associated data file>

         if any(isnan(R.(OPT.varname)(j,:)))
            disp(['Warning: ',timname,' contains NaN ',num2str(j)])
         else
            disp(['Confirm: ',timname,' is OK ',num2str(j)])
         end

         nr = nr + 1;
         mkpath([OPT.path,OPT.timrelpath])
         fid2 = fopen([OPT.path,OPT.timrelpath,filesep,timname],'w');
         if OPT.header
            fprintf(fid2,'# %s\n',char(R.source));
            fprintf(fid2,'# created at %s\n',datestr(now));
            fprintf(fid2,'# created by %s\n','$Id');
            fprintf(fid2,'# m=%g\n',R.m(j));
            fprintf(fid2,'# n=%g\n',R.n(j));
            fprintf(fid2,'# x=%f\n',R.x(j));
            fprintf(fid2,'# y=%f\n',R.y(j));
            if strcmpi(OPT.RefDate,'NOOS')
              fprintf(fid2,'# RefDate=%s\n','NOOS');
              fprintf(fid2,'# Tunit=%s\n','yyyymmddHHMM');
            elseif isnumeric(OPT.RefDate)
              fprintf(fid2,'# RefDate=%s\n',datestr(OPT.RefDate,'yyyy-mm-dd HH:MM:SS'));
              fprintf(fid2,'# Tunit=%s\n','minute');
            else
              fprintf(fid2,'# RefDate=%s\n','ISO8601');
            end
         end
         
         for it=1:length(R.datenum)
            if strcmpi(OPT.RefDate,'NOOS')
            fprintf(fid2,'%s %f\n',datestr(R.datenum(it),'yyyymmddHHMM'),R.data(j,it));
            elseif isnumeric(OPT.RefDate)
            % Tunit            = S                   # Time units in MDU (H, M or S)
            % make minutes
            minutes = (R.datenum(it) - OPT.RefDate)*24*60;
            if ~(minutes > 0 & OPT.only_future)
            fprintf(fid2,'%g %f\n',minutes,R.(OPT.varname)(j,it));
            else
            end
            else % ISO
            fprintf(fid2,'%s %f\n',datestr(R.datenum(it),'yyyy-mm-dd HH:MM:SS'),R.data(j,it));
            end
         end    
         fclose(fid2);
      end
   end
   fclose(fid);
   