/*==========================================================
 * running_median_filter.c 
 *
 * Calculates running median of window size n
 * 
 * The calling syntax is:
 *
 *		outMatrix = running_median(inMatrix,window)
 *
 * inMatrix: 1xn or mx1 double arry
 * window:   uint16 scalar
 *
 *========================================================*/

#include "mex.h"
#include <stdlib.h>
#include <stdint.h>

typedef double pixelvalue ;

#define PIX_SORT(a,b) { if ((a)>(b)) PIX_SWAP((a),(b)); }
#define PIX_SWAP(a,b) { pixelvalue temp=(a);(a)=(b);(b)=temp; }

/*----------------------------------------------------------------------------
 * Function :   opt_med3()
 * In       :   pointer to array of 3 pixel values
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 3 pixel values
 * Notice   :   found on sci.image.processing
 * cannot go faster unless assumptions are made
 * on the nature of the input signal.
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med3(pixelvalue * p)
{
    PIX_SORT(p[0],p[1]) ; PIX_SORT(p[1],p[2]) ; PIX_SORT(p[0],p[1]) ;
    return(p[1]) ;
}

/*----------------------------------------------------------------------------
 * Function :   opt_med5()
 * In       :   pointer to array of 5 pixel values
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 5 pixel values
 * Notice   :   found on sci.image.processing
 * cannot go faster unless assumptions are made
 * on the nature of the input signal.
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med5(pixelvalue * p)
{
    PIX_SORT(p[0],p[1]) ; PIX_SORT(p[3],p[4]) ; PIX_SORT(p[0],p[3]) ;
    PIX_SORT(p[1],p[4]) ; PIX_SORT(p[1],p[2]) ; PIX_SORT(p[2],p[3]) ;
    PIX_SORT(p[1],p[2]) ; return(p[2]) ;
}

/*----------------------------------------------------------------------------
 * Function :   opt_med6()
 * In       :   pointer to array of 6 pixel values
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 6 pixel values
 * Notice   :   from Christoph_John@gmx.de
 * based on a selection network which was proposed in
 * "FAST, EFFICIENT MEDIAN FILTERS WITH EVEN LENGTH WINDOWS"
 * J.P. HAVLICEK, K.A. SAKADY, G.R.KATZ
 * If you need larger even length kernels check the paper
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med6(pixelvalue * p)
{
    PIX_SORT(p[1], p[2]); PIX_SORT(p[3],p[4]);
    PIX_SORT(p[0], p[1]); PIX_SORT(p[2],p[3]); PIX_SORT(p[4],p[5]);
    PIX_SORT(p[1], p[2]); PIX_SORT(p[3],p[4]);
    PIX_SORT(p[0], p[1]); PIX_SORT(p[2],p[3]); PIX_SORT(p[4],p[5]);
    PIX_SORT(p[1], p[2]); PIX_SORT(p[3],p[4]);
    return ( p[2] + p[3] ) * 0.5;
    /* PIX_SORT(p[2], p[3]) results in lower median in p[2] and upper median in p[3] */
}


/*----------------------------------------------------------------------------
 * Function :   opt_med7()
 * In       :   pointer to array of 7 pixel values
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 7 pixel values
 * Notice   :   found on sci.image.processing
 * cannot go faster unless assumptions are made
 * on the nature of the input signal.
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med7(pixelvalue * p)
{
    PIX_SORT(p[0], p[5]) ; PIX_SORT(p[0], p[3]) ; PIX_SORT(p[1], p[6]) ;
    PIX_SORT(p[2], p[4]) ; PIX_SORT(p[0], p[1]) ; PIX_SORT(p[3], p[5]) ;
    PIX_SORT(p[2], p[6]) ; PIX_SORT(p[2], p[3]) ; PIX_SORT(p[3], p[6]) ;
    PIX_SORT(p[4], p[5]) ; PIX_SORT(p[1], p[4]) ; PIX_SORT(p[1], p[3]) ;
    PIX_SORT(p[3], p[4]) ; return (p[3]) ;
}

/*----------------------------------------------------------------------------
 * Function :   opt_med9()
 * In       :   pointer to an array of 9 pixelvalues
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 9 pixelvalues
 * Notice   :   in theory, cannot go faster without assumptions on the
 * signal.
 * Formula from:
 * XILINX XCELL magazine, vol. 23 by John L. Smith
 *
 * The input array is modified in the process
 * The result array is guaranteed to contain the median
 * value
 * in middle position, but other elements are NOT sorted.
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med9(pixelvalue * p)
{
    PIX_SORT(p[1], p[2]) ; PIX_SORT(p[4], p[5]) ; PIX_SORT(p[7], p[8]) ;
    PIX_SORT(p[0], p[1]) ; PIX_SORT(p[3], p[4]) ; PIX_SORT(p[6], p[7]) ;
    PIX_SORT(p[1], p[2]) ; PIX_SORT(p[4], p[5]) ; PIX_SORT(p[7], p[8]) ;
    PIX_SORT(p[0], p[3]) ; PIX_SORT(p[5], p[8]) ; PIX_SORT(p[4], p[7]) ;
    PIX_SORT(p[3], p[6]) ; PIX_SORT(p[1], p[4]) ; PIX_SORT(p[2], p[5]) ;
    PIX_SORT(p[4], p[7]) ; PIX_SORT(p[4], p[2]) ; PIX_SORT(p[6], p[4]) ;
    PIX_SORT(p[4], p[2]) ; return(p[4]) ;
}


/*----------------------------------------------------------------------------
 * Function :   opt_med25()
 * In       :   pointer to an array of 25 pixelvalues
 * Out      :   a pixelvalue
 * Job      :   optimized search of the median of 25 pixelvalues
 * Notice   :   in theory, cannot go faster without assumptions on the
 * signal.
 * Code taken from Graphic Gems.
 * ---------------------------------------------------------------------------*/

pixelvalue opt_med25(pixelvalue * p)
{
    PIX_SORT(p[0], p[1]) ;   PIX_SORT(p[3], p[4]) ;   PIX_SORT(p[2], p[4]) ;
    PIX_SORT(p[2], p[3]) ;   PIX_SORT(p[6], p[7]) ;   PIX_SORT(p[5], p[7]) ;
    PIX_SORT(p[5], p[6]) ;   PIX_SORT(p[9], p[10]) ;  PIX_SORT(p[8], p[10]) ;
    PIX_SORT(p[8], p[9]) ;   PIX_SORT(p[12], p[13]) ; PIX_SORT(p[11], p[13]) ;
    PIX_SORT(p[11], p[12]) ; PIX_SORT(p[15], p[16]) ; PIX_SORT(p[14], p[16]) ;
    PIX_SORT(p[14], p[15]) ; PIX_SORT(p[18], p[19]) ; PIX_SORT(p[17], p[19]) ;
    PIX_SORT(p[17], p[18]) ; PIX_SORT(p[21], p[22]) ; PIX_SORT(p[20], p[22]) ;
    PIX_SORT(p[20], p[21]) ; PIX_SORT(p[23], p[24]) ; PIX_SORT(p[2], p[5]) ;
    PIX_SORT(p[3], p[6]) ;   PIX_SORT(p[0], p[6]) ;   PIX_SORT(p[0], p[3]) ;
    PIX_SORT(p[4], p[7]) ;   PIX_SORT(p[1], p[7]) ;   PIX_SORT(p[1], p[4]) ;
    PIX_SORT(p[11], p[14]) ; PIX_SORT(p[8], p[14]) ;  PIX_SORT(p[8], p[11]) ;
    PIX_SORT(p[12], p[15]) ; PIX_SORT(p[9], p[15]) ;  PIX_SORT(p[9], p[12]) ;
    PIX_SORT(p[13], p[16]) ; PIX_SORT(p[10], p[16]) ; PIX_SORT(p[10], p[13]) ;
    PIX_SORT(p[20], p[23]) ; PIX_SORT(p[17], p[23]) ; PIX_SORT(p[17], p[20]) ;
    PIX_SORT(p[21], p[24]) ; PIX_SORT(p[18], p[24]) ; PIX_SORT(p[18], p[21]) ;
    PIX_SORT(p[19], p[22]) ; PIX_SORT(p[8], p[17]) ;  PIX_SORT(p[9], p[18]) ;
    PIX_SORT(p[0], p[18]) ;  PIX_SORT(p[0], p[9]) ;   PIX_SORT(p[10], p[19]) ;
    PIX_SORT(p[1], p[19]) ;  PIX_SORT(p[1], p[10]) ;  PIX_SORT(p[11], p[20]) ;
    PIX_SORT(p[2], p[20]) ;  PIX_SORT(p[2], p[11]) ;  PIX_SORT(p[12], p[21]) ;
    PIX_SORT(p[3], p[21]) ;  PIX_SORT(p[3], p[12]) ;  PIX_SORT(p[13], p[22]) ;
    PIX_SORT(p[4], p[22]) ;  PIX_SORT(p[4], p[13]) ;  PIX_SORT(p[14], p[23]) ;
    PIX_SORT(p[5], p[23]) ;  PIX_SORT(p[5], p[14]) ;  PIX_SORT(p[15], p[24]) ;
    PIX_SORT(p[6], p[24]) ;  PIX_SORT(p[6], p[15]) ;  PIX_SORT(p[7], p[16]) ;
    PIX_SORT(p[7], p[19]) ;  PIX_SORT(p[13], p[21]) ; PIX_SORT(p[15], p[23]) ;
    PIX_SORT(p[7], p[13]) ;  PIX_SORT(p[7], p[15]) ;  PIX_SORT(p[1], p[9]) ;
    PIX_SORT(p[3], p[11]) ;  PIX_SORT(p[5], p[17]) ;  PIX_SORT(p[11], p[17]) ;
    PIX_SORT(p[9], p[17]) ;  PIX_SORT(p[4], p[10]) ;  PIX_SORT(p[6], p[12]) ;
    PIX_SORT(p[7], p[14]) ;  PIX_SORT(p[4], p[6]) ;   PIX_SORT(p[4], p[7]) ;
    PIX_SORT(p[12], p[14]) ; PIX_SORT(p[10], p[14]) ; PIX_SORT(p[6], p[7]) ;
    PIX_SORT(p[10], p[12]) ; PIX_SORT(p[6], p[10]) ;  PIX_SORT(p[6], p[17]) ;
    PIX_SORT(p[12], p[17]) ; PIX_SORT(p[7], p[17]) ;  PIX_SORT(p[7], p[10]) ;
    PIX_SORT(p[12], p[18]) ; PIX_SORT(p[7], p[12]) ;  PIX_SORT(p[10], p[18]) ;
    PIX_SORT(p[12], p[20]) ; PIX_SORT(p[10], p[20]) ; PIX_SORT(p[10], p[12]) ;
    return (p[12]);
}

/*----------------------------------------------------------------------------
 * From wikipedia
 * insertion_sort is a very simple sorting routine, and appropriate because the 
 * buffer stays sorted
 * ---------------------------------------------------------------------------*/
insertion_sort(pixelvalue * p, uint16_t n)
{	
	uint16_t i;
	uint16_t k;
	for (i=1; i<(n); i++) {
		for (k = i; (k > 0 && p[k] < p[k-1]); k--) 
			PIX_SWAP(p[k], p[k-1])
	}
 }

void filterMedian_n(double *y, double *z, mwSize s, uint16_t *n)
{
    mwSize i;
    uint16_t k;
    uint16_t g;
    uint16_t half_n;
    
    /* Allocate space for buffer array */
    register pixelvalue *buffer_array = (pixelvalue *) calloc(*n,sizeof (pixelvalue));
    
    half_n = (*n-1)/2;
    
    /* multiply each element y by x */
    for (i=0; i<*n; i++) {
        buffer_array[i] = y[i];
    }
    k = *n-1;
    
    /*multiply each element y by x*/
    for (i=half_n; i<(s-half_n); i++) {
        
        /* update buffer */
        buffer_array[k] = y[i+half_n];

        /* calculate median */
        switch (*n) {
			case 1:
                z[i] = y[i];
				break;
            case 3:
                z[i] = opt_med3(buffer_array);
                break;
            case 5:
                z[i] = opt_med5(buffer_array);
                break;
            case 6:
                z[i] = opt_med6(buffer_array);
                break;
            case 7:
                z[i] = opt_med7(buffer_array);
                break;
            case 9:
                z[i] = opt_med9(buffer_array);
                break;
            case 25:
                z[i] = opt_med25(buffer_array);
                break;
			default:
				insertion_sort(buffer_array,*n);
				if (half_n == *n/2) 
					z[i] = buffer_array[half_n];
				else
					z[i] = (buffer_array[half_n]+buffer_array[half_n+1])/2;
				break;
        };
		
        /* find the index of a value that has to be updated */
        k = 0;
        while (((buffer_array[k] != y[i-half_n])) ) {
			k = k+1;
		}
    }

	// calculate firt parts of index
	// reset buffer
	for (i=0; i<*n; i++) {
        buffer_array[i] = y[i];
    }
	for (i=0; i<half_n; i++) {
		insertion_sort(buffer_array,2*i+1);
		z[i] = buffer_array[i];
	}
	for (i=0; i<*n; i++) {
        buffer_array[i] = y[s-i-1];
    }
	for (i=0; i<half_n; i++) {
		insertion_sort(buffer_array,2*i+1);
		z[s-i-1] = buffer_array[i];
	}
}

/* The gateway function */
void mexFunction( uint16_t nlhs, mxArray *plhs[],
        uint16_t nrhs, const mxArray *prhs[])
{
    double *inMatrix;               /* 1xN input matrix */
    mwSize ncols, mrows;            /* size of matrix */
    mwSize s;				    	/* total elements in matrix*/
    uint16_t *n;
    double *outMatrix;              /* output matrix */
    
    /* check for proper number of arguments */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs","Two inputs required.");
    }
    if(nlhs!=1) {
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
    // make sure the second input argument is scalar and a uint16
    if( !mxIsUint16(prhs[1]) ||
    mxGetNumberOfElements(prhs[1])!=1) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notScalar","Second input multiplier must be a scalar of class uint16");
    }    

    /* create a pointer to the real data in the input matrix  */
    inMatrix = mxGetPr(prhs[0]);
    n        = mxGetData(prhs[1]);
    
    /* get dimensions of the input matrix */
    ncols = mxGetN(prhs[0]);
    mrows = mxGetM(prhs[0]);
    
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(mrows,ncols,mxREAL);
    
    /* get a pointer to the real data in the output matrix */
    outMatrix = mxGetPr(plhs[0]);
    
    s = mrows*ncols;
	
    /* call the computational routine */
    filterMedian_n(inMatrix,outMatrix,s,n);
    
}

#undef PIX_SORT
#undef PIX_SWAP