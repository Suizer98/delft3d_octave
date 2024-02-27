function G = getG(TargetVolume, Hsig_t, w, Bend)
%GETG   routine to derive additional retreat due to coastal bends
% 
% routine to derive additional retreat due to coastal bends
%
% Syntax:       G = getG(TargetVolume, Hsig_t, w, Bend)
%
% Input: 
%               TargetVolume    = additional volume to be fitted in profile
%               Hsig_t          = wave height [m]
%               w               = fall velocity of the sediment in water
%               Bend            = bend interval [degrees] / 1000 m
%
% Output:       
%
%   See also 
% 
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>                                                            
% --------------------------------------------------------------------------

%% derive G0
G0 = getG0(Bend);

if ~isempty(G0)
    % TODO('This forlmulation lacks Tp_t and d. It should be adapted I guess??');
    G = TargetVolume / 300 * (Hsig_t/7.6)^.72 * (w/.0268)^.56 * G0;
    writemessage(51, ['Additional retreat of ' num2str(G, '%.1f') ' due to coastal bend']); 
else
    G = [];
    writemessage(52, 'Warning: consider this cross section in detail because of coastal bend'); 
end