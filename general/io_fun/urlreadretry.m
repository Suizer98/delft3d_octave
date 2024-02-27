function s = urlreadretry(N,varargin)
%URLREADRETRY Run URLREADFIX several times until success.
% URLREADFIX can fail due to network connection errors. The function will
% retry the same command several times before quitting.
% Run
%   s = urlreadretry(N,varargin)
% where
%   N - maximum number of retries
%   varargin - input to URLREADFIX
%
% See also: URLREADFIX

% $Id: urlreadretry.m 15380 2019-05-01 16:12:22Z omouraenko.x $

% Oleg Mouraenko, 01/28/2016

try
    s = urlreadfix(varargin{:});
catch
    i = 2;
    p = true;
    while i<=N && p
        fprintf('\n     ... retrying (%i out of %i)',i,N);
        pause(5)
        try
            s = urlreadfix(varargin{:});
            p = false;
        catch
        end
        i = i+1;
    end
end
