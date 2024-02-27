%
%  A demonstration file for gridLegend
%
% Adrian Cherry
% 2/11/2010
% Copyright (c) 2010, Adrian Cherry
% Copyright (c) 2010, Simon Henin
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Mar 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: gridDemo.m 8377 2013-03-27 10:16:53Z bartgrasmeijer.x $
% $Date: 2013-03-27 18:16:53 +0800 (Wed, 27 Mar 2013) $
% $Author: bartgrasmeijer.x $
% $Revision: 8377 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/gridDemo.m $
% $Keywords: $

% Lets generate lots of data and plot it
y=[0:0.1:3.0]'*sin(-pi:0.1:pi);
hdlY=plot(y');

% now the standard legend function will probably flow off the figure
% although if you maximise it then you might see all of the legend,
% however the print preview is probably truncated.
legend(hdlY);
pause

% plot again this time using gridLegend to print the legend in 4 columns
hdlY=plot(y');
gridLegend(hdlY,4);
pause

% As standard the legend flows down filling the first column before
% moing onto the next. We can change this by using the Orientation
% horizontal option to fill across the rows before moving down a row.
gridLegend(hdlY,4,'Orientation','Horizontal');
pause 

% to use some options the standard legend function needs a key
for i=1:31,
    key{i}=sprintf('trace %d',i);
end

% here we place legend on the lefthand side and reduce the fontsize
hdlY=plot(y');
gridLegend(hdlY,2,key,'location','westoutside','Fontsize',8,'Box','off','XColor',[1 1 1],'YColor',[1 1 1]);
