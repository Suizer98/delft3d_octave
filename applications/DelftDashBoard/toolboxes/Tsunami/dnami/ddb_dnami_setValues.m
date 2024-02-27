function ddb_dnami_setValues()
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_dnami_setValues.m
% Version:      Version 1.0, March 2007
% By:           Deepak Vatvani
% Summary:
%
% Copyright (c) WL|Delft Hydraulics 2007 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth    disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch  mrkrpatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%
global progdir   datadir     workdir
%

fig1 = findobj('name','Tsunami Toolkit');
filearea = [datadir 'default.png'];

set (findobj(fig1,'tag','AreaFilename'), 'string', filearea);
if lat_epi == 0
   set (findobj(fig1,'tag','EQLat'), 'string', '');
else
   set (findobj(fig1,'tag','EQLat'), 'string', num2str(lat_epi));
end
if lon_epi == 0
   set (findobj(fig1,'tag','EQLon'), 'string', '');
else
   set (findobj(fig1,'tag','EQLon'), 'string', num2str(lon_epi));
end

set (findobj(fig1,'tag','FDtop'), 'string', num2str(fdtop));

h1 = findobj(fig1,'tag','SeismoOkada');

if nseg == 0
   set(findobj(fig1,'tag','Nseg'), 'string', ' ');
else
   set(findobj(fig1,'tag','Nseg'), 'string', num2str(nseg));
   if nseg > 1
      foption='Fault unrelated to EQ';
      set(h1,'string','Fault unrelated to epicentre','SelectionHighlight','off','Visible', 'off');
%   else
%     foption='Centre Fault around EQ epicentre';
   end
end

if foption(1:1)=='C'
   set(h1,'string','Centre fault around epicentre','SelectionHighlight','on','Visible', 'on');
else
   if nseg == 1
      set(h1,'string','Fault unrelated to epicentre','SelectionHighlight','off','Visible', 'on');
   end
end

if Mw > 5
   set(findobj(fig1,'tag','Mw'), 'string', num2str(Mw));
   set(findobj(fig1,'tag','TotFLength'), 'string', int2str(totflength));
   set(findobj(fig1,'tag','FWidth'), 'string', int2str(fwidth));
   set(findobj(fig1,'tag','Disloc'), 'string', num2str(disloc));
else
   Mw=0;  totflength=0.;   fwidth=0.;   disloc=0;  fdtop=0;
   set(findobj(fig1,'tag','Mw'), 'string', ' ');
   set(findobj(fig1,'tag','TotFLength'), 'string', '');
   set(findobj(fig1,'tag','FWidth'), 'string', '');
   set(findobj(fig1,'tag','Disloc'), 'string', '');
end

for i=1:5
   enab = 'On';
   if i > nseg
     enab ='Off';
   end
   set(findobj(fig1,'tag',['FaultLstr' num2str(i)]),'string', int2str(userfaultL(i)),'Visible', enab);
   set(findobj(fig1,'tag',['Strikestr' num2str(i)]),'string', int2str(strike(i)),'Visible', enab);
   set(findobj(fig1,'tag',['Dipstr' num2str(i)]),   'string', int2str(dip(i)),'Visible', enab);
   set(findobj(fig1,'tag',['Slipstr' num2str(i)]),  'string', int2str(slip(i)),'Visible', enab);
   set(findobj(fig1,'tag',['FDepth' num2str(i)]),   'string', int2str(fdepth(i)),'Visible', enab);
end
