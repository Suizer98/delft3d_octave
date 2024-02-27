function surge=compute_ekman_surge_along_coast(coast,trackt,xacc,tacc,phi_rel)

surge=compute_ekman_surge_11(xacc,tacc,trackt.vmax,trackt.rmax,trackt.r35,trackt.forward_speed,phi_rel,trackt.phi_in,coast.w,coast.a,coast.manning,coast.latitude,2);
