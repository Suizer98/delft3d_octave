function obstacles=ddb_initializeDelft3DWAVEObstacle(obstacles,iob)

obstacles(iob).name='';
obstacles(iob).type='dam';
obstacles(iob).height=0;
obstacles(iob).alpha=2.6;
obstacles(iob).beta=0.15;
obstacles(iob).reflections='no';
obstacles(iob).transmcoef=0;
obstacles(iob).refleccoef=0;
obstacles(iob).x=0;
obstacles(iob).y=0;

obstacles(iob).plothandle=[];
