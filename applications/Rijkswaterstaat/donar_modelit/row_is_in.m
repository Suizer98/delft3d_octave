function [A2B,B2A]=row_is_in(A,B,Aunique)
% row_is_in - recognize rows of matrix A in matrix B (and vice versa)
% 
% CALL:
%  [A2B,B2A]=row_is_in(A,B,Aunique)
%
% INPUT:
%  A,B: matrices
%  Aunique: set this argument to 1 if A consists of unique rows
%
% OUTPUT:
%  A2B: vector with length= size(A,1)
%       if A2B(i)~=0:  A(i,:) == B(A2B(i,:))
%  B2A: vector with length= size(B,1)
%       if B2A(i)~=0:  B(i,:) == A(B2A(i,:))
%
% REMARKS
% 	returns indices >1 for each element of A which corresponds to elements of B
% 	returned value corresponds with FIRST occurrance in B
%
% NOTE
%     In some cases "unique" is more efficient. Example:
%     INEFFICIENT CODE:
%         u_rows=unique(strs,'rows');
%         indx=row_is_in(strs,u_rows);
%     EFFICIENT CODE:
%         [u_rows,dummy,indx]=unique(strs,'rows');
% 
% See also
%     is_in         (deals with vectors)
%     row_is_in     (deals with rows of a matrix)
%     is_in_struct  (deals with structures)
%     is_in_eq      (deals with equidistant time series)
%     is_in_sort    (deals with sorted time series)
%     strCompare
%     unique

% 	© Modelit, 2002-2008

% REVISIONS
% JUNE 2005:  
% - allow cell arrays for A and B
% - if A and B not equal width: pad with spaces (char matrices) or zeros
% (numeric matrices)


if ~isdeployed && nargout==1
    %temp debug message:
    warning('consider using ismember instead of row_is_in');
end
    

% check for empty A
if isempty(A)
    A2B=[];
    B2A=[];
    return
end
% check for empty B
if isempty(B)
    A2B=zeros(size(A,1),1); %Wijz: zijpp april 2005
    B2A=[];
    return
end
% check for cell argument A
if iscell(A)
    %WIJZ ZIJPP: strvscat==>char
    A=char(A); %empty strings replaced with spaces 
end
% check for cell argument B
if iscell(B)
    %WIJZ ZIJPP: strvscat==>char
    B=char(B); %empty strings replaced with spaces 
end
% check for width B < width A
if size(A,2)>size(B,2)
    %Adjust B
    if ischar(B)
        %pad char array with space
        B(:,end+1:size(A,2))=' ';
    else
        %pad numeric array with 0
        B(:,end+1:size(A,2))=0;
    end
end
% check for width A < width B
if size(A,2)<size(B,2)
    %Adjust A
    if ischar(A)
        %pad char array with space
        A(:,end+1:size(B,2))=' ';
    else
        %pad numeric array with 0
        A(:,end+1:size(B,2))=0;
    end
end

%--------------------------------
%ALL INPUT CHECKS DONE
%--------------------------------

%A is not empty
W=size(A,2);

%A and B are matrices of equal size
Bindex=[zeros(size(A,1),1);(1:size(B,1))'];
%     Bindex=0 ==> element of A
%     Bindex>0 ==> element of B
Aindex=[(1:size(A,1))';zeros(size(B,1),1)];
%     Aindex=0 ==> element of B
%     Aindex>0 ==> element of A
[ABsort idx]=sortrows([[A;B],Bindex]);
Aindex=Aindex(idx);
Bindex=Bindex(idx);

%==================
%Find A2B
%==================
A2B=zeros(size(A,1),1);
nextB=0;
h_AB=size(ABsort,1);
for k=1:h_AB
    %if this one is a member of A
    %and
    %and all elements match next member of B
    %then
    %A2B(Aindex(k))=Bindex(k+1)
    if Aindex(k)
        %k points to element of A
        if k>nextB
            %find next element of B
            ENDOFLIST=1;
            for nextB=k+1:h_AB
                if Bindex(nextB)
                    %nextB points to element of B
                    ENDOFLIST=0;
                    break; %found an element of B
                end
            end
            if ENDOFLIST
                %reached end of list without finding element of B
                %==> stop
                break;
            end
        end
        %else:nextB also applies to this k
        %nextB is first element of B greater or equal then A(k,:)
        %check for equality
        if all(ABsort(k,1:W)==ABsort(nextB,1:W))
            %they are equal!
            A2B(Aindex(k))=Bindex(nextB);
        end
        %else they are not equal : move to next in list
    end
    %else: k points to element of B==> increase k
end
%END OF LOOP: no more element of A or B available

%==================
%Find B2A if needed
%==================
if nargout==2
    if nargin<3
        Aunique=0;
    end
    %set elements of B already accounted for
    B2A=zeros(size(B,1),1);
    f_A_found=find(A2B);
    B2A(A2B(f_A_found))=(1:length(f_A_found))';

    if Aunique==0
        %set elements of B not yet accounted for
        %only useful if A contains double elements
        f_B_notfound=find(B2A==0);
        if ~isempty(f_B_notfound)&& ~isempty(f_A_found)
            %only look for elements of A that are in B!
            b2a=is_in(B(f_B_notfound,:),A(f_A_found,:));
            B2A(f_B_notfound)=f_A_found(b2a);
        end
    end
end


