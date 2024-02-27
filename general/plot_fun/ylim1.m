function a = ylim(arg1, arg2)
%YLIM1 Y limits with option to get 1st or 2nd value only.
%   YL = YLIM             gets the y limits of the current axes.
%   YL = YLIM(1)          gets lower y limit of the current axes.
%   YL = YLIM(2)          gets upper y limit of the current axes.
%   YLIM([YMIN YMAX])     sets the y limits.
%   YLMODE = YLIM('mode') gets the y limits mode.
%   YLIM(mode)            sets the y limits mode.
%                            (mode can be 'auto' or 'manual')
%   YLIM(AX,...)          uses axes AX instead of current axes.
%
%   YLIM sets or gets the YLim or YLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, ZLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $
%   G.J. de Boer, April 24th 2006: Added option to get lower/upper limit of current axes
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $

if nargin == 0
  a = get(gca,'ylim');
else
  if isscalar(arg1) && ishandle(arg1) && strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'ylim');
      return
    end
  elseif length(arg1)==1 & isnumeric(arg1)
      if any(arg1==[1 2])
         a   = get(gca,'ylim');
         a   = a(arg1);
         val = [];
      else
          error('wrong syntax: ylim1(1) or ylim1(2)')
      end
  else
    if nargin==2
      error('MATLAB:ylim1:InvalidNumberArguments', 'Wrong number of arguments')
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'ylimmode');
    else
      set(ax,'ylimmode',val);
    end
  elseif length(val==2)
    set(ax,'ylim',val);
  end
end
