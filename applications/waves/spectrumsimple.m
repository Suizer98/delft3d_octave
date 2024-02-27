function [fx vy] = spectrumsimple(x,y,varargin)
% Generates simple spectrum of y(x) with hann filter and welch method
%
% [fx vy] = spectrumsimple(x,y,varargin) 
%
% Input:
% x = time/distance vector, or scalar measurement interval
% y = vector of measurements
% varargin:
% fresolution = required frequency resolution (0.01)
% detrend     = logical detrend input signal before FFT (1)
% overlap     = maximum overlap in Welch method (0.5)
% figures     = logical output to figure (1)
% strict      = limit FFT size to power of 2 (0)
% filter      = filter type: 'Hann','Hamming' or 'none' ('Hann')
% tolerance   = check for relative error between input and output wave height (1E-3)
%
% Output:
% fx = frequency / wavenumber vector
% vy = variance density of y
%

OPT.fresolution = 0.01;
OPT.detrend     = 1;
OPT.overlap     = 0.5;
OPT.figures     = 1;
OPT.strict      = 0;
OPT.filter      = 'Hamming';
OPT.tolerance   = 1E-3;
OPT.correctvar  = true;

OPT = setproperty(OPT, varargin{:});


% input checks
if min(size(y))>1
    error('Input y must be a vector');
else
    if min(size(x))>1
        error('Input x must be a vector');
    elseif length(x)>1 && length(x)~=length(y)
        error('Input x and input y must have the same length')
    elseif length(x)>1 && length(x)==length(y)
        % set to zero base time
        xi = x-x(1);
    elseif length(x)==1
        xi = [0:x:(length(y)-1)*x];
        xi = reshape(xi,size(y));        
    end
end
% test time/space axis monotonically increasing
if min(diff(xi))<0 || max(diff(xi))-min(diff(xi))>1E-8 % this is needed for tolerance in rounding numbers
    error('Input x must be monotonic increasing');
end

% Convert to column vectors
Y=y(:);
X=xi(:);

% Time step in time/space axis
dt = X(2)-X(1);

% Number of data points in the total signal
N=length(X);

% Number of data points required for OPT.fresolution
Nr = ceil((1/OPT.fresolution)/dt);
if OPT.strict
    Nr = 2^nextpow2(Nr);
end

% Check if there are sufficient data points to acquire the set frequency
% resolution
if Nr>N
    % reset Nr
    Nr = N;
    warning('The required frequency resolution could not be achieved.');
end

% Number of Welch repetitions
Nw = ceil((N-Nr)/(OPT.overlap*Nr))+1;

% Index input arrays for start and end of each Welch repetition
indend = round(linspace(Nr,N,Nw));
indstart = indend-Nr+1;

% Time and frequency array 
T=X(indend(1));
df = 1/T;
ff = df*[0:1:round(Nr/2) -1*floor(Nr/2)+1:1:-1];
fx = ff(1:floor(Nr/2));

% Storage arrays
vy=zeros(floor(Nr/2),1);

% Detrend input signal
if OPT.detrend
    Y = detrend(Y);
end

varpre = var(Y);
% do Welch repetition
for i = 1:Nw
    d = Y(indstart(i):indend(i));
    switch OPT.filter
        case 'Hann'
            % Hann filter
            d = d.* (0.5*(1-cos(2*pi*(0:Nr-1)/(Nr-1))))';
            varpost = var(d);
        case 'Hamming'
            d = d.* (0.54-0.46*cos(2*pi*(0:Nr-1)/(Nr-1)))';
            varpost = var(d);
        case 'none'
             varpost = varpre;
    end
    % FFT
    Q = fft(d,[],1);
    % Power density
    V = 2*T/Nr^2*abs(Q).^2;
    % Store in array
    vy = vy + 1/Nw*squeeze(V(1:floor(Nr/2)));
end

% Restore the total variance
if OPT.correctvar
   vy = (varpre/trapz(fx,vy))*vy;
end

% input/output check
hrmsin = 4*std(Y)/sqrt(2);
hrmsout =  sqrt(8*trapz(fx,vy));
dif = abs(hrmsout-hrmsin);
if dif > OPT.tolerance
    warning(['Difference in input and output wave height (' num2str(dif) ') is greater than set tolerance (' num2str(OPT.tolerance) ')']);
end

% plot figure
if OPT.figures
    figure;
    plot(fx,vy);
    title('Variance density')
    xlabel('frequency (Hz) / wave number (-)');
    ylabel('variance');
end

% % reshape output variables to match input
% if length(x)>1
%     fx = reshape(fx,size(x));
% else
%     fx = reshape(fx,size(y));
% end
%     




        






