function p=indexpatch(x,y,z,vals,rgb)

z=z(1:end-1,1:end-1);

x1=x(1:end-1,1:end-1);
x2=x(1:end-1,2:end  );
x3=x(2:end  ,2:end  );
x4=x(2:end  ,1:end-1);

y1=y(1:end-1,1:end-1);
y2=y(1:end-1,2:end  );
y3=y(2:end  ,2:end  );
y4=y(2:end  ,1:end-1);

for icode=1:length(vals)
    
    i1=find(z==vals(icode));
    
    if ~isempty(i1)
        xx1=[];
        yy1=[];
        
        xx1(1,:)=x1(i1);
        xx1(2,:)=x2(i1);
        xx1(3,:)=x3(i1);
        xx1(4,:)=x4(i1);
        
        yy1(1,:)=y1(i1);
        yy1(2,:)=y2(i1);
        yy1(3,:)=y3(i1);
        yy1(4,:)=y4(i1);
        
        p(icode)=patch(xx1,yy1,rgb(icode,:));hold on
        set(p(icode),'linestyle','none');
        
    end
    
end
