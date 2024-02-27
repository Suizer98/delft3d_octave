function a = clim(arg1, arg2)
%CLIM1 C limits with option to get 1st or 2nd value only.
%   CL = CLIM             gets the c limits of the current axes.
%   CL = CLIM(1)          gets lower c limit of the current axes.
%   CL = CLIM(2)          gets upper c limit of the current axes.
%   CLIM([CMIN CMAX])     sets the c limits.
%   CLMODE = CLIM('mode') gets the c limits mode.
%   CLIM(mode)            sets the c limits mode.
%                            (mode can be 'auto' or 'manual')
%   CLIM(AX,...)          uses axes AX instead of current axes.
%
%   CLIM sets or gets the CLim or CLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM<1>, YLIM<1>, ZLIM<1>, CAXIS, CLIM.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $
%   G.J. de Boer, Feb 2006, edited form xlim.m. April 7th 2008: Added option to get lower/upper limit of current axes
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 209 $  $Date: 2009-02-13 18:27:02 +0800 (Fri, 13 Feb 2009) $

if nargin == 0
  a = get(gca,'clim');
else
  if isscalar(arg1) && ishandle(arg1) && strcmp(get(arg1, 'type'), 'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'clim');
      return
    end
  elseif length(arg1)==1 & isnumeric(arg1)
      if any(arg1==[1 2])
         a   = get(gca,'clim');
         a   = a(arg1);
         val = [];
      else
          error('wrong syntax: clim1(1) or clim1(2)')
      end
  else
    if nargin==2
      error('MATLAB:clim1:InvalidNumberArguments', 'Wrong number of arguments')
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'climmode');
    else
      set(ax,'climmode',val);
    end
  elseif length(val==2)
    set(ax,'clim',val);
  end
end
