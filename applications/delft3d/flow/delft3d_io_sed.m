function varargout = delft3d_io_sed(fname,varargin)
%DELFT3D_IO_SED   load delft3d online sed *.sed keyword file 
%
%  D   = DELFT3D_IO_SED(fname)
% 
% loads contents of *.sed file into struct D
%
%  [D,U]   = DELFT3D_IO_SED(fname)
%  [D,U,M] = DELFT3D_IO_SED(fname)
%
% optionally loads units and meta-info into structs U and M.
%
%  [...] = DELFT3D_IO_SED(fname,<gridfile>) with any spatially varying fields
%
% Also works for *.mor files that have the same *.ini structure.
%
%See also: delft3d, inivalue
% 
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id: delft3d_io_sed.m 17131 2021-03-25 10:48:04Z chavarri $
% $Date: 2021-03-25 18:48:04 +0800 (Thu, 25 Mar 2021) $
% $Author: chavarri $
% $Revision: 17131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_io_sed.m $
% $Keywords: $

OPT.commentchar = '*';
OPT.FileOption  = {{'Sediment','SdBUni'},...
                   {'Sediment','TcrSed'},...
                   {'Sediment','TcrEro'},...
                   {'Sediment','EroPar'},...
                   {'Sediment','IniSedThick'}};
               
if ~odd(nargin)
   gridfile = varargin{1};
   OPT = setproperty(OPT,varargin{2:end});
else
   gridfile = '';
   OPT = setproperty(OPT,varargin{:});
end

INI = inivalue(fname,struct('commentchar',OPT.commentchar));

Chapters = fieldnames(INI);
nChapter = length(Chapters);

for iChapter = 1:nChapter

   Chapter  = Chapters{iChapter};
   Keywords = fieldnames(INI.(Chapter));
   nKeyword = length(Keywords);
   
   for iKeyword = 1:nKeyword
      Keyword   = Keywords{iKeyword};
      ValueLine = INI.(Chapter).(Keyword);
      if ischar(ValueLine)
      ValueLine    = strtrim(ValueLine);
      end
      
      if any(strcmpi(Chapter,{'SedimentFileInformation','MorphologyFileInformation'}))
         Value   = ValueLine;
         Comment = '';
      else
        if strcmp(ValueLine(1),'#')
            tmp = regexp(ValueLine,'#','split');
            Value = tmp{2};
            Comment = tmp{3};
        else
            if strcmp(Keyword,'Percentiles')
                Value=ValueLine;
            else
                [Value,Comment] = strtok(ValueLine);
            end
                
        end
         Value = strtrim(Value);
         
         if strcmp(Value(1),'#')
            ind = strfind(Value,'#');
            if length(ind)==2
             Value = Value(ind(1)+1:ind(2)-1);
            else
             error('string contains not two #')
            end
         else
%             if ~isempty(str2num(Value))
%               Value = str2num(Value);
%             end
%             val_raw=Value;
            val_num=str2double(Value);
            if isnan(val_num) %it is a character
%                 Value=val_raw;
            else %it is a number
                if any(strcmp(Keyword,{'FileVersion','Percentile'})) %treat as string
%                     Value=val_raw;
                else %treat as number
                    Value=val_num;
                end
            end
         end
      end
      
      i0 = strfind(Comment,'[');
      i1 = strfind(Comment,']');
     
         unit    = '';
      if length(i0)>0 & length(i1)>0 
         unit    = Comment(i0(1)+1:i1(1)-1);
         Comment = Comment(i1(1)+1:end);
      end
      
      DATA.(Chapter).(Keyword) = Value;
      UNIT.(Chapter).(Keyword) = unit;
      META.(Chapter).(Keyword) = strtrim(Comment);
      
   end
   
end

%% optionally load spatially varying fields
%  not yet finished
if 0
for ifld=1:length(OPT.FileOption)
   Chapter = OPT.FileOption{ifld}{1};
   Keyword = OPT.FileOption{ifld}{2};
   if isfield(DATA.(Chapter),(Keyword));
   if ischar (DATA.(Chapter).(Keyword));
      if isempty(gridfile)
      warning(['Not loaded spatially varying field ''',Keyword,''', please supply grid file.'])
      else
      G = delft3d_io_grd('read',gridfile);
       dummy = delft3d_io_dep('read',DATA.(Chapter).(Keyword),G,'location','cen');
       DATA.(Chapter).(Keyword).cor.x         = dummy.cor.x;
       DATA.(Chapter).(Keyword).cor.y         = dummy.cor.y;
       DATA.(Chapter).(Keyword).cen.x         = dummy.cen.x;
       DATA.(Chapter).(Keyword).cen.y         = dummy.cen.y;
       DATA.(Chapter).(Keyword).cen.(Keyword) = dummy.cen.dep;
      end
   end
   end
end
end

if nargout==1
   varargout = {DATA};
elseif nargout==2
   varargout = {DATA,UNIT};
else
   varargout = {DATA,UNIT,META};
end


%[SedimentFileInformation]
%   FileCreatedBy    = Delft3D-FLOW-GUI, Version: 3.41.02         
%   FileCreationDate = Tue May 03 2011, 18:23:52         
%   FileVersion      = 02.00                        
%[SedimentOverall]
%   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations
%   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions
%[Sediment]
%   Name             = #Sediment01#                  Name of sediment fraction
%   SedTyp           = mud                           Must be "sand", "mud" or "bedload"
%   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density
%   SalMax           =  0.0000000e+000      [ppt]    Salinity for saline settling velocity
%   WS0              =  1e-4                [m/s]    Settling velocity fresh water
%   WSM              =  1e-4                [m/s]    Settling velocity saline water
%   TcrSed           =  1e3                 [N/m2]   Critical bed shear stress for sedimentation (uniform value or filename)
%   TcrEro           =  0.2                 [N/m2]   Critical bed shear stress for erosion       (uniform value or filename)
%   EroPar           =  2e-5                [kg/m2/s] Erosion parameter                           (uniform value or filename)
%   CDryB            =  5.0000000e+002      [kg/m3]  Dry bed density
%   IniSedThick      =  0.0000000e-002      [m]      Initial sediment layer thickness at bed (uniform value or filename)
%   FacDSS           =  1.0000000e+000      [-]      FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]

%[SedimentFileInformation]
%   FileCreatedBy    = Delft3D-FLOW-GUI, Version: 3.39.15.00         
%   FileCreationDate = Mon Nov 06 2006, 13:45:07         
%   FileVersion      = 02.00                        
%[SedimentOverall]
%   Cref             = 1.6000000e+003       [kg/m3]  CSoil Reference density for hindered settling calculations
%   IopSus           = 0                             Suspended sediment size is Y/N calculated dependent on d50         
%[Sediment]
%   Name             = #Sediment1#                   Name as specified in NamC in md-file
%   SedTyp           = mud                           Must be "sand", "mud" or "bedload"
%   RhoSol           = 2.6500000e+003       [kg/m3]  Density
%   SedDia           = 1.9999999e-004       [m]      Median sediment diameter (D50)
%   CDryB            = 5.0000000e+002       [kg/m3]  Dry bed density
%   SdBUni           = 0.0000000e+000       [kg/m2]  Initial sediment mass at bed per unit area  (uniform value or file name)
%   FacDSS           = 1.0000000e+000       [-]      FacDss * SedDia = Initial suspended sediment diameter. range [0.6 - 1.0]
%   SalMax           = 0.0000000e+000       [ppt]    Salinity for saline settling velocity
%   WS0              = 3.0000000e-005       [m/s]    Settling velocity fresh water
%   WSM              = 3.0000000e-005       [m/s]    Settling velocity saline water
%   TcrSed           = 9.9999997e-006       [N/m2]   Critical stress for sedimentation (uniform value or file name)
%   TcrEro           = 1.0000000e+002       [N/m2]   Critical stress for erosion       (uniform value or file name)
%   EroPar           = 9.9999997e-005       [kg/m2s] Erosion parameter                 (uniform value or file name)
