function openBoundaries=delft3dflow_setDefaultBoundaryType(openBoundaries,ib)

openBoundaries(ib).alpha=0.0;
openBoundaries(ib).compA='unnamed';
openBoundaries(ib).compB='unnamed';
openBoundaries(ib).type='Z';
openBoundaries(ib).forcing='A';
openBoundaries(ib).profile='Uniform';
