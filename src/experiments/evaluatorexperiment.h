#pragma once

#include "experiment.h"
#include "genomemanager.h"
#include "network.h"
#include "organism.h"
#include "population.h"
#include "stats.h"
#include "timer.h"
#include "util.h"
#include "Parameters.h"
namespace NEAT {

//------------------------------
//---
//--- CLASS EvaluatorExperiment
//---
//------------------------------
    class EvaluatorExperiment : public Experiment {
    private:
        std::string get_dir_path(int experiment_num) {
            char buf[1024];
            sprintf(buf, "./experiment_%d", experiment_num);
            return buf;
        }

        std::string get_fittest_path(int experiment_num, int generation) {
            char buf[1024];
            sprintf(buf, "%s/fittest_%d",
                    get_dir_path(experiment_num).c_str(),
                    generation);
            return buf;
        }

    public:
        typedef std::function<NetworkEvaluator *()> CreateEvaluatorFunc;
        typedef std::function< std::vector<std::unique_ptr<Genome>> (rng_t rng)> CreateSeedsFunc;

        CreateEvaluatorFunc create_evaluator;
        CreateSeedsFunc create_seeds;
        std::unique_ptr<NetworkEvaluator> network_evaluator;

        EvaluatorExperiment(const char *name,
                            CreateEvaluatorFunc create_evaluator_,
                            CreateSeedsFunc create_seeds_)
            : Experiment(name)
            , create_evaluator(create_evaluator_)
            , create_seeds(create_seeds_) {
        }

        virtual ~EvaluatorExperiment() {
        }



        virtual void run(class rng_t &rng, int gens) override {
            using namespace std;

            network_evaluator = unique_ptr<NetworkEvaluator>(create_evaluator());
            
            vector<size_t> nnodes;
            vector<size_t> nlinks;
            vector<real_t> fitness;

            mkdir( get_dir_path(1) );
            //Create a unique rng sequence for this experiment
            rng_t rng_exp(rng.integer());

            fittest = nullptr;
            env->genome_manager = GenomeManager::create();
            vector<unique_ptr<Genome>> genomes = create_seeds(rng_exp);


            pop = Population::create(rng_exp, genomes);
    
            
            int gen = 0;
            for(double progress = 0; progress < 1.0; progress = ((double) global_timer.toc() / (double) MAX_TRAIN_TIME)) {
                gen++;
                cout << "\n\n";
                cout << "Epoch " << gen << ", progress: " << progress << endl;	
                cout << "Time left:" << ((double) MAX_TRAIN_TIME - global_timer.toc()) / 60.0 / 60.0 << "h" << endl;
                

                static Timer timer("epoch");
                timer.start();

                if(gen != 1) {
                    pop->next_generation();
                }

                evaluate();

                timer.stop();
                Timer::report();
                

                #define SAVE_THIS_MANY_NETWORKS_DURING_CONVERGENCE 8 
                int number_of_saved = 1;
                double save_every = MAX_TRAIN_TIME / (double) SAVE_THIS_MANY_NETWORKS_DURING_CONVERGENCE * 0.999;
                if (save_every * number_of_saved  < global_timer.toc())
                {
                    number_of_saved++;
                    print(1, gen);
                }
                #undef SAVE_THIS_MANY_NETWORKS_DURING_CONVERGENCE
            }

            {
                Genome::Stats gstats = fittest->genome->get_stats();
                fitness.push_back(fittest->eval.fitness);
                nnodes.push_back(gstats.nnodes);
                nlinks.push_back(gstats.nlinks);
            }
            delete pop;
            delete env->genome_manager;

            cout << "fitness stats: " << stats(fitness) << endl;
            cout << "nnodes stats: " << stats(nnodes) << endl;
            cout << "nlinks stats: " << stats(nlinks) << endl;

        }

    private:
        void print(int experiment_num,
                   int generation) {
            using namespace std;

            ofstream out(get_fittest_path(experiment_num, generation));
            fittest->write(out);
        }

        void evaluate() {
            using namespace std;

            static Timer timer("evaluate");
            timer.start();

            size_t norgs = pop->size();
            Network *nets[norgs];
            for(size_t i = 0; i < norgs; i++) {
                nets[i] = pop->get(i)->net.get();
            }
            OrganismEvaluation evaluations[norgs];

            network_evaluator->execute(nets, evaluations, norgs);

            Organism *best = nullptr;
            for(size_t i = 0; i < norgs; i++) {
                Organism *org = pop->get(i);
                org->eval = evaluations[i];
                if( !best || (org->eval.fitness > best->eval.fitness) ) {
                    best = org;
                }
            }

            timer.stop();

            // Fittest is not evaluated.
            if(!fittest || (best->eval.fitness > fittest->eval.fitness)) {
                fittest = pop->make_copy(best->population_index);
            }

            Genome::Stats gstats = fittest->genome->get_stats();
            cout << "fittest [" << fittest->population_index << "]"
                 << ": fitness=" << fittest->eval.fitness
                 << ", error=" << fittest->eval.error
                 << ", nnodes=" << gstats.nnodes
                 << ", nlinks=" << gstats.nlinks
                 << endl;
        }

        class Population *pop;
        std::unique_ptr<Organism> fittest;
    };

}
