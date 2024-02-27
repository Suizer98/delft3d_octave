function varargout = disp(File,varargin)
%DISP  displays overview of contents of DONAR (blocks + variables)
%
% disp(Filex) displays overview of all variables in Filex for 
% File1 = donar.open_file() and [File2,File3]=donar.open_files.
%
% Example:
% 
%  File            = donar.open_file(diafile)
%                    donar.disp(File)
% [data, metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
%
%See also: open_file, read, disp

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: disp.m 10180 2014-02-10 15:07:22Z boer_g $
% $Date: 2014-02-10 23:07:22 +0800 (Mon, 10 Feb 2014) $
% $Author: boer_g $
% $Revision: 10180 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/disp.m $
% $Keywords: $

OPT.format = 0;

if nargin==0
    varargout = {OPT};return
end
OPT = setproperty(OPT,varargin);

if length(File) > 1

  for ifile=1:length(File)
     disp(sprintf('======+ File % d ===============================>',ifile))
     donar.disp(File(ifile))
  end

else

   V = File.Variables;
   
   %%
   if ischar(File.Filename)
      File.Filename = cellstr(File.Filename);
   end
   
       disp(['------+---------------------------------------->'])
       disp(['File #| Filename'])
       disp(['------+---------------------------------------->'])
   for ifile=1:length(File.Filename)
       disp([pad(num2str(ifile,'%d'),-6,' '),'|',File.Filename{ifile}])
   end
       %disp(['------+---------------------------------------->'])
       %disp([' '])
   
   fmt = '%5s+%5s+%7s+%7s+%8s+%8s+%65s+%16s-+-%s';
   disp(sprintf(fmt,'-----','-----','-------','-------','--------','--------','-----------------------------------------------------------------','----------------','--------->'))
   
   %%
   fmt = '%5s|%5s|%7s|%7s|%8s|%8s|%64s |%17s| %s';
   disp(sprintf(fmt,'Var'  ,'WNS ','overall', 'overall', 'overall', 'DONAR','CF', 'P01:SDN     ', 'DONAR'))
   disp(sprintf(fmt,'index','code','files', 'blocks', 'values', 'name','standard_name [UDunits]', '      urn        ', 'long_name [EHD]'))
   %%
   fmt = '%5s+%5s+%4s+%6s+%8s+%8s+%65s+%16s-+-%s';
   disp(sprintf(fmt,'-----','-----','-------','-------','--------','--------','-----------------------------------------------------------------','----------------','--------->'))
   %%
   fmt = '%5d|%5s|%7d|%7d|%8d|%8s|%64s |%17s| %s';
   
   for i=1:length(V)
   
   disp(sprintf(fmt, i, V(i).WNS, length(unique(V(i).file_index)), length(V), sum(V(i).nval), V(i).hdr.PAR{1}, [V(i).standard_name,' [',V(i).units,']'], V(i).sdn_parameter_urn ,[V(i).long_name,' [',V(i).EHD,']']))
   
   end
   %%
   fmt = '%5s+%5s+%7s+%7s+%8s+%8s+%65s+%16s-+-%s';
   disp(sprintf(fmt,'-----','-----','-------','-------','--------','--------','-----------------------------------------------------------------','----------------','--------->'))
   
   
end