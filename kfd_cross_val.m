function report_stats=kfd_cross_val(data,order,regul,xval_type,multi,pairwise,full_stats_disp,....
    balance_trajec_length, do_dcm,incl_subop_lags,balance_task_epochs,min_trajec_length)
%v5.0b
%Out-of-sample, cross-validation script.
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
%
%Log of changes: Please specify here your code modifications
%(#Line@author: Change description). This will be useful if assistance is
%required
%250, 338, 487, 627, 662@ebb: Adding the possibility of just classfying and ommiting 2-class discr.
%199,277,380,381,409(implicit),467,468,480-483@ebb: Mean (stderr) Jensen-Shannon
%                                                                                        divergence for multivariate
%                                                                                        discriminant is displayed and
%                                                                                        returned in "report_stats"
%277-80, 489-94@ebb: Multivariate statistics. Storing wilks lambda and mahalanobis
%                                 between group means (see class_trajec.m for more details)
%214,332, 455, 469@ebb: Recovering Jensen-Sh. also for pairwise comparisons
%507@ebb: Returning the multivariate mean statistics per validation block
%124, 126@ebb: Corrected bug, lines simple deleted (inicialization of data matrixes has to be [])
%455, 512, 513, 529@ebb: Reporting JS averaged for 2-classes
%486-501@ebb: Bug. Ammended control over problems in 2-class JS and Manova
%207,296@ebb: Recover JS per class in a  multivariate setting
%299@ebb:Added new xval option.One trial for estimation and rest for validation, once per block (opt 4)
%@ebb: min_trajec_length parameter is now passed
%489andBelow@ebb: Adding gaussian error in JS
%357 and below @ebb: xval modality 5, trial by trial, causal but any past
%trial is used for estimation
%__________________________________________________________________________
%Inputs:
%
%       data (number of time bins x (dimensionality of neural responses+3) ), and with the following
%                                                                         structure:
%
%       (note: dimensionality of neural responses refers e.g. to the number of simultaneously
%       recorded "neurons" and/or delayed version of them)
%               -Columns "1:end-3" of "data" matrix:  Must contain neural responses values over
%                                       time.
%               -Column "end-1" of "data" matrix: Must contain natural numbers>0, they are
%                                      alternative labelling used only for
%                                      display (number of
%                                      labels smaller than 8). If all "epochs"
%                                      are to be displayed, this column has
%                                      to be a copy of "end-2" one.
%
%               -Column "end-2" of "data" matrix: Must contain natural numbers>0, labelling
%                                      the different stimulus or behavioral "epochs" in which
%                                      the experimentalist segments the
%                                      task. "-1" encodes "no-labelled"
%                                      time-bins.
%               -Last column of "data" matrix: Must contain natural numbers>0, labelling the
%                                      different trials of the task.
%
%       order (1x1) = "1" for a regulularized naive fisher discriminant.
%
%       multi (1x1)= If >0, statistics from multiple discriminat analysis will
%                be also reported.
%
%       regul  (1x1) = regularization penalty, in units of % of the mean dot product of any two vectors.
%               (i.e. mean(mean(Kernel matrix)). If order = "1", It penalizes directy the pooled covariance matrix.
%               Default value is 0.15
%
%       xval_type (1x1) =Cross-validation that will be performed. Three  kinds of cross-validation are supported:
%                               0: Leave-one-out (standard method): each ith-trial is removed in turn then optimum discriminant
%                                                                directions are computed using all-but-the ith trial;
%                                                                this trial will be the ith-validation set
%                               1: Causal n-fold cross-validation
%                               (respects causality): last j-trials are removed in each jth validation
%                                                     block. The remaining trials form the reference set,
%                                                     which thus is smaller for increasing jth-validation blocks.
%                                                     There will be n=(m/2)-1 validation blocks (m=number of trials)
%                                >1: Single-trial cross validation: each individual trial is a training sample and validation one
%                                                      in turn. There will be n=2*m validations blocks. This could be  used when
%                                                      trials are not comparable for example when they do belong to different animals
%
%       full_stats_disp (1x1) = If >0 Computes and displays in the command window
%                      other statistics of validation set
%                      classification accuracy (besides the posterior probabilites and
%                      percentage of errors) as well as different
%                      parametric and non-parametric tests.
%                      Warning: requires Matlab "Statistics Toolbox".
%
%       balance_trajec_length (1x1) = If >0, the length of any class-specific
%                                 trajectory is upper-bounded by the smallest
%                                 mean trajectory length (across all groups)
%                                 plus n-times its standard deviations
%                                (where n=balance_trajec_length). Default
%                                value is 0. Useful when classes have very
%                                 different sizes.
%       do_dcm (1x1). Performs a delay-coordinate map expansion before kernel expansion.
%           Not used by default in multivariate recordings unless all
%           responses are often the same for two different
%           taks-epochs. In that situation, trajectories should be
%           disambiguated by a lag-expansion.
%
%       incl_subop_lags (1x1). Binary, indicating if all lags below the
%           optimum/maximum one will be included as a
%           new axes or not.
%
%        balance_task_epochs (1x1). This parameter controls the disbalanced in epochs size:
%                      If>0, the number of time bins of the longest
%                      task-epochs is, at maximum "x balance_task_epochs" of the shortest
%                       one.
%       min_trajec_length (1x1) = Is critical for trajectory classification (%div) See meaning of this parameter in
%                                       "class_trajec.m"
%
%
%Outputs:
%    report_stats (1x12) = Structure with the fields specified in the code
%                          below. Note: All they refer to the validation
%                         set, they are out-of-sample statistics.
%__________________________________________________________________________
%I-PRELIMINARIES
%
if full_stats_disp
    warning('on','all')
else  
    warning('off','all')
end
disp('_________________________________')
disp('*PERFORMING ANALYSES...*')
%I.1 Define useful variables.
activ=data(:,1:end-3);%Contaning only smoothed firing-rates per neuron
trial_labels=data(:,end);
%phase_labels=data(:,end-1);%Not used. Code can be easlily modified for
%                            computing the cross-validation error of phase-labels
epoch_labels=data(:,end-2);
%
%I.2 Check out that trials are consecutive natural numers starting from
%"1". Performing also a delay-coordinate map per trial, only used if requested.
m_trials=max(trial_labels); %l_trials=length(trial_labels);
%If a delay coordinate map is performed, the las vectors from the time
%series will be lost. Therefore new data matrixes and labels will
%have less rows.
del_activ=[]; del_trial_lab=[]; del_epoch_lab=[];
n_vars=Inf;%This will be used when delay-coordinate-map dimensionality changes across trials
for i=1:m_trials
    current_trial_labels=trial_labels(trial_labels==i);
    current_epoch_labels=epoch_labels(trial_labels==i);
    current_activ=activ(trial_labels==i,:);
    if all(i.*ones(length(current_trial_labels),1)-current_trial_labels)
        error('Trial labels are not natural numbers starting with "1" and increasing by "1". Please create consecutive labels in previous-to-last column of input "data" matrix'),
    end
    % Delay-coordinate map per trial, only used if requested
    if do_dcm
        disp(['*Trial ',num2str(i),' embedding*'])
        if i>1, warning('off','all'), end
        %delayed_trial_activ=dcm(current_activ,0,incl_subop_lags,1,lost_frac);
         delayed_trial_activ=dcm(current_activ,1,incl_subop_lags);
         %delayed_trial_activ=dcm(current_activ,2,incl_subop_lags);
         %delayed_trial_activ=dcm(current_activ,4,incl_subop_lags);
         %delayed_trial_activ=dcm(current_activ,5,incl_subop_lags);
         %Example: Forcing a DCM with lag "t-1" and ignoring the
        %          lags optimization. This speeds up the procces. 
    else
        delayed_trial_activ=current_activ;
    end
    %Balancing epochs sizes
    l_curr_trial=length(delayed_trial_activ(:,1));
    indexes=balance_epochs(current_epoch_labels(1:l_curr_trial),balance_task_epochs);%Returns the indexes of the radomly selected labels
    delayed_trial_activ=delayed_trial_activ(indexes,:);
    current_trial_labels=current_trial_labels(indexes,:);
    current_epoch_labels=current_epoch_labels(indexes,:);
    [current_n_vec,current_n_var]=size(delayed_trial_activ);
    n_vars=min(n_vars,current_n_var);
    if i>1, del_activ=[del_activ(:,1:n_vars);delayed_trial_activ(:,1:n_vars)];
    else
        del_activ=delayed_trial_activ;
    end
    %Updating labels size
    del_trial_lab=[del_trial_lab;current_trial_labels(1:current_n_vec)];
    del_epoch_lab=[del_epoch_lab;current_epoch_labels(1:current_n_vec)];
end
if full_stats_disp, warning('on','all'), end
%
%
%II-CROSS-VALIDATION. Removing a set of trials in turn, compute the discriminant
%                 directions are computed using all-but-the-removed trials and
%                 use such optimal direction(s) to predict the
%                 task-epoch vs high-dim responses interactions associations of the
%                 remained trial.
%
%II.1. Defining validation data blocks
min_epoch=min(del_epoch_lab(del_epoch_lab>-1));n_epochs=max(del_epoch_lab(del_epoch_lab>-1))-min_epoch+1;
if xval_type<=0
    val_blocks=m_trials;
elseif xval_type==1
    val_blocks=floor(m_trials/2);%It is convenient that the size of the validation dataset
    %                               do not exceeds those form the
    %                               reference set.
elseif xval_type==2
    val_blocks=m_trials*(m_trials-1); %Each trial is used twice, as a reference and as a validating set (2*combnk([1:m_trials],2))
elseif xval_type==5
    val_blocks=0;
    for k=1:m_trials-1
     val_blocks=val_blocks+(m_trials-k); %all past trials used for estimation
    end
else
    %Same as before, but only one-step-ahead future trials can be used as
    %validation sets.
    %This also includes the modality #4, in which only the first trial is
    %used for estimation and the m_trials-1 remaining for validating
    val_blocks=m_trials-1;
end
%
%Allocating variable for results storage
%Each column will represent the value of one classication statistic for
%each validation block. This number will be later averaged across tras-epochs in the
%case of bi-variate classifcation.
%A full report of statistics used can be obtained by typing ">help kfd_multi.m"
%or ">help class_trajec.m.
%Only few of them will be displayed (see "class_trajec.m" for more details).
%The statistics retained and plotted can be easily changed in the code.
%
%a) Multiple-discriminating statistics
%
%"cum_global_multi_stats" cotent:
%Column 1: Percent of  missclasified vectors(=Fisher discriminant operating on the original or delayed
%   axes)
%Column 2: Percent of outlier vectors (for all x-valid. realisations)
%Column 3: Percent of divergent task-epoch trajectories (for all x-val. realisations)
%Column 4: Percent of outlier task-epoch trajectories (for all x-val. realisations)
%Column 5: J-S divergence
cum_global_multi_stats=100.*ones(val_blocks,9);%100.*(   (n_epochs-1)/n_epochs).*ones(val_blocks,4);
%
%"cum_multi_stats content":
%Each column of the next matrix represent one class (i.e. one task-epoch)
%while, each row contains, exactly the same statistics over all x-val
%realisations as in previous vector.
cum_multi_stats=100.*ones(val_blocks,n_epochs,3);%100.*(   (n_epochs-1)/n_epochs).*ones(val_blocks,n_epochs,2);
%
%b) Pairwise-discriminating statistics
%
%Next vector contains results for all possible pairwie comparisons
%"combi" is matrix with 2 columns and n_epochs!/2!(n_epochs�2)! rows, where each row contains the
%index of the two task-epochs to be compared with.
combi=combnk(1:n_epochs,2); n_combi=length(combi(:,1));
combi=combi+(min_epoch-1).*ones(n_combi,2);
cum_pair_stats=100.*ones(val_blocks,n_combi,8);
%
%II.2 Validation "per-se"
%
real_blocks_multi=1;%Number of validation blocks contaning predictions
real_blocks_two=1;
block_valid=1;%Flag to signal the validity of a block (used in two-class discrim. predictions)
validated_trial=1;%This will be used only for the single-trial corss-validation modality
trial_counter=1;%This will be used only for the single-trial corss-validation modality
ref_trials=(2:m_trials);%This will be used only for the single-trial cross-validation modality
ref_tr2=1;%Used only in mode 5
val_tr2=ref_tr2;%Used only in mode 5
for i=1:val_blocks
    %II.2 Splitting data and group labels into reference and test set
    if xval_type==1
        test_trials=(m_trials:-1:(m_trials-i+1));test_trials=sort(test_trials);
        disp('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _'),
        disp(['Causal cross-validation: testing trial(s) #',num2str(test_trials)]),
        disp(' ')
        ref_set=del_activ(del_trial_lab<min(test_trials),:);
        ref_labels=del_epoch_lab(del_trial_lab<min(test_trials));
        test_set=del_activ(del_trial_lab>=min(test_trials),:);
        test_labels=del_epoch_lab(del_trial_lab>=min(test_trials));
    elseif xval_type==0
        disp('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _'),
        disp(['Leave-one-out: testing trial #',num2str(i)])
        disp(' ')
        ref_set=del_activ(del_trial_lab~=i,:);
        ref_labels=del_epoch_lab(del_trial_lab~=i);
        test_set=del_activ(del_trial_lab==i,:);
        test_labels=del_epoch_lab(del_trial_lab==i);
    elseif xval_type<0
        disp('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _'),
        disp(['Only classification: trial #',num2str(i)])
        disp(' ')
        ref_set=del_activ(del_trial_lab==i,:);
        ref_labels=del_epoch_lab(del_trial_lab==i);
        test_set=del_activ(del_trial_lab==i,:);
        test_labels=del_epoch_lab(del_trial_lab==i);
    else
        disp('_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _'),
        if xval_type==2%All trials used as reference and validation
            %Each ith-trial will be tested on the basis of the remaining ones
            if  trial_counter==m_trials %i.e. length(ref_trials)+1
                validated_trial= validated_trial+1;
                ref_trials=[(1:validated_trial-1),(validated_trial+1:m_trials)];
                trial_counter=1;
            end
            disp(['Single-trial leave-one-out: testing trial #',num2str(validated_trial),' (ref: ',num2str(ref_trials(trial_counter)),')'])
            disp(' ')
            %
            ref_set=del_activ(del_trial_lab==ref_trials(trial_counter),:);
            ref_labels=del_epoch_lab(del_trial_lab==ref_trials(trial_counter));
            test_set=del_activ(del_trial_lab==validated_trial,:);
            test_labels=del_epoch_lab(del_trial_lab==validated_trial);
            trial_counter=trial_counter+1;
        elseif xval_type==3
            %Only the inmediately next trial is used as validation set
            disp(['Causal Single-trial leave-one-out: testing trial #',num2str(trial_counter+1),' (ref: ',num2str(trial_counter),')'])
            disp(' ')
            %
            ref_set=del_activ(del_trial_lab==trial_counter,:);
            ref_labels=del_epoch_lab(del_trial_lab==trial_counter,:);
            %
            test_set=del_activ(del_trial_lab==trial_counter+1,:);
            test_labels=del_epoch_lab(del_trial_lab==trial_counter+1);
            trial_counter=trial_counter+1;
        elseif xval_type==4
            %Only the first trial is used as estimation, rest for
            %validation
            disp(['Only 1st trial for estimating: testing trial #',num2str(trial_counter+1),' (ref: ',num2str(1),')'])
            disp(' ')
            %
            %NO need to do it twice
            if i<2
                ref_set=del_activ(del_trial_lab==1,:);
                ref_labels=del_epoch_lab(del_trial_lab==1,:);
            end
            %
            test_set=del_activ(del_trial_lab==trial_counter+1,:);
            test_labels=del_epoch_lab(del_trial_lab==trial_counter+1);
            trial_counter=trial_counter+1;
        elseif xval_type==5
            %Only the future trials used as validation set
            if  val_tr2==m_trials
                if ref_tr2<m_trials
                 ref_tr2=ref_tr2+1;
                 val_tr2=ref_tr2;
                end
            end
            %
            if ref_tr2<m_trials
                val_tr2=val_tr2+1;
                ref_set=del_activ(del_trial_lab==ref_tr2,:);
                ref_labels=del_epoch_lab(del_trial_lab==ref_tr2,:);
                %
                test_set=del_activ(del_trial_lab==val_tr2,:);
                test_labels=del_epoch_lab(del_trial_lab==val_tr2);
                
                disp(['Causal+full single-trial leave-one-out: testing trial #',num2str(val_tr2),' (ref: ',num2str(ref_tr2),')'])
                disp(' ')

            end
        end
    end
    %
    %Multi-class, regularized (kernelized-) Fisher Discriminant
    if multi
        %Activate some warnings only for multivariate analyses
        warning('on','class_trajec:wrongClassific');warning('on','class_trajec:GaussTests_error');warning('on','class_trajec:PairTests_error');
        warning('on','class_trajec:NaN_divergence_error');warning('on','class_trajec:multiv_error'); warning('on','class_trajec:Manova_error');
        disp('   Performing multi-class analyses...'),
        [~,basic_stats,~, issue_matrix]=kfd_multiv(ref_set,ref_labels,order,regul,...
            test_set,test_labels,balance_trajec_length,min_trajec_length,full_stats_disp);
        %If we cannot get predictions for all classes let's
        %eliminate the multivariate block
        
        %The issues matrix index is correct, it was used from may 2018 to aug 2018 with the new data I guess
        %in aug 2018 (final) is temporarily disconnected by the next line
        %issue_matrix=0;
        if  (   (~(  isempty(basic_stats) )) && (~issue_matrix)   )%Novelty may 18. Issues with convergence
            valid_predic=length(basic_stats.cum_misscla_class);
            valid_div=length(basic_stats.cum_diverg_trajec_class);
            if ~(   (valid_predic<n_epochs)&& (valid_div<n_epochs)  ) 
                global_percent=basic_stats.percent_misscla; %global_percent(global_percent>100)=100;
                cum_global_multi_stats(real_blocks_multi,1)=global_percent;
                cum_global_multi_stats(real_blocks_multi,2)=basic_stats.error;
                global_div=basic_stats.percent_div_trajec; %global_div(global_div>100)=100;
                cum_global_multi_stats(real_blocks_multi,3)=global_div;
                cum_global_multi_stats(real_blocks_multi,4)=basic_stats.error_trajec;
                %cum_global_multi_stats(real_blocks_multi,5)=basic_stats.uncertainty;%New 2013: Uncertainty measure
                %disp('Warning: Uncertainty measure used instead of JS divergence. Very easy to change in "kfd_cross_val.m"')
                cum_global_multi_stats(real_blocks_multi,5)=basic_stats.js;
                cum_global_multi_stats(real_blocks_multi,6)=basic_stats.lambda;
                cum_global_multi_stats(real_blocks_multi,7)=basic_stats.mhd;
                cum_global_multi_stats(real_blocks_multi,8)=basic_stats.lambda2;
                %cum_global_multi_stats(real_blocks_multi,9)=basic_stats.err_uncertainty;%Uncertainty measure error
                cum_global_multi_stats(real_blocks_multi,9)=basic_stats.jsErr;
                dimension_manova=basic_stats.D;%Correction to pairwise comparisons
                %
                %Class-by-class
                current_class_miss=100.*(basic_stats.cum_misscla_class./basic_stats.n_bins_per_class);
                current_class_miss(current_class_miss>100)=100;
                cum_multi_stats(real_blocks_multi,:,1)=current_class_miss;
                current_tr_miss=100.*(basic_stats.cum_diverg_trajec_class./basic_stats.cum_trajec_class);
                current_tr_miss(current_tr_miss>100)=100;
                cum_multi_stats(real_blocks_multi,:,2)=current_tr_miss;
                cum_multi_stats(real_blocks_multi,:,3)=basic_stats.class_js;
                %In versions over 1.0, the posterior probability and "on-line"
                %predicted class will be also stored in here.
                if full_stats_disp>0,disp(['Multi-class validation block #',num2str(real_blocks_multi)]),end
                real_blocks_multi=real_blocks_multi+1;
            else
                warning('kfd_cross_val:block_miss','Validation block missed')
                if issue_matrix; warning('kfd_crss_val:block_miss2','convergence issues'), end
            end
        end
    end
    %Next warnings will appear in 2-class analyses, where those statistics
    %are not generally used thus we better silent them
    warning('off','class_trajec:wrongClassific');warning('off','class_trajec:GaussTests_error');warning('off','class_trajec:PairTests_error');
    warning('off','class_trajec:NaN_divergence_error');warning('off','class_trajec:multiv_error'); warning('off','class_trajec:Manova_error');
    %
    if pairwise
        %Two-class, regularized (kernelized-) Fisher Discriminant. Select all possible task-epoch combinations
        disp('   Performing two-class analyses...'),
        for j=1:n_combi
            current_pair=combi(j,:);
            if full_stats_disp>0
                disp(['     Task-epochs ',num2str(current_pair(1)),' vs ',num2str(current_pair(2))]),
            end
            %Choosing the two task-epochs involved
            class_ref_set=ref_set((ref_labels==current_pair(1))|(ref_labels==current_pair(2)),:);
            class_ref_labels=ref_labels((ref_labels==current_pair(1))|(ref_labels==current_pair(2)));
            class_test_set=test_set((test_labels==current_pair(1))|(test_labels==current_pair(2)),:);
            class_test_labels=test_labels((test_labels==current_pair(1))|(test_labels==current_pair(2)));
            %
            [~,basic_stats,~]=kfd_multiv(class_ref_set,class_ref_labels,order,regul,...
                class_test_set,class_test_labels,balance_trajec_length,min_trajec_length,full_stats_disp); %Note: variable "full stats" is set to
            %                                                                 "0" regardless its value (avoiding a crowded command window
            %For a test block to be valid, all pairwise comparisons must be possible
            %
            if ~isempty(basic_stats)
                global_percent=basic_stats.percent_misscla; global_percent(global_percent>100)=100;
                cum_pair_stats(real_blocks_two,j,1)=global_percent;
                cum_pair_stats(real_blocks_two,j,2)=basic_stats.error;
                global_div=basic_stats.percent_div_trajec; global_div(global_div>100)=100;
                cum_pair_stats(real_blocks_two,j,3)=global_div;
                cum_pair_stats(real_blocks_two,j,4)=basic_stats.error_trajec;
                cum_pair_stats(real_blocks_two,j,5)=basic_stats.js;
                cum_pair_stats(real_blocks_two,j,6)=basic_stats.lambda;
                cum_pair_stats(real_blocks_two,j,7)=basic_stats.mhd;
                %
                %Correction to pairwise manova stats in order to be comaprable with multiv.
                la2=basic_stats.lambda2;
                if multi
                    if basic_stats.D<2, la2=la2*(basic_stats.D/dimension_manova); end
                end
                cum_pair_stats(real_blocks_two,j,8)=la2;
                %
                %In versions over 1.0, the posterior probability and "on-line"
                %predicted class will be also stored in here.
            else
                %If a comparison fails, the entire test block will be deleted
                block_valid=0;
            end
        end
        if block_valid
            if full_stats_disp>0, disp(['Two-class validation block ',num2str(real_blocks_two)]), end
            real_blocks_two=real_blocks_two+1;
        end
        block_valid=1;
    end
end
%Resizing the arrays by eliminating the test blocks which
%do not contain valid predictions
real_blocks_multi=real_blocks_multi-1;
real_blocks_two=real_blocks_two-1;
cum_global_multi_stats=cum_global_multi_stats(1:real_blocks_multi,:);
cum_multi_stats=cum_multi_stats(1:real_blocks_multi,:,:);
cum_pair_stats=cum_pair_stats(1:real_blocks_two,:,:);
%
%
%III-COMMAND WINDOW REPORTS AND PLOTS
%
%Note: display figures showing convergence in probability with the speed of movement
%and other auxiliary displays are not implemented in version 1.0 of this
%script. Version 1.0 only shows a limited, basic display.
%
%Command window display of adittional statistics and fill the otput argument
disp(' ');
disp('_____________________________')
disp('*STATISTICAL REPORT*'),
if full_stats_disp<2, warning('off','all'); end
%III.1 Multi-class statistics
%Each column of the next vector contains the following averaged and
%standart error statistics over all x-valid. realisations:
%   Column 1: Percent of  missclasified vectors (averaged over all
%   x-valid. realisations) for order O (=Fisher discriminant operating on the original or delayed
%   axes or linear kernel)
%   Column 2: SEM for order O
%   Column 3: Percent of outlier vectors (averaged over all x-valid.) for order O
%   Column 4: SEM for order O
%   Column 5: Percent of divergent task-epoch trajectories (averaged over all x-valid.) for order O
%   Column 6: SEM for order O
%   Column 7: Percent of outlier task-epoch trajectories (averaged over all x-valid.) for order O
%   Column 8: SEM for order O
%
if multi
    disp('__ __ __ __ __ __ __ __ __ __')
    disp('*Multi-class discriminant trajectory-analyses*')
    disp(' '),
    global_multi_stats(1)=mean(cum_global_multi_stats(:,1));
    global_multi_stats(2)=std(cum_global_multi_stats(:,1))./sqrt(real_blocks_multi);
    global_multi_stats(3)=mean(cum_global_multi_stats(:,2));
    global_multi_stats(4)=std(cum_global_multi_stats(:,2))./sqrt(real_blocks_multi);
    global_multi_stats(5)=mean(cum_global_multi_stats(:,3));
    global_multi_stats(6)=std(cum_global_multi_stats(:,3))./sqrt(real_blocks_multi);
    global_multi_stats(7)=mean(cum_global_multi_stats(:,4));
    global_multi_stats(8)=std(cum_global_multi_stats(:,4))./sqrt(real_blocks_multi);
    %Remove NaNs in the additional statistics
    JS_cum=cum_global_multi_stats(:,5); 
    JS_cum=JS_cum(JS_cum>0);%disp('WARNING that was uncomment for testing errors before Nov 2020')
    %disp('Control over JS sign temporarily removed, kfd_corss-val 469'), 
    global_multi_stats(9)=mean(JS_cum);
    global_multi_stats(10)=std(JS_cum)./sqrt(length(JS_cum));
    lambda_cum=cum_global_multi_stats(:,6);
    if (    any(isnan(lambda_cum))||(any(lambda_cum<0))    ), warning('kfd_cross_val:lambda','Summed wilks lambda statistics is negative or not a number'),end
    lambda_cum=lambda_cum(lambda_cum>0);
    global_multi_stats(11)=mean(lambda_cum);
    global_multi_stats(12)=std(lambda_cum)./sqrt(real_blocks_multi);
    mhd_cum=cum_global_multi_stats(:,7);
    if (    any(isnan(mhd_cum))||(any(mhd_cum<0))    ), warning('kfd_cross_val:mhd','Averaged across-means mahalanobis distances are negative or not a number'),end
    mhd_cum=mhd_cum(mhd_cum>0);
    global_multi_stats(13)=mean(mhd_cum);
    global_multi_stats(14)=std(mhd_cum)./sqrt(real_blocks_multi);
    lambda2_cum=cum_global_multi_stats(:,8);
    if (    any(isnan(lambda2_cum))||(any(lambda2_cum<0))    ), warning('kfd_cross_val:lambda2','Minimum wilks lambda statistics is negative or not a number'),end
    lambda2_cum=lambda2_cum(lambda2_cum>0);
    global_multi_stats(15)=mean(lambda2_cum);
    global_multi_stats(16)=std(lambda2_cum)./sqrt(real_blocks_multi);
    JS_cum_err=cum_global_multi_stats(:,9);
    JS_cum_err=JS_cum_err(JS_cum_err>0);%disp('WARNING that was uncomment for testing errors before Nov 2020')
    %disp('Control over JS sign temporarily removed, kfd_corss-val 488'), 
    global_multi_stats(17)=mean( JS_cum_err);
    %
    %a) Global statistical tests of normality across validation blocks. "global_multi_tests" contents:
    %   Column 1: Row 1: p-value of Chi2gof. Row 2: df. Row 3: stastitic value.
    %   Column 2: Row 1: p-value of ks. Row 2: n. Row 3: stastitic value.
    %   Column 3: Row 1: p-value of Liliefors. Row 2: n. Row 3: stastitic value.
    if real_blocks_multi>3 %Less than three real validation blocks cannot provide realible statistics
        global_multi_tests=stat_tests(cum_global_multi_stats(:,1));
        %Exactly the same for the global percent of divergent trajectories
        tr_global_multi_tests=stat_tests(cum_global_multi_stats(:,3));
        %b) Multi-class analyses: epoch-by-epoch results
        multi_tests=zeros(n_epochs,3,3);tr_multi_tests=zeros(n_epochs,3,3);
        if ~(  (valid_predic<n_epochs) && (valid_div<n_epochs)    )
            for i=1:n_epochs
                stats_predic=cum_multi_stats(:,i,1);
                stats_div=cum_multi_stats(:,i,2);
                if  (  ~any(any(isnan(stats_predic)))  &&    ~any(any(isnan(stats_div))) )
                    multi_tests(i,:,:)=stat_tests(stats_predic);
                    %tr_multi_tests(i,:,:)=stat_tests(stats_predic);
                    %disp('WARNING that was uncomment for testing errors before Nov 2020')
                    tr_multi_tests(i,:,:)=stat_tests(stats_div);
                end
            end
        end
    else
        warning('kfd_cross_val:no_enough_val_blocks',['Only ',num2str(real_blocks_multi),' validation sets. No normality tests reported']),
        global_multi_tests=NaN.*ones(3,3); tr_global_multi_tests=NaN.*ones(3,3);%See "stat_tests.m" for more info
        multi_tests=NaN.*ones(n_epochs,3,3);tr_multi_tests=NaN.*ones(n_epochs,3,3);
    end
    %Command-window display of results
    global_multi_stats_report(order,global_multi_stats,global_multi_tests,tr_global_multi_tests);
    if full_stats_disp>0
        class_multi_stats_report(order,cum_multi_stats,multi_tests,tr_multi_tests,full_stats_disp);
    end
end
%_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
%
if pairwise
    %III.2 Two-class statistics
    disp('__ __ __ __ __ __ __ __ __ __')
    disp('*Two-class discriminant trajectory-analyses*')
    pair_stats(:,1)=mean(cum_pair_stats(:,:,1));
    pair_stats(:,2)=std(cum_pair_stats(:,:,1))./sqrt(real_blocks_two);
    pair_stats(:,3)=mean(cum_pair_stats(:,:,2));
    pair_stats(:,4)=std(cum_pair_stats(:,:,2))./sqrt(real_blocks_two);
    pair_stats(:,5)=mean(cum_pair_stats(:,:,3));
    pair_stats(:,6)=std(cum_pair_stats(:,:,3))./sqrt(real_blocks_two);
    pair_stats(:,7)=mean(cum_pair_stats(:,:,4));
    pair_stats(:,8)=std(cum_pair_stats(:,:,4))./sqrt(real_blocks_two);
    %
    %Control over nonsense values. This was ommited in multivariate because normaly occurs in 2-class manova
    js=cum_pair_stats(:,:,5);
    lambda=cum_pair_stats(:,:,6);
    mhd=cum_pair_stats(:,:,7);
    lambda2=cum_pair_stats(:,:,8);
    %
    means_js=zeros(n_combi,1);means_lambda=zeros(n_combi,1);means_mhd=zeros(n_combi,1);means_lambda2=zeros(n_combi,1);
    es_js=zeros(n_combi,1);es_lambda=zeros(n_combi,1);es_mhd=zeros(n_combi,1);es_lambda2=zeros(n_combi,1);
    %
    for com=1:n_combi
        js_c=js(:,com);
        if (    any(isnan(js_c))||any(js_c<0)||any(js_c>10^10) ), warning('kfd_cross_val:lambda','Jensen-Shannon is negative or not a number'),end
        js_c=js_c((js_c>0)&(js_c<10^10));
        means_js(com)=mean(js_c);
        es_js(com)=std(js_c)./sqrt(length(js_c));
        %
        lambda_c=lambda(:,com);
        if (    any(isnan(lambda_c))||any(lambda_c<0)||any(lambda_c==1) ), warning('kfd_cross_val:lambda','Summed wilks lambda statistics is negative; one or not a number'),end
        lambda_c=lambda_c(  (lambda_c>0)&(lambda_c<1)  );
        means_lambda(com)=mean(lambda_c);
        es_lambda(com)= std(lambda_c)./sqrt(length(lambda_c));
        %
        mhd_c=mhd(:,com);
        if (    any(isnan(mhd_c))||any(mhd_c<0)||any(mhd_c>10^10) ), warning('kfd_cross_val:lambda','MHD negative, too big, infinite or not a number'),end
        mhd_c=mhd_c(  (mhd_c>0)&(mhd_c<10^10)  );
        means_mhd(com)=mean(mhd_c);
        es_mhd(com)= std(mhd_c)./sqrt(length(mhd_c));
        %
        lambda2_c=lambda2(:,com);
        if (    any(isnan(lambda2_c))||any(lambda2_c<0)||any(lambda2_c==1) ), warning('kfd_cross_val:lambda2','Min wilks lambda statistics normalized by the sig. dims. is neg.,  one or not a number'),end
        lambda2_c=lambda2_c(  (lambda2_c>0)&(lambda2_c<1)  );
        means_lambda2(com)=mean(lambda2_c);
        es_lambda2(com)= std(lambda2_c)./sqrt(length(lambda2_c));
        %
    end
    pair_stats(:,9)=means_js;
    pair_stats(:,10)=es_js;
    pair_stats(:,11)=means_lambda;
    pair_stats(:,12)=es_lambda;
    pair_stats(:,13)= means_mhd;
    pair_stats(:,14)=es_mhd;
    pair_stats(:,15)=means_lambda2;
    pair_stats(:,16)=es_lambda2;
    %
    %Each column of the next vector contains an averages and SEM over all
    %pairwise task-epoch comparisons and one column for each x-val realisation
    global_pair_stats(1)=mean(pair_stats(:,1));
    %global_pair_stats(2)=std(pair_stats(:,1))./sqrt(n_epochs);
    global_pair_stats(2)=mean(pair_stats(:,2));%Retain instead the "mean of the errors" (optional)
    
    global_pair_stats(3)=mean(pair_stats(:,3));
    %global_pair_stats(4)=std(pair_stats(:,3))./sqrt(n_epochs);
    global_pair_stats(4)=mean(pair_stats(:,4));
    
    global_pair_stats(5)=mean(pair_stats(:,5));
    %global_pair_stats(6)=std(pair_stats(:,5))./sqrt(n_epochs);
    global_pair_stats(6)=mean(pair_stats(:,6));
    
    global_pair_stats(7)=mean(pair_stats(:,7));
    %global_pair_stats(8)=std(pair_stats(:,7))./sqrt(n_epochs);
    global_pair_stats(8)=mean(pair_stats(:,8));
    
    global_pair_stats(9)=mean(pair_stats(:,9));
    %global_pair_stats(10)=std(pair_stats(:,9))./sqrt(n_epochs);
    global_pair_stats(10)=mean(pair_stats(:,10));
    
    global_pair_stats(11)=mean(pair_stats(:,11));
    %global_pair_stats(12)=std(pair_stats(:,11))./sqrt(n_epochs);
    global_pair_stats(12)=mean(pair_stats(:,12));
    
    global_pair_stats(13)=mean(pair_stats(:,13));
    %global_pair_stats(14)=std(pair_stats(:,13))./sqrt(n_epochs);
    global_pair_stats(14)=mean(pair_stats(:,14));
    
    global_pair_stats(15)=mean(pair_stats(:,15));
    %global_pair_stats(16)=std(pair_stats(:,15))./sqrt(n_epochs);
    global_pair_stats(16)=mean(pair_stats(:,16));
    
    %
    %a) Global test between across-class means. Same is in previous lines
    if real_blocks_two>3 %Less than three real validation blocks cannot provide realible statistics
        global_pair_tests=stat_tests(pair_stats(:,1));
        %Exactly the same for the global percent of divergent
        %trajectories, stored in "tr_global_multi_tests" matrix
        tr_global_pair_tests=stat_tests(pair_stats(:,3));
        %b) Two-class analyses: Pairwise-class combinations results
        pair_tests=zeros(n_combi,3,3);tr_pair_tests=zeros(n_combi,3,3);
        for j=1:n_combi
            pair_tests(j,:,:)=stat_tests(cum_pair_stats(:,j,1));
            tr_pair_tests(j,:,:)=stat_tests(cum_pair_stats(:,j,3));
        end
    else
        warning('kfd_cross_val:no_enough_val_blocks',['Only ',num2str(real_blocks_two),' validation sets. No statistical tests reported']),
        global_pair_tests=NaN.*ones(3,3);tr_global_pair_tests=NaN.*ones(3,3);%See "stat_tests.m" for more info
        pair_tests=NaN.*ones(n_combi,3);tr_pair_tests=NaN.*ones(n_combi,3);
    end
    global_2class_stats_report(order,global_pair_stats,global_pair_tests,tr_global_pair_tests);
    if full_stats_disp>0
        class_2class_stats_report(order,cum_pair_stats,pair_tests,tr_pair_tests,combi);
    end
end
warning('on','all');
%_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
%
%III.3 Returning only selected statistics. This can be trivially changed
if multi
    report_stats.multiClass_err=global_multi_stats(1);
    report_stats.bars_multiClass_err=global_multi_stats(2);
    report_stats.multiClass_diver=global_multi_stats(5);
    report_stats.bars_multiClass_diver=global_multi_stats(6);
    report_stats.js=global_multi_stats(9);
    report_stats.bars_js=global_multi_stats(10);
    report_stats.lambda=global_multi_stats(11);
    report_stats.bars_lambda=global_multi_stats(12);
    report_stats.mhd=global_multi_stats(13);
    report_stats.bars_mhd=global_multi_stats(14);
    report_stats.lambda2=global_multi_stats(15);
    report_stats.bars_lambda2=global_multi_stats(16);
    %Mean error bars across cross-validations based just gaussian outliers
    %(for completing single-trial stats without bootstraping).
    %see details hardocded in class_trajec. 
    report_stats.meanEbGauss=global_multi_stats(3);
    report_stats.meanEbTrGauss=global_multi_stats(7);
    report_stats.meanEbJSGauss=global_multi_stats(17);
    %Just all results
    report_stats.cum_global_multi_stats=cum_global_multi_stats;
    report_stats.cum_multi_stats=cum_multi_stats;%All results
end
%
%b) Pairwise-discriminating statistics
%
%Next vector contains results for all possible pairwie comparisons
%"combi" is matrix with 2 columns and n_epochs!/2!(n_epochs�2)! rows, where each row contains the
%index of the two task-epochs to be compared with.
%
if pairwise
    %Two-class reports
    report_stats.twoClass_2mean_err=global_pair_stats(1);
    report_stats.twoClass_2std_err=global_pair_stats(2);%Note:'mean of standart errors' is contained in here instead of the standart error
    report_stats.twoClass_2mean_div=global_pair_stats(5);
    report_stats.twoClass_2std_div=global_pair_stats(6);
    report_stats.twoClass_2mean_js=global_pair_stats(9);
    report_stats.twoClass_2std_js=global_pair_stats(10);
    report_stats.twoClass_2mean_lambda=global_pair_stats(11);
    report_stats.twoClass_2std_lambda=global_pair_stats(12);
    report_stats.twoClass_2mean_mhd=global_pair_stats(13);
    report_stats.twoClass_2std_mhd=global_pair_stats(14);
    report_stats.twoClass_2mean_lambda2=global_pair_stats(15);
    report_stats.twoClass_2std_lambda2=global_pair_stats(16);
    %
    report_stats.twoClass_mean_err=pair_stats(:,1);
    report_stats.twoClass_std_err=pair_stats(:,2);
    report_stats.twoClass_mean_div=pair_stats(:,5);
    report_stats.twoClass_std_div=pair_stats(:,6);
    report_stats.twoClass_mean_js=pair_stats(:,9);
    report_stats.twoClass_std_js=pair_stats(:,10);
    report_stats.twoClass_mean_M=pair_stats(:,13);
    report_stats.twoClass_std_M=pair_stats(:,14);
    report_stats.cum_pair_stats=cum_pair_stats;%All results
end
%
disp(' ');
disp('Summary:')
disp(['Order ',num2str(order),' regul ',num2str(regul)]),
if multi
    disp(['CE multi: ',num2str(report_stats.multiClass_err),' (',num2str(report_stats.bars_multiClass_err),') patterns']),
    disp(['DIV Trajec. multi ',num2str(report_stats.multiClass_diver),' (',num2str(report_stats.bars_multiClass_diver),') patterns']),
    disp(['J-S diverg. multi: ',num2str(report_stats.js),' (',num2str(report_stats.bars_js),') patterns']),
    disp(['Min Wilks lambda. multi/signifc. dimensions: ',num2str(report_stats.lambda2),' (',num2str(report_stats.bars_lambda2),') ']),
    disp(['Mean across-class mahalanobis. multi: ',num2str(report_stats.mhd),' (',num2str(report_stats.bars_mhd),') ']),
end
if pairwise
    disp(' '),
    disp(['Mean CE two-class: ',num2str(report_stats.twoClass_2mean_err), '%; Mean div. Trajec. two-class ',num2str(report_stats.twoClass_2mean_div),'%' ]);
    disp(['J-S diverg. two-class: ',num2str(report_stats.twoClass_2mean_js),' (',num2str(report_stats.twoClass_2std_js),') %']),
    disp(['Min Wilks lambda. two-class/signifc. dimensions: ',num2str(report_stats.twoClass_2mean_lambda2),' (',num2str(report_stats.twoClass_2std_lambda2),') %']),
    disp(['Mean across-class mahalanobis. two-class: ',num2str(report_stats.twoClass_2mean_mhd),' (',num2str(report_stats.twoClass_2std_mhd),') %']),
end

disp('*End of main statistics report*'),
disp('_____________________________')


