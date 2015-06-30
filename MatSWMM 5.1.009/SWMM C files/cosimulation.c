//-------------------------------------------------------------------------------------
//   cosimulation.c
//	(Universidad de los Andes - GIAP)
//
//   Project:  SWMM 5.1 Cosimulation Toolbox
//   Version:  0.0.1
//   Date:     06/08/14
//   Author:   Gerardo Riano Briceno
//	 Visit us: http://giap.uniandes.edu.co
//
//	 This is an additional module with basic functions to compute cosimulation
//	 processes with SWMM. The main goal of this module is to allow its users to
//	 design optimization models and real time control systems, for drainage systems.
//
//--------------------------------------------------------------------------------------
#include "headers.h" // It is used because some of the functions developed for SWMM are re-used.
#include "cosimulation.h"

#include <malloc.h>
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

/****************************************************************************
 *
 * Cosimulation global variables and functions
 *
 ****************************************************************************/

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
 * Inputs: id        (str) -> ID of the object whose attribute is going to be retrieved.
   	       attribute (int) -> Attribute that needs to be known.
 		   units     (int) -> Unit system that must be used to calculate the attribute (SI/US).
 * Output: Value of the attribute (double) - If the attribute or the type are incoherent return negative value.
		   Returns error code if there is an error.
 * Purpose: Retrieves information of a specific object.
 * Notes: [IT MUST BE USED WHILE A SIMULATION IS RUNNING]
 */
double c_get( char* id, int attribute, int units )
{
	int j, i, type;
	int object_types[] = {NODE, LINK, SUBCATCH};
	int len = sizeof(object_types)/sizeof(object_types[0]);

	// Defines the type of the object and looks for the object
	for(i=0; i<len; i++)
	{
		j = project_findObject(object_types[i], id); // Index for the object being sought in the hash table.
		if( j>=0 )
		{
			type = object_types[i];
			break;
		}
	}

	// Do if the object was found
	if( j >= 0 )
	{
		switch(type)
		{
			case NODE:
				switch(attribute)
				{
					case C_DEPTH:
						if (units == SI) return FTTOM(Node[j].newDepth);
						else return Node[j].newDepth;
					case C_INFLOW:
						if (units == SI) return CFTOCM(Node[j].inflow);
						else return Node[j].inflow;
					case C_VOLUME:
						if (units == SI) return CFTOCM(Node[j].newVolume);
						else return Node[j].newVolume;
					case C_FLOODING:
						if (units == SI) return CFTOCM(Node[j].overflow);
						else return Node[j].overflow;
					default: return C_ERROR_ATR; /* Attribute not compatible */
				}
			case LINK:
				switch(attribute)
				{
					case C_FLOW:
						if (units == SI) return CFTOCM(Link[j].newFlow);
						else return Link[j].newFlow;
					case C_DEPTH:
						if (units == SI) return FTTOM(Link[j].newDepth);
						else return Link[j].newDepth;
					case C_VOLUME:
						if (units == SI) return CFTOCM(Link[j].newVolume);
						else return Link[j].newVolume;
					case C_FROUDE: return Link[j].froude;
					case C_SETTING: return Link[j].setting;
					case C_LINK_AREA:
						if (units == SI) return FT2TOM2(Link[j].xsect.aFull);
						else return Link[j].xsect.aFull;
					default: return C_ERROR_ATR; /* Attribute not compatible */
				}
			case SUBCATCH:
				switch(attribute)
				{
					case C_PRECIPITATION:
						if (units == SI) return FTPERSTOMMPERHR(Subcatch[j].rainfall);
						else return Subcatch[j].rainfall;
					case C_RUNOFF:
						if (units == SI) return CFTOCM(Subcatch[j].newRunoff);
						else return Subcatch[j].newRunoff;
					default: return C_ERROR_ATR; /* Attribute not compatible */
				}
			default: return C_ERROR_TYPE; /* Type of object not compatible */
		}
	}

	return C_ERROR_NFOUND; /*Object not found*/
}

/*
 * Inputs:  input_file 	(str)    -> Path to the input file.
 			id 			(str)    -> ID of the object that is going to be changed.
 			object_type (int)    -> Type of the object that is going to be changed.
 			attribute   (int)    -> Constant - Attribute that is going to be changed.
 			value       (double) -> Value of the attribute that is going to be changed.
 * Outputs: Returns error code if there is an error.
 * Purpose: It modifies a specific attribute from the input file.
 */
double c_get_from_input(char* input_file, char *id, int attribute)
{
	FILE* file = fopen(input_file, "r"); /* Read only */
	int i, res, object_type = -1;
	char line [ LEN ];
	double value;
	InputInfo positions;

	if ( file != NULL )
	{
		// Defines the type of object and seeks its position in the input file
		res = c_look4inputID(&file, &object_type, line, id);
		if (res != 0)
		{
			fclose(file);
			return res; /* Object not found */
		}
		// Defines the position of the attribute in the table of the input file
		res = c_get_key_column(&positions, object_type, attribute);
		if ((res != 0 ) || !positions.isNumeric)
		{
			fclose(file);
			if(!positions.isNumeric) return C_ERROR_IS_NUMERIC;
			return res; /* Attribute not found -*- Object_type not found */
		}

		// Searches the object attribute
		for(i=1; i != positions.column; i++)
			fscanf(file, "%s ", line);

		// Retrieves the searched value
		fscanf(file, "%lf", &value);
		fclose ( file );

		return value; /*Succesful result*/

	}else{
		perror ( input_file );
		return C_ERROR_PATH; /* Incorrect path */
	}
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


/*
 * Inputs:  input_file 	(str)    -> Path to the input file.
 			id 			(str)    -> ID of the object that is going to be changed.
 			attribute   (int)    -> Constant - Attribute that is going to be changed.
 			value       (double) -> Value of the attribute that is going to be changed.
 * Purpose: It modifies a specific attribute from the input file.
 * Outputs: Returns error code if there is an error.
 * Time Complexity: O(n)
 */
int c_modify_input_value(char* input_file, char *id, int attribute, double value)
{
	FILE* file = fopen(input_file, "r+"); /* Read & overwrite */
	int object_type = -1;
	int i, res, leftover;
	char line [ LEN ];
	InputInfo positions;

	if ( file != NULL )
	{
		// Defines the type of object and seeks its position in the input file
		res = c_look4inputID(&file, &object_type, line, id);
		if (res != 0)
		{
			fclose(file);
			return res; /* Object not found */
		}

		// Defines the location of the variable in the table of the input file.
		res = c_get_key_column(&positions, object_type, attribute);
		if ((res != 0 ) || !positions.isNumeric)
		{
			fclose(file);
			if(!positions.isNumeric){
				return C_ERROR_IS_NUMERIC;
			}
			return res; /* Attribute not found -*- Object_type not found */
		}

		// Searches the object attribute
		for(i=1; i != positions.column; i++)
		{
			fscanf(file, "%s ", line);
		}

		// Overwrites the file
		fseek(file, 0, SEEK_CUR);
		if(attribute == C_ROUGHNESS)
			fprintf(file, "%.3f", value);
		else
			fprintf(file, "%.2f", value);
		fseek(file, 0 , SEEK_CUR);

		// Replaces leftover characters with blank space characters
		do{
			leftover = fgetc(file);
			fseek(file, -1 , SEEK_CUR);
			fprintf(file, "%s", " ");
			fseek(file, 0 , SEEK_CUR);
		}while (leftover != ' ');

		fclose ( file );

   }else{
		perror ( input_file ); /* File openning error */
   		return C_ERROR_PATH; /* Incorrect path */
   }

   return 0; /* Success! */
}



/*
 * Inputs:  input_file 	(str)    -> Path to the input file.
 			object_type (int)    -> Type of the objects that are going to be searched.
 			attribute   (int)    -> Constant - Attribute that is going to be searched.
 * Purpose: It writes a file with a simplified version of the input information.
			The new file is saved as "info.dat" -> it contains two or one colums of
			information. The first one is composed by the IDs of the objects related to
			the object_type. The second, is composed by the attribute information of each
			object, if an attribute is requested. Else if the attribute is not requested
			i.e. attribute == 1, then the file is going to be composed of a single column.
 * Output:  Returns the error code if there is an error.
 */
int c_look4all(char* input_file, int object_type, int attribute)
{
	FILE* file = fopen(input_file, "r"); //Input file
	FILE* persistent = fopen("info.dat", "w"); // Data file -> info.dat
	int res, i, k=0;
	char *token;
	char line[LEN];
	char variable_name[25];
	char variable_value[25];
	InputInfo positions; // Positioning struct

	if (file == NULL) return C_ERROR_PATH;

	// Retrieves table positioning variables
	res = c_get_key_column(&positions, object_type, attribute);
	if (res != 0 )
	{
		fclose(file);
		fclose(persistent);
		return res; /* Attribute not found -*- Object_type not found */
	}

	// Finds the section related to the object_type
	while( strncmp(line, positions.key, sizeof(positions.key)) != 0)
	{
		fscanf( file, "%s ", line);
		if(feof(file))
		{
			fclose(file);
			fclose(persistent);
			return C_ERROR_NFOUND;
		}
	}

// Write data file
	while(fgets(line, LEN, file) != NULL){

		if (strncmp(line,";", 1) == 0) continue;
		if (strncmp(line,"\n",1) == 0) continue;
		token = strtok(line, " ");

		// Verifies the end of the table
		if( strncmp(line, "[", 1) == 0 ) break;
		// Writes the data file
		while(token != NULL){
			if(positions.column != 0){
				fprintf(persistent, "%s ", token);
				while(k < positions.column){
					token = strtok(NULL, " ");
					k ++;
				}
				k = 0;
				fprintf(persistent, "%s\n", token);
				break;
			}
			else{
				fprintf(persistent, "%s\n", token);
				break;
			}
		}
	}

	// Close files Succesfully
	fclose(file);
	fclose(persistent);
	if (feof(file)) return C_ERROR_NFOUND;
	return 0;
}

/*
 * Inputs:  input_file 	(FILE**) -> Pointer to the input file.
 			object_type (int)    -> Type of the objects that are going to be searched/modified.
 			line 		(str)    -> Last line read in the input file.
 			id 			(str)	 -> ID of the object that is going to be changed.
 * Purpose: It defines the type of object and seeks its position in the input file
 * Output:  Returns error code if the object was not found.
 */

int c_look4inputID(FILE** input_file, int* object_type, char* line, char* id)
{
	char* keys[] = {"[CONDUITS]", "[JUNCTIONS]", "[STORAGE]", "[SUBCATCHMENTS]", "[ORIFICES]", NULL};
	int attribute_key;

	while(*object_type == -1){
		char id_key[LEN];
		int cmp_len = 0;

		fgets(line, LEN, *input_file);
		if( strncmp("[", line, 1) == 0 ) attribute_key = c_in_list(keys, line); // Saves the current
		sscanf(line, "%s", id_key);

		if (strlen(id_key) > strlen(id)) cmp_len = strlen(id_key);
		else cmp_len = strlen(id);

		if( strncmp(id_key, id, cmp_len) == 0 ){
			int seek_length = 0 - strlen(line) + strlen(id_key); // It leaves the cursor at the beginning of the row

			fseek(*input_file, seek_length, SEEK_CUR);

			// Define the object type if the object was found.
			if( attribute_key == 0 ) *object_type = LINK;
			else if( attribute_key == 1 ) *object_type = JUNCTION;
			else if( attribute_key == 2 ) *object_type = STORAGE;
			else if( attribute_key == 3 ) *object_type = SUBCATCH;
			else if( attribute_key == 4 ) *object_type = C_ORIFICE;
			break;
		}
		else if( feof(*input_file) ) return C_ERROR_NFOUND;

	}

	return 0;
}

/*
 * Inputs:  new_i 		(InputInfo*) -> Pointer to Struct with positioning information.
 			object_type (int)    	 -> Type of the objects that are going to be searched.
 			attribute   (int)    	 -> Constant - Attribute that is going to be searched.
 * Purpose: It encodes the position of an object from the input file. The position is
 			defined by two variables: key and column.
 * Outputs: Returns error code if there is an error.
 */
int c_get_key_column(InputInfo* new_i, int object_type, int attribute)
{
	new_i->isNumeric = 1;
	// No attribute
	new_i->column = 0;

	/* ---------------------- ATTRIBUTES -----------------------*/
	if(attribute != -1){
		// Subcatchments
		if( object_type == SUBCATCH ){
			if(attribute == C_OUTLET){
				new_i->column = 2;
				new_i->isNumeric = 0;
			}
			else if(attribute == C_AREA) new_i->column = 3;
			else if(attribute == C_IMPERV) new_i->column = 4;
			else if(attribute == C_WIDTH) new_i->column = 5;
			else if(attribute == C_SLOPE) new_i->column = 6;
			else return C_ERROR_ATR;
		}

		// Junctions, Storages, Orifices and Links
		else if( (object_type == JUNCTION) || (object_type == C_STORAGE)
					|| (object_type == LINK) || (object_type == C_ORIFICE) || (object_type == C_OUTFALL))
		{

			if(attribute == C_INVERT) new_i->column = 1; // Outfalls
			else if( object_type == C_OUTFALL ) return C_ERROR_ATR;
			else if(attribute == C_DEPTH_SIZE) new_i->column = 2;
			else if( object_type == JUNCTION ) return C_ERROR_ATR;

			if( (object_type == C_STORAGE) && (new_i->column == 0)){
				// Storages
				if(attribute == C_STORAGE_A) new_i->column = 5;
				else if(attribute == C_STORAGE_B) new_i->column = 6;
				else if(attribute == C_STORAGE_C) new_i->column = 7;
				else return C_ERROR_ATR;
			}
			if( (object_type == LINK)  && (new_i->column == 0)){
				if(attribute == C_LENGTH) new_i->column = 3;
				else if(attribute == C_ROUGHNESS) new_i->column = 4;
				else if(attribute == C_IN_OFFSET) new_i->column = 5;
				else if(attribute == C_OUT_OFFSET) new_i->column = 6;
			}
			if( (object_type == C_ORIFICE) || (object_type == LINK)){
				// Links: Counduits and Orifices
				if(attribute == C_FROM_NODE){
					new_i->column = 1;
					new_i->isNumeric = 0;
				}
				else if(attribute == C_TO_NODE){
					new_i->column = 2;
					new_i->isNumeric = 0;
				}
				else if( new_i->column == 0 ) return C_ERROR_ATR;
			}
		}
		// Default
		else return C_ERROR_TYPE;
	}

	/* ---------------------- TYPE -----------------------*/
	if (object_type == JUNCTION) new_i->key = "[JUNCTIONS]";
	else if (object_type == NODE) new_i->key = "[COORDINATES]";
	else if (object_type == C_STORAGE) new_i->key = "[STORAGE]";
	else if (object_type == LINK){
		if(attribute == C_DEPTH_SIZE) new_i->key = "[XSECTIONS]";
		else  new_i->key = "[CONDUITS]";
	}
	else if (object_type == C_OUTFALL) new_i->key = "[OUTFALLS]";
	else if (object_type == C_ORIFICE) new_i->key = "[ORIFICES]";
	else if (object_type == SUBCATCH) new_i->key = "[SUBCATCHMENTS]";
	else return C_ERROR_TYPE;

	return 0;
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