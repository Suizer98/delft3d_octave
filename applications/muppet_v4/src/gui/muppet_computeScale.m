function [xl,yl,scale]=muppet_computeScale(xl,yl,sz,projection,opt)

scale=[];
scale=(xl(2)-xl(1))/(0.01*sz(1));
ymax=yl(1)+scale*0.01*sz(2);
