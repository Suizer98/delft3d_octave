function IMAGE=gimread
%GIMREAD    calls UIGETFILE and passes result to IMREAD
%
%See also: GIMREAD, IMREAD

% $Id: gimread.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/gimread.m $
% $Keywords$

[filename, pathname ] = uigetfile(...
       {'*.jpg;*.tiff;*.gif;*.bmp;*.png;*.hdf;*.pcx;*.xwd;*.ico;*.cur;*.ras;*.pbm;*.pgm;*.ppm;',...
           'suported image types';,...
        '*.*',...
           'All Files (*.*)'}, ...
        'Pick a file');
    
IMAGE = imread([pathname,filename]);    

%% EOF