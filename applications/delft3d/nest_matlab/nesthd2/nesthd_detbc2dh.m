function [bndval,nfs_inf] = detbc(bndval,bnd,nfs_inf,add_inf)

% dethyd2dh : retrieves depth averaged bc from a 3d simulation

%% Get some general information
no_pnt   = length(bnd.DATA);
notims   = nfs_inf.notims;
kmax     = nfs_inf.kmax;
thick    = nfs_inf.thick;
lstci    = -1;
if kmax > 1                           profile  = add_inf.profile; end
if length(size(bndval(1).value)) == 3 lstci    = nfs_inf.lstci  ; end

%% Averaging needed?
if kmax > 1 && (strcmpi(profile,'uniform') || strcmpi(profile,'logarithmic'))

    %% Cycle over all boundary points
    for i_pnt = 1: no_pnt
        type = lower(bnd.DATA(i_pnt).bndtype);
        for itim = 1: notims
            if lstci == -1
                if strcmpi(type,'c') || strcmpi(type,'p') || strcmpi(type,'r') || strcmpi(type,'x')

                    %% Determine depth averaged value of velocity, riemann invariant or constituent
                    hulp(itim).value(i_pnt,1) = sum(thick.*bndval(itim).value(i_pnt,1:kmax));

                elseif strcmpi(type,'z') || strcmpi(type,'n')

                    %% Water level or neumann boundary, do nothing
                    hulp(itim).value(i_pnt,1) = bndval(itim).value(i_pnt,1);

                end

                %% Parallel velocity component
                if strcmpi(type,'p') || strcmpi(type,'x')
                    hulp(itim).value(i_pnt,2) = sum(thick.*bndval(itim).value(i_pnt,kmax+1:2*kmax));
                end
            else

                %% Constituents
                for l = 1: lstci
                    if add_inf.genconc(l)
                        hulp(itim).value(i_pnt,1,l) = sum(thick.*bndval(itim).value(i_pnt,1:kmax,l));
                    end
                end

            end
        end
    end

    clear bndval

    bndval = hulp;

    nfs_inf.nolay = 1;

else
    nfs_inf.nolay = kmax;
end
