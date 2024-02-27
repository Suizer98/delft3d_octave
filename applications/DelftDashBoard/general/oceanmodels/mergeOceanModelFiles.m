function errmsg = mergeOceanModelFiles(dr, name, outfile, par, t0, t1)
%MERGEOCEANMODELFILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   errmsg = mergeOceanModelFiles(dr, name, outfile, par, t0, t1)
%
%   Input:
%   dr      =
%   name    =
%   outfile =
%   par     =
%   t0      =
%   t1      =
%
%   Output:
%   errmsg  =
%
%   Example
%   mergeOceanModelFiles
%
%   See also

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

% $Id: mergeOceanModelFiles.m 5538 2011-11-29 12:07:28Z boer_we $
% $Date: 2011-11-29 20:07:28 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5538 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/oceanmodels/mergeOceanModelFiles.m $
% $Keywords: $

%%
errmsg=[];
flist=dir([dr filesep name '.' par '.*.mat']);
if isempty(flist)
    errmsg='Could not find data files from ocean model!';
    return
end

lpar=length(par);
lname=length(name);
for i=1:length(flist)
    nm=flist(i).name;
    tstr=nm(lname+lpar+3:lname+lpar+16);
    t(i)=datenum(tstr,'yyyymmddHHMMSS');
end
it0=find(t<=t0,1,'last');
it1=find(t>=t1,1,'first');
if isempty(it0)
    errmsg='First time in data files from ocean model after model start time!';
    return
end
if isempty(it1)
    errmsg='Last time in data files from ocean model before model stop time!';
    return
end

nt=it1-it0+1;
for it=it0:it1
    ff=[dr filesep flist(it).name];
    fstruc=load(ff);
    if it==it0
        % First file
        newstruc=fstruc;
    else
        ntim=length(newstruc.time);
        newstruc.time(ntim+1)=fstruc.time;
        if ndims(fstruc.data)==2
            newstruc.data(:,:,ntim+1)=fstruc.data;
        else
            newstruc.data(:,:,:,ntim+1)=fstruc.data;
        end
    end
end
save(outfile,'-struct','newstruc');


