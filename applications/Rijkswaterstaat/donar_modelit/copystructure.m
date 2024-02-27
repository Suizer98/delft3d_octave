function copyto = copystructure(copyfrom,copyto)
% copystructure - kopieer inhoud van de ene naar de andere structure,
%                 maar houd oorspronkelijke volgorde van velden vast
%                 Indien nodig worden nieuwe velden toegevoegd
%
% CALL:
%  copyto = copystructure(copyfrom,copyto)
%
% INPUT:
%  copyfrom: <struct> structure with overrides
%            NOTE: "copyfrom" should support methods "fieldnames" and
%            "subsasgn". Therefore undoredo objects are allowed here.
%
%  copyto:   <struct> structure with overridable data
%
% OUTPUT:
%  copyto:   <struct> adapted structure

% DISCUSSION (2009 02 06)
%     What should be done in the following cases?
%     "S=copystructure(copyfrom[N],copyto[M])"
%     N=M=1    ==> 
%         straightforward
%     N=0    ==> 
%         return copyto
%     M=0    ==> 
%         return copyfrom
%     N>1, M=1 ==> 
%         this is equivalent to:
%         for k=1:N
%             S(k)=copystructure(copyfrom(N),copyto)
%         end
%         Size of output equals size(copyfrom)
%     N=1, M>1 ==>
%         this is equivalent to:
%         for k=1:M
%             S(k)=copystructure(copyfrom,copyto(M))
%         end
%         Size of output equals size(copyto)
%     N>1, M>1, N==M ==>
%         Size of output equals size(copyto)
%     N>1, M>1, N~=M ==>
%         This should generate an error
%         Current behavior: copyto(2:end) is ignored

%REVISIONS:
%    ZIJPP FEB 2007: 
%        fast vectorized method for simple structures implemented
%    ZIJPP FEB 2009: code simplified. under some circumstances this 
%        modification is not backwards compatible (see discussion above).
%        The use of "copyFast" disabled, because this is not fully compatible.
%        In cases where it is needed for speed, seperate calls to this
%        procedures should be built in. At this time it is not known where
%        these calls are needed.
%    ZIJPP 20090323:
%        Correct bug: use resize where reshape was intended

% if nargin==0
%     load  copystructure
%     tic
%     copyto = copystructure(copyfrom,copyto);
%     toc
%     return
% end

%specify how to deal with copyfrom=[]
if isempty(copyfrom) 
    %nothing to do!
    return
end
if isempty(copyto) 
    %
    copyto=copyfrom;
    return
end

%NOTE:  "copyfrom" should support methods "fieldnames" and "subsasgn".
%Therefore undoredo objects are allowed here. Ther is no explicit test for
%class-types, but errors will occur if the inputs are not of the required
%type.

%copyfrom and copyto are both structures
if length(copyfrom)>1 || length(copyto)>1
    %vectorize,possible cases
    %copyto and copyfrom are arrays of equal size
    %copyto and copyfrom are arrays of different size
    %copyfrom is array, copyto is single structure
    %copyfrom is single structure, copyto is array

    if length(copyfrom)>1 %N>1
        if length(copyto)>1 %M>1
            if numel(copyto)==numel(copyfrom)
                %copyto and copyfrom are arrays of equal size
                %First collect results in cell array
                COPYTO=cell(size(copyto));
                for k=1:numel(COPYTO)
                    COPYTO{k}=copystructure(copyfrom(k),copyto(k));
                end
                %Then return data in struct array
                copyto=reshape([COPYTO{:}],size(copyto));
            else
                %copyto and copyfrom are arrays of different size
                error('in copystructure(A,B) when length(A)>1 and length(B)>1, A and B must have equal length');
            end
        else %M=1
            %copyfrom is array, copyto is single structure ==> vectorize

            %First collect results in cell array
            COPYTO=cell(size(copyfrom));
            for k=1:numel(COPYTO)
                COPYTO{k}=copystructure(copyfrom(k),copyto);
            end
            %Then return data in struct array
            copyto=reshape([COPYTO{:}],size(copyfrom));
        end
    else %N=1
        %length(copyfrom)==1
        if length(copyto)>1 %M>1
            %copyfrom is single structure, copyto is array  ==> vectorize
            %First collect results in cell array
            COPYTO=cell(size(copyto));
            for k=1:numel(COPYTO)
                COPYTO{k}=copystructure(copyfrom,copyto(k));
            end
            %Then return data in struct array
            copyto=reshape([COPYTO{:}],size(copyto));
        end
    end
    if ~isdeployed
%         disp('Vectorized version of copystructure is applied');
    end
    return
end

% %check if fast method is appropriate:
% if length(copyfrom)>1 && length(copyto)==1
%     copyto=copyFast(copyfrom,copyto);
%     return
% end

%- copyfrom and copyto are single structures

fields = fieldnames(copyfrom);
for k=1:length(fields)
    fld=fields{k};
    source=copyfrom.(fld);
    if isstruct(copyfrom.(fld))&&isfield(copyto,fld)&&isstruct(copyto.(fld))
        %- source is structure 
        %- corresponding field exists in target
        %- source is single structure (not array)
        copyto.(fld)=copystructure(source,copyto.(fld));
    else
        %source is not a structure
        %OR
        %corresponding field does not exists in target
        %OR
        %corresponding field is not a structure
        copyto.(fld)=source;
    end
    %volgorde blijft behouden, nieuwe velden worden aan het eind ingevoegd
end

%__________________________________________________________________________
function copyto=copyFast(copyfrom,copyto)
fldsFrom=fieldnames(copyfrom);
fldsTo  =fieldnames(copyto);
[m,n]=size(copyfrom);
if m~=m*n
    copyfrom=copyfrom(:);
end
dataFrom=struct2cell(copyfrom);

%initialize output:
dataTo  =repmat(struct2cell(copyto),1,size(dataFrom,2));

%look up fields:
old2new=row_is_in(fldsFrom,fldsTo);

%copy in data:
dataTo(old2new(old2new>0),:)=dataFrom(old2new>0,:);

%appendable data
dataTo    = cat(1,dataTo,dataFrom(old2new==0,:));
fldsTo    = cat(1,fldsTo,fldsFrom(old2new==0));

%all data are now available in cells
copyto=cell2struct(dataTo,fldsTo);
copyto =reshape(copyto,m,n);





