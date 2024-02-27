%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fit_function.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/fit_function.m $
%


function [B,fval,y_fit,fcn]=fit_function(fun,x,y,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x0',[]);

parse(parin,varargin{:});

x0=parin.Results.x0;

%%
error('see <stat_fit_gumbel> and similar')

switch fun
    case 'lin'
%         error('not sure what happens here but does not work fine')
        fcn = @(b,x) b(1).*x+b(2);
        if isempty(x0)
            x0=ones(1,2);
        end
    case 'exp'
        fcn = @(b,x) b(1).*exp(b(2).*x);
        if isempty(x0)
            x0=ones(1,2);
        end
    otherwise
        error('add')
end

opt=optimset('MaxFunEvals',15000,'MaxIter',10000);
% fcn_min=@(b) norm(y - fcn(b,x));
fcn_min=@(b) sqrt(sum((y - fcn(b,x)).^2)/numel(y));
[B,fval] = fminsearch(fcn_min,x0,opt);

y_fit=fcn(B,x);

%%
% figure
% hold on
% plot(x,y,'-*')
% plot(x,y_fit,'-*')
