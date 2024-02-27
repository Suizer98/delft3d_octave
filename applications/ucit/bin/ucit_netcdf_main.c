/*
 * MATLAB Compiler: 4.11 (R2009b)
 * Date: Mon Dec 06 15:49:54 2010
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v" "-d"
 * "bin" "ucit_netcdf.m" "-B" "complist" "-a" "ucit_netcdf.m" "betacdf.m"
 * "betainv.m" "betapdf.m" "distchck.m" "polyconf.m" "tinv.m"
 * "UCIT_IsohypseInPolygon.m" "UCIT_getCrossSection.m"
 * "UCIT_plotDataInGoogleEarth.m" "UCIT_plotDataInPolygon.m"
 * "UCIT_plotDifferenceMap.m" "UCIT_plotGridOverview.m"
 * "UCIT_sandBalanceInPolygon.m" "UCIT_exportTransects2GoogleEarth.m"
 * "UCIT_plotTransectOverview.m" "UCIT_selectTransect.m"
 * "UCIT_showTransectOnOverview.m" "UCIT_analyseTransectVolume.m"
 * "UCIT_calculateMKL.m" "UCIT_calculateTKL.m" "UCIT_plotMultipleYears.m"
 * "UCIT_plotTransect.m" "UCIT_plotAlongshore.m" "UCIT_plotDots.m"
 * "UCIT_plotDotsInPolygon.m" "UCIT_plotLidarTransect.m"
 * "UCIT_plotMultipleTransects.m" "UCIT_SelectTransectsUS.m" "UCIT_cdots_amy.m"
 * "UCIT_clbPlotUSGS.m" "UCIT_exportSelectedTransects2GoogleEarth.m"
 * "UCIT_fncResizeUSGS.m" "UCIT_getLidarMetaData.m" "UCIT_plotDots.m"
 * "UCIT_plotDotsAmy.m" "UCIT_saveDataUS.m" "UCIT_toggleCheckBoxes.m"
 * "UCIT_DC_selectTransects.m" "UCIT_DC_setValuesOnPopup.m" "UCIT_Help.m"
 * "UCIT_Options.m" "UCIT_batchCommand.m" "UCIT_checkPopups.m"
 * "UCIT_findAvailableActions.m" "UCIT_getInfoFromPopup.m" "UCIT_getObjTags.m"
 * "UCIT_loadRelevantInfo2Popup.m" "UCIT_makeUCITConsole.m" "UCIT_next.m"
 * "UCIT_preparePlot.m" "UCIT_print.m" "UCIT_quit.m" "UCIT_resetUCITDir.m"
 * "UCIT_resetValuesOnPopup.m" "UCIT_restoreWindowsPositions.m"
 * "UCIT_selectFile.m" "UCIT_selectRay.m" "UCIT_selectRayPoly.m"
 * "UCIT_selectUser.m" "UCIT_setIniDir.m" "UCIT_setValues2Popup.m"
 * "UCIT_showRay.m" "UCIT_takeAction.m" "addUCIT.m" "doNothing.m"
 * "ucit_about.m" "UCIT_computeGridVolume.m" "UCIT_findCoverage.m"
 * "UCIT_getDatatypes.m" "UCIT_getMetaData.m" "UCIT_getMetaData_grid.m"
 * "UCIT_getMetaData_transect.m" "UCIT_getSandBalance.m"
 * "UCIT_getSandBalance_test_exclude.m" "UCIT_plotSandbalance.m"
 * "readLidarDataNetcdf.m" "UCIT_CompXYLim.m" "UCIT_WS_getCrossSection.m"
 * "UCIT_WS_polydraw.m" "UCIT_ZoomInOutPan.m" "UCIT_findAllObjectsOnToken.m"
 * "UCIT_focusOn_Window.m" "UCIT_getPlot.m" "UCIT_getPlotPosition.m"
 * "UCIT_parseStringOnToken.m" "UCIT_plotFilteredTransectContours.m"
 * "UCIT_plotGrid.m" "UCIT_plotLandboundary.m" "UCIT_plotTransectContours.m"
 * "UCIT_prepareFigureN.m" "UCIT_selectGridPoly.m" "UCIT_selectObject.m"
 * "Im2Ico.m" "-a" "..\..\io\netcdf\toolsUI-4.1.jar" 
 */
#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_ucit_netcdf_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifndef LIB_ucit_netcdf_C_API
#define LIB_ucit_netcdf_C_API /* No special import/export declaration */
#endif

LIB_ucit_netcdf_C_API 
bool MW_CALL_CONV ucit_netcdfInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst, 
                                                     &__MCC_ucit_netcdf_component_data, 
                                                     true, NoObjectType, ExeTarget, 
                                                     error_handler, print_handler, 
                                                     19844091, NULL))
    return false;
  return true;
}

LIB_ucit_netcdf_C_API 
bool MW_CALL_CONV ucit_netcdfInitialize(void)
{
  return ucit_netcdfInitializeWithHandlers(mclDefaultErrorHandler, 
                                           mclDefaultPrintHandler);
}
LIB_ucit_netcdf_C_API 
void MW_CALL_CONV ucit_netcdfTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_ucit_netcdf_component_data.path_to_component = path_to_component; 
  if (!ucit_netcdfInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "ucit_netcdf", 0);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  ucit_netcdfTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_ucit_netcdf_component_data.runtime_options, 
    __MCC_ucit_netcdf_component_data.runtime_option_count))
    return 0;

  return mclRunMain(run_main, argc, argv);
}
