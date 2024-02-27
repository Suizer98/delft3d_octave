function Station = rws_waterbase_get_locations(Code,CodeName,varargin)
%RWS_WATERBASE_GET_LOCATIONS   reads all available location info for 1 DONAR Substance
%
%    Station = rws_waterbase_get_locations(Code,CodeName)
%
% where Code = the Substance code as returned by getWaterbaseData_substances
% e.g. 22 for the following Substance code as returned by GETWATERBASEDATA_SUBSTANCES
% e.g. 22 for :
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. "22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% Station struct has fields:
%
% * FullName, e.g. 'Aukfield platform'
% * ID      , e.g. 'AUKFPFM'
%
% Meta-data (e.g. coordinates) for a station can be retrived with rws_waterbase_location.
%
% Example:
%  S = rws_waterbase_get_locations(22,'22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater')
%
% See also: <a href="http://live.waterbase.nl">live.waterbase.nl</a>, rijkswaterstaat, rws_waterbase_location

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Y. Friocourt
%
%       yann.friocourt@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%   --------------------------------------------------------------------

% $Id: rws_waterbase_get_locations.m 12592 2016-03-17 08:36:52Z gerben.deboer.x $
% $Date: 2016-03-17 16:36:52 +0800 (Thu, 17 Mar 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12592 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_get_locations.m $

% 2009 jan 27: removed from getWaterbaseData to separate function [Gerben de Boer]
% 2009 dec 28: adapted to new waterbase.nl html page [Gerben de Boer]
% 2010 jun 24: inserted new url live.waterbase.nl [Gerben de Boer]

   OPT.version  = 3; % 0 = local cache, 1 is before summer 2009, 2 is after mid dec 2009, 3=needed on 3 feb 2012
   OPT.baseurl  = 'http://live.waterbase.nl';

%% load url

   if       OPT.version==0
     url = ['file:///' fileparts(mfilename('fullpath')) filesep 'locations.txt'];
   elseif   OPT.version==1
     url = [OPT.baseurl,'/getGML.cfm?wbwns=' sprintf('%d', Code)];
   elseif   OPT.version==2
     url = [OPT.baseurl,'/index.cfm?page=start.locaties&whichform=1&wbwns1=' sprintf('%s', CodeName) '&wbthemas=&search='];
   elseif   OPT.version==3
     url = [OPT.baseurl,'/waterbase_locaties.cfm?whichform=1&wbwns1=' sprintf('%s', CodeName) '&wbthemas=&search='];
   end
   
%% load locations data file

   [s status] = urlread(url);
   if (status == 0)
       warndlg([OPT.baseurl,' may be offline or you are not connected to the internet','Online source not available']);
       OutputName = [];
       return;
   end
   
%% interpret locations data file   
%  change in html page after relaunch of waterbase.nl dec 2009

   if   OPT.version==1
     exprFullName = '<property typeName="FullName">[^<>]*</property>';
     sFullName    = regexp(s, exprFullName,'match');
     exprID       = '<property typeName="ID">[^<>]*</property>';
     sID = regexp(s, exprID,'match');
   elseif any(OPT.version==[2 3])
     exprFullName = '<option value="[^<>]*">[^<>]*</option>'; %'<property typeName="FullName">[^<>]*</property>';
     sFullName    = regexp(s, exprFullName,'match');
     % <option value="ADLWG">Adelaarsweg (Hoge Vaart)</option> 
     % ...
     % <option value="ZWARTHN">Zwarte Haan</option>  
   end
   
   for iStation = 1:length(sFullName)
       sTemp                        = sFullName{iStation};
       if   OPT.version==1
         Station.FullName{iStation} = sTemp(31:end-11);
         sTemp                      = sID{iStation};
         Station.ID{iStation}       = sTemp(25:end-11);
       elseif any(OPT.version==[2 3])
         ind                        = strfind(sTemp,'"');
         Station.ID{iStation}       = sTemp(ind(1)+1:ind(2)-1);
         ind(1)                     = strfind(sTemp,'">');
         ind(2)                     = strfind(sTemp,'</');
         Station.FullName{iStation} = sTemp(ind(1)+2:ind(2)-1);
       end
   end
   
%% EOF
