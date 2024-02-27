function d0=pathdistance(x0,y0,z0),
% PATHDISTANCE computes the distance along a path
%       Computes the distance along the path from the first
%       point for every point on the path.
%
%       Distance=PATHDISTANCE(XCoord,YCoord,ZCoord)
%       Distance=PATHDISTANCE(XCoord,YCoord)
%       Distance=PATHDISTANCE(Coord)
%
%       NaNs are skipped in the computation of the path length.

% (c) Copyright 1997-2000, H.R.A.Jagers, Delft Hydraulics, The Netherlands

d0=repmat(NaN,size(x0));

if nargin==1,
  iprev=min(find(~isnan(x0)));
  d0(iprev)=0;
  for i=(iprev+1):length(x0),
    if isnan(x0(i)),
      d0(i)=NaN;
    else,
      d0(i)=d0(iprev)+abs(x0(i)-x0(iprev));
      iprev=i;
    end;
  end;
elseif nargin==2,
  iprev=min(find(~isnan(x0) & ~isnan(y0)));
  d0(iprev)=0;
  for i=(iprev+1):length(x0),
    if isnan(x0(i)) | isnan(y0(i)),
      d0(i)=NaN;
    else,
      d0(i)=d0(iprev)+sqrt((x0(i)-x0(iprev))^2+(y0(i)-y0(iprev))^2);
      iprev=i;
    end;
  end;
elseif nargin==3,
  iprev=min(find(~isnan(x0) & ~isnan(y0)) & ~isnan(z0));
  d0(iprev)=0;
  for i=(iprev+1):length(x0),
    if isnan(x0(i)) | isnan(y0(i)) | isnan(z0(i)),
      d0(i)=NaN;
    else,
      d0(i)=d0(iprev)+sqrt((x0(i)-x0(iprev))^2+(y0(i)-y0(iprev))^2+(z0(i)-z0(iprev))^2);
      iprev=i;
    end;
  end;
end;
