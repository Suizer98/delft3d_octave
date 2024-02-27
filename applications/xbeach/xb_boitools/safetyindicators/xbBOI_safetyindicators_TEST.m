%% Testscript voor het uitlezen van relevante XBeach-resultaten
%
%  Dit script is opgesteld t.b.v. implementatie in Morphan, als onderdeel van het project BOI Zandige Waterkeringen.
%
%  Versie script:   25-04-2022
%
%  Ontwikkeld door:	Deltares & Arcadis
%  Contactpersoon:  Robbin van Santen (Arcadis)
%
clear all
close all
disp(date)

%%
mypath      = 'c:\Users\santenr\OneDrive - ARCADIS\data\C06041.000018-BOI_Zandige_Keringen\4_uitwerkingen\05 - grensprofiel\';
runpath     = [mypath '1_xbeach\runs_testexec\surf\full\'];
    runname     = '2000700';
%     runname     = '5004377';
%     runname     = '7000308';
%     runname     = '7001483';
%     runname     = '7003775';
%     runname     = '11001002';
%     runname     = '12001000';
xbdirout    = [runpath runname '\'];

% xbdirout    = 'h:\NLZW2DT0002\C06041.000018_BOI_Duinen_JvdB\model\other\7000308\';

%%
[xafslag,zafslag, xnat,znat, xgp,zgp,grensprf] = xbBOI_safetyindicators(xbdirout);

%% EOF
