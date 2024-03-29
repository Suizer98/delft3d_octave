function boundaries=ddb_initializeDelft3DWAVEBoundary(boundaries,ib)

boundaries(ib).name='';
boundaries(ib).definition='orientation';
boundaries(ib).orientation='north';
boundaries(ib).overallspecfile='';
boundaries(ib).wwspecfile='';
boundaries(ib).distancedir='counter-clockwise';
boundaries(ib).startcoordm=0;
boundaries(ib).endcoordm=0;
boundaries(ib).startcoordn=0;
boundaries(ib).endcoordn=0;
boundaries(ib).startcoordx=0;
boundaries(ib).endcoordx=0;
boundaries(ib).startcoordy=0;
boundaries(ib).endcoordy=0;
boundaries(ib).spectrumspec='parametric';
boundaries(ib).spshapetype='jonswap';
boundaries(ib).periodtype='peak';
boundaries(ib).dirspreadtype='power';
boundaries(ib).peakenhancfac=1;
boundaries(ib).gaussspread=0;
boundaries(ib).condspecatdist=0;
boundaries(ib).waveheight=0;
boundaries(ib).period=0;
boundaries(ib).direction=0;
boundaries(ib).dirspreading=10;
boundaries(ib).spectrum='';

boundaries(ib).alongboundary='uniform';
boundaries(ib).segmentnames={''};
boundaries(ib).activesegment=1;
boundaries(ib).nrsegments=1;
boundaries(ib).segmentnames={'Segment 1'};
boundaries(ib).segments(1).condspecatdist=0;
boundaries(ib).segments(1).waveheight=0;
boundaries(ib).segments(1).period=0;
boundaries(ib).segments(1).direction=0;
boundaries(ib).segments(1).dirspreading=10;
boundaries(ib).plothandle=[];
