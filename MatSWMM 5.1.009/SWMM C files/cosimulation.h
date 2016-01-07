//-------------------------------------------------------------------------------------
//   cosimulation.h
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

#define CFTOCM(m) m*0.0283168466
#define FT2TOM2(m) m*0.09290304
#define FTTOM(m) m*0.3048
#define FTPERSTOMMPERHR(m) m*304.8*3600
#define LEN(x) sizeof(x)/sizeof(x[0])

/************* ERROR CONSTANTS *************/
enum ErrorConstants{
	C_ERROR_PATH = -300,
	C_ERROR_ATR,
	C_ERROR_TYPE,
	C_ERROR_NFOUND,
	C_ERROR_INCOHERENT,
	C_ERROR_IS_NUMERIC,
	C_ERROR_NRUNNING,
	C_ERROR_NOVER


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