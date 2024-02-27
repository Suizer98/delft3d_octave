function plotprofile(start,stop,inp,varargin)
%
% plotprofile(start,stop,inp,varargin)
%
% input arguments:
% - cols (color vector)
% - fac (multiplication vector for plotting variable with length inp)
% - lw (line weight vector)
% - ylimit (ylim vector)
% - pausel (pause length, scalar)
% - movie (true/false integer)
% - row (plot row number, default 2, integer)
% - stride (number of timesteps to stride)
% - offset

if mod(length(varargin),2)~=0
    error('Input parameter value pairs not correct length')
end

for i=1:2:length(varargin)-1
    eval([varargin{i} '=cell2mat(varargin(i+1));']);
end


% XBdims=getdimensions;
XBdims=getdimensions;
nt=XBdims.nt;
x=XBdims.x;
y=XBdims.y;
ny = XBdims.ny;

% function plotprofile(start,stop,inp,fac,cols,lw,ylimit,pausel,movie,row)

%  plotprofile(start,stop,inp,fac,cols,lw,ylimit,pausel,movie,row)

for i=1:length(inp)
    eval(['fid',num2str(i),'=fopen(''',inp{i},'.dat'',''r'');']);
    eval(['if fid',num2str(i),'<0;error(''cannot find ',inp{i},'.dat'');end']);
end

if ~exist('cols','var')
    cols=['k','r','g','b','m','k','r','g','b','m','k','r','g','b','m','k','r','g','b','m'];
end

if  ~exist('lw','var')
    lw=ones(length(inp),1);
end

if  ~exist('fac','var')
    fac=ones(length(inp),1);
end

if  ~exist('movie','var')
    movie=0;
end

if  ~exist('row','var')
    row=min(2,ny+1);
end

if  ~exist('pausel','var')
    pausel=.1;
end

if  ~exist('stride','var')
    stride=1;
end

if  ~exist('offset','var')
    offset=zeros(length(inp),1);
end

% original profile
fidzb0=fopen('zb.dat','r');
zb0=fread(fidzb0,size(x),'double');
fclose(fidzb0);

if movie
    mov = avifile('plotprofile.avi','fps',4,'quality',85);
end

f1=figure;

h0=plot(x(:,row),zb0(:,row),'color','k','linewidth',2,'linestyle','-.');

if exist('ylimit','var')
    ylim(ylimit);
end

if movie
    F=getframe(f1);
    mov = addframe(mov,F);
end

hold on;
for ii=1:length(inp)
    eval(['var',num2str(ii),'=fac(ii).*fread(fid',num2str(ii),',size(x),''double'')+offset(ii);']);
    eval(['h',num2str(ii),'=plot(x(:,row),var',num2str(ii),'(:,row),''color'',''',cols(ii),''',''linewidth'',lw(ii));']);
end
legtext{1}='zb0';
for i=1:length(inp)
    if fac(i)==1
        legtext{i+1}=inp{i};
    else
        legtext{i+1}=[inp{i} ' (x ' num2str(fac(i)) ')'];
    end
end
l=legend(legtext,'location','eastoutside');
if start>2
    progressbar(0);
end
grid on
title('Start');
pause
times = [start:stride:stop];

for i=2:stop
    for ii=1:length(inp)
        eval(['var',num2str(ii),'=fac(ii).*fread(fid',num2str(ii),',size(x),''double'')+offset(ii);']);
    end
    
    
    if any(times==i) %i>=start
        if isempty(pausel)
            show=true;
        else
            if or(pausel>0,i==stop)
                show=true;
            else
                show=false;
            end
        end
        if show
            for ii=1:length(inp)
                eval(['set(h',num2str(ii),',''YData'',var',num2str(ii),'(:,row));']);
            end
            title(num2str(i));
            if movie
                F=getframe(f1);
                mov = addframe(mov,F);
            end
            if isempty(pausel)
                pause
            else
                pause (pausel);
            end
        end
    elseif i<start
        progressbar(i/(start-1));
    end
end

if movie
    mov=close(mov);
end

fclose all