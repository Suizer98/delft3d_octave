% Toolbox for reading and writing yml or yaml files.
%
% This toolbox was created by Energocentrum PLUS, s.r.o. and Czech
% Technical University (CTU) in Prague, and modified by R.A. van der Hout
% (Van oord) to a namespace function and shared in the OpenEarth tools.
% The toolbox makes use of a java tool: snakeyaml-1.9.jar
%
% The original code is hosted in Google Code.
%   Source: https://code.google.com/archive/p/yamlmatlab/
%           YAMLMatlab_0.4.3
%
% TODO's: 
%       - make time parsing optional? Keep the time as a string?
%       - make test for time and time zone etc. when not parsed
%
% START:
%   yml.read.m    - reads yml files and parses the contents
%   yml.readraw.m - reads yml files (and parses it partly)
%   yml.write.m   - writes a structure to a yml file
%
% EXAMPLES
%   \examples\examples.m  - some simple examples
%
% TESTS
%   \test\selftest_yamlmatlab.m     - automated test
%   \test\test_ReadYaml.m           - read tests
%   \test\test_WriteYaml.m          - write tests
%   \test\Data                      - folders containing the test datafiles
%
% TOOLS
%   \+tools                         - internal matlab functions for the toolbox
%
%   Tools not directly used in the read/write functions:
%       GetYamlVals.m
%       datadump.m
%       TimeVals2Cell.m
%
% EXTERNAL
%   \external\snakeyaml-1.9.jar     - java tool for io to yml files


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
% --------------------------------------------------------------------
%   $Id: votemplate.m 5290 2015-12-08 11:33:47Z rho@vanoord.com $
%   $HeadURL: svn://10.12.184.200/votools/trunk/matlab/general/vo_template/votemplate.m $
%   $Keywords:
% --------------------------------------------------------------------
