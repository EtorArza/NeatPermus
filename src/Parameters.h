
#include <string>
#include "Tools.h"
#ifndef EXTERN
#define EXTERN extern
#endif


void load_global_params(std::string conf_file_path);



// PARAMS TO BE SPECIFIED IN CONFIG FILE//
EXTERN int N_OF_THREADS;
EXTERN double MAX_TRAIN_TIME;
EXTERN int POPSIZE_NEAT;
EXTERN stopwatch global_timer;



// Global variables // 
EXTERN double BEST_FITNESS_TRAIN;
EXTERN double N_TIMES_BEST_FITNESS_IMPROVED_TRAIN;
EXTERN double* F_VALUES_OBTAINED_BY_BEST_INDIV;
EXTERN std::string EXPERIMENT_FOLDER_NAME;







# define CUTOFF_0 0.25 // NN consider value near 0



// MACROS // 
#define MAX(A,B) ( (A > B) ? A : B)
#define MIN(A,B) ( (A < B) ? A : B)
///////////