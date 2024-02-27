function OK = poly_unique_test(varargin)
%poly_unique_test test for poly_unique
%
% 8-shape (toppled over lemniscaat) with doubles occurence of top point and x-crossing
%
% See also: poly_unique

OPT.plot = 0;

OPT = setproperty(OPT,varargin)

p.x = [0 -1 0 +1  0  0 nan  0 -1 0 +1 0 nan nan nan];
p.y = [2 +1 0 -1 -2 -2 nan -2 -1 0 +1 2 nan nan nan];
p.z = [1  1 1  1  1  2 nan  2 1 2  1 2   1   1   1]; % optionally lift doubles to have different z


[q1.xu,q1.yu      ,q1.ind]=poly_unique(p.x,p.y    ,'eps',Inf);% should return only one point
[q2.xu,q2.yu      ,q2.ind]=poly_unique(p.x,p.y    ,'eps',eps);
[q3.xu,q3.yu,q3.zu,q3.ind]=poly_unique(p.x,p.y,p.z,'eps',eps);

if OPT.plot
    FIG = figure;
    plot(p.x,p.y,'.-')
    for i=1:length(p.x)
        text(p.x(i),p.y(i),[num2str(i),repmat('  ',[1,i-1])],'color','k','verticalalignment','top','horizontalalignment','right')
    end
    hold on
    axis([-1.5 1.5 -2.5 2.5])
    plot(q2.xu,q2.yu,'go')
    for i=1:length(q2.ind)
        text(p.x(i),p.y(i),[repmat('  ',[1,i-1]),num2str(q2.ind(i))],'color','g','verticalalignment','top')
    end
    plot(q3.xu,q3.yu,'rs')
    for i=1:length(q3.ind)
        text(p.x(i),p.y(i),[repmat('  ',[1,i-1]),num2str(q3.ind(i))],'color','r','verticalalignment','bottom')
    end
    title('\color[rgb]{0 0 0}{input poly}    \color[rgb]{0 1 0}_{unique points for 2D with 2 overlapping points}  \color[rgb]{1 0 0}^{unique points for 3D with 0 overlapping points}')
    pausedisp
    try
        close(FIG)
    end
end


OK(1) = length(q1.xu)==1 & length(q1.yu)==1;

OK(2) = isequalwithequalnans(q2.xu ,[-1 -1  0 0   0   +1 +1 nan]) & ...
        isequalwithequalnans(q2.yu ,[-1 +1 -2 0   2   -1 +1 nan]) & ...
        isequalwithequalnans(q2.ind,[5 2 4 6 3 3 8 3 1 4 7 5 8 8 8]');
    
OK(3) = isequalwithequalnans(q3.xu ,[-1 -1  0  0 0 0 0 0 +1 +1 nan]) & ...
        isequalwithequalnans(q3.yu ,[-1 +1 -2 -2 0 0 2 2 -1 +1 nan]) & ...
        isequalwithequalnans(q3.zu ,[ 1  1  1  2 1 2 1 2  1  1 nan]) & ...
        isequalwithequalnans(q3.ind,[7 2 5 9 3 4 11 4 1 6 10 8 11 11 11]');

