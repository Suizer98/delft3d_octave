function [xpol,ypol,noval,nopol] = detpol(Fileinfo)
%
% Bepaalt polygooncoordinaten

% First determine the total number of polygons and maximum number of
% values in a polygon

ipol    = 0;
novl    = 0;
noblock = size(Fileinfo.Field,2);

for iblock = 1: noblock;
   ival   = 0;
   ipol  = ipol + 1;
   nodat = size (Fileinfo.Field(iblock).Data,1);
   for idat = 1: nodat;
      xeff = Fileinfo.Field(iblock).Data(idat,1);
      if (xeff ~= 999.999);
         ival = ival + 1;
      else
         novl = max(novl,ival);
         ipol = ipol + 1;
         ival  = 0;
      end;
   end;
end;

% Then initialize the arrays

nopol = ipol;
noval(1:nopol)         = NaN;
xpol (1:nopol,1:novl ) = NaN;
ypol (1:nopol,1:novl ) = NaN;

% Finally fill the arrays

ipol        = 0;

noblock = size(Fileinfo.Field,2);

for iblock = 1: noblock;
   ipol        = ipol + 1;
   noval(ipol) = 0;
   nodat = size (Fileinfo.Field(iblock).Data,1);
   for idat = 1: nodat;
      xeff = Fileinfo.Field(iblock).Data(idat,1);
      yeff = Fileinfo.Field(iblock).Data(idat,2);
      if (xeff ~= 999.999);
         noval(ipol) = noval(ipol)+1;
         xpol(ipol,noval(ipol)) = xeff;
         ypol(ipol,noval(ipol)) = yeff;
      else
         ipol = ipol + 1;
         noval(ipol) = 0;
      end;
   end;
end;
