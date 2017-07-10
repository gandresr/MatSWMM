//-------------------------------------------------------------------------------------
//   cosimulation.h
//	(Universidad de los Andes - GIAP)
//
//   Project:  SWMM 5.1 Cosimulation Toolbox
//   Version:  0.0.1
//   Date:     06/08/14
//   Author:   Gerardo Riano Briceno
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
#define LEN 1024
#define MIN_LEN 512


/************* ERROR CONSTANTS *************/
enum ErrorConstants{
	C_ERROR_PATH = -300,
	C_ERROR_ATR,
	C_ERROR_TYPE,
	C_ERROR_NFOUND,
	C_ERROR_INCOHERENT,
	C_ERROR_IS_NUMERIC,
};

/*******************************************
 * Attribute constants - The C prefix is to
 * differentiate the variable as one
 * of the cosimulation module
 *******************************************/
enum Aconstants{
	C_DEPTH = 200,		// [LINK] [NODE]
	C_VOLUME,			// [LINK] [NODE]
	C_FLOW,				// [LINK] [NODE]
	C_SETTING,			// [LINK]
	C_FROUDE,			// [LINK]
	C_INFLOW,			// [NODE]
	C_FLOODING,			// [NODE]
	C_PRECIPITATION,	// [SUBCATCHMENT]
	C_RUNOFF,			// [SUBCATCHMENT]
	C_LINK_AREA, 		// [LINK]
};

 /*******************************************
 * Input file constants - Constants used to c
 * modify variables from the input file
 *******************************************/
enum InputFileConstants{
	C_INVERT = 400,		// [NODE]
	C_DEPTH_SIZE,		// [LINK] [NODE] 401
	C_STORAGE_A,		// [NODE] 402
	C_STORAGE_B,		// [NODE] 403
	C_STORAGE_C,		// [NODE] 404
	C_LENGTH,			// [LINK] 405
	C_ROUGHNESS,		// [LINK] 406
	C_IN_OFFSET,		// [LINK] 407
	C_OUT_OFFSET,		// [LINK] 408
	C_AREA,				// [SUBCATCHMENTS] 409
	C_IMPERV,			// [SUBCATCHMENTS] 410
	C_WIDTH,			// [SUBCATCHMENTS] 411
	C_SLOPE,			// [SUBCATCHMENTS] 412
	C_OUTLET,			// [SUBCATCHMENTS] 413
	C_ORIFICE,			// [LINK] 414
	C_FROM_NODE,		// [LINK] 415
	C_TO_NODE = 416,	// [LINK] 416
	C_STORAGE = 4,		// [SUBCATCHMENTS] 4
	C_OUTFALL = 417,	// [NODE] 417
	C_WIDTH_SIZE		// [LINK] 418
};

 /*******************************************
 * Struct with positioning info of a variable
 * in the input file.
 *******************************************/

typedef struct
{
	int column;
	char* key;
	int isNumeric;
} InputInfo;

//=============================================================================
//    Cosimulation functions
//=============================================================================

// Getters
double c_get( char* id, int attribute, int units );
double c_get_from_input(char* input_file, char *id, int attribute);
int c_look4all(char* input_file, int object_type, int attribute);
// Setters
int  c_modify_setting(char* id, double new_setting, double tstep);
int c_modify_input_value(char* filename, char *id, int attribute, double value);
// Aux (parsers)
int c_look4inputID(FILE** input_file, int* object_type, char* line, char* id);
int c_get_key_column(InputInfo* new_i, int object_type, int attribute);
int c_in_list(char** list, char* key);
// Savers
int c_saveResults();