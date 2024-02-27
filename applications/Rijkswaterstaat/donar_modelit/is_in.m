function [elm,isfound]=is_in(g,h,H,Hindx)
% is_in - vectorized version of 'find'
% 
% CALL
%     function elm=is_in(g,h,G,H)
%
% INPUT
%   g: vector with elements to be located
%   h: vector in which elements are looked for
%   H: sorted version of h (saves time)
%   Hindx: outcome of  [hsort hidx]=sort(h);
%
% OUTPUT
%   elm: returns indices >1 for each element of g which corresponds to elements of h
%        returned value corresponds with FIRST occurance in h
%
% EXAMPLE
%     [H,Hindx]=sort(h);
%     for ...
%            elm=is_in(g,[],H,Hindx)
%            ..
%     end
% EXAMPLE (2):copy elements from other table using key
% 		[f,ok]=is_in(key1,key2)
% 		attrib1(ok)=attrib2(f(ok))
%
% NOTE
%     In some cases "unique" is more efficient. Example:
%     INEFFICIENT CODE:
%         u_nrs=unique(nrs);
%         indx=is_in(nrs,u_nrss);
%     EFFICIENT CODE:
%         [u_nrs,dummy,indx]=unique(nrs);
%
% See also:
%     ismember      (Matlab native)
%     is_in         (deals with vectors)
%     is_in_id      (return matched IDs instead of indices)
%     is_in_find    (shell around is_in that returns, first, second, etc match)
%     is_in_sort    (deals with sorted vectors)
%     row_is_in     (deals with rows of a matrix)
%     is_in_struct  (deals with structures)
%     is_in_eq      (deals with equidistant time series)

if nargin==0


    %Benchmark test
    
    t0 = clock;
      
    SZG=120;
    SZH=40;
    Perf=zeros(SZG,SZH);
    Ratio=zeros(SZG,SZH);
    for row=1:SZG
        for col=1:SZH
            g=randperm(row*20);
            h=randperm(col*20);
%             tic;b=is_in(g,h);
            tic;[b,d]=ismember(g,h);
            Perf(row,col)=toc;
            
           Ratio(row,col)= (length(g)+length(h))/(length(g)*length(h));
        end
    end
    
     dsprintf('CPU=%.2f sec', etime(clock,t0))
     PerfMember=Perf;
    save Perf PerfMember Ratio -append
%     PerfSimple=Perf;
%     save Perf PerfSimple Ratio -append
%     PerfComplex=Perf;
%     save Perf PerfComplex Ratio -append
    
    load Perf
    figure('name','PerfSimple is fastest')
    spy(PerfMember>PerfSimple)
    xlabel('size H')
    ylabel('size G')
    
    figure('name','Ratio above T')
    spy(Ratio>0.004)
    xlabel('size H')
    ylabel('size G')
    disp done
    
        
%     save PerfComplex Perf
    
%     a=randperm(10000);
%     disp(' ');
%     for N=40:1:100
%         aa=rem(a,N-1);
%         uaa=unique(aa);
%         tic;b=is_in(aa,uaa);
%         dsprintf('N=%d toc=%f',N,toc)
%     end

    %Outcomes with fixed length(h) and length(g)=N
    %Method "find":
    %                        ratio
    %     N=40 toc=0.009103 [0.0257] <<<<<<<BEST
    %     N=50 toc=0.009361 [0.0205] <<<<<<<BEST
    %     N=60 toc=0.011223 [0.0170]
    %     N=70 toc=0.013273 [0.0146]

    %Method "sort":
    %                        ratio
    %     N=40 toc=0.009628 [0.0257]
    %     N=50 toc=0.009651 [0.0205]
    %     N=60 toc=0.010972 [0.0170] <<<<<<<BEST
    %     N=70 toc=0.010037 [0.0146] <<<<<<<BEST
    %
    %     Conclusion: if ratio>0.02: use method "find"

    return
end

if nargin==2
    %redirect to ismember
    [isfound,elm]=ismember(g,h(end:-1:1));
    %note: ismember finds last indices, is_in returns first.
    elm(isfound)=1+length(h)-elm(isfound);
    return
end

%Nanne van der Zijpp, Modelit, 2002
%Revised, 2003
g=g(:);
h=h(:);
if isempty(g)
    elm=[];
    isfound=[];
    return
end

%     NOTE:
%     - In some case find might be faster then sort
%     - Cost of sorting "g" is proportional to length(g). This was
%     established by an experiment
%     - Cost of comparing is proportional to length(g)*length(h)
%     - the trade-off depends on the outcome of:
%       (length(g)+length(h)) [cost of sorting]
%       (length(g)*length(h)) [cost of comparing]

%Benchmark for sort:
%     N=20000;
%     P=1000000/N;
%     for k=1:P
%         a=rand(N*k,1);
%         tic;sort(a);p(k)=toc;
%     end
%     plot(N*(1:P),p);
    
elm=zeros(size(g));
if isempty(h)
    %WIJZ ZIJPP MAR 2008
    return
end
ratio= (length(g)+length(h))/(length(g)*length(h)); %cost of sort/cost of compare

%WIJZ ZIJPP 20090616 optimize for speed
%Notes: 
%- Condition "length(h)<length(g)" is vital and was added;
%- Simple method seems to work for lengthy vector g and short vector h, but
%not vice versa;
%- Speed increase of factor 10 for h<10 has been observed

 if  ratio>0.004 && length(h)<length(g)
    %sort too expensive, find will be faster

    %This does not appear to be as fast as option below
%     if length(g)<length(h)
%         for k=1:length(g);
%             %loop over g
%             val=find(g(k)==h,1);
%             if ~isempty(val)
%                 elm(k)=val;
%             end
%         end
%     else
        %loop over h
        for k=length(h):-1:1;
            elm(g==h(k))=k;
        end
%     end
else
    [gsort gidx]=sort(g);
    if nargin<4
        [hsort hidx]=sort(h);
    else
        hsort=H(:);
        hidx=Hindx(:);
    end

    kk=1;
    %k: INDEX in g
    %kk: INDEX in h
    for k=1:length(g)
        while kk<=length(hsort)
            if hsort(kk)<gsort(k)
                kk=kk+1;
            else
                if gsort(k)==hsort(kk)
                    elm(gidx(k))=hidx(kk);
                end
                break
            end
        end
    end
end
if nargout>1
    isfound=elm>0;
end