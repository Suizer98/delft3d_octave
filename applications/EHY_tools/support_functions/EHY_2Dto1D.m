function Data = EHY_2Dto1D(Data)

% Converts gridinfo data (horizontal) from d3d structure (mmax*nmax) to dfm structure

%% Conversion needed (d3d information)
if strcmp(Data.modelType,'d3d')
    
    names  = fieldnames(Data);
    nr_cor  = get_nr(names,'Xcor'); 
    nr_cen  = get_nr(names,'Xcen');
    nr_wl   = get_nr(names,'wl'  );
    nr_bed  = get_nr(names,'bed' );
    nr_val  = get_nr(names,'val' );
    nr_Zcen = get_nr(names,'Zcen');
    nr_Zint = get_nr(names,'Zcen');
    
    % Masking on waterlevels and/or centers
    mask_wl  = [];
    mask_cen = [];
    mask_1d  = [];   
    if ~isempty(nr_wl)  mask_wl  = squeeze(~isnan(Data.wl  (1,:,:))); end
    if ~isempty(nr_cen) mask_cen =         ~isnan(Data.Xcen(  :,:)) ; end
    if ~isempty(mask_wl) && ~isempty(mask_cen)
        if length(find(mask_wl - mask_cen ~= 0)) > 0
            warning('Masking inconsitent in EHY_2Dto1D')
        end
        dims = size(mask_wl); mask_1d = reshape(mask_wl & mask_cen,1,prod(dims));
    elseif  ~isempty(mask_wl)
        dims = size(mask_wl); mask_1d = reshape(mask_wl,1,prod(dims));
    elseif ~isempty(mask_cen)
        dims = size(mask_cen); mask_1d = reshape(mask_cen,1,prod(dims));
    else
        warning('No masking active/inactive in EHY_2Dto1D')
    end
    
    %  Convert corner information
    if ~isnan(nr_cor)
        dims = size(Data.(names{nr_cor}));
        mmax    = dims(1);
        nmax    = dims(2);
        
        %  start with: masking/numbering active corner points, and,
        %              creating 1-dimensional array with corner coordinates
        %              not skipping NaNs to be consistent with reshape
        mask(1:mmax,1:nmax) = NaN;
        
        nr_cell = 0;
        for n = 1: nmax
            for m = 1: mmax
                if ~isnan (Data.(names{nr_cor}) (m,n))
                    nr_cell       = nr_cell + 1;
                    mask(m,n)     = nr_cell;
                    Xtmp(nr_cell) = Data.(names{nr_cor})  (m,n); % can be replaced with reshape
                    Ytmp(nr_cell) = Data.(names{nr_cor+1})(m,n); % can be replaced with reshape
                end
            end
        end
        Data.(names{nr_cor}   ) = Xtmp;
        Data.(names{nr_cor+ 1}) = Ytmp;
        
        % construct 1 dimensional array edge_nodes array
        Data.edge_nodes = [];
        for m = 1: mmax
            for n = 1: nmax - 1
                if ~isnan(mask(m,n)) && ~isnan(mask(m,n+1))
                    Data.edge_nodes(1,end + 1) = mask(m,n    );
                    Data.edge_nodes(2,end    ) = mask(m,n + 1);
                end
            end
        end
        
        for n = 1: nmax
            for m = 1: mmax - 1
                if ~isnan(mask(m,n)) && ~isnan(mask(m + 1,n))
                    Data.edge_nodes(1,end + 1) = mask(m    ,n);
                    Data.edge_nodes(2,end    ) = mask(m + 1,n);
                end
            end
        end
    end
    
    clear mask Xtmp Ytmp
    
    %  Convert corner information
    if ~isnan(nr_cen)
        dims = size(Data.(names{nr_cen}));
        mmax    = dims(1);
        nmax    = dims(2);
        
        %  start with: masking/numbering active centre points, and,
        %              creating 1-dimensional array with centre coordinates
        %              not skipping NaNs to be consistent with reshape
        mask(1:mmax,1:nmax) = NaN;
        
        nr_cell = 0;
        for n = 1: nmax
            for m = 1: mmax
                if  mask_1d((n-1)*mmax + m)
                    nr_cell      = nr_cell + 1;
                    mask(m,n)    = (n-1)*mmax + m;
                    Xtmp(nr_cell) = Data.(names{nr_cen})  (m,n);
                    Ytmp(nr_cell) = Data.(names{nr_cen+1})(m,n);
                end
            end
        end
        Data.(names{nr_cen}   ) = Xtmp;
        Data.(names{nr_cen+ 1}) = Ytmp;
        
        % construct 1 dimensional array face_nodes array (TODO: when I have time)
        
    end
    
    clear mask Xtmp Ytmp
        
    %% Reshape all other information (might be a smarter way to program this but will have to do for now)
    if ~isempty(nr_wl)
        dims    = size(Data.wl);
        Data.wl = reshape(Data.wl      ,[dims(1) prod(dims(2:3))               ]);
    end
    
    if ~isempty(nr_bed)
        dims     = size(Data.bed);
        Data.bed = reshape(Data.bed     ,[1       prod(dims(2:3))               ]);
     end
    
    if ~isempty(nr_val)
        dims     = size(Data.val);
        Data.val = reshape(Data.val     ,[dims(1) prod(dims(2:3))     dims(4)   ]);
    end
    
    if ~isempty(nr_Zcen)
        dims     = size(Data.Zcen);
        Data.Zcen= reshape(Data.Zcen     ,[dims(1) prod(dims(2:3))     dims(4)   ]);
    end
    
    if ~isempty(nr_Zint)
        dims     = size(Data.Zint);
        Data.Zint= reshape(Data.Zint     ,[dims(1) prod(dims(2:3))     dims(4)   ]);
    end
    
    %%  Mask (remove inactive points)
    if ~isempty(mask_1d)
        if ~isempty(nr_wl  ) Data.wl   = Data.wl   (:,mask_1d  );end
        if ~isempty(nr_bed ) Data.bed  = Data.bed  (  mask_1d  );end
        if ~isempty(nr_val ) Data.val  = Data.val  (:,mask_1d,:);end 
        if ~isempty(nr_Zcen) Data.Zcen = Data.Zcen (:,mask_1d,:);end
        if ~isempty(nr_Zint) Data.Zint = Data.Zint (:,mask_1d,:);end
    end
end




