# AILearnsToPlayFoldIt
Greetings!

It is a script that use genetic algorithm to find actions in game that gain score and adjust them over time.
Source code can be found here: https://github.com/Grommii/Foldit/blob/master/AILearnsToPlayFoldIt.lua

Adjustable parameters:
**Population Size** - Number of species in population. In other words - number of top species that survive to the next generation;
**Mutation Size** - Number of mutated algorithms that will be added and checked each generation;
**Aliens Size** - Number of random algorithms that will be added and checked each generation;
**Cross Size** - Number of crossed algorithms that will be added and checked each generation;
**Number Of Algorithm Steps** - Number of actions (genes) that can perform each algorithm;
**Iteration Score Threshold** - Score gain threshold for algorithm to be executed again during evaluation; 
**Reset World Generation Each** - Number of generations that will be tested based on the same starting position before new top position will be saved as start point;
**Mutate Rate** - Probability of new gene during mutation;

Also you can check/uncheck pre-defined algorithms to start with. By default two common algorithms included.

https://fold.it/portal/recipe/102993