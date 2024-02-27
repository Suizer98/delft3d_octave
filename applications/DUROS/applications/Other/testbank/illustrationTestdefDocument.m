MakeFigure = false;
MakeFigure = true;

%% addXvaluesExactCrossings
fh = figure(1);
a.x = [0 2];
a.y = ones(size(a.x));

[b(1).x b(2).x] = deal(a.x);
b(1).y = [0 2];
b(2).y = [2 2];
b(3).x = [2 4];
b(3).y = b(1).y;

for i = 1:3
    subplot(2,2,i)
    plot(a.x, a.y, '-o', b(i).x, b(i).y, '-.o')
    set(gca, 'XLim', [0 4], 'YLim', [0 3]);
    title(['test ' num2str(i)])
end

if MakeFigure
    printFigure(fh, [mfilename('fullpath') '_addXvaluesExactCrossings'], 'overwrite', '-dmeta')
end

%% getCumVolume
fh = figure(2);
for i = 1
    patch([a.x fliplr(a.x)], [a.y fliplr(b(i).y)], ones(1,3)*.75)
    hold on
    plot(a.x, a.y, '-o', b(i).x, b(i).y, '-.o')
    set(gca, 'XLim', [-1 3], 'YLim', [-1 3]);
    title(['test ' num2str(i)])
end

if MakeFigure
    printFigure(fh, [mfilename('fullpath') '_getCumVolume'], 'overwrite', '-dmeta')
end

%% getVolumeCorrection
fh = figure(3);
dx = pi/10;
a.x = 0:dx:2*pi;
a.y = sin(a.x);
b(1).x = a.x;
b(1).y = b(1).x/-pi/4;
[xcr, zcr, a.x, a.y, b(1).x, b(1).y] = findCrossings(a.x, a.y, b(1).x, b(1).y);
id{1} = a.x <= xcr(2);
id{2} = a.x <= xcr(3);
id{3} = a.x >= xcr(2) & a.x <= xcr(3);

for i = 1:3
    subplot(2,2,i)
    plot(a.x(id{i}), a.y(id{i}), '-', b(1).x(id{i}), b(1).y(id{i}), '-.')
    set(gca, 'XLim', [0 2*pi], 'YLim', [-1.5 1.5]);
    title(['test ' num2str(i)])
end

if MakeFigure
    printFigure(fh, [mfilename('fullpath') '_getVolumeCorrection'], 'overwrite', '-dmeta')
end

%% getSteepPoints
fh = figure(4);
a.x = [-1 0 12.5 13.5];
a.y = [1 1 0 0];

for i = 1:3
    subplot(2,2,i)
    plot(a.x, a.y*i/2, '-o')
    set(gca, 'XLim', [min(a.x) max(a.x)], 'YLim', [-.5 2]);
    title(['test ' num2str(i)])
end

if MakeFigure
    printFigure(fh, [mfilename('fullpath') '_getSteepPoints'], 'overwrite', '-dmeta')
end

%% getVolume
fh = figure(5);
subplot(1,2,1)
patch([0 1 1 0], [0 0 1 1], ones(1,3)*.75)
set(gca, 'XLim', [-.5 1.5], 'YLim', [-.5 1.5]);
title('test 1')
box on

a.x = 0:dx:2*pi;
a.y = sin(a.x);
b(1).x = a.x;
b(1).y = -sin(a.x);
subplot(1,2,2)
plot(a.x, a.y, '-o', b(1).x, b(1).y, '-.o')
set(gca, 'XLim', [0 2*pi], 'YLim', [-1.5 1.5]);
title('test 2')

if MakeFigure
    printFigure(fh, [mfilename('fullpath') '_getVolume'], 'overwrite', '-dmeta')
end
