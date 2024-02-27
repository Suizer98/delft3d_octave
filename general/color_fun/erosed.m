function col = erosed(m)
%EROSED Sets colormap to erosed with m values, 16 is default.
%  
%See also: colormap.

r=[  
45  
75  
105 
135 
165 
195 
225 
255 
255 
255 
255 
255 
255 
255 
255 
255 
];

g=[ 
45 
75 
105
135
165
195
225
255
255
225
195
165
135
105
 75
 45
];

b=[
255
255
 255
 255
 255
 255
 255
 255
 255
  75
  75
  75
  75
  75
  75
  75
];

if nargin < 1
    col=[r g b];
else
    x=1:1:length(r);
    r=interp1(x,r,linspace(1,length(r),m));
    g=interp1(x,g,linspace(1,length(g),m));
    b=interp1(x,b,linspace(1,length(b),m));
    col=[r' g' b'];
end
col=col/255;
end