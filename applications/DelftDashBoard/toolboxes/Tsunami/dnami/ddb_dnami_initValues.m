function ddb_dnami_initValues()
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

lat_epi  = 0;
lon_epi  = 0;

faultTotL= 0.;
mrkrpatch= 0.;           fltpatch=0;

faultX    =[0 0 0 0 0 0];  faultY=[0 0 0 0 0 0];    fdepth=[0 0 0 0 0];
userfaultL=[0 0 0 0 0];       dip=[0 0 0 0 0];      strike=[0 0 0 0 0];
slip      =[0 0 0 0 0];      xvrt=[0 0 0 0 0];        yvrt=[0 0 0 0 0];
fltpatch  =[0 0 0 0 0];
Mw        =0;          totflength= 0.;
fwidth    =0.;            disloc = 0;
fdtop     =0;
nseg      =0;
foption   ='Fault unrelated to EQ';
