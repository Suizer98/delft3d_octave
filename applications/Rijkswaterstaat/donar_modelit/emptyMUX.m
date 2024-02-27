function MUX = emptyMUX
% Make default MUX (Multiplex administratie) block.
% 
% CALL:
%  MUX = emptyMUX
% 
% INPUT:
%   No input required.
% 
% OUTPUT:
%  MUX:  Structure with fields:
%        +----iKannum (double)
%        +----lWnsnum (double)
%        +----sParcod (char)  
%        +----sParoms (char)  
%        +----sCasnum (char)  
%        +----sStaind (char)  
%        +----nCpmcod (double)
%        +----sCpmoms (char)  
%        +----sDomein (char)  
%        +----sEhdcod (char)  
%        +----sOrgcod (char)  
%        +----sOrgoms (char)  
%        +----sHdhcod (char)  
%        +----sHdhoms (char)  
%        +----sSgkcod (char) 
% 
% EXAMPLE:
%  MUX = emptyMUX
% 
% See also: emptyblok

MUX.iKannum= 1;
MUX.lWnsnum= 0;
MUX.sParcod= '';
MUX.sParoms= '';
MUX.sCasnum='';   %WIJZ ZIJPP 20110909 Added field to MUX
%This is needed because sCasnum is stored in MUX as of 06-11-2007
MUX.sStaind= '';
MUX.nCpmcod= 0;
MUX.sCpmoms= '';
MUX.sDomein= '';
MUX.sEhdcod= '';
MUX.sOrgcod= '';
MUX.sOrgoms= '';
MUX.sHdhcod= '';
MUX.sHdhoms= '';
MUX.sSgkcod= '';