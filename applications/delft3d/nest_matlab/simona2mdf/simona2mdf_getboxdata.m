function data = simona2mdf_getboxdata(box,data)

% siminp2mdf_getboxdata : gets box data out of the parsed siminp file

for ibox = 1: length(box)
    m1 = box(ibox).MNMN(1);
    n1 = box(ibox).MNMN(2);
    m2 = box(ibox).MNMN(3);
    n2 = box(ibox).MNMN(4);
    k  = 1;
    if simona2mdf_fieldandvalue(box(ibox),'LAYER')
        k = box(ibox).LAYER;
        if k == 0; k = 1; end
    end
    
    if simona2mdf_fieldandvalue(box(ibox),'CONST_VALUES')
        data(m1:m2,n1:n2,k) = box(ibox).CONST_VALUES;
    end
    
    if simona2mdf_fieldandvalue(box(ibox),'VARIABLE_VAL')
        for m = m1:m2
            for n = n1:n2
                data(m,n,k) = box(ibox).VARIABLE_VAL((m-m1)*(n2-n1+1) + n - n1 + 1);
            end
        end
    end
    
    if simona2mdf_fieldandvalue(box(ibox),'CORNER_VALUE')
        m1  = box(ibox).MNMN(1);
        n1  = box(ibox).MNMN(2);
        m2  = box(ibox).MNMN(3);
        n2  = box(ibox).MNMN(4);
                  
        [XX,YY] = meshgrid( 1:m2-m1+1 , 1:n2-n1+1 );
        [X ,Y ] = meshgrid([1;m2-m1+1],[1;n2-n1+1]);
    
        Z(1,1) = box(ibox).CORNER_VALUE(1);
        Z(1,2) = box(ibox).CORNER_VALUE(2);
        Z(2,1) = box(ibox).CORNER_VALUE(4);
        Z(2,2) = box(ibox).CORNER_VALUE(3);
                
        data_n = interp2(X,Y,Z,XX,YY);
        
        data(m1:m2,n1:n2,k) = data_n';
    end
    
end
