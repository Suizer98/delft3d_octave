function buq = buq_find_neighbors(buq)

nb=length(buq.n);

buq.mu =zeros(1,nb);
buq.mu1=zeros(1,nb);
buq.mu2=zeros(1,nb);
buq.md =zeros(1,nb);
buq.md1=zeros(1,nb);
buq.md2=zeros(1,nb);
buq.nu =zeros(1,nb);
buq.nu1=zeros(1,nb);
buq.nu2=zeros(1,nb);
buq.nd =zeros(1,nb);
buq.nd1=zeros(1,nb);
buq.nd2=zeros(1,nb);

% Find neighbors
for ib=1:nb

    % Same level

    % Right
    j=find(buq.level==buq.level(ib) & buq.m==buq.m(ib)+1 & buq.n==buq.n(ib));
    if ~isempty(j)
        buq.mu(ib)=0;
        buq.mu1(ib)=j;
        buq.mu2(ib)=0;
        buq.md(j)=0;
        buq.md1(j)=ib;
        buq.md2(j)=0;
    end
    
    % Above
    j=find(buq.level==buq.level(ib) & buq.m==buq.m(ib) & buq.n==buq.n(ib)+1);
    if ~isempty(j)
        buq.nu(ib)=0;
        buq.nu1(ib)=j;
        buq.nu2(ib)=0;
        buq.nd(j)=0;
        buq.nd1(j)=ib;
        buq.nd2(j)=0;
    end
    
    % Coarser (only possible if level>0)
    if buq.level(ib)>0
        
        % Right
        % Only possible for even numbers of m
        if iseven(buq.m(ib))
            if iseven(buq.n(ib))            
                j=find(buq.level==buq.level(ib)-1 & (buq.m==buq.m(ib)/2+1 & buq.n==buq.n(ib)/2));
                if ~isempty(j)
                    buq.mu(ib)=-1;
                    buq.mu1(ib)=j;
                    buq.mu2(ib)=0;                    
                    buq.md2(j)=ib;
                    buq.md(j)=1;
                end    
            else
                j=find(buq.level==buq.level(ib)-1 & (buq.m==buq.m(ib)/2+1 & buq.n==(buq.n(ib)+1)/2));
                if ~isempty(j)
                    buq.mu(ib)=-1;
                    buq.mu1(ib)=j;
                    buq.mu2(ib)=0;                    
                    buq.md1(j)=ib;
                    buq.md(j)=1;
                end    
            end            
        end
        
        % Above
        % Only possible for even numbers of n
        if iseven(buq.n(ib))
            if iseven(buq.m(ib))            
                j=find(buq.level==buq.level(ib)-1 & (buq.n==buq.n(ib)/2+1 & buq.m==buq.m(ib)/2));
                if ~isempty(j)
                    buq.nu(ib)=-1;
                    buq.nu1(ib)=j;
                    buq.nu2(ib)=0;                    
                    buq.nd2(j)=ib;
                    buq.nd(j)=1;
                end    
            else
                j=find(buq.level==buq.level(ib)-1 & (buq.n==buq.n(ib)/2+1 & buq.m==(buq.m(ib)+1)/2));
                if ~isempty(j)
                    buq.nu(ib)=-1;
                    buq.nu1(ib)=j;
                    buq.nu2(ib)=0;                    
                    buq.nd1(j)=ib;
                    buq.nd(j)=1;
                end    
            end            
        end
    end    
        
    % Finer

    % Right
    j=find(buq.level==buq.level(ib)+1 & (buq.m==buq.m(ib)*2+1 & buq.n==buq.n(ib)*2-1));
    if ~isempty(j)
        buq.mu(ib)=1;
        buq.mu1(ib)=j;
        buq.md1(j)=ib;
        buq.md2(j)=0;
        buq.md(j)=-1;
    end    
    j=find(buq.level==buq.level(ib)+1 & (buq.m==buq.m(ib)*2+1 & buq.n==buq.n(ib)*2  ));
    if ~isempty(j)
        buq.mu(ib)=1;
        buq.mu2(ib)=j;
        buq.md1(j)=ib;
        buq.md2(j)=0;
        buq.md(j)=-1;
    end
        
    % Above
    j=find(buq.level==buq.level(ib)+1 & (buq.n==buq.n(ib)*2+1 & buq.m==buq.m(ib)*2-1));
    if ~isempty(j)
        buq.nu(ib)=1;
        buq.nu1(ib)=j;
        buq.nd1(j)=ib;
        buq.nd2(j)=0;
        buq.nd(j)=-1;
    end    
    j=find(buq.level==buq.level(ib)+1 & (buq.n==buq.n(ib)*2+1 & buq.m==buq.m(ib)*2  ));
    if ~isempty(j)
        buq.nu(ib)=1;
        buq.nu2(ib)=j;
        buq.nd1(j)=ib;
        buq.nd2(j)=0;
        buq.nd(j)=-1;
    end
    
end

function check=iseven(ix)
if rem(ix,2)
    check=false;
else
    check=true;
end
