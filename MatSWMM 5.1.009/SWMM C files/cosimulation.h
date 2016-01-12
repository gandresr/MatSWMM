//-------------------------------------------------------------------------------------
//  cosimulation.h
//	(Universidad de los Andes - GIAP)
//
//   Project:  MatSWMM 2
//   Author:   Gerardo Riano-Briceno
//	 Visit us: http://giap.uniandes.edu.co
//
//	 Constants and functions used by cosimulation.c
//--------------------------------------------------------------------------------------

//=============================================================================
//    UNIT CONVERTION - For units in SI
//=============================================================================

#define LEN(x) sizeof(x)/sizeof(x[0])
#define GTRTHANZERO(x) x > 0 ? TRUE : FALSE

/************* ERROR CONSTANTS *************/
enum ErrorConstants {
	C_ERROR_PATH = -300,
	C_ERROR_ATR,
	C_ERROR_TYPE,
	C_ERROR_NFOUND,
	C_ERROR_INCOHERENT,
	C_ERROR_IS_NUMERIC,
	C_ERROR_NRUNNING,
	C_ERROR_NOVER
};

enum SubcatchProperties {
	C_GAGE,
	C_OUTNODE,
	C_OUTSUBCATCH,
	C_INFIL,
	C_WIDTH,
	C_AREA,
	C_FRACIMPERV,
	C_SLOPE,
	C_CURBLENGTH,
	C_INITBUILDUP,
	C_LID
};

enum NodeProperties {
	C_INVERTELEV,
	C_INITDEPTH,
	C_FULLDEPTH,
	C_SURDEPTH,
	C_PONDEDAREA,
	C_DEGREE,
	C_CROWNELEV,
	C_LOSSES,
	C_FULLVOLUME
};

enum LinkProperties {
	C_NODE1,
	C_NODE2,
	C_OFFSET1,
	C_OFFSET2,
	C_XSECT,
	C_Q0,
	C_QLIMIT,
	C_CLOSSINLET,
	C_CLOSSOUTLET,
	C_CLOSSAVG,
	C_SEEPRATE,
	C_HASFLAPGATE,
	C_SURFAREA1,
	C_SURFAREA2,
	C_QFULL,
	C_SETTING,
	C_FROUDE,
	C_FLOWCLASS,
	C_DQDH,
	C_DIRECTION
};

enum PumpSubProperties {
	C_INITSETTING,
	C_YON,
	C_YOFF,
	C_XMIN,
	C_XMAX
};

enum OrificeSubProperties {
	C_SHAPE,
	C_CDISCH,
	C_ORATE,
	C_CORIF,
	C_HCRIT,
	C_CWEIR,
	C_LENGTH,
	C_SURFAREA
};

enum WeirSubProperties {
	C_CDISCH1,
	C_CDISCH2,
	C_ENDCON,
	C_CANSURCHARGE,
	C_CSURCHARGE,
	C_LENGTH,
	C_SLOPE,
	C_SURFAREA
};

enum OutletSubProperties {
	C_QCOEFF,
	C_QEXPON,
	C_QCURVE,
	C_CURVETYPE
};

//=============================================================================
//    Cosimulation functions
//=============================================================================

// Getters
double c_get( char* id, int attribute, int units );
// Setters
int  c_modify_setting(char* id, double new_setting, double tstep);
// Aux
int c_in_list(char** list, char* key);
// Savers
int c_saveResults();

int get_nobjects();
int get_nperiods();