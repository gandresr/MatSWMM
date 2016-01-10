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
/* Results vectors defined in OUTPUT.C */
extern REAL4* SubcatchResults;
extern REAL4* NodeResults;
extern REAL4* LinkResults;

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
	int i, lenIdsPtr;
	lenIdsPtr = c_get_nobjects(swmmType, swmmSubType);

	for(i = 0; i < lenIdsPtr; i++) {
		if (swmmType == NODE) {
			if (swmmSubType == -1 || swmmSubType == JUNCTION) {
				idsPtr[i] = Node[i].id;
			} else if (swmmSubType == OUTFALL) {
				idsPtr[i] = Node[idxOutfall[i]].id;
			} else if (swmmSubType == STORAGE) {
				idsPtr[i] = Node[idxStorage[i]].id;
			} else if (swmmSubType == DIVIDER) {
				idsPtr[i] = Node[idxDivider[i]].id;
			}
		} else if (swmmType == LINK) {
				idsPtr[i] = Link[i].id;
			} else if (swmmSubType == CONDUIT) {
				idsPtr[i] = Link[idxConduit[i]].id;
			} else if (swmmSubType == PUMP) {
				idsPtr[i] = Link[idxPump[i]].id;
			} else if (swmmSubType == ORIFICE) {
				idsPtr[i] = Link[idxOrifice[i]].id;
			} else if (swmmSubType == WEIR) {
				idsPtr[i] = Link[idxWeir[i]].id;
			} else if (swmmSubType == OUTLET) {
				idsPtr[i] = Link[idxOutlet[i]].id;
			}
		} else if (swmmType == SUBCATCH) {
			idsPtr[i] = Subcatch[i].id;
		}
	}
}

/*
 * Inputs:
 * Purpose:
 * Output:
 */
int c_get(char **idsPtr, int lenIdsPtr, double *valuesPtr,
	int swmmProp, int swmmType, int swmmSubType, int units, int t) {
	// TODO - Convert units, define conversion factor
	int i, j, k;
	// Weighting time factor
    double f = (reportTime - OldRoutingTime) / (NewRoutingTime - OldRoutingTime);

	for (i = 0; i < lenIdsPtr; i++) {
		if (IsOpenFlag) {
			if (swmmType == SUBCATCH) {
				j = project_findObject(SUBCATCH, idsPtr[i]);
				if(j < 0) return C_ERROR_NFOUND;

				if (t == -1) subcatch_getResults(j, f, SubcatchResults);
				else output_readSubcatchResults(t, j);

				/* Results */
				if (swmmProp == SUBCATCH_RAINFALL) {
					valuesPtr[i] = SubcatchResults[SUBCATCH_RAINFALL];
				} else if (swmmProp == SUBCATCH_SNOWDEPTH) {
					valuesPtr[i] = SubcatchResults[SUBCATCH_SNOWDEPTH];
				} else if (swmmProp == SUBCATCH_EVAP) {
					valuesPtr[i] = SubcatchResults[SUBCATCH_EVAP];
				} else if (swmmProp == SUBCATCH_INFIL) {
					valuesPtr[i] = SubcatchResults[SUBCATCH_INFIL];
				} else if (swmmProp == SUBCATCH_RUNOFF) {
					valuesPtr[i] = SubcatchResults[SUBCATCH_RUNOFF];
				} else if (swmmProp == SUBCATCH_WASHOFF) {
					// TODO - Handle Qual!!
					return C_ERROR_ATR;
				/* Properties */
				} else if (swmmProp == C_GAGE) {
					valuesPtr[i] = Subcatch[j].gage;
				} else if (swmmProp == C_OUTNODE) {
					valuesPtr[i] = Subcatch[j].outNode;
				} else if (swmmProp == C_OUTSUBCATCH) {
					valuesPtr[i] = Subcatch[j].outSubcatch;
				} else if (swmmProp == C_INFIL) {
					valuesPtr[i] = Subcatch[j].infil;
				} else if (swmmProp == C_WIDTH) {
					valuesPtr[i] = Subcatch[j].width;
				} else if (swmmProp == C_AREA) {
					valuesPtr[i] = Subcatch[j].area;
				} else if (swmmProp == C_FRACIMPERV) {
					valuesPtr[i] = Subcatch[j].fracImperv;
				} else if (swmmProp == C_SLOPE) {
					valuesPtr[i] = Subcatch[j].slope;
				} else if (swmmProp == C_CURBLENGTH) {
					valuesPtr[i] = Subcatch[j].curbLength;
				} else if (swmmProp == C_INITBUILDUP) {
					valuesPtr[i] = Subcatch[j].initBuildup;
				} else if (swmmProp == C_LIDAREA) {
					valuesPtr[i] = Subcatch[j].lidArea;
				} else {
					return C_ERROR_ATR;
				}
			} else if (swmmType == NODE) {
				j =	project_findObject(NODE, idsPtr[i]);
				if(j < 0) return C_ERROR_NFOUND;

				if (t == -1) node_getResults(j, f, NodeResults);
				else output_readNodeResults(t, j);

				/* Results */
				if (swmmProp == NODE_DEPTH) {
					valuesPtr[i] = NodeResults[NODE_DEPTH];
				} else if (swmmProp == NODE_HEAD) {
					valuesPtr[i] = NodeResults[NODE_HEAD];
				} else if (swmmProp == NODE_VOLUME) {
					valuesPtr[i] = NodeResults[NODE_VOLUME];
				} else if (swmmProp == NODE_LATFLOW) {
					valuesPtr[i] = NodeResults[NODE_LATFLOW];
				} else if (swmmProp == NODE_INFLOW) {
					valuesPtr[i] = NodeResults[NODE_INFLOW];
				} else if (swmmProp == NODE_OVERFLOW) {
					valuesPtr[i] = NodeResults[NODE_OVERFLOW];
				} else if (swmmProp == NODE_QUAL) {
					// TODO - Handle Qual!!
					return C_ERROR_ATR;
				/* Properties */
				} else if (swmmProp == C_INVERTELEV) {
					valuesPtr[i] = Node[j].invertElev;
				} else if (swmmProp == C_INITDEPTH) {
					valuesPtr[i] = Node[j].initDepth;
				} else if (swmmProp == C_FULLDEPTH) {
					valuesPtr[i] = Node[j].fullDepth;
				} else if (swmmProp == C_SURDEPTH) {
					valuesPtr[i] = Node[j].surDepth;
				} else if (swmmProp == C_PONDEDAREA) {
					valuesPtr[i] = Node[j].pondedArea;
				} else if (swmmProp == C_DEGREE) {
					valuesPtr[i] = Node[j].degree;
				} else if (swmmProp == C_CROWNELEV) {
					valuesPtr[i] = Node[j].crownElev;
				} else if (swmmProp == C_LOSSES) {
					valuesPtr[i] = Node[j].losses;
				} else if (swmmProp == C_FULLVOLUME) {
					valuesPtr[i] = Node[j].fullVolume;
				}  else {
					return C_ERROR_ATR;
				}
			} else if (swmmType == LINK) {
				j =	project_findObject(LINK, idsPtr[i]);
				if(j < 0) return C_ERROR_NFOUND;

				if (t == -1) link_getResults(j, f, LinkResults);
				else output_readLinkResults(t, j);

				/* Results */
				if (swmmProp == LINK_FLOW) {
					valuesPtr[i] = LinkResults[LINK_FLOW];
				} else if (swmmProp == LINK_DEPTH) {
					valuesPtr[i] = LinkResults[LINK_DEPTH];
				} else if (swmmProp == LINK_VELOCITY) {
					valuesPtr[i] = LinkResults[LINK_VELOCITY];
				} else if (swmmProp == LINK_VOLUME) {
					valuesPtr[i] = LinkResults[LINK_VOLUME];
				} else if (swmmProp == LINK_CAPACITY) {
					valuesPtr[i] = LinkResults[LINK_CAPACITY];
				} else if (swmmProp == LINK_QUAL) {
					// TODO - Handle Qual!!
					return C_ERROR_ATR;
				/* Properties */
				} else if (swmmProp == C_NODE1) {
					valuesPtr[i] = Link[j].node1;
				} else if (swmmProp == C_NODE2) {
					valuesPtr[i] = Link[j].node2;
				} else if (swmmProp == C_OFFSET1) {
					valuesPtr[i] = Link[j].offset1;
				} else if (swmmProp == C_OFFSET2) {
					valuesPtr[i] = Link[j].offset2;
				} else if (swmmProp == C_XSECT) {
					/* TODO - Handle Xsect */
					return C_ERROR_ATR;
				} else if (swmmProp == C_Q0) {
					valuesPtr[i] = Link[j].q0;
				} else if (swmmProp == C_QLIMIT) {
					valuesPtr[i] = Link[j].qLimit;
				} else if (swmmProp == C_CLOSSINLET) {
					valuesPtr[i] = Link[j].clossInlet;
				} else if (swmmProp == C_CLOSSOUTLET) {
					valuesPtr[i] = Link[j].clossOutlet;
				} else if (swmmProp == C_CLOSSAVG) {
					valuesPtr[i] = Link[j].clossAvg;
				} else if (swmmProp == C_SEEPRATE) {
					valuesPtr[i] = Link[j].seepRate;
				} else if (swmmProp == C_HASFLAPGATE) {
					valuesPtr[i] = Link[j].hasFlapGate;
				} else if (swmmProp == C_SURFAREA1) {
					valuesPtr[i] = Link[j].surfArea1;
				} else if (swmmProp == C_SURFAREA2) {
					valuesPtr[i] = Link[j].surfArea2;
				} else if (swmmProp == C_QFULL) {
					valuesPtr[i] = Link[j].qFull;
				} else if (swmmProp == C_SETTING) {
					valuesPtr[i] = Link[j].setting;
				} else if (swmmProp == C_FROUDE) {
					valuesPtr[i] = Link[j].froude;
				} else if (swmmProp == C_FLOWCLASS) {
					valuesPtr[i] = Link[j].flowClass;
				} else if (swmmProp == C_DQDH) {
					valuesPtr[i] = Link[j].dqdh;
				} else if (swmmProp == C_DIRECTION) {
					valuesPtr[i] = Link[j].direction;
				/* Sub-properties */
				} else if (swmmSubType != CONDUIT) {
					k = Link[j].subIndex; // Index for sub-category
					if (swmmSubType == PUMP) {
						if (swmmProp == C_INITSETTING) {
							valuesPtr[i] = Pump[k].initSetting;
						} else if (swmmProp == C_YON) {
							valuesPtr[i] = Pump[k].yOn;
						} else if (swmmProp == C_YOFF) {
							valuesPtr[i] = Pump[k].yOff;
						} else if (swmmProp == C_XMIN) {
							valuesPtr[i] = Pump[k].xMin;
						} else if (swmmProp == C_XMAX) {
							valuesPtr[i] = Pump[k].xMax;
						}
					} else if (swmmSubType == ΟRIFICE) {
						if (swmmProp == C_SHAPE) {
							valuesPtr[i] = Orifice[k].shape;
						} else if (swmmProp == C_CDISCH) {
							valuesPtr[i] = Orifice[k].cDisch;
						} else if (swmmProp == C_ORATE) {
							valuesPtr[i] = Orifice[k].orate;
						} else if (swmmProp == C_CORIF) {
							valuesPtr[i] = Orifice[k].cOrif;
						} else if (swmmProp == C_HCRIT) {
							valuesPtr[i] = Orifice[k].hCrit;
						} else if (swmmProp == C_CWEIR) {
							valuesPtr[i] = Orifice[k].cWeir;
						} else if (swmmProp == C_LENGTH) {
							valuesPtr[i] = Orifice[k].length;
						} else if (swmmProp == C_SURFAREA) {
							valuesPtr[i] = Orifice[k].surfArea;
						}
					} else if (swmmSubType == WEIR) {
						if (swmmProp == C_CDISCH1) {
							valuesPtr[i] = Weir[k].cDisch1;
						} else if (swmmProp == C_CDISCH2) {
							valuesPtr[i] = Weir[k].cDisch2;
						} else if (swmmProp == C_ENDCON) {
							valuesPtr[i] = Weir[k].endCon;
						} else if (swmmProp == C_CANSURCHARGE) {
							valuesPtr[i] = Weir[k].canSurcharge;
						} else if (swmmProp == C_CSURCHARGE) {
							valuesPtr[i] = Weir[k].cSurcharge;
						} else if (swmmProp == C_LENGTH) {
							valuesPtr[i] = Weir[k].length;
						} else if (swmmProp == C_SLOPE) {
							valuesPtr[i] = Weir[k].slope;
						} else if (swmmProp == C_SURFAREA) {
							valuesPtr[i] = Weir[k].surfArea;
						}
					} else if (swmmSubType == OUTLET) {
						if (swmmProp == C_QCOEFF) {
							valuesPtr[i] = Outlet[k].qCoeff;
						} else if (swmmProp == C_QEXPON) {
							valuesPtr[i] = Outlet[k].qExpon;
						} else if (swmmProp == C_QCURVE) {
							valuesPtr[i] = Outlet[k].qCurve;
						} else if (swmmProp == C_CURVETYPE) {
							valuesPtr[i] = Outlet[k].curveType;
						}
					} else {
						return C_ERROR_ATR;
					}
				} else {
					return C_ERROR_ATR;
				}
			} else {
				return C_ERROR_ATR;
			}
		} else {
			return C_ERROR_NRUNNING;
		}
	}
	return 0;
}

int c_get_results(char **idsPtr, int lenIdsPtr, double ** valuesPtrPtr,
	int swmmProp, int swmmType, int swmmSubType, int units) {

	int period, error;
	double valuesPtr[lenIdsPtr]; // Rows

	if (IsOpenFlag && !IsStartedFlag) {
		for ( period = 0; period <= Nperiods; period++ ) {
			error = c_get(idsPtr, lenIdsPtr, valuesPtr, swmmProp, swmmType, swmmSubType, units, period);
			if (error != 0) return error;

			valuesPtrPtr[period] = valuesPtr;
		}
	} else return C_ERROR_NOVER;

	return 0;
}

int c_set(char **idsPtr, int lenIdsPtr, double * valuesPtr,
	int swmmProp, int swmmType, int swmmSubType, int units) {
// TODO - documentation

	int j, k;

	if (swmmType == LINK) {
		j = project_findObject(LINK, id);
		if(j < 0) return C_ERROR_NFOUND;
		for (i = 0; i < lenIdsPtr; i++) {
			if (swmmProp == C_SETTING) {
				Link[j].targetSetting = valuesPtr[i];
				link_setSetting(j, 0);
			} else if (swmmType == CONDUIT) {
				k = Link[j].subIndex;
				if (swmmProp == LENGTH) {
					Conduit[k].length    = valuesPtr[j] / UCF(LENGTH);
					Conduit[k].modLength = Conduit[k].length;
				} else if (swmmProp == C_ROUGHNESS)
				Conduit[k].roughness = valuesPtr[j];
				Link[j].offset1      = valuesPtr[j] / UCF(LENGTH);
				Link[j].offset2      = valuesPtr[j] / UCF(LENGTH);
				Link[j].q0           = valuesPtr[j] / UCF(FLOW);
				Link[j].qLimit       = valuesPtr[j] / UCF(FLOW);
			} else if (swmmType == ) {
			} else if (swmmType == ) {
			} else if (swmmType == ) {
			} else if (swmmType == ) {
		}
	} else {
		return C_ERROR_ATR;
	}

	return 0;
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