function surge=compute_ibe_surge_along_coast(coast,trackt)

surge=compute_ibe_surge_v03(coast.x,coast.y,trackt.x,trackt.y,trackt.vmax,trackt.rmax,trackt.r35,trackt.forward_speed,trackt.heading,trackt.phi_in,coast.w,coast.a,coast.manning,coast.latitude);

