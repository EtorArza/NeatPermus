#include "cpunetwork.h"
#include "PERMU_params.h"

#pragma once

namespace PERMU{

class PBP;
void GetProblemInfo(std::string problemType, std::string filename, PBP ** problem);
double FitnessFunction_permu(NEAT::CpuNetwork *net, int seed, PERMU::params *parameters);

}