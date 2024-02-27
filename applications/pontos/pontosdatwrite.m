function pontosdatwrite(data,datfilename)
%PONTOSDATREAD writes the data struct to a PonTos dat file
% (ALPHA RELEASE, UNDER CONSTRUCTION)
%
%   PonTos is an integrated conceptual model for Shore Line Management,
%   developed to assess the long-term and large-scale development
%   of coastal stretches. It is originally based on the multi-layer model
%   that was used to predict the development of the Dutch Wadden coast
%   [Steetzel, 1995].
%
%   The input of the PonTos-model for a specific case is gathered in a
%   file Case.DAT. This is a TEGAGX formatted ASCII file.
%
%   Syntax:
%   pontosdatread(data,datfilename)
%
%   Input:
%   data = struct containing input data (e.g. read with pontosdatread)
%   datfilename  = filename of the PonTos dat file (PonTos input)
%
%   Output:
%   PonTos input file
%
%   Example
%   datfilename =
%   'l:\A2112\Morfologie\PonTos\Voorbeeld invoer\Run_t_Sch_PBV1n_50.dat';
%   pontosdatwrite(data,datfilename);
%
%   See also pontosdatread

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       Bart Grasmeijer
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oettemplate.m 688 2009-07-15 11:46:33Z damsma $
% $Date: 2009-07-15 13:46:33 +0200 (Wed, 15 Jul 2009) $
% $Author: damsma $
% $Revision: 688 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/oet_template/oettemplate.m $
% $Keywords: $

%%

[datpathstr,datfilenamenopath,datfileext,datfileversn] = fileparts(datfilename);

myfieldnames = fieldnames(data);
fid = fopen(datfilename,'wt');
for i = 1:length(myfieldnames)
    if strcmp(char(myfieldnames(i,:)),'CMT')
        fprintf(fid,'%s\n','CMT');
        cmt = data.CMT;
        fprintf(fid,'%g',length(data.CMT));
        for j = 1:length(data.CMT);
            fprintf(fid,'%s',cmt{j});
        end
            fprintf(fid,'%s\n','');
    else
        fprintf(fid,'%s\n',char(myfieldnames(i,:)));
        mysize = size(getfield(data,char(myfieldnames(i,:))));
        if strcmp(char(myfieldnames(i,:)),'Y0C') && mysize(1)>25
            disp(['Warning: Y0C is too long in ',datfilenamenopath,'; maximum is 25 points']);
        end
        if strcmp(char(myfieldnames(i,:)),'Y1C') && mysize(1)>200
            disp(['Warning: Y1C is too long in ',datfilenamenopath,'; maximum is 200 points']);
        end
        if strcmp(char(myfieldnames(i,:)),'Y2C') && mysize(1)>25
            disp(['Warning: Y2C is too long in ',datfilenamenopath,'; maximum is 25 points']);
        end
        if strcmp(char(myfieldnames(i,:)),'Y3C') && mysize(1)>10
            disp(['Warning: Y3C is too long in ',datfilenamenopath,'; maximum is 10 points']);
        end
        if strcmp(char(myfieldnames(i,:)),'Y4C') && mysize(1)>5
            disp(['Warning: Y4C is too long in ',datfilenamenopath,'; maximum is 5 points']);
        end
        fprintf(fid,'%g %g\n',mysize);
        myformat = '%15.4f';
        for j = 1:mysize(2)-1
            myformat = [myformat, ' %15.4f'];
        end
        myformat = [myformat,'\n'];
        if mysize(1)~=0
            fprintf(fid,myformat,[getfield(data,char(myfieldnames(i,:)))]');
        else
            fprintf(fid,'%s\n','* ');
        end
    end
end
fclose(fid);
