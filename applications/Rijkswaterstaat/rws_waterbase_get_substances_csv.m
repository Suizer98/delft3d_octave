function Substance = rws_waterbase_get_substances_csv(fname)
%RWS_WATERBASE_GET_SUBSTANCES_CSV   list of waterbase substances from 'donar_substances.csv'
%
%    Substance = getWaterbaseData_substances(<fname.csv>)
%
% gets list of all SUBSTANCES available for queries at <a href="http://live.waterbase.nl">live.waterbase.nl</a>
% where by default <fname.csv> = 'donar_substances.csv'
%
% Substance struct has fields:
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. 22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% See also: <a href="http://live.waterbase.nl">live.waterbase.nl</a>, rijkswaterstaat

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

% $Id: rws_waterbase_get_substances_csv.m 8476 2013-04-19 08:43:26Z boer_g $
% $Date: 2013-04-19 16:43:26 +0800 (Fri, 19 Apr 2013) $
% $Author: boer_g $
% $Revision: 8476 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_get_substances_csv.m $

% 2009 jan 27: removed from getWaterbaseData to separate function [Gerben de Boer]

%% load substances data file
   if nargin==0
      fname = 'rws_waterbase_substances.csv';
   end

   fid = fopen(fname, 'r+');
   s1   = fscanf(fid, '%c', [1 inf]);
   fclose(fid);
   
%% interpret substances data file
   IndLine               = regexp(s1, '\n');
   nSub                  = length(IndLine);
   IndSubs               =  regexp(s1(        1:IndLine(1)-1), ';');
   Substance.FullName{1} =         s1(        2:IndSubs   -2);
   Substance.CodeName{1} =         s1(IndSubs+2:IndLine(1)-3);
   IndCode               =  regexp(s1(IndSubs+1:IndLine(1)-1), '%');
   Substance.Code(1)     = str2num(s1(IndSubs+2:IndSubs+IndCode(1)-1));
   for iSub = 1:nSub-1
       IndSubs                    =  regexp(s1(IndLine(iSub)+1        :IndLine(iSub+1)                   -1), ';');
       Substance.FullName{iSub+1} =         s1(IndLine(iSub)+2        :IndLine(iSub  )+IndSubs           -2);
       Substance.CodeName{iSub+1} =         s1(IndLine(iSub)+IndSubs+2:IndLine(iSub+1)                   -3);
       IndCode                    =  regexp(s1(IndLine(iSub)+IndSubs+1:IndLine(iSub+1)                   -1), '%');
       Substance.Code(iSub+1)     = str2num(s1(IndLine(iSub)+IndSubs+2:IndLine(iSub  )+IndSubs+IndCode(1)-1));
   end
   
%% EOF   