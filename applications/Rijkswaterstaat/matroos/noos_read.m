function varargout = noos_read(varargin)
%NOOS_READ   read NOOS timeseries ASCII format
%
%   [time, values, headerlines] = noos_read(cellstr)
%
% When the file contains multiple data blocks,
%  [time, values, headerlines], are cells. 
%
% The headerlines can be interpreted with MATROOS_NOOS_HEADER 
% if the <a href="http://www.noos.cc/">NOOS</a> file file originates from the matroos service: GET_SERIES. 
%
% The headerlines can also contain non-standard header information
% as in the the matroos service: GET_MAP2SERIES. 
%
% Alternative output:
%
%   D = noos_read(cellstr)
%
% where D has fields datenum, value and headers.
%
%See also: NOOS_WRITE, MATROOS_NOOS_HEADER

%% TO DO: parse a file with only concatenated comment blocks (in case of no data)
%% TO DO: take missing value into account

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
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
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: noos_read.m 11354 2014-11-07 16:32:18Z gerben.deboer.x $
% $Date: 2014-11-08 00:32:18 +0800 (Sat, 08 Nov 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11354 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/noos_read.m $
% $Keywords: $

   OPT.varname = 'value';
   
   OPT = setproperty(OPT,varargin{2:end});

%% load file, if necesarry

   if ischar(varargin{1})
      fname    = varargin{1}; 
      fid      = fopen(fname,'r');
      allLines = textscan(fid,'%s','Delimiter','');
      allLines = allLines{1}';
      fclose(fid);
   else
      allLines = varargin{1};
   end

%% detect blocks and headers
%  Mind that data sections can be missing altogether!: so header blocks are concatenated
%  The NOOS format is as follows, where multiple blocks can occur, seperated by headers

%% Example from: GET_SERIES

% #------------------------------------------------------
% # Timeseries retrieved from the MATROOS maps1d database
% # Created at Tue Oct 28 20:33:51 CET 2008
% #------------------------------------------------------
% # Location    : MAMO001_0
% # Position    : (64040,444970)
% # Source      : sobek_hmr
% # Unit        : waterlevel
% # Analyse time: 200709020100
% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
% 200709010100   -0.309808939695358
% 200709010110   -0.297703713178635
% 200709010120   -0.289261430501938
% 200709010130   -0.256232291460037
% #------------------------------------------------------
% # Timeseries retrieved from the MATROOS maps1d database
% # Created at Tue Oct 28 20:33:51 CET 2008
% #------------------------------------------------------
% # Location    : MAMO001_0
% # Position    : (64040,444970)
% # Source      : sobek_hmr
% # Unit        : waterlevel
% # Analyse time: 200709020100
% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
% 200709010100   -0.309808939695358
% 200709010110   -0.297703713178635
% 200709010120   -0.289261430501938
% 200709010130   -0.256232291460037

%% Example from: GET_MAP2SERIES

% # ----------------------------------------------------------------
% #                                                                 
% # Timeseries created at Wed Aug  3 14:32:02 CEST 2011 by Matroos  
% # Values retrieved from mapdata interpolated in space             
% #                                                                 
% # Source           : hmcn_kustfijn                                
% # Analysis time    : 20110803085000                               
% # Time zone        : GMT                                          
% # Coordinate system: RD                                           
% # x-coordinate     : 227674.22                                    
% # y-coordinate     : 633319.8                                     
% #                                                                 
% # ----------------------------------------------------------------
% #                                                                 
% # Variable     : sep                                              
% # long_name    : waterlevel                                       
% # units        : m                                                
% # missing value: 9.96920996838687e+36                             
% #                                                                 
% 201108030000    0.83237                                           
% 201108030010    0.78763                                           
% 201108030020    0.73298                                           
% 201108030030    0.67331                                           

   % find all comment lines.
   % we assume contiguous blocks with # exist in between between contiguous data blocks
   
   ind   = strmatch('#',allLines)';
   
   % handle case where 1st line is data instead of header
   if length(ind) == 0
   hind0 = 0;
   hind1 = 0;
   D.header = '';
   else
   if ~(ind(1)==1)
      ind = [0 ind];
   end

   % header start & end indices
   hind0 = ind(find(diff(ind)>1)+1); % indices at start of blocks
   hind0 = [1 hind0]; % 1st block always starts at line 1, regardless of whether it starts with a comment line or data line
   
   hind1 = ind(find(diff(ind)>1));
   hind1 = [hind1 ind(end)];
   end
   
   % data start & end indices
   dind0 = hind1+1;
   dind1 = [(hind0(2:end)-1) length(allLines)];
   
   nloc  = length(hind0);

%% parse data

   for iloc=1:nloc
   
      %% read data lines, with pre-allocated vectors for speed
      
      done                  = 0;
      pointIndex            = 1;
      nt                    = dind1(iloc) - dind0(iloc) + 1;
      if length(ind) > 0
      D(iloc).header        = allLines(hind0(iloc):hind1(iloc));
      end
      D(iloc).datenum       = repmat(nan,[1 nt]);
      D(iloc).(OPT.varname) = repmat(nan,[1 nt]);
      
      for i = dind0(iloc):dind1(iloc)
          line                              = allLines{i};
          data                              = sscanf(line,'%f %f');

          if length(data)>0 % handle empty lines ??
           year                              = sscanf(line( 1: 4),'%d');
           month                             = sscanf(line( 5: 6),'%d');
           day                               = sscanf(line( 7: 8),'%d');
           hour                              = sscanf(line( 9:10),'%d');
           min                               = sscanf(line(11:12),'%d');
           sec                               = 0;
           D(iloc).datenum(pointIndex)       = datenum(year,month,day,hour,min,sec);
          else
           D(iloc).datenum(pointIndex)       = nan;
          end

          if length(data)>1 % handle line with only date and no value
          
           % 201301311200  -0.3600
           % 201301311210  
           % 201301311220  -0.4400
          
           D(iloc).(OPT.varname)(pointIndex) = data(end);
          else
           D(iloc).(OPT.varname)(pointIndex) = nan;
          end

          i                                 = i+1;
          pointIndex                        = pointIndex+1;
      end;
      
   end
   
%% output

   if nargout==1
      varargout = {D};
   elseif nargout==2
      if nloc==1
         varargout = { D.datenum , D.(OPT.varname) };
      else
         varargout = {{D.datenum},{D.(OPT.varname)}};
      end
   elseif nargout==3
      if nloc==1
         varargout = { D.datenum , D.(OPT.varname) , D.header };
      else
         varargout = {{D.datenum},{D.(OPT.varname)},{D.header}};
      end
   end

%% EOF   
   