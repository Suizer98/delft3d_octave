function result = read(filename, nosuchfileaction, makeords, treatasdata, dictionary)
% Reads YAML files (and also json files)
%   Functions are copied from Google Code and modified to a name space 
%   structure. The test are updated and complimented.
%
%   Source: https://code.google.com/archive/p/yamlmatlab/
%           YAMLMatlab_0.4.3
%
%   Reads YAML file and transforms it using several mechanisms:
%   - Transforms mappings and lists into Matlab structs and cell arrays,
%     for timestamps uses DateTime class, performs all imports (when it
%     finds a struct field named 'import' it opens file(s) named in the
%     field content and substitutes the filename by their content.
%   - Deflates outer imports into inner imports - see deflateimports(...)
%     for details.
%   - Merges imported structures with the structure from where the import
%     was performed. This is actually the same process as inheritance with
%     the difference that parent is located in a different file.
%   - Does inheritance - see doinheritance(...) for details.
%   - Makes matrices from cell vectors - see makematrices(...) for details.
%
%   Input:
%       filename         = name of an input yaml file
%       nosuchfileaction = Determines what to do if a file to read is missing
%                          0 or not present - missing file will only throw a
%                                             warning
%                          1                - missing file throws an
%                                             exception and halts the process
%       makeords          = Determines whether to convert cell array to
%                           ordinary matrix whenever possible (1).
%       dictionary        = Dictionary of of labels that will be replaced,
%                           struct is expected
%       treatasdata       = ? (0 or 1)
%
%   Output: 
%       result            = Read data as struct/cell
%
%   Example
%   	fname  = C:\checkouts\oetools\trunk\matlab\io\+yml\examples\ibm_example.yml;
%       result = yml.read(fname);
%
%   Remarks
%       - Datetime is read and parsed to an yml.tools.DateTime object containing the Matlab datenum
%         as a double. This object can be use as a double.
%       - Tests are stored in: C:\checkouts\oetools\trunk\matlab\io\+yml\tests
%         Running the selftest_yamlmatlab.m will produce all the results
%
%   See also yml.readraw  yml.write

% TODO: 
%       - make time parsing optional? Keep the time as a string?
%       - make test for time and time zone etc. when not parsed
% DONE:
%       - converted the code to namespace functions
%       - added milliseconds to time read and write (parsing)
%       - updated tests (including time issues)

%   --------------------------------------------------------------------
%   Copyrights (C) see below code
% --------------------------------------------------------------------
%   $Id: votemplate.m 5290 2015-12-08 11:33:47Z rho@vanoord.com $
%   $HeadURL: svn://10.12.184.200/votools/trunk/matlab/general/vo_template/votemplate.m $
%   $Keywords:
% --------------------------------------------------------------------

    if ~exist('nosuchfileaction','var')
        nosuchfileaction = 0;
    end;
    if ~ismember(nosuchfileaction,[0,1])
        error('nosuchfileexception parameter must be 0,1 or missing.');
    end;
    if ~exist('makeords','var')
        makeords = 0;
    end;
    if ~ismember(makeords,[0,1])
        error('makeords parameter must be 0,1 or missing.');
    end;    
    if(~exist('treatasdata','var'))
        treatasdata = 0;
    end;
    if ~ismember(treatasdata,[0,1])
        error('treatasdata parameter must be 0,1 or missing.');
    end; 

    
    ry = yml.readraw(filename, 0, nosuchfileaction, treatasdata);
    ry = yml.tools.deflateimports(ry);
    if iscell(ry) && ...
        length(ry) == 1 && ...
        isstruct(ry{1}) && ...
        length(fields(ry{1})) == 1 && ...
        isfield(ry{1},'import')        
        ry = ry{1};
    end;
    ry = yml.tools.mergeimports(ry);    
    ry = yml.tools.doinheritance(ry);
    ry = yml.tools.makematrices(ry, makeords);    
    if exist('dictionary','var')
        ry = yml.tools.dosubstitution(ry, dictionary);
    end;
    
    result = ry;
    clear global nsfe;
end

%   --------------------------------------------------------------------
%   Copyright (C) 2017 Van Oord, RHO@vanoord.com
%
%   This library is copyrighted Van Oord software intended for internal
%   use only: you cannot redistribute it outside of Van Oord.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. In case of
%   errors or suggestions, refer to the central HeadURL address below.
%   --------------------------------------------------------------------
%
%   ---------------- Original code -------------------------------------
%   Copyright (c) 2011 CTU in Prague and  Energocentrum PLUS s.r.o.
% 
%   Permission is hereby granted, free of charge, to any person
%   obtaining a copy of this software and associated documentation
%   files (the "Software"), to deal in the Software without
%   restriction, including without limitation the rights to use,
%   copy, modify, merge, publish, distribute, sublicense, and/or sell
%   copies of the Software, and to permit persons to whom the
%   Software is furnished to do so, subject to the following
%   conditions:
% 
%   The above copyright notice and this permission notice shall be
%   included in all copies or substantial portions of the Software.
% 
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%   OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%   OTHER DEALINGS IN THE SOFTWARE.
%   --------------------------------------------------------------------
