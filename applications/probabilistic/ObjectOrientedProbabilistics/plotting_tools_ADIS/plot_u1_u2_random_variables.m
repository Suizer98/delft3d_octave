 

% GENERATE random directions 

Seed=10;
rng('default');
rng(Seed);
randomsamples   = rand(25,2);                                    
u               = norm_inv(randomsamples,0,1);
    u1 = u(:,1);
    u2 = u(:,2);

            f1=figure(1)
            plot(u1,u2, 'b*')
            vector_position = [ 53         379        1067         569];
            hold on;
            for j=1:size(u1,1)
                if mod(j,2)==0
                    text(u1(j,1),u2(j,1),[' \leftarrow',num2str(j)],...
                        'VerticalAlignment','middle',...
                        'HorizontalAlignment','left',...
                        'FontSize',8,'Color','r')
                else
                    text(u1(j,1),u2(j,1),[num2str(j),' \rightarrow'],...
                        'VerticalAlignment','middle',...
                        'HorizontalAlignment','right',...
                        'FontSize',8,'Color','r')
                end
                
            end
            grid on;
            xlabel('u1')
            ylabel('u2')
            title('Distribution of u1 and u2')
            
print -dpng values_u1_and_u2

       % NORMALIZE VECTOR u1 and u2
       
            uLength             = sqrt(sum(u.^2,2));
            UNormalVector  = u./repmat(uLength,1,2);
            
            f2=figure(2)
            
            plot(UNormalVector(:,1),UNormalVector(:,2), 'b*')
            vector_position = [ 53         379        1067         569];
            hold on;
            for j=1:size(UNormalVector,1)
                if mod(j,2)==0
                    text(UNormalVector(j,1),UNormalVector(j,2),[' \leftarrow',num2str(j)],...
                        'VerticalAlignment','middle',...
                        'HorizontalAlignment','left',...
                        'FontSize',8,'Color','r')
                else
                    text(UNormalVector(j,1),UNormalVector(j,2),[num2str(j),' \rightarrow'],...
                        'VerticalAlignment','middle',...
                        'HorizontalAlignment','right',...
                        'FontSize',8,'Color','r')
                end
                
            end
            
            set(f2,'position',vector_position)
            axis([-1.5 1.5 -1.5 1.5])
            grid on;
            xlabel('u1')
            ylabel('u2')
            
            title('Plot of the vector normalized vector u./ sqrt(sum(u.^2,2)')
print -dpng normalized_values_u1_and_u2

