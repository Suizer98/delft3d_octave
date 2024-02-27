/*==========================================================
 * reduce.c 
 *
 * Reduce a set of x,y points by linearizing over a subset,
 * and iteratively adding the point with largest error to
 * the subset, as in the Ramer–Douglas–Peucker algorithm
 * but with only y distance as critrion
 * 
 * Routine continues until either tolerance criterion
 * or max nr of points criterion is met
 * 
 * The calling syntax is:
 *
 *		outMatrix = reduce(x,y,tolerance,max nr of points)
 *
 * x:           	   1xn or mx1 sorted double array
 * y:                  1xn or mx1 double array
 * tolerance:          double scalar
 * max nr of points:   uint32 scalar
 *
 *========================================================*/

#include "mex.h"
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <stdio.h>

int compare(const void *a, const void *b) 
{
  if (*(uint32_t*)a > *(uint32_t*)b) return 1;
  else if (*(uint32_t*)a < *(uint32_t*)b) return -1;
  else return 0;  
}

uint32_t reduce(double *x, double *y,uint32_t *starts,uint32_t *ends,uint32_t *max_err_locs,double *max_err_vals, size_t s, double *tolerance, uint32_t *nmax, double *max_err_val)
{
    uint32_t next_empty, loop[2], nloops;
    uint32_t i, j, max_err_segment;
    double dydx, dx, dy, loc_err_val;
	double array[] = { 90, 3, 33, 28, 80, 49, 8, 30, 36, 25 };
	
	starts[0] = 0;
	ends[0]   = s-1;
	
	next_empty = 1;
	
	loop[0] = 0;
	nloops = 1;
	*max_err_val = *tolerance + 1;
	while (*max_err_val>*tolerance && next_empty<*nmax) {
		for (j=0; j<nloops; j++) {
			dydx = (y[starts[loop[j]]] - y[ends[loop[j]]])/(x[starts[loop[j]]] - x[ends[loop[j]]]);
			for (i=starts[loop[j]]+1; i<ends[loop[j]]; i++) {
				dx =  x[i] - x[starts[loop[j]]];
				dy =  y[i] - y[starts[loop[j]]];
				loc_err_val = fabs(dy - dydx * dx);
				if (loc_err_val >= max_err_vals[loop[j]]) {
					max_err_vals[loop[j]] = loc_err_val;
					max_err_locs[loop[j]] = i;
				}
			}
		}
		
		*max_err_val = 0;
		for (i=0; i<next_empty; i++) {
			if (max_err_vals[i] >= *max_err_val) {
				*max_err_val = max_err_vals[i];
				max_err_segment = i;
			}
		}
				
		ends[next_empty] = ends[max_err_segment];
		starts[next_empty] = max_err_locs[max_err_segment];
		ends[max_err_segment] = max_err_locs[max_err_segment];

		max_err_vals[max_err_segment]   = 0;
		max_err_locs[max_err_segment]   = 0;

		loop[0] = max_err_segment;
		loop[1] = next_empty;
		nloops = 2;
		next_empty = next_empty+1;	
		
	}
	/* Return number of points needed to fulfill criteria */
	return (next_empty-1);
}

/* The gateway function */
void mexFunction( uint16_t nlhs, mxArray *plhs[],
        uint16_t nrhs, const mxArray *prhs[])
{
    double *x;                  /* 1xN input matrix */
	double *y;                  /* 1xN input matrix */
    size_t ncols, mrows;            /* size of matrix */
    size_t s;				    	/* total elements in matrix*/
	uint32_t dims[2];
	double *tolerance;          /* maximum error*/
	uint32_t i;
    uint32_t *nmax;
    uint32_t *starts;               /* output matrix */
    uint32_t *ends;                 /* output matrix */
	uint32_t *max_err_locs;         /* output matrix */
	uint32_t *indices;
	double *max_err_val;
	double *max_err_vals;       /* output matrix */
	uint32_t nvals;
	
    /* check for proper number of arguments */
    if(nrhs!=4) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs","Two inputs required.");
    }
    if(nlhs!=6) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs","One output required.");
    }
    // make sure the second input argument is a double array
    if( !mxIsDouble(prhs[0]) ||
    mxIsComplex(prhs[0])) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notScalar","First input must be an array of doubles");
    }
    // check that number of rows in first input argument is 1
    if(mxGetM(prhs[0])!=1 && mxGetN(prhs[0])!=1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notRowVector","First input must be a row vector.");
    }
	// make sure the second input argument is scalar of type double
    if( !mxIsDouble(prhs[2]) ||
    mxGetNumberOfElements(prhs[2])!=1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notScalar","Second input multiplier must be a scalar of class double");
    }
    // make sure the third input argument is scalar of type uint16
    if( !mxIsUint32(prhs[3]) ||
    mxGetNumberOfElements(prhs[3])!=1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notScalar","Third input multiplier must be a scalar of class uint32");
    }    

    /* create a pointer to the real data in the input matrix  */
    x         = mxGetData(prhs[0]);
	y         = mxGetData(prhs[1]);
	tolerance = mxGetData(prhs[2]);
    nmax      = mxGetData(prhs[3]);
    
    /* get dimensions of the input matrix */
    ncols = mxGetN(prhs[0]);
    mrows = mxGetM(prhs[0]);
    
    /* create the output matrix */
    // plhs[0] = mxCreateDoubleMatrix(mrows,ncols,mxREAL);
	dims[0] = 1;
    dims[1] = *nmax;
	
    plhs[2] = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL);
    starts = mxGetData(plhs[2]);
	
    plhs[3] = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL);
    ends    = mxGetData(plhs[3]);
    
	plhs[4] = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL);
    max_err_locs = mxGetData(plhs[4]);
    
	plhs[5] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
    max_err_vals = mxGetData(plhs[5]);    
	
    s = mrows*ncols;
	
	dims[1] = 1;
	plhs[1] = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
	max_err_val = mxGetData(plhs[1]);
	
    /* call the computational routine */
    nvals = reduce(x,y,starts,ends,max_err_locs,max_err_vals,s,tolerance,nmax,max_err_val);
    
    dims[1] = nvals+1;
	
	plhs[0] = mxCreateNumericArray(2, dims, mxUINT32_CLASS, mxREAL);
    indices = mxGetData(plhs[0]);
	

	
	for (i=0; i<nvals; i++) {
		indices[i] = starts[i]+1;
		} 
	indices[nvals] = (int)s;	
	qsort (indices, nvals, sizeof(indices[0]), compare);
}