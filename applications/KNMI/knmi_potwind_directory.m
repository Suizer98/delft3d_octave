function names = knmi_potwind_directory(directory,varargin)
%KNMI_POTWIND_DIRECTORY   scans a directory for potwind_***_**** files
%
%   names = knmi_potwind_directory(directory)
%
%  returns a cellstr names with the decadal data files per
%  KNMI station code. Each names cellstr can be passed to 
%  KNMI_POTWIND_MULTI, which will concatenate the decadal files.
%
%See also: KNMI_POTWIND, KNMI_POTWIND_GET_URL, KNMI_POTWIND_MULTI

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_potwind_directory.m 7856 2012-12-19 13:39:00Z boer_g $
% $Date: 2012-12-19 21:39:00 +0800 (Wed, 19 Dec 2012) $
% $Author: boer_g $
% $Revision: 7856 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_potwind_directory.m $
% $Keywords: $

%% Keyword,value

  %OPT = setproperty(OPT,varargin{:});
   
%% File loop

   OPT.files         = dir([directory]);
   OPT.stations      = cell(length(OPT.files),1);
   OPT.decade        = cell(length(OPT.files),1);
   
%% get unique station codes

   for ifile=1:length(OPT.files)
   
      OPT.stations{ifile} = OPT.files(ifile).name( 9:11);
      OPT.decade{ifile}   = OPT.files(ifile).name(13:16);
      
   end

   OPT.stations = unique(OPT.stations);
   OPT.decade   = unique(OPT.decade);
   
%% get all /decadal filesper unique station code

   names        = cell(length(OPT.stations),1);

   for ifile=1:length(OPT.files)
   
      station = OPT.files(ifile).name( 9:11);
      index   = find(strcmpi(OPT.stations,station));
      fname   = [fileparts(directory),filesep,OPT.files(ifile).name];
      
      if length(names{index})==0
         names{index} = fname;
      else
         names{index} = strvcat(names{index},fname);
      end
      
   end
   
   for istat=1:length(names)
      names{istat} = cellstr(names{istat});
   end
   
   
%% EOF   
   