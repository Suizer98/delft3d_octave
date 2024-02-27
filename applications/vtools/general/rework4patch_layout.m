%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: rework4patch_layout.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/rework4patch_layout.m $
%




%% INPUT

%[nvx,nvy] = [number of vertices in x, number of vertices in y]
x=(0:1:10)*2; %[1,nvx]
y=repmat(sort(rand(1,7))',1,numel(x)-1); %[nvy,nvx-1]
c=rand(size(y,1)-1,numel(x)-1); %[nvy-1,nvx-1]

%% RENAME

%absurd renaming due to how stupid I was (I am still)

in.XCOR=x;
in.sub=y;
in.cvar=c;

% in.nx=numel(in.XCOR)+1;
% in.nl=size(in.sub,1)-1;

[f,v,col]=rework4patch(in);

%% PLOT

figure
patch('Faces',f,'Vertices',v,'FaceVertexCData',col,'FaceColor','flat','EdgeColor','k');