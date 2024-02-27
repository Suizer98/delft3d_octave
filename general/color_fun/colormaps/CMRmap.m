function CMRmap=CMRmap
%CMRMAP  9 Level Color Scale Colormap with Mapping to Grayscale for Publications.
%
% CMRMAP comes from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/2662">Mathworks download central</a>, for copyright: edit cmrmap
%
%See also: COLORMAPEDITOR, COLORMAP, COLORMAPGRAY, COLORGRAYMAP

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (c) 2002, Carey Rappaport
%   All rights reserved.
%   
%   Redistribution and use in source and binary forms, with or without 
%   modification, are permitted provided that the following conditions are 
%   met:
%   
%       * Redistributions of source code must retain the above copyright 
%         notice, this list of conditions and the following disclaimer.
%       * Redistributions in binary form must reproduce the above copyright 
%         notice, this list of conditions and the following disclaimer in 
%         the documentation and/or other materials provided with the distribution
%         
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%   POSSIBILITY OF SUCH DAMAGE.
%   --------------------------------------------------------------------- 

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id: CMRmap.m 685 2009-07-15 08:12:55Z boer_g $
% $Date: 2009-07-15 16:12:55 +0800 (Wed, 15 Jul 2009) $
% $Author: boer_g $
% $Revision: 685 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colormaps/CMRmap.m $
% $Keywords: $

%% CMRmap
%       r     g     b
CMRmap=[0.    0.    0.  ;...
         .15   .15   .5 ;...
         .3    .15   .75;...
         .6    .2    .50;...
        1.     .25   .15;...
         .9    .5   0.  ;...
         .9    .75   .1 ;...
         .9    .9    .5 ;...
        1.    1.    1.];
        
 colormap(CMRmap)
%colorbar

%% EOF