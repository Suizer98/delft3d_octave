function R = odvplot_overview_kml(D,varargin)
%odv_merge   merges set of odv files to one struct for one parameter
%
%   M = odv_merge(D(:))
%
% merges one parameter from multiple odv files read into D(:)
% into one struct with vectors.
%
%   odv_merge(D,'sdn_standard_name',''SDN:P01::ODSDM021'',<keyword,value>)
%
% Works for both trajectory and cast data, but only for 1 parameter.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

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

% $Id: odv_merge.m 10522 2014-04-10 21:00:37Z boer_g $
% $Date: 2014-04-11 05:00:37 +0800 (Fri, 11 Apr 2014) $
% $Author: boer_g $
% $Revision: 10522 $
% $HeadURL

% TO DO: merge ALL  variables when none specified instead of throwing GUI

   OPT.sdn_standard_name = ''; % char or numeric: (P01::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.z                 = ''; % char or numeric: (P01::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.metadataFcn       = @(z) z; %':'; % e.g. 1 extract only surface layer
   OPT.dataFcn           = @(z) z; %':'; % e.g. 1 extract only surface layer
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);

%% find column to plot based on sdn_standard_name
   OPT.index.var = 0;
   if isempty(OPT.sdn_standard_name)
      [OPT.index.var, ok] = listdlg('ListString', {D(1).sdn_long_name{10:2:end}} ,...
                           'InitialValue', [1],... % first is likely pressure so suggest 2 others
                           'PromptString', 'Select single variables to plot as colored dots', ....
                                   'Name', 'Selection of c/z-variable');
      OPT.index.var = OPT.index.var*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D(1).sdn_standard_name)
      %disp(['SDN name: ',D.sdn_standard_name{i},'  <-?->  ',OPT.sdn_standard_name])
         if any(strfind(D(1).sdn_standard_name{i},OPT.sdn_standard_name))
            OPT.index.var = i;
            break
         end
      end
      if OPT.index.var==0
         error([OPT.sdn_standard_name,' not found.'])
         return
      end
   end
   
%% find column to use as vertical axis
   OPT.index.z = 0;
   if D(1).cast
    if isempty(OPT.z)
      [OPT.index.z, ok] = listdlg('ListString', {D(1).sdn_long_name{10:2:end}} ,...
                           'InitialValue', [1],... % first is likely pressure so suggest 2 others
                           'PromptString', 'Select single variables to plot as colored dots', ....
                                   'Name', 'Selection of c/z-variable');
      OPT.index.z = OPT.index.z*2-1 + 9; % 10th is first on-meta data item
    else
      for i=1:length(D(1).sdn_standard_name)
      %disp(['SDN name: ',D.sdn_standard_name{i},'  <-?->  ',OPT.sdn_standard_name])
         if any(strfind(D(1).sdn_standard_name{i},OPT.z))
            OPT.index.z = i;
            break
         end
      end
      if OPT.index.z==0
         error([OPT.z,' not found.'])
         return
      end
    end
   end

%% resolve parameter

    if isempty(D(1).sdn_long_name)
     [~,M.sdn_standard_name,~] =  sdn_parameter_mapping_resol(D(1).odv_name);
      M.sdn_long_name =  '';
      M.sdn_units     =  '';
    end

%% merge parameter

   fldnames = ...
   {'odv_name',...
    'standard_name',...    
    'units',...    
    'local_name',...    
    'local_units',...       
    'sdn_long_name',...       
    'sdn_standard_name',...
    'sdn_units'};
    
    for ifld=1:length(fldnames)
       fldname     = fldnames{ifld};
       R.(fldname) = D(1).(fldname){OPT.index.var};
    end

%%% merge data

   R.cruise        = cell([length(D),1]);
   R.station       = cell([length(D),1]);
   R.type          = cell([length(D),1]);
   R.datenum       = cell([length(D),1]);
   R.latitude      = cell([length(D),1]);
   R.longitude     = cell([length(D),1]);
   R.LOCAL_CDI_ID  = cell([length(D),1]);
   R.CDI_record_id = cell([length(D),1]);
   R.EDMO_code     = cell([length(D),1]);
   R.data          = cell([length(D),1]);
   
   for i=1:length(D)
   
%% extract data

      R.cruise{i}        =              D(i).data{D(i).index.cruise      };  % D(i).cruise;
      R.station{i}       =              D(i).data{D(i).index.station     };  % D(i).station;
      R.type{i}          =              D(i).data{D(i).index.type        };  % D(i).type;
      R.LOCAL_CDI_ID{i}  =              D(i).data{D(i).index.LOCAL_CDI_ID};  % D(i).LOCAL_CDI_ID;
      R.CDI_record_id{i} =              D(i).CDI_record_id;
      R.EDMO_code{i}     =              D(i).data{D(i).index.EDMO_code   };  % D(i).EDMO_code;

      R.datenum{i}       = datenum(char(D(i).data{D(i).index.time        }),'yyyy-mm-ddTHH:MM:SS');
      R.latitude{i}      =     cell2mat(D(i).data(D(i).index.latitude    ));
      R.longitude{i}     =     cell2mat(D(i).data(D(i).index.longitude   ));
      
      R.data{i} = D(i).data{OPT.index.var}; % empties in here get lost, so ...
      if isempty(R.data{i})
         R.data{i} = nan.*D(i).metadata.datenum;
      end
      
%% subset one data value per odv file or ...?

      R.cruise{i}        = OPT.metadataFcn(R.cruise{i}       );
      R.station{i}       = OPT.metadataFcn(R.station{i}      );
      R.type{i}          = OPT.metadataFcn(R.type{i}         );
      R.LOCAL_CDI_ID{i}  = OPT.metadataFcn(R.LOCAL_CDI_ID{i} );
      R.CDI_record_id{i} = OPT.metadataFcn(R.CDI_record_id{i});
      R.EDMO_code{i}     = OPT.metadataFcn(R.EDMO_code{i}    );

      R.datenum{i}       = OPT.metadataFcn(R.datenum{i}      );
      R.latitude{i}      = OPT.metadataFcn(R.latitude{i}     );
      R.longitude{i}     = OPT.metadataFcn(R.longitude{i}    );
      R.data{i}          =     OPT.dataFcn(R.data{i}         );

      %if D(1).cast
      %   R.data{i}      = str2num(char(D(i).data{OPT.index.z}));
      %end
   
   end
   
   %% either expand per-file meta-info or do not cell2mat per-file data
   
   % R.data         = cell2mat(R.data     );
   % R.datenum      = cell2mat(R.datenum  );
   % R.latitude     = cell2mat(R.latitude );
   % R.longitude    = cell2mat(R.longitude);

%% EOF