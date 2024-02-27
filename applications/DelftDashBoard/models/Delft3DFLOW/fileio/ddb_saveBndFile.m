function ddb_saveBndFile(openBoundaries,filename)
%DDB_SAVEBNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveBndFile(openBoundaries,filename)
%
%   Input:
%   handles =
%   id      =
%
%   Example
%   ddb_saveBndFile
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
fid=fopen(filename,'w');

nr=length(openBoundaries);

% Astronomic
for n=1:nr
    if openBoundaries(n).forcing=='A'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        compa=openBoundaries(n).compA;
        compb=openBoundaries(n).compB;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s %s %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'A',m1,n1,m2,n2,alpha,prof,compa,compb);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'A',m1,n1,m2,n2,alpha,compa,compb);
        end
    end
end

% Harmonic
for n=1:nr
    if openBoundaries(n).forcing=='H'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'H',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'H',m1,n1,m2,n2,alpha);
        end
    end
end

% Time series
for n=1:nr
    if openBoundaries(n).forcing=='T'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'T',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'T',m1,n1,m2,n2,alpha);
        end
    end
end

% QH-relation
for n=1:nr
    if openBoundaries(n).forcing=='Q'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha);
        end
    end
end

fclose(fid);

