function h=EHY_geoShow(figureFile,dx)
%% h=EHY_geoShow(figureFile,dx)
%
% This functions plots a figureFile that has a corresponding worldFile
% in geographical coordinates (instead of pixels).
%
% Input example:
% figureFile   e.g.  'figure.jpg' (with corresponding file: figure.jgw)
%
% Example1: EHY_geoShow('D:\figure1.png')
% Example2: EHY_geoShow('D:\figure1.png',5)
%
% created by Julien Groenenboom, January 2019
% Largely based on script of R. Morelissen and G. de Boer
%
%% get and set paths
[pathstr, name, ext] = fileparts(figureFile);
worldFile=[pathstr filesep name ext(1:2) ext(4) 'w'];
if ~exist(worldFile)
    error(['Could not find corresponding world file: ' char(10) worldFile])
end
%%
I=imread(figureFile);
d=load(worldFile);
r=[d(3:4)';d(1:2)';d(5:6)'];

h=[];

if ~exist('dx','var')
    dx=max(max(abs(r(1:2,1:2)))); %Use pixel resolution of image
end

T=[r(2,1) r(2,2) 0; r(1,1) r(1,2) 0; r(3,:) 1];

%[x y]=[u v 1]*r
XYlim=[[1 1 size(I,1) size(I,1)]' [1 size(I,2) 1 size(I,2)]' [1 1 1 1]']*r;

aX=min(XYlim(:,1)):dx:max(XYlim(:,1));
aY=min(XYlim(:,2)):dx:max(XYlim(:,2));

[X,Y]=meshgrid(aX,aY);

XY=[X(:) Y(:) ones(numel(X),1)];

UV=XY*pinv(T);

UV = UV ./ repmat(UV(:,3), 1, 3);

U = reshape(UV(:,1), size(X,1),size(X,2));
V = reshape(UV(:,2), size(X,1),size(X,2));

for j=1:size(I,3)
    K(:,:,j) = interp2(1:size(I,2),1:size(I,1)', double(I(:,:,j)), U,V);
end

K                     = round(K);
bg                    = get(0,'defaultUicontrolBackgroundColor');
K(isnan(K)|K>255|K<0) = round(bg(1)*256);
K                     = uint8(K);

h=imagesc(aX,aY,K);
set(gca,'ydir','norm');
axis image
end
