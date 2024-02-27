function a = xlim(arg1, arg2)
%XLIM1 X limits with option to get 1st or 2nd value only.
%   XL = XLIM             gets the x limits of the current axes.
%   XL = XLIM(1)          gets lower x limit of the current axes.
%   XL = XLIM(2)          gets upper x limit of the current axes.
%   XLIM([XMIN XMAX])     sets the x limits.
%   XLMODE = XLIM('mode') gets the x limits mode.
%   XLIM(mode)            sets the x limits mode.
%                            (mode can be 'auto' or 'manual')
%   XLIM(AX,...)          uses axes AX instead of current axes.
%
%   XLIM sets or gets the XLim or XLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, YLIM, ZLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $
%   G.J. de Boer, April 24th 2006: Added option to get lower/upper limit of current axes
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $

if nargin == 0
  a = get(gca,'xlim');
else
  if isscalar(arg1) && ishandle(arg1) && strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'xlim');
      return
    end
  elseif length(arg1)==1 & isnumeric(arg1)
      if any(arg1==[1 2])
         a   = get(gca,'xlim');
         a   = a(arg1);
         val = [];
      else
          error('wrong syntax: xlim1(1) or xlim1(2)')
      end
  else
    if nargin==2
      error('MATLAB:xlim1:InvalidNumberArguments', 'Wrong number of arguments')
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'xlimmode');
    else
      set(ax,'xlimmode',val);
    end
  elseif length(val==2)
    set(ax,'xlim',val);
  end
end
