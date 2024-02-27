function domains=ddb_initializeDelft3DWAVEDomain(domains,id)

domains(id).grid='';
domains(id).bedlevelgrid='';
domains(id).bedlevel='';
domains(id).dirspace='circle';
domains(id).ndir=36;
domains(id).startdir=0;
domains(id).enddir=360;
domains(id).nfreq=24;  
domains(id).freqmin=0.05;  
domains(id).freqmax=1.0;  
domains(id).nestedindomain=[];
domains(id).flowbedlevel=0;
domains(id).flowwaterlevel=0;
domains(id).flowvelocity=0;
domains(id).flowwind=0;
domains(id).output=1;
domains(id).vegetation=0;
domains(id).vegetationmap='';
domains(id).vegheight=1; 
domains(id).vegdiamtr=0.01;
domains(id).vegnstems=100; 
domains(id).vegdrag=1;
 
domains(id).gridname   = '';
domains(id).gridplot   = [];
domains(id).bathyplot   = [];
domains(id).nestgrid   = '';
domains(id).coordsyst  = '';
domains(id).mmax       = 0;
domains(id).nmax       = 0;

domains(id).mdffile = '';