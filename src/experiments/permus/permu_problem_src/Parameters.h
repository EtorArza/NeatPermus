
#include <string>
#include "PBP.h"
#include <mutex>
#ifndef EXTERN
#define EXTERN extern
#endif



#define N_OF_INPUT_PARAMS_TRAIN 3
#define N_OF_INPUT_PARAMS_TEST 5

class stopwatch;
// CONSTANT PARAMETERS //
EXTERN double MAX_TIME_PSO;
EXTERN int POPSIZE;
EXTERN int N_EVALS;
EXTERN int N_REEVALS;
EXTERN int TABU_LENGTH;
/////////////////////////

// BASH INPUT PARAMETERS //
// binary name
EXTERN std::string INSTANCE_PATH;
EXTERN std::string PROBLEM_TYPE;
EXTERN std::string CONTROLLER_PATH;
///////////////////////////

// TRAIN PARAMS //
EXTERN int n_of_threads_omp;
EXTERN double MAX_TRAIN_TIME;
EXTERN stopwatch global_timer;
///////////////////////////

// TECHNICAL PARAMETERS // 
#define MAX_LONG_INTEGER 429496729500000
#define MIN_LONG_INTEGER -42949672950000
#define MAX(A,B) ( (A > B) ? A : B)
#define MIN(A,B) ( (A < B) ? A : B)

// NEAT PARAMETERS //
# define CUTOFF_0 0.25
//////////////////////

///////////////////////////


// argv[0] --> name of the binary executable
// argv[1] --> type of problem, i.e. LOP
// argv[2] --> path to the problem
void set_parameters(int argc, char *argv[]);
void set_parameters(int argc, char const *argv[]);
std::string return_parameter_string(void);
void print_parameters(void);
void set_other_params();


PBP *GetProblemInfo(std::string problemType, std::string filename);



