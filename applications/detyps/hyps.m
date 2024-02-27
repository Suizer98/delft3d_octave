function [rvol,rare,rdep] = hyps(kcs,dps,gsqs,rmax,rmin)

nohyps = 100;

nmax = size(dps,1);
mmax = size(dps,2);

rint = (rmax-rmin)/(nohyps - 1);

for idep = 1: nohyps;
   rdep(idep) = rmax - (idep-1)*rint;
   rvol(idep) = 0.;
   rare(idep) = 0.;

   for m = 1:mmax;
      for n = 1: nmax;
         if (kcs(n,m) == 1);
            if (dps(n,m) > rdep(idep));
               rvol (idep) = rvol(idep) + gsqs(n,m)* ...
                                         (dps(n,m) - rdep(idep));
               rare (idep) = rare(idep) + gsqs(n,m);
            end;
         end;
      end;
   end;
end;

rdep = -rdep;
