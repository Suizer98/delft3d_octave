function white_noise_play(varargin)

%%

parin=inputParser;

addOptional(parin,'tim',3600);

parse(parin,varargin{:});

tim=parin.Results.tim;

%%

y1=randn(1,1E+5);
player=audioplayer(y1,2000);
play(player);
pause(tim)
% stop(player);

%%

% f=1e3;
% % y1=wgn(f,1,1,1);
% y1=randn(1, 1E+5);
% for k=1:1e5
% soundsc(y1,f)
% t=1; %time depends on f
% pause(t)
% end