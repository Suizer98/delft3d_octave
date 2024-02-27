% Examples demonstrating the colors.
%
% The default Matlab default line spec and colormaps are astoundingly crude. 
% This function creates distinguishable colors by spacing them out ~equally
% in *perceptive* space, not in RGB space. It is based off the research of
% professor Cynthia Brewer (colorbrewer!) but amazingly easy to use. 
% This function creates an Nx3 array of N [R B G] colors 
% These can be used to plot lots of lines with distinguishable and nice
% looking colors.  
% lineStyles = linspecer(N); makes N colors for you to use: lineStyles(ii,:) 
% colormap(linspecer); set your colormap to have easily distinguishable
% colors and a pleasing aesthetic  
%   lineStyles = linspecer(N,'qualitative'); forces the colors to all be distinguishable (up to 12) 
%   lineStyles = linspecer(N,'sequential'); forces the colors to vary along a spectrum
%
% _______________________________________________


% LINE COLORS 
N=6; 
X = linspace(0,pi*3,1000); 
Y = bsxfun(@(x,n)sin(x+2*n*pi/N), X.', 1:N); 
C = linspecer(N); 
axes('NextPlot','replacechildren', 'ColorOrder',C); 
plot(X,Y,'linewidth',5) 
ylim([-1.1 1.1]);

% SIMPLER LINE COLOR EXAMPLE 
N = 6; X = linspace(0,pi*3,1000); 
C = linspecer(N); 
hold off; 
for ii=1:N 
    Y = sin(X+2*ii*pi/N); 
    plot(X,Y,'color',C(ii,:),'linewidth',3); 
    hold on; 
end

% COLORMAP EXAMPLE 
A = rand(15); 
figure; imagesc(A); % default colormap 
figure; imagesc(A); colormap(linspecer); % linspecer colormap

% _______________________________________________
% 
% Credits and where the function came from:
% 
% The colors are largely taken from: 
% http://colorbrewer2.org and Cynthia Brewer, Mark Harrower and The Pennsylvania State University 
% She studied this from a phsychometric perspective and crafted the colors 
% beautifully.
% 
% I made choices from the many there to decide the nicest once for plotting
% lines in Matlab. I also made a small change to one of the colors I
% thought was a bit too bright. In addition some interpolation is going on
% for the sequential line styles. An Apache-Style Software License is
% included in the file. 