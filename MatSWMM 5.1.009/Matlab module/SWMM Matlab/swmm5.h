//-----------------------------------------------------------------------------
//   swmm5.h
//
//   Project: EPA SWMM5
//   Version: 5.0
//   Date:    6/19/07   (Build 5.0.010)
//            1/21/09   (Build 5.0.014)
//            4/10/09   (Build 5.0.015)
//   Author:  L. Rossman
//
//   Prototypes for SWMM5 functions exported to swmm5.dll.
//
//   Modified to better accommodate non-Windows OS's (5.0.014)                 //(5.0.014 - LR)
//   Modified to accommodate usage in C++ programs (5.0.015)                   //(5.0.015 - LR)
//-----------------------------------------------------------------------------
#ifndef SWMM5_H
#define SWMM5_H

// --- define WINDOWS

#undef WINDOWS
#ifdef _WIN32
  #define WINDOWS
#endif
#ifdef __WIN32__
  #define WINDOWS
#endif

// --- define DLLEXPORT

#ifdef WINDOWS
  #define DLLEXPORT __declspec(dllexport) __stdcall
#else
  #define DLLEXPORT
#endif

// --- use "C" linkage for C++ programs

#ifdef __cplusplus
extern "C" {
#endif

int  DLLEXPORT   swmm_run(char* f1, char* f2, char* f3);
int  DLLEXPORT   swmm_open(char* f1, char* f2, char* f3);
int  DLLEXPORT   swmm_start(int saveFlag);
int  DLLEXPORT   swmm_step(double* elapsedTime);
int  DLLEXPORT   swmm_end(void);
int  DLLEXPORT   swmm_report(void);
int  DLLEXPORT   swmm_getMassBalErr(float* runoffErr, float* flowErr,
                 float* qualErr);
int  DLLEXPORT   swmm_close(void);
int  DLLEXPORT   swmm_getVersion(void);

// Cosimulation getters
double DLLEXPORT swmm_get( char* id, int attribute, int units );
double DLLEXPORT swmm_get_from_input(char* filename, char *id, int attribute);
int DLLEXPORT swmm_save_all(char* input_file, int object_type, int attribute);
// Cosimulation setters
int DLLEXPORT swmm_modify_setting(char* id, double new_setting, double tstep);
int DLLEXPORT swmm_modify_input(char* input_file, char *id, int attribute, double value);
int DLLEXPORT swmm_save_results();

#ifdef __cplusplus
}   // matches the linkage specification from above */
#endif

#endif
