function DATA=gload
%GLOAD    gui to load a *.mat file
%
%See also: GLOAD, LOAD, GIMREAD

% $Id: gload.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/gload.m $
% $Keywords$

   [filename, pathname ] = uigetfile;

   DATA=load([pathname,filename]);
   
%% EOF   