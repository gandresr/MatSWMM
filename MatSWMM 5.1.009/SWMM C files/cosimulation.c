//-------------------------------------------------------------------------------------
//   cosimulation.c
//	(Universidad de los Andes - GIAP)
//
//   Project:  MatSWMM 2
//   Author:   Gerardo Riano-Briceno
//	 Visit us: http://giap.uniandes.edu.co
//
//	 This is an additional module with basic functions to compute cosimulation
//	 processes with SWMM. The main goal of this module is to allow its users to
//	 design optimization models and real time control systems, for drainage systems.
//
//--------------------------------------------------------------------------------------
#include "headers.h" // It is used because some of the functions developed for SWMM are re-used.
#include "cosimulation.h"

#include <string.h>
#include <math.h>
#include <time.h>

//-----------------------------------------------------------------------------
//  Imported variables
//-----------------------------------------------------------------------------
#define REAL4 float
extern REAL4* SubcatchResults;         // Results vectors defined in OUTPUT.C
extern REAL4* NodeResults;             //  "
extern REAL4* LinkResults;             //  "

//-----------------------------------------------------------------------------
//  Cosimulation global variables
//-----------------------------------------------------------------------------
double total_flooding;
// List of indexes in Nodes[] for each subtype of NODE
int idxOutfall[Nnodes[OUTFALL]];
int idxStorage[Nnodes[STORAGE]];
int idxDivider[Nnodes[DIVIDER]];
// List of indexes in Nodes[] for each subtype of LINK
int idxConduit[Nlinks[CONDUIT]];
int idxPump[Nlinks[PUMP]];
int idxOrifice[Nlinks[ORIFICE]];
int idxWeir[Nlinks[WEIR]];
int idxOutlet[Nlinks[OUTLET]];
// List of IDs per type
char ** nodesIDs, linksIDs, subcatchIDs;
int typesInitialized[3] = {0, 0, 0};
// List of IDs per sub-category
char ** outfallIDs, storageIDs, dividerIDs;
int nodeTypesInitialized[3] = {/* Outfall */0, /* Storage */0, /* Divider */0};
char ** conduitIDs, pumpIDs, orificeIDs, weirIDs, outletIDs;
int linkTypesInitialized[5] = {/* Conduit */0, /* Pump */0, /* Orifice */0, /* Weir */0, /* Outlet */0};

/****************************************************************************
 *
 * Cosimulation functions
 *
 ****************************************************************************/

/**
 * Inputs:
 *     swmmType: constant that represents the type of object.
 *     swmmSubType: constant that represents the sub-type of certain type
 *         of objects. It is equal to -1 if no sub-type is requested.
 * Purpose: It returns the number objects of certain type and/or sub-type.
 * Outputs: number of objects, C_ERROR_ATR if there is an error.
 */
int c_get_nobjects(int swmmType, int swmmSubType) {
	if (swmmType == SUBCATCH) {
		return Nobjects[SUBCATCH];
	} else if (swmmType == NODE) {
		if (swmmSubType == -1) return Nobjects[NODE];
		else if (swmmSubType == JUNCTION) return Nnodes[JUNCTION];
		else if (swmmSubType == OUTFALL) return Nnodes[OUTFALL];
		else if (swmmSubType == STORAGE) return Nnodes[STORAGE];
		else if (swmmSubType == DIVIDER) return Nnodes[DIVIDER];
	} else if (swmmType == LINK) {
		if (swmmSubType == -1) return Nobjects[NODE];
		else if (swmmSubType == CONDUIT) return Nlinks[CONDUIT];
		else if (swmmSubType == PUMP) return Nlinks[PUMP];
		else if (swmmSubType == ORIFICE) return Nlinks[ORIFICE];
		else if (swmmSubType == WEIR) return Nlinks[WEIR];
		else if (swmmSubType == OUTLET) return Nlinks[OUTLET];
	}
	return C_ERROR_ATR;
}

/**
 * Inputs: None
 * Purpose: It saves the indexes related to the objects with
 * sub-category in Node[] a Link[].
 * Outputs: None
 */
void c_store_ids() {
	int i, o, s, d, c, p, or, w, ot;
	o=0; s=0; d=0; c=0; p=0; or=0; w=0; ot=0;

	for (i = 0; i < Nobjects[NODE]; i++) {
		if (Node[i].type == OUTFALL) idxOutfall[o++] = i;
		else if (Node[i].type == STORAGE) idxStorage[s++] = i;
		else if (Node[i].type == DIVIDER) idxDivider[d++] = i;
	}

	for (i = 0; i < Nobjects[LINK]; i++) {
		if (Link[i].type == CONDUIT) idxConduit[c++] = i;
		else if (Link[i].type == PUMP) idxPump[p++] = i;
		else if (Link[i].type == ORIFICE) idxOrifice[or++] = i;
		else if (Link[i].type == WEIR) idxWeir[w++] = i;
		else if (Link[i].type == OUTLET) idxOutlet[ot++] = i;
	}
}

/**
 * Inputs:
 *     idsPtr: array of pointers to strings with IDs
 *     swmmType: constant that represents the type of object.
 *     swmmSubType: constant that represents the sub-type of certain type
 *         of objects. It is equal to -1 if no sub-type is requested.
 * Purpose: It fills the array of pointers looking all the objects of
 * an specific type and/or sub-category.
 * Outputs: None
 */
void c_get_all(char **idsPtr, int swmmType, int swmmSubType) {
	int i;
	int lenIdsPtr = c_get_nobjects(swmmType, swmmSubType);

	for(i = 0; i < lenIdsPtr; i++) {
		if (swmmType == NODE) {
			if (swmmSubType == -1 || swmmSubType == JUNCTION)
				if (typesInitialized[0]) {
					idsPtr = nodesIDs;
					break;
				}
				idsPtr[i] = Node[i].id;
				if (i == 0) {
					nodesIDs = idsPtr;
					typesInitialized[0] = 1;
				}
			}
			else if (swmmSubType == OUTFALL) {
				if (nodeTypesInitialized[0]) {
					idsPtr = outfallIDs;
					break;
				}
				idsPtr[i] = Node[idxOutfall[i]].id;
				if (i == 0) {
					outfallIDs = idsPtr;
					nodeTypesInitialized[0] = 1;
				}
			}
			else if (swmmSubType == STORAGE) {
				if (nodeTypesInitialized[1]) {
					idsPtr = storageIDs;
					break;
				}
				idsPtr[i] = Node[idxStorage[i]].id;
				if (i == 0) {
					storageIDs = idsPtr;
					nodeTypesInitialized[1] = 1;
				}
			}
			else if (swmmSubType == DIVIDER) {
				if (nodeTypesInitialized[2]) {
					idsPtr = dividerIDs;
					break;
				}
				idsPtr[i] = Node[idxDivider[i]].id;
				if (i == 0) {
					dividerIDs = idsPtr;
					nodeTypesInitialized[2] = 1;
				}
			}
		} else if (swmmType == LINK) {
			if (swmmSubType == -1) {
				if (typesInitialized[1]) {
					idsPtr = linksIDs;
					break;
				}
				idsPtr[i] = Link[i].id;
				if (i == 0) {
					linksIDs = idsPtr;
					typesInitialized[1] = 1;
				}
			} else if (swmmSubType == CONDUIT) {
				if (linkTypesInitialized[0]) {
					idsPtr = conduitIDs;
					break;
				}
				idsPtr[i] = Link[idxConduit[i]].id;
				if (i == 0) {
					conduitIDs = idsPtr;
					linkTypesInitialized[0] = 1;
				}
			} else if (swmmSubType == PUMP) {
				if (linkTypesInitialized[1]) {
					idsPtr = pumpIDs;
					break;
				}
				idsPtr[i] = Link[idxPump[i]].id;
				if (i == 0) {
					pumpIDs = idsPtr;
					linkTypesInitialized[1] = 1;
				}
			} else if (swmmSubType == ORIFICE) {
				if (linkTypesInitialized[2]) {
					idsPtr = orificeIDs;
					break;
				}
				idsPtr[i] = Link[idxOrifice[i]].id;
				if (i == 0) {
					orificeIDs = idsPtr;
					linkTypesInitialized[2] = 1;
				}
			} else if (swmmSubType == WEIR) {
				if (linkTypesInitialized[3]) {
					idsPtr = weirIDs;
					break;
				}
				idsPtr[i] = Link[idxWeir[i]].id;
				if (i == 0) {
					weirIDs = idsPtr;
					linkTypesInitialized[3] = 1;
				}
			} else if (swmmSubType == OUTLET) {
				if (linkTypesInitialized[4]) {
					idsPtr = outletIDs;
					break;
				}
				idsPtr[i] = Link[idxOutlet[i]].id;
				if (i == 0) {
					outletIDs = idsPtr;
					linkTypesInitialized[4] = 1;
				}
			}
		} else if (swmmType == SUBCATCH) {
			if (typesInitialized[2]) {
				idsPtr = subcatchIDs;
				break;
			}
			idsPtr[i] = Subcatch[i].id;
			if (i == 0) {
				subcatchIDs = idsPtr;
				typesInitialized[2] = 1;
			}
		}
	}
}

/*
 * Inputs:
 * Purpose:
 * Output:
 */
int c_get(char **idsPtr, double *valuesPtr, int swmmProp, int swmmType, int swmmSubType)
{


	return C_ERROR_NFOUND; /*Object not found*/
}

/*
 * Inputs: None
 * Purpose: Save the results at the end of the simulation of all the objects
 	The results are saved in three folders:
 		Subcatchments       Nodes          Links
 		- Rainfall          - Inflow       - Flow
 		- Evap              - Overflow     - Velocity
 		- Infiltration      - Depth        - Depth
 		- Runoff            - Head         - Capacity
							- Volume
 * Outputs: None
 */
int c_saveResults()
{
	int period, j;
	FILE* temporal;
	FILE* temp_time;
	char path[25];
	char* extention = ".csv";
	char s[30];
	long time_val = 0;
	mkdir("Subcatchments", "w");
	mkdir("Links", "w");
	mkdir("Nodes", "w");
	mkdir("Time", "w");

	temp_time = fopen("Time/time.txt", "w");
	fprintf(temp_time, "%d,%d\n", ReportStep, Nperiods);
	fclose(temp_time);

	for ( j = 0; j < Nobjects[SUBCATCH]; j++ ) {
		/* File path writing */
		strcpy(path, "Subcatchments/");
		strcat(path, Subcatch[j].ID);
		strcat(path, extention);

		temporal = fopen(path, "w");

		for ( period = 1; period <= Nperiods; period++ ) {
		    output_readSubcatchResults(period, j);
		    fprintf(temporal, "%10.3f,%10.3f,%10.4f\n",
		        SubcatchResults[SUBCATCH_RAINFALL],
		        SubcatchResults[SUBCATCH_EVAP]/24.0 +
		        SubcatchResults[SUBCATCH_INFIL],
		        SubcatchResults[SUBCATCH_RUNOFF]);
		}
		fclose(temporal);
	}
	for ( j = 0; j < Nobjects[LINK]; j++ ) {
		/* File path writing */
		strcpy(path, "Links/");
		strcat(path, Link[j].ID);
		strcat(path, extention);

		temporal = fopen(path, "w");

		for ( period = 1; period <= Nperiods; period++ ) {
		    output_readLinkResults(period, j);
			fprintf(temporal, "%9.3f,%9.3f,%9.3f,%9.3f,%9.3f\n",
			    LinkResults[LINK_FLOW],
			    LinkResults[LINK_VELOCITY],
				LinkResults[LINK_DEPTH],
				LinkResults[LINK_VOLUME],
			    LinkResults[LINK_CAPACITY]);
		}
		fclose(temporal);
	}
	for ( j = 0; j < Nobjects[NODE]; j++ ) {
		/* File path writing */
		strcpy(path, "Nodes/");
		strcat(path, Node[j].ID);
		strcat(path, extention);

		temporal = fopen(path, "w");

		for ( period = 1; period <= Nperiods; period++ ) {
		    output_readNodeResults(period, j);
		    fprintf(temporal, "%9.3f,%9.3f,%9.3f,%9.3f,%9.3f\n",
		        NodeResults[NODE_INFLOW],
		        NodeResults[NODE_OVERFLOW],
				NodeResults[NODE_DEPTH],
				NodeResults[NODE_VOLUME]);
		}
		fclose(temporal);
	}
	return Nperiods;
}



/*
 * Inputs:  id 			(str)	 -> ID of the setting
 			new_setting (double) -> New value of the setting, decimal percentage.
 			tstep		(double) -> Time in seconds over which setting is adjusted.
 									0.0 means that the orifice is adjusted automatically.
 * Purpose: For the time being, this can only modify the setting of orifices.
  			The setting can only be modified in the case of links.
 * Outputs: Returns error code if there is an error.
 * Notes: 	[IT MUST BE USED WHILE A SIMULATION IS RUNNING]
 * Time Complexity: O(n)
 */
int  c_modify_setting(char* id, double new_setting, double tstep)
{
	int j = project_findObject(LINK, id); // Index for the object being sought in the hash table.

	if(j < 0)
		return C_ERROR_NFOUND; /* Invalid object or object does not exist*/
	else if((new_setting<0) || (new_setting>1))
		return C_ERROR_INCOHERENT; /* Incoherent setting value */

	Link[j].targetSetting = new_setting;
	link_setSetting(j, tstep);

	return 0; /* Success */
}


/* Inputs: list (char **) -> Array of strings. The last element in the list is NULL.
		   key  (char  *) -> String.
 * Output: -1 if the string was not found otherwise return the position index.
 * Purpose: It determines if a string belongs to an array of strings and re
 */
int c_in_list(char* list[], char* key){
	int i = 0;
	while(list[i] != NULL){
		if(strncmp( list[i], key, strlen(list[i]) ) == 0) return i;
		i++;
	}
	return -1;
}