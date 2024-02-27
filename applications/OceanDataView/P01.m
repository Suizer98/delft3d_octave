function varargout = P01(varargin);
%P01   read/search BODC P01 parameter vocabulary
%
%    L = P01()
%    L = P01('read',1)
%
% returns struct with field per database entry.
%
% If only P01.xml exists locally, reading is slow. Therefore
% P01 will save a cache as *.mat (+ dead-end *.nc and *.xls), 
% which makes reading any 2nd time much faster.
%
%    <indices> = P01(<L>,'find','pattern')
%
% displays table AND returns indices into fields of L after
% searching the description (long_name, entryTerm).
%
%    [description,<indices>] = P01(<L>,'resolve','standard_name')
%
% returns description (long_name, entryTerm) of standard_name (entryKey).
% description isempty when nothing was found.
%
% The P01 parameter vocabulary needs to be downloaded (xml) first from
% http://www.bodc.ac.uk/products/web_services/
% into the directory >> fileparts(which('p01')), use the P01.url.
%
% After one call, the P01 + P061 vocabs are saved as persistent
% variables to boost performance, use munlock P01 to free ~ 10 MB memory.
%
% Examples:
%
%    L         = P01(  'read'       ,1         )
%    indices   = P01(L,'find'       ,'salinity');
%    long_name = P01(L,'resolve'    ,'ODSDM021')
%    long_name = P01(L,'resolve'    ,'ODSDM0')
%
% http://vocab.ndg.nerc.ac.uk/collection/
% http://vocab.nerc.ac.uk/collection/
% http://seadatanet.maris2.nl/v_cdi_v2/print_xml.aspx?n_code=5900
%
%See also: SDN_PARAMETER_MAPPING_RESOLVE, SDN_PARAMETER_MAPPING_PARSE, NC_CF_STANDARD_NAME_TABLE

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
% $Id: P01.m 10522 2014-04-10 21:00:37Z boer_g $
% $Date: 2014-04-11 05:00:37 +0800 (Fri, 11 Apr 2014) $
% $Author: boer_g $
% $Revision: 10522 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/P01.m $
% $Keywords: $

%% input

persistent P01  % cache this as it takes too long to load many times
persistent P06

L                 = [];
OPT.listReference = 'P01';
OPT.disp          = 1;
OPT.list_method   = '';%'getList'        

OPT.read          = 0;
OPT.find          = ''; % description to standard_name
OPT.resolve       = ''; % check existence of standard_name

if nargin > 0
 if isstruct(varargin{1})
    L        =  varargin{1};
    varargin = {varargin{2:end}};
 end
end

OPT = setproperty(OPT,varargin{:});

if strcmpi(OPT.list_method,'getList')
 % Pxxx_getList.url
 % http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getList?recordKey=http://vocab.ndg.nerc.ac.uk/list/P061/current&earliestRecord=1900-01-01T00:00:00Z
 OPT.standard_name = 'entryKey';   % fieldname of L (xml)
 OPT.long_name     = 'entryTerm';  % fieldname of L (xml)
elseif isempty(OPT.list_method)
 % Pxxx.url
 % http://vocab.ndg.nerc.ac.uk/list/P061/current
 OPT.standard_name = 'externalID'; % fieldname of L (xml)
 OPT.long_name     = 'prefLabel';  % fieldname of L (xml)
end

%% load and cache vocab

if ~isempty(OPT.read) | isempty(L)

    ncfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.nc'];
   xlsfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.xls'];
   matfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.mat'];

   if exist(matfile,'file')==2
   
      if strcmpi(OPT.listReference,'P01')
      
          if isempty(P01)
          disp(['Loading cached ',OPT.listReference '.mat for persistent use (30MB) to interpret SDN/ODV codes (>> clear P01 to free memory) ...'])
          P01 = load(matfile); %P01 = nc2struct(ncfile);
          end
          L = P01; % variable P01 required for memory caching
          
      elseif strcmpi(OPT.listReference,'P06') 
      
          if isempty(P06)
          P06 = load(matfile); %P06 = nc2struct(ncfile);
          disp(['Loading cached ',OPT.listReference '.mat for persistent use (.4 Mb) to interpret SDN/ODV codes (>> clear P061 to free memory) ...'])
          end
          L = P06; % variable P01 required for memory caching
      
      else

      disp([OPT.listReference ': loaded cached ' OPT.listReference '.mat'])
      end
   
   else
   
      PREF.KeepNS = 0;
      
     % TODO
     % disp([OPT.listReference ': downloading looong xml file, please wait about 10 minutes (any next times only 9 sec)'])
     % urlwrite('')
      
%% parse xml file, to allow indentical behavior for nc_cf_standard_name_table and P01

      tic
      tmpfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.xml.mat'];
      if exist(tmpfile)
         L2  = load(tmpfile);
         disp([mfilename,': loaded parsed xml from ',tmpfile])
      else
         disp([OPT.listReference ': parsing looong xml file, please wait about 10 minutes (any next times only 9 sec) ...'])
         L2  = xml_read([OPT.listReference '.xml'],PREF);
         save(tmpfile,'-struct','L2');
         disp([mfilename,': cached parsed xml to   ',tmpfile])
      end
      toc

%% get rid of nested fields (turn all xml attributes into elements)
      
      if strcmpi(OPT.list_method,'getList')

   %% http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getList?recordKey=http://vocab.ndg.nerc.ac.uk/list/P061/current&earliestRecord=1900-01-01T00:00:00Z

      % <ns1:getListResponse xmlns:ns1="urn:vocab/types">
      % <ns1:codeTableRecord>
      % <ns1:listKey>http://vocab.ndg.nerc.ac.uk/list/P01/185</ns1:listKey>
      % <ns1:entryKey>http://vocab.ndg.nerc.ac.uk/term/P01/185/PAGEPAMS</ns1:entryKey>
      % <ns1:entryTerm>14C Age of peat by accelerator mass spectrometry</ns1:entryTerm>
      % <ns1:entryTermAbbr>AMSPeatAge</ns1:entryTermAbbr>
      % <ns1:entryTermDef>Unavailable</ns1:entryTermDef>
      % <ns1:entryTermLastMod>2008-07-02T10:59:58.000+00:00</ns1:entryTermLastMod>
      % </ns1:codeTableRecord>
      % </ns1:getListResponse>

         fldnames = fieldnames(L2.codeTableRecord);
         for ifld=1:length(fldnames)
            fldname = fldnames{ifld};
            L.(fldname) = {L2.codeTableRecord(:).(fldname)};
         end
         
      elseif isempty(OPT.list_method)

   %% http://vocab.ndg.nerc.ac.uk/list/P061/current

      % <?xml version="1.0" ?>
      % <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
      %
      % xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
      % xmlns:dc="http://purl.org/dc/elements/1.1/"> 
      %
      % <skos:Concept rdf:about='http://vocab.ndg.nerc.ac.uk/term/P01/251/SAGEMSFM'>
      % <skos:externalID>SDN:P01:251:SAGEMSFM</skos:externalID>
      % <skos:prefLabel>14C age of Foraminiferida (ITIS: 44030: WoRMS 22528) [Subcomponent: tests] in sediment by picking and accelerator mass spectrometry</skos:prefLabel>
      % <skos:altLabel>AMSSedAge</skos:altLabel>
      % <skos:definition>Unavailable</skos:definition>
      % <dc:date>2011-01-19T10:09:47.500+0000</dc:date>
      % <skos:broadMatch rdf:resource="http://vocab.ndg.nerc.ac.uk/term/P021/61/SAGE" /> 
      %
      % </skos:Concept>
      % </rdf:RDF> 

         for i=1:length(L2.Collection.member)
          L2i = L2.Collection.member(i).Concept;
          L2.Concept(i).about       = L2i.ATTRIBUTE.about;
          L2.Concept(i).(OPT.standard_name) = L2i.identifier;
          L2.Concept(i).(OPT.long_name)     = L2i.prefLabel.CONTENT;
          L2.Concept(i).definition          = L2i.definition.CONTENT;          
          
          if strcmpi(OPT.listReference,'P01')
          L2.Concept(i).related     = ATTRIBUTE_resource2char(L2i.related);          
          L2.Concept(i).broader     = ATTRIBUTE_resource2char(L2i.broader);
          elseif strcmpi(OPT.listReference,'P061')
          end
          
         end
         L2            = rmfield(L2           ,'ATTRIBUTE');
         L2.Collection = rmfield(L2.Collection,'ATTRIBUTE');
         
      end
      
%% make struct of fields into field of structs

      L = array_of_structs2struct_of_arrays(L2.Concept);

      ind = strfind(L.(OPT.standard_name){1},':'); % whole xml file start with SDN:listReference:same_version_numer

      L.listReference  = OPT.listReference;
      L.listVersion    = L.(OPT.standard_name){1}(ind(end-1)+1:ind(end)-1);
      L.entryReference = char(L.(OPT.standard_name));
      L.entryReference = cellstr(L.entryReference(:,ind(end)+1:end)); % needed for quick search

      %fldnames = fieldnames(L2.Concept);
      %for ifld=1:length(fldnames)
      %   fldname = fldnames{ifld}
      %   L.(fldname) = {char(L2.Concept(:).(fldname))};
      %end
      
      % xml                                14   Mb, loads in 653   sec ( ~ 10 minutes)
      struct2nc (ncfile ,L);             % 34   Mb, loads in   2.3 sec
      struct2xls(xlsfile,L);             % 19   Mb, loads in   8.9 sec
      save      (matfile,'-struct','L'); %  1.6 Mb, loads in   2.8 sec
   
   end

   if nargout<2
      varargout = {L};
   end

end

%% find and display results of a search (description to standard_name)

if ~isempty(OPT.find)

   % find indices

   searchpattern = OPT.find;
   ii = regexpi(L.(OPT.long_name),searchpattern); % per cell item, empty or start index of searchpattern
   ii = find(~cellfun(@isempty,ii));       % indices of non-empty searchpattern matches

   % make table
   
   if ~isempty(ii) & OPT.disp
   
   standard_names = {L.(OPT.standard_name){ii}};
   standard_names = strrep(standard_names,'http://vocab.ndg.nerc.ac.uk/term/','');
   standard_names = char(standard_names);
   definition     = char({L.definition{ii}});
   
   n  = length(ii);
   n1 = size(standard_names             ,2);
   n2 = size(char(L.(OPT.long_name){ii}),2);
   col = repmat(' | ',[n 1]) ;

   disp([OPT.listReference ' entries matching: "',searchpattern,'"'])
   disp([OPT.listReference ' entries matching: "',searchpattern,'"'])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   disp([pad(num2str([1:n]'),' ',-4) repmat(' | ',[n 1]) standard_names       col char(L.(OPT.long_name){ii}) col definition])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   else
   disp([OPT.listReference ': no match found'])
   end

   % output
   if nargout<1
      varargout = [];
   else
      varargout = {ii};
   end

end

%% find and display results of a search (standard_name present)

if isempty(OPT.resolve)
      varargout = {''};
else
        
    
   searchpattern = OPT.resolve;
   
   ind = strfind(searchpattern,':');
   if length(ind)==0
       % ok
   elseif length(ind)==3
       searchpattern = searchpattern(ind(end)+1:end);
   else
       error('Only P01:SDN::xxxxxx and xxxxxx implemented.')
   end

   % cannot search for exact only due to presence of both list and list number in standard_name
   
  %ii = regexpi(L.(OPT.standard_name),searchpattern); % per cell item, empty or start index of searchpattern
  %ii = find(~cellfun(@isempty,ii));                  % indices of non-empty searchpattern matches
   ii = strmatch(searchpattern,L.entryReference);     % faster than 2 lines above
   
   long_name = char({L.(OPT.long_name){ii}}); % can be more than one

   if length(ii)==1
      OK = long_name;
   elseif ii > 1
      disp(char({L.(OPT.long_name){ii}}))
      error(['multiple occurences found for ',searchpattern,', please specify unique id.'])
   else
      OK = '';
   end
   
   if nargout<2
      varargout = {OK};
   elseif nargout==2
      varargout = {OK,ii};
   end   

end


%% subsidiary function to turn xml attributes into elements

      function txt = ATTRIBUTE_resource2char(S)
      if isempty(S)
       txt = '';
      else
       txt = S(1).ATTRIBUTE.resource;
        for j=2:length(S)
         txt = strcat(txt,[' ' S(j).ATTRIBUTE.resource]);
        end
      end

%% EOF
