function [estimates,varargout] = getFUNCTIONfit(xdata,ydata,method,startvalues)
% Fits the parameters of 14 available functions on a 2d data set.
%
%   Syntax:
%       function [estimates,XYfit,ErrVal] = getFUNCTIONfit(xdata,ydata,method,startvalues)
%
%   Input: 
%       xdata
%       ydata
%       method       String with name of available fit function (or alternatively its number)
%                     'linear'              : linear fit                           y = A*x + B
%                     'linear2'             : linear fit (no constant)             y = A*x
%                     'parabolic'           : second order parabolic               y = A*x^2 + B*x + C
%                     'thirdorder'          : third order parabolic                y = A*x^3 + B*x^2 + C*x + D
%                     'expx'                : exponential x-axis                   x = A .* exp(-B * ydata);
%                     'expy'                : exponential y-axis                   y = A .* exp(-B * xdata);
%                     'power'               : power function                       y = A + B * x.^C;
%                     'power2'              : power function (no vertical offset)  y = A * x.^B;
%                     'normal'              : normal distribution (i.e. pdf)       y = 1/(sqrt(2*pi)*x*B) * exp( -(x-A)^2 / (2*B^2) );
%                     'lognormal'           : lognormal distribution (i.e. pdf)    y = 1/(sqrt(2*pi)*x*B) * exp( -(ln(x)-A)^2 / (2*B^2) );
%                     'normal2'             : normal distribution (i.e. pdf)       y = 1/(sqrt(2*pi)*x*A) * exp( -(x-sigma)^2 / (2*B^2) );       %  <- uses fixed value for A
%                     'lognormal2'          : lognormal distribution (i.e. pdf)    y = 1/(sqrt(2*pi)*x*A) * exp( -(ln(x)-sigma)^2 / (2*B^2) );   %  <- uses fixed value for A
%                     'lognormalcumulative' : lognormal distribution (i.e. pdf)    y = 0.5*erfc(-(log(x)-A)./(B*sqrt(2)));
%                     'lognormalcumulative2': lognormal distribution (i.e. pdf)    y = 0.5*erfc(-(log(x)-A)./(B*sqrt(2)));  %  <- uses fixed value for A
%       startvalues  [1xN] array with start values (number of startvalues depends on formulation)
%
%   Output:
%       estimates    Array with the fit parameters (in the order A, B, C, D)
%       XYfit        fitted XY data
%       ErrVal       Total error value
%
%   Example
%       xdata = [1:10];
%       ydata = xdata .* (2.35 + rand(1,10));
%       [estimates,XYfit] = getFUNCTIONfit(xdata,ydata,'linear');
%       figure;plot(xdata,ydata,'b.');hold on;plot(XYfit(:,1),XYfit(:,2),'r-');
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%       B.J.A. Huisman
%
%       bas.huisman@deltares.nl
%
%       Boussinesqweg 1, 2629 HV, Delft, The Netherlands
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
% Created: 03 Apr 2015
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

xmean = mean(xdata);
dydx  = max(min(sum(diff(ydata))/sum(diff(xdata)),10000),-10000);


%% SELECT METHOD PARAMETERS
% method
methoddescr = {'linear','linear2','parabolic','thirdorder','expx','expy','power','power2','normal','normal2','lognormal','lognormal2','lognormalcumulative','lognormalcumulative2'};
if isnumeric(method); method = methoddescr{method}; end
method = lower(method);
if strcmp(method,'linear');          model = @linearfit;  start_point = [dydx -xmean*dydx];     % linear fit                               y = A*x + B
elseif strcmp(method,'linear2');     model = @linearfit2; start_point = [dydx];                 % linear fit (no constant)                 y = A*x
elseif strcmp(method,'parabolic');   model = @parabolic;  start_point = [0 dydx -xmean*dydx];   % second order parabolic                   y = A*x^2 + B*x + C
elseif strcmp(method,'thirdorder');  model = @thirdorder; start_point = [0 0 dydx -xmean*dydx]; % third order parabolic                    y = A*x^3 + B*x^2 + C*x + D
elseif strcmp(method,'expx');        model = @expx;       start_point = rand(1, 2);             % exponential x-axis                       x = A .* exp(-B * ydata);
elseif strcmp(method,'expy');        model = @expy;       start_point = rand(1, 2);             % exponential y-axis                       y = A .* exp(-B * xdata);
elseif strcmp(method,'power');       model = @power;      start_point = [18, -0.3, 0];          % power function                           y = A + B * x.^C;
elseif strcmp(method,'power2');      model = @power2;     start_point = [18, -0.3];             % power function (no vertical offset)      y = A * x.^B;
elseif strcmp(method,'normal');      model = @normal;     start_point = [1, 0.3, 0.1];          % normal function                          y = 1/(sqrt(2*pi)*x*B) * exp( -(x-A)^2 / (2*B^2) );
elseif strcmp(method,'lognormal');   model = @lognormal;  start_point = [1, 0.3, 0.1];          % lognormal function (no vertical offset)  y = 1/(sqrt(2*pi)*x*B) * exp( -(ln(x)-A)^2 / (2*B^2) );
elseif strcmp(method,'normal2');     model = @normal2;    start_point = [0.1, 0.1];             % normal function                          y = 1/(sqrt(2*pi)*x*B) * exp( -(x-A)^2 / (2*B^2) );
elseif strcmp(method,'lognormal2');  model = @lognormal2; start_point = [0.1, 0.1];             % lognormal function (no vertical offset)  y = 1/(sqrt(2*pi)*x*B) * exp( -(ln(x)-A)^2 / (2*B^2) );
elseif strcmp(method,'lognormalcumulative');  model = @lognormalcumulative; start_point = [0.1, 0.1]; % cumulative of lognormal function                 y = 0.5*erfc(-(log(x)-A)./(B*sqrt(2)));
elseif strcmp(method,'lognormalcumulative2'); model = @lognormalcumulative2; start_point = [0.1];     % cumulative of lognormal function (mu specified)  y = 0.5*erfc(-(log(x)-A)./(B*sqrt(2))); %<- with A being a fixed startvalue that is specified
end

if nargin>3
    start_point = startvalues;
end
if strcmp(method,'normal2') || strcmp(method,'lognormal2') || strcmp(method,'lognormalcumulative2')
    start_point = start_point(2:end);
end
%        f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
%        c = 1.5;                        % The parameter.
%        X = fminsearch(@(x) f(x,c),[0.3;1])

%% OPTIMISE THE FIT PARAMETERS
% Call fminsearch with a random starting point.
options.MaxFunEvals=25000;
% options.TolX = 1e-18;
% options.TolFun = 1e-12;
estimates = fminsearch(model,start_point,options);
%[x,resnorm] = lsqcurvefit(model,start_point,xdata,ydata) 
if strcmp(method,'linear');                                                          %method==1
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* xdata2 + estimates(2);
elseif strcmp(method,'linear2');                                                     %method==2
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* xdata2;
elseif strcmp(method,'parabolic');                                                   %method==3
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* xdata2.^2 + estimates(2) .* xdata2 + estimates(3);
elseif strcmp(method,'thirdorder');                                                  %method==4
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* xdata2.^3 + estimates(2) .* xdata2.^2 + estimates(3) .* xdata2 + estimates(4);
elseif strcmp(method,'expx');                                                        %method==5
    ydata2 = sort(ydata);
    xdata2 = estimates(1) .* exp(-estimates(2) * ydata2);
elseif strcmp(method,'expy');                                                        %method==6
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* exp(-estimates(2) * xdata2);
elseif strcmp(method,'power');                                                       %method==7
    xdata2 = sort(xdata);
    ydata2 = estimates(1) + estimates(2) .* xdata2.^estimates(3);
elseif strcmp(method,'power2');                                                      %method==8
    xdata2 = sort(xdata);
    ydata2 = estimates(1) .* xdata2.^estimates(2);
elseif strcmp(method,'normal');                                                      %method==9
    xdata2 = sort(xdata);
    ydata2 = estimates(3)./((2*pi).^0.5 .* xdata2 .*estimates(2)) .* exp( -((xdata2-estimates(1)).^2 ./ (2*estimates(2).^2)) );
elseif strcmp(method,'lognormal');                                                   %method==10
    xdata2 = sort(xdata);
    ydata2 = estimates(3)./((2*pi).^0.5 .* xdata2 .*estimates(2)) .* exp( -((log(xdata2)-estimates(1)).^2 ./ (2*estimates(2).^2)) );
elseif strcmp(method,'normal2');                                                      %method==9
    xdata2 = sort(xdata);
    ydata2 = estimates(2)./((2*pi).^0.5 .* xdata2 .*estimates(1)) .* exp( -((xdata2-startvalues(1)).^2 ./ (2*estimates(1).^2)) );
elseif strcmp(method,'lognormal2');                                                   %method==10
    xdata2 = sort(xdata);
    ydata2 = estimates(2)./((2*pi).^0.5 .* xdata2 .*estimates(1)) .* exp( -((log(xdata2)-startvalues(1)).^2 ./ (2*estimates(1).^2)) );
elseif strcmp(method,'lognormalcumulative');                                                   %method==10
    xdata2 = sort(xdata);
    ydata2 = 0.5*erfc(-(log(xdata2)-estimates(1))/(estimates(2)*sqrt(2)));
elseif strcmp(method,'lognormalcumulative2');                                                   %method==10
    xdata2 = sort(xdata);
    ydata2 = 0.5*erfc(-(log(xdata2)-startvalues(1))/(estimates(2)*sqrt(2)));
end

ErrVal = ydata2 - ydata;

%% PLOT THE FITTED FUNCTION
%plot(xdata,ydata,'b*');hold on;
%plot(xdata2,ydata2,'r');
%semilogx(xdata,ydata,'b*');hold on;
%semilogx(xdata2,ydata2,'r');
%semilogy(xdata,ydata,'b*');hold on;
%semilogy(xdata2,ydata2,'r');
%loglog(xdata,ydata,'b*');hold on;
%loglog(xdata2,ydata2,'r');
if nargout>1
    varargout{1}=[xdata2(:),ydata2(:)];
    varargout{2}=ErrVal;
    varargout{3}=find(ErrVal>=-(2*std(ErrVal)));
end


% -----------------------------------------------------------------------------
%% FITTED FUCNTIONS
% -----------------------------------------------------------------------------
% linear, parabolic, third order, exponential and power fitting functions
% are provided here. The functions accept starting parameters of which
% one to four are used (depending on function). It outputs the fit result and 
% the sum of the squared error. FMINSEARCH only needs sse, but the fittedCurve
% is useful for plotting.
    function [sse, FittedCurve] = linearfit(params)
        A = params(1);
        B = params(2);
        FittedCurve = A.*xdata+B;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = linearfit2(params)
        A = params(1);
        FittedCurve = A.*xdata;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = parabolic(params)
        A = params(1);
        B = params(2);
        C = params(3);
        FittedCurve = A.*xdata.^2+B.*xdata+C;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = thirdorder(params)
        A = params(1);
        B = params(2);
        C = params(3);
        D = params(4);
        FittedCurve = A.*xdata.^3+B.*xdata.^2+C.*xdata+D;
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = expx(params)
        A = params(1);
        lambda = params(2);
        FittedCurve = A .* exp(-lambda * ydata);
        ErrorVector = FittedCurve - xdata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = expy(params)
        A = params(1);
        lambda = params(2);
        FittedCurve = A .* exp(-lambda * xdata);
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = power(params)
        A = params(1);
        B = params(2);
        C = params(3);
        FittedCurve = A + B*xdata.^C; 
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = power2(params)
        A = params(1);
        B = params(2);
        FittedCurve = A*xdata.^B; 
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = normal(params)
        A = params(1);
        B = params(2);
        C = params(3);
        if B<0; fprintf('Warning B<0 (set it at 0)\n');B=0;end
        if C<0; fprintf('Warning C<0 (set it at 0)\n');C=0;end
        FittedCurve = C./(sqrt(2*pi) .* xdata .*B) .* exp( -((xdata-A).^2 ./ (2*B.^2)) );
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = lognormal(params)
        A = params(1);
        B = params(2);
        C = params(3);
        if B<0; fprintf('Warning B<0 (set it at 0)\n');B=0;end
        if C<0; fprintf('Warning C<0 (set it at 0)\n');C=0;end
        
        FittedCurve = C./(sqrt(2*pi) .* xdata .*B) .* exp( -((log(xdata)-A).^2 ./ (2*B.^2)) );
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
        %fprintf(' A=%12.9f, B=%12.9f, sse=%12.9f\n',A,B,sse);
    end
    function [sse, FittedCurve] = normal2(params)
        %A = params(1);
        B = params(1);
        C = params(2);
        if B<0; fprintf('Warning B<0 (set it at 0)\n');B=0;end
        if C<0; fprintf('Warning C<0 (set it at 0)\n');C=0;end
        A=startvalues(1);
        FittedCurve = C./(sqrt(2*pi) .* xdata .*B) .* exp( -((xdata-A).^2 ./ (2*B.^2)) );
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = lognormal2(params)
        %A = params(1);
        B = params(1);
        C = params(2);
        if B<0; fprintf('Warning B<0 (set it at 0)\n');B=0;end
        if C<0; fprintf('Warning C<0 (set it at 0)\n');C=0;end
        A=startvalues(1);
        FittedCurve = C./(sqrt(2*pi) .* xdata .*B) .* exp( -((log(xdata)-A).^2 ./ (2*B.^2)) );
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = lognormalcumulative(params)
        A = params(1);
        B = params(2);
        if (min(xdata)-A)<0; fprintf('Warning A is too small (set it at min(xdata) +epsilon)\n');A=min(xdata)+1e-5;end
        % if B<0; fprintf('Warning B<0 (set it at 0)\n');B=1e-5;end
        % Fx_lognormal = 0.5*erfc(-(ln(szi)-mu)/(sigma*sqrt(2)));
        FittedCurve = 0.5*erfc(-(log(xdata)-A)./(B*sqrt(2)));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
    function [sse, FittedCurve] = lognormalcumulative2(params)
        %A = params(1);
        B = params(1);
        if B<0; fprintf('Warning B<0 (set it at 0)\n');B=1e-5;end
        A=startvalues(1);
        % Fx_lognormal = 0.5*erfc(-(ln(szi)-mu)/(sigma*sqrt(2)));
        FittedCurve = 0.5*erfc(-(log(xdata)-A)./(B*sqrt(2)));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end
