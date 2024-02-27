function writeMDA1(mda_filename, MDAdata)
%writeMDA: Writes a unibest mda-file based on a baseline (ldb). Can also
%          include a shoreline (ldb), it will then automatically determine
%          the cross-shore (perpendicular) distance between the baseline
%          and shoreline. You can also specify a minimum grid resolution
%          or cut-up your baseline with a certain resolution. Finally, the
%          output can automatically be visualized using a keyword:
%
%  Syntax:
%     writeMDA(mda_filename, baseline_ldb, <keyword,value>);
% 
%  Input:
%    mda_filename       Required: String with output filename of mda-file
%    MDAdata            Structure
% 
%  Output:
%     *.mda file as specified by mda_filename (or figure if save_to_mda = 0)
%
%  Example 1:
%     writeMDA('test.MDA',MDAdata);
%
%   See also readMDA landboundary add_equidist_points polyintersect

%% Copyright notice
%   --------------------------------------------------------------------
%
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%       Bas.Huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.


    %% Write everything to the MDA file:
    N=length(MDAdata.X);
    fid=fopen(mda_filename,'wt');
    fprintf(fid,'%s\n',' BASISPOINTS');
    fprintf(fid,'%4.0f\n',N);
    fprintf(fid,'%s\n','     Xw             Yw             Y              N              Ray');
    for ii=1:N
        fprintf(fid,'%13.2f   %13.2f %11.3f %11.0f %11.0f\n',[MDAdata.X(ii), MDAdata.Y(ii), MDAdata.Y1(ii),  MDAdata.nrgridcells(ii) MDAdata.nr(ii)]');
        if ~isnan(MDAdata.Y2(ii))
            fprintf(fid,'%13s   %13s %11.3f\n','','',MDAdata.Y2(ii));
        end
    end
    fclose(fid);

end
