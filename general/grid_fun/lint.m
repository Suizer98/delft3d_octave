function stot=lint(x,y,u,v,pol,outfile)

if ischar(pol)
    tekpol=tekal('read',pol,'loaddata');
    pol=[];
    for ipol=1:length(tekpol.Field)
        pol(ipol).x=tekpol.Field(ipol).Data(:,1)';
        pol(ipol).y=tekpol.Field(ipol).Data(:,2)';
    end
end

n=100;

for ipol=1:length(pol)
    stot(ipol)=0;
    for isec=1:length(pol(ipol).x)-1
        xx=[pol(ipol).x(isec) pol(ipol).x(isec+1)];
        yy=[pol(ipol).y(isec) pol(ipol).y(isec+1)];
        dx=(xx(2)-xx(1))/n;
        dy=(yy(2)-yy(1))/n;
        dst=sqrt(dx.^2+dy.^2);
        phi=atan2(dy,dx);
        if dx~=0
            xxx=xx(1)+0.5*dx:dx:xx(2)-0.5*dx;
        else
            xxx=repmat(xx(1),[1 n]);
        end
        if dy~=0
            yyy=yy(1)+0.5*dy:dy:yy(2)-0.5*dy;
        else
            yyy=repmat(yy(1),[1 n]);
        end
        uuu=interp2curvi(x,y,u,xxx,yyy);
        vvv=interp2curvi(x,y,v,xxx,yyy);
        s=-uuu*sin(phi)+vvv*cos(phi);
        s=nansum(s*dst);
        stot(ipol)=stot(ipol)+s;        
    end
end

varargout{1}=stot;

fid=fopen(outfile,'wt');
fprintf(fid,'%s\n','Lint');
fprintf(fid,'%i %i\n',length(pol),2);
for ipol=1:length(pol)
    fprintf(fid,'%i %14.7e\n',ipol,stot(ipol));
end
fclose(fid);
