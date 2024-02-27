function description = sdn_parameter_mapping_resolve(SDNstring,varargin)
%SDN_PARAMETER_MAPPING_RESOLVE   resolves a SeaDatNet vocabulary term on http://vocab.ndg.nerc.ac.uk webservice (BETA)
%
%    description = sdn_parameter_mapping_resolve(SDNstring)
%
% verifies a SeaDatNet vocabulary term on http://vocab.ndg.nerc.ac.uk 
% webservice by extracting the long description from the xml.
%
% SDNstring can either be the full http vocab address
%
%    description = sdn_parameter_mapping_resolve('http://vocab.ndg.nerc.ac.uk/term/P061/current/UPBB')
%    description = sdn_parameter_mapping_resolve('http://vocab.ndg.nerc.ac.uk/term/P011/current/PRESPS01')
%
% or a the relevant part of a SeaDataNet code
%
%    description = sdn_parameter_mapping_resolve('SDN:P061:<version>:UPBB')
%    description = sdn_parameter_mapping_resolve('SDN:P011:<version>:PRESPS01')
%
% Please report non-resolvable cases to: webmaster@bodc.ac.uk <webmaster@bodc.ac.uk>
%
%See also: OCEANDATAVIEW, sdn_parameter_mapping_parse

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: sdn_parameter_mapping_resolve.m 12211 2015-08-31 07:35:29Z santinel $
% $Date: 2015-08-31 15:35:29 +0800 (Mon, 31 Aug 2015) $
% $Author: santinel $
% $Revision: 12211 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/sdn_parameter_mapping_resolve.m $
% $Keywords: $

%% Settings

   OPT.method       = 'web'; % 'loc' is much faster than 'web'
   OPT.save         = 0;
   OPT.disp         = 0;
   
   if nargin==0
    varargout = {OPT};
    return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);   
   
   
%% Example
% <skos:Concept rdf:about='http://vocab.ndg.nerc.ac.uk/term/P061/33/UMKS'>
% <skos:externalID>SDN:P061:33:UMKS</skos:externalID>
% <skos:prefLabel>10^-8 * Cubic metres per kilogram</skos:prefLabel>
% <skos:altLabel>10^-8m^3kg-1</skos:altLabel>
% <skos:definition>Unavailable</skos:definition>
% <dc:date>2011-01-20T20:39:40.295+0000</dc:date></skos:Concept>   

%% <skos:Concept rdf:about='http://vocab.ndg.nerc.ac.uk/term/P061/33/UMKS'>

   if strcmpi(SDNstring(1:7),'http://')
   
      if ~(strcmpi(SDNstring(end),'/'))
         SDNstring = [SDNstring,'/'];
      end
   
      index            = strfind(SDNstring,'/');
      
      realm            = 'URI';
      listReference    =  SDNstring(index(end-3)+1:index(end-2)-1); % e.g.'P011';
      listVersion      =  SDNstring(index(end-2)+1:index(end-1)-1); % e.g.'' or 213
      entryReference   =  SDNstring(index(end-1)+1:index(end  )-1); % e.g.'EWDAZZ01';

      url              = SDNstring;

%% <skos:externalID>SDN:P061:33:UMKS</skos:externalID>

   else 
   
      index            = strfind(SDNstring,':');
      
      realm            =  SDNstring(         1:index(1)-1); % e.g.'SDN';
      listReference    =  SDNstring(index(1)+1:index(2)-1); % e.g.'P011';
      listVersion      =  SDNstring(index(2)+1:index(3)-1); % e.g.'' or 213
      entryReference   =  SDNstring(index(3)+1:end       ); % e.g.'EWDAZZ01';
      
      % BODC migrated P011>P01 and P061>P06
      if strcmpi(listReference,'P011')
          listReference = 'P01';
      end
      if strcmpi(listReference,'P061')
          listReference = 'P06';
      end        

      if isempty(listVersion)
      listVersion      =  'current';
      end

      % construct URI
      
      server           =  'http://vocab.ndg.nerc.ac.uk/';
      service          =  'term/';
      url              = [server,service,listReference,'/',listVersion,'/',entryReference];
      
      if OPT.disp;disp(url);end

   end
   
%% Resolve

   if strcmpi(OPT.method,'web') % | strcmpi(SDNstring(1:7),'http://')
      
      if OPT.save
      fname            = [mkvar(SDNstring) '.xml'];
                         urlwrite(url,fname);
      end
      
      pref.KeepNS      = 0;
      D                = xml_read(url,pref);
      if isfield(D,'Concept')
      description      = D.Concept.prefLabel;
      else
      description      = 'error';
      end
      
      if OPT.disp
      disp(description)
      disp(' ')
      end
      
   elseif strcmpi(OPT.method,'loc')
   
      description  = P01('resolve',entryReference,'listReference',listReference);
      
   end   
   


