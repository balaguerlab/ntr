function conf=kspaces_config()
%v 4.0
%Configuration file.
%
%This code is not commercial and thus is not guaranteed.
%Distributed accourding to the MIT license
%https://opensource.org/licenses/MIT
%However, it is used on regular basis with multiple datasets.
%References:
% Balaguer-Ballester, E., Nogueira, R., Abofalia, J.M., Moreno-Bote, R. Sanchez-Vives, M.V., 2020. Representation of Foreseeable Choice Outcomes in Orbitofrontal Cortex Triplet-wise Interactions. Plos Comput Biol, 16(6): e1007862.
% Previous versions:
% Lapish, C. and Balaguer-Ballester, E. (shared first authorship), Phillips, A, Seamans, J. and Durstewitz, D. 2015. Amphetamine Bidirectionally alters Prefrontal Cortex Attractor Dynamics during Working Memory. The Journal of Neuroscience 35(28): 10172-10187.
% Balaguer-Ballester, E., Tabas-Diaz, A., Budka, M., 2014. Can we identify non-stationary dynamics of trial-to-trial variability?. PLoS One, 9 (4).
% Hyman, J., Ma, L., Balaguer-Ballester, E., Durstewitz, D., Seamans, J. 2012. Contextual encoding by ensembles of medial prefrontal cortex neurons. PNAS, 109 (13)5086-5091.
% Balaguer-Ballester, E., Lapish, C.C., Seamans, J.K., Durstewitz, D. 2011. Attracting dynamics of frontal cortex ensembles during memory-guided decision-making. PLoS Comput Biol, 7 (5), e1002057.
%
%by Emili Balaguer-Ballester.
%April 2020
%__________________________________________________________________________
%
%PLEASE SPECIFY IN THIS FILE THE CONFIGURATION PARAMETERS (1x1).
%
%Example of configuration:
%   (Multi)nomial kernel with expansion order 3.
%   Regularization 30% of the mean kernel matrix value.
%   Show multivariate discriminant statistics.
%   Displays activated of trial 1 and flow of trials 1-5 will be shown in the
%       maximum discriminating subspace
%   Full stat. analyses not reported
%For information about parameter settings please see comments below or 'readMeFirst.pdf'
%
%Log of changes: Please specify here your code modifications
%(#Line@author: Change description). This will be useful if assistance is
%required
%@ebb:Added new xval option. 
%     One trial for estimation and rest for validation, once per block (opt
%     4)
%@ebb: min_trajec_length parameter is now passed
%@ebb: modality 5 cross val added
%19-Jun-2015 #173,180@ebb:new input argument for not dispalying the flow
%field
%      
%_______________________________________________________________________
%1-Basic parameters, they have to be specified by the user
%
order=1;%3;%5%2;% (1x1) Natural number>0.  Degree of the product among neural responses across units.
%
is_shuffled_events=0;%(1x1) Natural. If >0, shuffles blocks as specified by the labels in �end-2" data column (task-epoch labels).
%
is_shuffled_within_events=0;%(1x1). Natural. If>0, preserves blocks as specified by the labels in"end-2" data column (task-epoch labels), but shuffles all time-bins within. 
%
trial_disp=0;%(1x1) Natural number indicating the trial to be displayed.
%                   Only one trial at a time is allowed to be displayed. 
%                   on a "3-D" trajectory plot. If <1, there will be no display at all.
%
make_video=0;%(1x1) Natural number indicating the trial to be displayed. 
%             If>0 a video of a single trajectory will be displayed
%             instead the static plot of the trial, regardless the value of
%             "trial_disp".
%
trials_flow_disp=[];%[1];%(1x2) Range of trials "flows" to be displayed in thre
%                   maximum discriminating (canonical) axis. If empty, no
%                   display will be produced.
%
%
%
%__________________________________________________________________________
%__________________________________________________________________________
%__________________________________________________________________________
%
%
%
%
%2-Advanced parameters. No need to be modified unless default options are not enough.
%
regularization=0.1;%0.2;%0% (1x1) Dimensionality penalization (0,1), represtenting fraction of the average 
%                   value of the kernel matrix( see kfdmultiv.m for technical details)
%                   Suggested values: Lower values that default (e.g.
%                   0.148; 0.185) provide optimal cross-validations on
%                   weakly nonstationary time series(for instance see
%                   Balaguer-Ballester & Lapish et al. 2011)
%                   In contrast, larger values than default (e.g. 0.423; 0.396) typically provide best
%                   regularization results on non-stationary time series.
%regularization=0.4;%for o=2, small space stable min. on DIV
%regularization=0.15;%for o=3, big space unstable min. on DIV
%regularization=0.2548;%for o=3, big space stable min. on DIV
%regularization=0.4548;%for o=3 A bit more stable minimum of error in DIV. Space is smaller
%regularization=0.1771;%for o=4 Stable plus a big space
%regularization=0.1414;%for o=5 Unstable plus a big space
%regularization=0.15;%for o=3, big space unstable min. on DIV
is_multiple_discriminant=1;% (1x1). Natural. If>0, prediction statistics based on a multiple discriminat
%             will be also reported (besides the average of all pairwise combinations of groups).
%
is_pairwise=0;%Same for the 2-class disc. If is_multiple_discriminant<0, the two-class will
%                   be performed anyway
%
xval_type=5;%3;%-1;4%2;%  (1x1). Natural. %Type of Cross-validation that will be performed. 6  kinds of cross-validation are supported:
%                               0: Leave-one-out (standard method): each ith-trial is removed in turn then optimum discriminant
%                                                                directions are computed using all-but-the ith trial;
%                                                                this trial will be the ith-validation set
%                               1: Causal n-fold cross-validation 
%                               (respects causality): last j-trials are removed in each jth validation
%                                                     block. The remaining trials form the reference set, 
%                                                     which thus is smaller for increasing jth-validation blocks.
%                                                     There will be n=(m/2)-1 validation blocks (m=number of trials)
%                                2: Single-trial cross validation: each individual trial is a training sample and validation one
%                                                      in turn. There will be n=2*m validations blocks. This could be  used when 
%                                                      trials are not comparable for example when they do belong to different animals
%                               3: Single-trial+causal.
%                                   
%                               4: Single-trial, but only the first
%                               trial is used for estimation. There will be
%                               then m-1 validation blocks
%                               
%                               <0: Only classification, trial by trial. Warning: use only once the regul.
%                                   constant have been optimized previously by cross-validation
%
full_stats_disp=1;%(1x1). Warning: Matlab Statistical Toolbox is needed for activating this option.
%                   If==1, command window information, some statistics as
%                   certain warnings will be displayed
%                   If > 1, all warnings will be displayed as well as multiple parametric and non-parametric tests 
%                   If>2, a full display of the procces will be shown
%
balance_trajec_length=15;%0;%(1x1) Note: Parameter only used for the high-dim statistical analyses & flow display,
%                 not during 3D trajectory visualization pruposes. If >0, the length of any class-specific-trajectory is 
%           upper-bounded by the smallest of the mean trajectory length (across all groups) and
%           this number of bins. Useful when classes have very different sizes.
%           In addition, if this parameter is positive, chance priors will 
%           be automatically used in the discriminant analyses (for
%           avoiding size-biases between classes).
%             
%
min_trajec_length=4;%0;%45;%Do not classifiy as "convergent" or not trajectories shorter than this number of bins
%
do_dcm=0;%1;%1;%(1x1) If>0, performs a delay-coordinate map expansion before kernel expansion.
%           Not compelling in multivariate recordings unless all
%           units responses are often the same for two different
%           task-epochs. In that situation, trajectories would better be
%           disambiguated by a lag-expansion.
%           Note: Regardless this parameter value,
%           a delay-coordinate map will be used in the trajectory visualization depending 
%           only on the value of the next parameter. 
%
fixed_lag=1;%1;%(1x1) Note: Parameter only used during 3D trajectory visualization pruposes, 
%           not for the high-dim statistical analyses neither for the flow display. 
%           Natural number, indicating the maximum lag (in time
%           bins units) which should have every axes  in a delay-coordinate map. If <=0, lags will be
%           obtained as the average/maximum lag across the "first" minimum between cross-correlation 
%           functions (see code below in dcm.m for details).
%   
incl_subop_lags=1;%(1x1) Note: Parameter only used for the high-dim statistical analyses & flow display,
%                 not during 3D trajectory display. 
%                 Binary, indicating if all lags below the
%                 optimum/maximum one will be included as a new axes or not.
%
balance_task_epochs=4;%30;%(1x1) This parameters controls the disbalanced in epochs size:
%                 If>0, the number of time bins of the longest
%                 task-epochs is, at maximum "x balance_task_epochs" of the shortest
%                 one.
%
lost_frac=.1;%.1;% (1x1) Note: Parameter only used for the high-dim statistical analyses & flow display,
%                 not during 3D trajectory display. 
%                 Maximum percentage of lags that can be lost during a DCM embedding.
%
do_record=0; %(1x1) Record a video of the trajectory display in mp4 format
%
video_quality=50;% (1x1) Quality of the recorded video (if any) in (0-100%)
%
is_gauss_kernel=0;% (1x1) WARNING: Not implemented, found not necessary. Value will be ignored & can be ommited]
%             If >0, infinite dimensional gaussian kernel will be used (not interpretable as
%             spike matrix but translation-invariant. The value of this
%             configuration, when >=0, specifies standard deviation (in units of bins)
%             used in the kernel. if is_expo>=0, polynomial kernel will be not used
%             then, thus "order" parameter will be irrelevant.
%
no_flow_field=0;     %For not dispalying the flow field, it only affects visualization
%_________________________________________________________________________

conf=setup_config(order,regularization,...
    is_shuffled_events,is_shuffled_within_events,...
trial_disp,make_video,trials_flow_disp,is_multiple_discriminant,is_pairwise,xval_type,...    
full_stats_disp,balance_trajec_length,min_trajec_length,do_dcm,fixed_lag,incl_subop_lags,balance_task_epochs,...
lost_frac,do_record,video_quality,is_gauss_kernel,no_flow_field);
end


