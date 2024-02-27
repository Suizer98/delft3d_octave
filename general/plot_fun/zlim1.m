function a = zlim(arg1, arg2)
%ZLIM1 Z limits with option to get 1st or 2nd value only.
%   ZL = ZLIM             gets the z limits of the current axes.
%   ZL = ZLIM(1)          gets lower z limit of the current axes.
%   ZL = ZLIM(2)          gets upper z limit of the current axes.
%   ZLIM([ZMIN ZMAX])     sets the z limits.
%   ZLMODE = ZLIM('mode') gets the z limits mode.
%   ZLIM(mode)            sets the z limits mode.
%                            (mode can be 'auto' or 'manual')
%   ZLIM(AX,...)          uses axes AX instead of current axes.
%
%   ZLIM sets or gets the ZLim or ZLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, YLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $
%   G.J. de Boer, April 24th 2006: Added option to get lower/upper limit of current axes
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $

if nargin == 0
  a = get(gca,'zlim');
else
  if isscalar(arg1) && ishandle(arg1) && strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'zlim');
      return
    end
  elseif length(arg1)==1 & isnumeric(arg1)
      if any(arg1==[1 2])
         a   = get(gca,'zlim');
         a   = a(arg1);
         val = [];
      else
          error('wrong syntax: zlim1(1) or zlim1(2)')
      end
  else
    if nargin==2
      error('MATLAB:zlim1:InvalidNumberArguments', 'Wrong number of arguments')
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'zlimmode');
    else
      set(ax,'zlimmode',val);
    end
  elseif length(val==2)
    set(ax,'zlim',val);
  end
end
