function [c0,h,wp]=contourf_mvo(x0,y0,z0,col)

[c0,h]=contourfcorr(x0,y0,z0,col);hold on;

set(h,'EdgeColor','none');

jj=1;
wp=[];

% Add white triangles
mmax=size(x0,1);
nmax=size(x0,2);
for i=2:mmax-1
    for j=2:nmax-1
        if isfinite(z0(i,j))
            k(1)=isfinite(z0(i-1,j+1));
            k(2)=isfinite(z0(i  ,j+1));
            k(3)=isfinite(z0(i+1,j+1));
            k(4)=isfinite(z0(i+1,j  ));
            k(5)=isfinite(z0(i+1,j-1));
            k(6)=isfinite(z0(i  ,j-1));
            k(7)=isfinite(z0(i-1,j-1));
            k(8)=isfinite(z0(i-1,j  ));
            fac=0.2;
            z1=zeros(5);
            if sum(k)<8;
                if k(8) && k(2) && ~k(1)
                    x1(1)=x0(i-1,j  );
                    x1(3)=x0(i  ,j+1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i-1,j  );
                    y1(3)=y0(i  ,j+1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(2) && k(4) && ~k(3)
                    x1(1)=x0(i  ,j+1);
                    x1(3)=x0(i+1,j  );
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i  ,j+1);
                    y1(3)=y0(i+1,j  );
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(4) && k(6) && ~k(5)
                    x1(1)=x0(i+1,j  );
                    x1(3)=x0(i  ,j-1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i+1,j  );
                    y1(3)=y0(i  ,j-1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(6) && k(8) && ~k(7)
                    x1(1)=x0(i-1,j  );
                    x1(3)=x0(i  ,j-1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i-1,j  );
                    y1(3)=y0(i  ,j-1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
            end
        end
    end
end
