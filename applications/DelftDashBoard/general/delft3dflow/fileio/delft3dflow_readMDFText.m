function MDF = delft3dflow_readMDFText(filename)
%DELFT3DFLOW_READMDFTEXT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   MDF = delft3dflow_readMDFText(filename)
%
%   Input:
%   filename =
%
%   Output:
%   MDF      =
%
%   Example
%   delft3dflow_readMDFText
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: delft3dflow_readMDFText.m 5946 2012-04-11 12:35:47Z ormondt $
% $Date: 2012-04-11 20:35:47 +0800 (Wed, 11 Apr 2012) $
% $Author: ormondt $
% $Revision: 5946 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/fileio/delft3dflow_readMDFText.m $
% $Keywords: $

%%
fid=fopen(filename);

k=0;
n=1;
for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%s','delimiter','=');
        % nn=length(v0);
        % concatenate strings containing =
        % still to be implemented
        switch lower(deblank(v0{1}))
            case{'comment','commnt'}
            otherwise
                if ~isnan(str2double(v0{1})) && length(v0)==1
                    % Vertical layers
                    n=n+1;
                    val=MDF.(activeField);
                    val(n)=str2double(v0{1});
                    MDF.(activeField)=val;
                elseif isnan(str2double(v0{1})) && length(v0)==1
                    % Description, tidal forces
                    n=n+1;
                    if n==2
                        vl=MDF.(activeField);
                        val=[];
                        val{1}=vl;
                        MDF.(activeField)=val;
                        val=[];
                    end
                    val=MDF.(activeField);
                    strtmp=strread(v0{1},'%s','delimiter','#','whitespace','');
                    try
                    val{n}=strtmp{2};
                    catch
                        shite=1
                    end
                    MDF.(activeField)=val;
                else
                    n=1;
                    if length(v0)==2
                        activeField=lower(deblank(v0{1}));
                        if ~isnan(str2double(v0{2}))
                            MDF.(activeField)=str2double(v0{2});
                        elseif ~isnan(str2num(v0{2}))
                            MDF.(activeField)=str2num(v0{2});
                        else
                            strtmp=strread(v0{2},'%s','delimiter','#','whitespace','');
                            if length(strtmp)>1
                                MDF.(activeField)=strtmp{2};
                            end
                        end
                        %                        activeField=deblank(v0{1});
                    end
                end
        end
    else
        v0='';
    end
end

fclose(fid);

