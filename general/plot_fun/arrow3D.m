function varargout = arrow3D(varargin)
% ARROW3D create arrow/vector patch object
% without using goniometric fcns, e.g. sin, cos

S.res	= 8;	% number of faces per cone/cylinder
S.hCone	= .7;
S.rCone	= .03;
S.rCyl	= .01;

if nargout
  if nargin
    varargout{1}	= arrow3Dvertices(varargin{:});
  else
    varargout{1}	= arrow3Dpatch;
  end

else
  if nargin
    arrow3Dupdate(varargin{:});
  else
    arrow3Ddemo
  end
end



% _________________________________________________________________________
%% #patch: invoked once per arrow
%
  function arrowPrp = arrow3Dpatch

    arrowPrp			= [];
    arrowPrp.EdgeColor		= 'none';
    arrowPrp.FaceLighting	= 'none';
    arrowPrp.Faces		= [
      ones(1,S.res)		S.res + 2 : 2*S.res + 1
      2 : S.res + 1		(1 : S.res) + 2*S.res + 1
      mod(1 : S.res,S.res) + 2	mod(1:S.res,S.res) + 2*S.res + 2
      ones(1,S.res)		mod(1:S.res,S.res) +   S.res + 2]';
    arrowPrp.Vertices		= nan(max(arrowPrp.Faces(:)), 3);


    % =====================================================================
    % create unit arrows
    range	= linspace(0, 2*pi, S.res + 1)';
    range(end)	= [];	% remove last
    vertices	= [
      0				0			1
      S.rCone*cos(range)	S.rCone*sin(range)	S.hCone*ones(S.res,1)
      S.rCyl*cos(range)		S.rCyl*sin(range)	S.hCone*ones(S.res,1)
      S.rCyl*cos(range)		S.rCyl*sin(range)	zeros(S.res,1)];

    if 0
      % heavy distortion in all planes
      unitArrow.x	= vertices(:,[3 2 1]);
      unitArrow.y	= vertices(:,[1 3 2]);
      unitArrow.z	= vertices;

    elseif 0
      % heavy distortion in all planes
      R			= [
	0	0	1
	1	0	0
	0	1	0];
      unitArrow.x	= vertices * R';
      unitArrow.y	= vertices * R;
      unitArrow.z	= vertices;

    elseif 0
      % only distortion in xy-plane
      Rx		= [
	0	0	-1
	0	1	0
	1	0	0];
      Ry		= [
	1	0	0
	0	0	-1
	0	1	0];
      unitArrow.x	= vertices * Rx;
      unitArrow.y	= vertices * Ry;
      unitArrow.z	= vertices;

    else
      % least distortion
      % Rx		= [
      %   0	0	-1
      %   0	1	0
      %   1	0	0];
      % Rx30		= [
      %   1	0		0
      %   0	sqrt(3)/2	-1/2
      %   0	1/2		sqrt(3)/2];
      Rx		= [
	0	-1/2		-sqrt(3)/2
	0	sqrt(3)/2	-1/2
	1	0		0];		% Rx * Rx30
      % Ry		= [
      %   1	0	0
      %   0	0	-1
      %   0	1	0];
      % Ry30		= [
      %   sqrt(3)/2	0	-1/2
      %   0		1	0
      %   1/2		0	sqrt(3)/2];
      Ry		= [
	sqrt(3)/2	0	-1/2
	-1/2		0	-sqrt(3)/2
	0		1	0];		% Ry * Ry30
      unitArrow.x	= vertices * Rx;
      unitArrow.y	= vertices * Ry;
      unitArrow.z	= vertices;
    end

    % ..............................
    arrowPrp.UserData	= unitArrow;
    % ..............................

  end  % arrow3Dpatch



% _________________________________________________________________________
%% #update: to be invoked in a loop
%
  function arrow3Dupdate(hObject, vector, org)

    UA		= get(hObject, 'UserData');

    vAbs	= abs(vector);
    mSign	= meshgrid(2*(vector>=0) - 1, UA.x(:,1));

    if nargin<3
      mOrg	= 0*UA.x;
    else
      mOrg	= meshgrid(org, UA.x(:,1));
    end

    % .....................................................................
    vertices	= (vAbs(1)*UA.x + vAbs(2)*UA.y + vAbs(3)*UA.z).*mSign + mOrg;
    % .....................................................................

    set(hObject, 'Vertices', vertices)

  end  % arrow3Dupdate



% _________________________________________________________________________
%% #vertices
%
  function patchPrp = arrow3Dvertices(patchPrp, vector, org)

    UA		= patchPrp.UserData;

    vAbs	= abs(vector);
    mSign	= meshgrid(2*(vector>=0) - 1, UA.x(:,1));

    if nargin<3
      mOrg	= 0*UA.x;
    else
      mOrg	= meshgrid(org, UA.x(:,1));
    end

    % .....................................................................
    patchPrp.Vertices	= (vAbs(1)*UA.x + vAbs(2)*UA.y + vAbs(3)*UA.z) .* mSign + mOrg;
    % .....................................................................

  end  % arrow3Dvertices



% _________________________________________________________________________
%% #qqq
%
  function arrow3Dqqq

  end  % arrow3Dqqq


end  % arrow3D



% _________________________________________________________________________
%% #demo
%
function arrow3Ddemo
% 
% 1. Create patch properties: arrowPrp = ARROW3D
% 2. Create patch object:     hArrow = patch(arrowPrp)
% 3. Update vector vertices:  ARROW3D(hArrow, vector, [origin])

figPrp					= [];
figPrp.Name				= mfilename;
figPrp.NumberTitle			= 'off';
delete(findall(0, 'Name', figPrp.Name))
fig	= figure(figPrp);
ax	= axes('DataAspectRatio', [1 1 1], 'Parent', fig);
light('Parent', ax, 'Position', [0 0 1])

% ................................
arrowPrp		= arrow3D;	% 1. return patch properties
% ................................
arrowPrp.FaceColor	= 'g';
arrowPrp.FaceLighting	= 'flat';
arrowPrp.Parent		= ax;

% test vectors
range	= 0:30:180;
v	= [
  cosd(range)'			sind(range)'		0*range'
  sqrt(2)/2*cosd(range)'	-sqrt(2)/2*cosd(range)'	sind(range)'
  ];

for vv = 1:size(v,1)
  if 1
    % method i. update vector vertices (& optionally position)

    hArrow	= patch(arrowPrp);
    % ...............................
    arrow3D(hArrow, v(vv,:), [1 2 3])
    % ...............................

  else
    % method ii. pre-define vertices (& optionally position)

    % ...............................................
    arrowPrp	= arrow3D(arrowPrp, v(vv,:), [1 2 3]);
    % ...............................................
    patch(arrowPrp)
  end
end  % for vv

xlabel X, ylabel Y, zlabel Z
rotate3d(fig, 'on')

end  % arrow3Ddemo
