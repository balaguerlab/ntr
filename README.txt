Neuronal trajectories reconstruction utilities in Matlab v1.7-beta.

v1.7-beta. Current revision of this text 24 Nov 2020. Under the terms of the MIT license: https://opensource.org/licenses/MIT

by Emili Balaguer-Ballester et al. (see citations below)  https://staffprofiles.bournemouth.ac.uk/display/eb-ballester

Balaguer Lab 
Faculty of Science and Technology,
Interdisciplinary neuroscience research centre, Bournemouth University. https://research.bournemouth.ac.uk/centre/interdisciplinary-neuroscience-research/

Citation for this code: Balaguer-Ballester, E., Nogueira, R., Abofalia, J.M., Moreno-Bote, R. Sanchez-Vives, M.V., 2020. Representation of Foreseeable Choice Outcomes in Orbitofrontal Cortex Triplet-wise Interactions. Plos Comput Biol, 16(6): e1007862.

Previous versions:
Lapish, C. and Balaguer-Ballester, E. (shared first authorship), Phillips, A, Seamans, J. and Durstewitz, D. 2015. Amphetamine Bidirectionally alters Prefrontal Cortex Attractor Dynamics during Working Memory. The Journal of Neuroscience 35(28): 10172-10187.
Balaguer-Ballester, E., Tabas-Diaz, A., Budka, M., 2014. Can we identify non-stationary dynamics of trial-to-trial variability?. PLoS One, 9 (4).
Hyman, J., Ma, L., Balaguer-Ballester, E., Durstewitz, D., Seamans, J. 2012. Contextual encoding by ensembles of medial prefrontal cortex neurons. PNAS, 109 (13)5086-5091.
Balaguer-Ballester, E., Lapish, C.C., Seamans, J.K., Durstewitz, D. 2011. Attracting dynamics of frontal cortex ensembles during memory-guided decision-making. PLoS Comput Biol, 7 (5), e1002057.
Requirements: Matlab © 2018 or more recent, parallel computing, statistics and machine learning, signal processing libraries. All subfolders must be added to the Matlab path.

How-to: For a demo, type ” >ntr”. For standard use:

1) Drop a ".mat" or ASCII-type file (e.g. named “file_name.mat”) on the .\data folder, where “.\” indicates the directory containing this code. This ‘file_name.mat’ should contain a Matlab matrix named "data.mat" of dimension “number of time bins x (dimensionality of neural responses+3)”, where the dimensionality of neural responses refers to the number of simultaneously recorded neurons. The dataset structure is:
* Columns "1:end-3" of "Data" matrix: Neural responses over time.
* Column "end-2" of "Data" matrix: Natural numbers>0, labelling the different stimuli or behavioural "epochs" in which the experimentalist segments the task. "-1" should encode "no-labelled" time-bins.
* Column "end-1" of "Data" matrix: Natural numbers>0, they are alternative labelling used only for trial trajectory (see comments in file for more info). Those labels typically represent “phases” of the task, containing different “epochs”. If this is irrelevant in the experiment, then this column can be a copy of "end-2" one.
* Last column of "Data" matrix: Natural numbers>0, labelling the                       different trials of the task. Trials typically represents repetitions of the experiment, containing each the same “phases” of the task.

2) “kspaces_configuration.m” contains a default configuration.  Please find a detailed description of the parameters by typing ">help kspaces_config”.

3) type ">ntr(‘file_name’);”. Alternatively, one can load in the workspace the data matrix variable formatted as indicated in I.1 (e.g. “Data_matrix_name”) and type “>ntr(Data_matrix_name);"

Implementation:

.\

10 main functions (in alphabetic order).
dcm: Embedding for univariate time series using a delay coordinate map
kfd_cross_val: Out-of-sample, cross-validation script
kfd_multiv: Kernel Fisher-Discriminant
kfd_multiv_orthogonal: Kernel Fisher-Discriminant - Discriminant subspace axes are orthogonalized
kpca: Kernel principal components
kspaces_config: Configuration file
ntr: Starting function for the utility "neural activity trajectories reconstruction". For a demo, run ” >ntr”.
setup_config: Auxiliar configuration file.
shuff_data: Shuffles data across epochs.
visualization: Displays a trial and a flow filed using kernel PCA/kernel FDA

.\priv

29 auxiliary functions, called from the main functions. See code for details

.\example

Batch files and examples 
global_stats, global_stats_residuals: Compares correct and incorrect trials 
oneFileAnova: Examples of stats comparing behaviours
example_optimize: Batch procces script, to demonstrate the optimization of the decoder on any data file.
config_values: Auxiliary file for example_optimize

