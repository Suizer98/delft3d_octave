function G2=rotateNet(G1,ang)
%rotateNet   Rotate networks read by dflowfm.readNet by ang in degrees
%
% Example 1:
%
%
G2 = G1; 
z = G1.node.x + i*G1.node.y; 
z2 = z*exp(i*pi*ang/180); 
G2.node.x = real(z2); 
G2.node.y = imag(z2); 

warning('face nodes (if present) have not been updated');



