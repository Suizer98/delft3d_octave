function sout = dflowfmreadextfile(fname)
%ddb_DFlowFM_readExternalForcing  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: dflowfmreadextfile.m 11467 2014-11-27 13:33:04Z ormondt $
% $Date: 2014-11-27 14:33:04 +0100 (Thu, 27 Nov 2014) $
% $Author: ormondt $
% $Revision: 11467 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/dflowfmreadextfile.m $
% $Keywords: $

%% Reads DFlow-FM external forcing

% s=[];

s = ddb_readDelft3D_keyWordFile(fname);

% % Read file
% n=0;
% fid=fopen(fname,'r');
% while 1
%     str=fgetl(fid);
%     if str==-1
%         break
%     end
%     str=deblank2(str);
%     if ~isempty(str)
%         if strcmpi(str(1),'*')
%             % Comment line
%         else
%             nis=find(str=='=');
%             switch lower(str(1:6))
%                 case{'quanti'}
%                     n=n+1;
%                     s(n).quantity=deblank2(str(nis+1:end));
% %                 case{'filety'}
% %                     s(n).filetype=deblank2(str(nis+1:end));
% %                 case{'filena'}
% %                     s(n).filename=deblank2(str(nis+1:end));
% %                 case{'method'}
% %                     s(n).method=deblank2(str(nis+1:end));
% %                 case{'operan'}
% %                     s(n).operand=deblank2(str(nis+1:end));
%                 case{'locati'}
%                     s(n).locationfile=deblank2(str(nis+1:end));
%                 case{'forcin'}
%                     s(n).forcingfile=deblank2(str(nis+1:end));
%             end
%         end
%         
%     end
% end
% fclose(fid);

% Clear boundary info
sout.boundaries=[];
sout.meteo=[];

nb=0;
nm=0;

% for ii=1:length(s)
%     switch lower(s(ii).quantity)
%         case{'waterlevelbnd'}
%             nb=nb+1;
%             sout.boundaries(nb).name=s(ii).filename(1:end-4);
%             sout.boundaries(nb).filetype=s(ii).filetype;
%             sout.boundaries(nb).filename=s(ii).filename;
%             sout.boundaries(nb).type=s(ii).quantity;
%         case{'dischargebnd'}
%             nb=nb+1;
%             sout.boundaries(nb).name=s(ii).filename(1:end-4);
%             sout.boundaries(nb).filetype=s(ii).filetype;
%             sout.boundaries(nb).filename=s(ii).filename;
%             sout.boundaries(nb).type=s(ii).quantity;
%         case{'spiderweb'}
%             nm=nm+1;
%             sout.meteo(nb).name=s(ii).filename(1:end-4);
%             sout.meteo(nb).filename=s(ii).filename;
%             sout.meteo(nb).filetype=s(ii).filetype;
%             sout.meteo(nb).type=s(ii).quantity;
%     end
% end

if isfield(s,'boundary')
    
    for ii=1:length(s.boundary)
        switch lower(s.boundary(ii).quantity)
            case{'waterlevelbnd'}
                nb=nb+1;
                sout.boundaries(nb).name=s.boundary(ii).locationfile(1:end-4);
                sout.boundaries(nb).locationfile=s.boundary(ii).locationfile;
                sout.boundaries(nb).forcingfile=s.boundary(ii).forcingfile;
            case{'dischargebnd'}
                nb=nb+1;
                sout.boundaries(nb).name=s.boundary(ii).locationfile(1:end-4);
                sout.boundaries(nb).locationfile=s.boundary(ii).locationfile;
                sout.boundaries(nb).forcingfile=s.boundary(ii).forcingfile;
            case{'spiderweb'}
                nm=nm+1;
                sout.meteo(nb).name=s(ii).filename(1:end-4);
                sout.meteo(nb).filename=s(ii).filename;
                sout.meteo(nb).filetype=s(ii).filetype;
                sout.meteo(nb).type=s(ii).quantity;
        end
    end
    
end
