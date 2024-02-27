%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18087 $
%$Date: 2022-06-01 16:12:53 +0800 (Wed, 01 Jun 2022) $
%$Author: chavarri $
%$Id: decimal_sexagesimal.m 18087 2022-06-01 08:12:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/decimal_sexagesimal.m $
%

function varargout=decimal_sexagesimal(varargin)

if nargin==1 %from decimal to sexagesimal
    do_decsexa=1;
else
    do_decsexa=2;
end

if do_decsexa==1
    deg_f=varargin{1,1};
    deg=floor(deg_f);
    min_f=(deg_f-deg)*60;
    min=floor(min_f);
    sec=(min_f-min)*60;
    varargout{1,1}=deg;
    varargout{1,2}=min;
    varargout{1,3}=sec;
elseif do_decsexa==2
    varargout{1,1}=varargin{1,1}+varargin{1,2}./60+varargin{1,3}/3600;
else
    error('?')
end

end %function