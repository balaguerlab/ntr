function visualization(data,order,trial_disp,fixed_lag,do_dcm,make_video,trials_flow_disp,...
    balance_task_epochs,regul,incl_subop_lags,lost_frac,do_record,videoQuality,no_flow_field)
%v 2
%Displays a "single-trial" (short time series) using kernel-PCA (Sch�lkopf et al., 1998)
%and "flow" or "velocity vectors" of multiple-trials using kernel-FDA (Mika et al., 2000).
%
%Orders #1 and higher "order" will be displayed in a 2x2 Figure.
%It is only an orientative display, not precisely reflecting high-dimensional 
%detailed statistics.
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
%
%Log of changes: Please specify here your code modifications
%(#Line@author: Change description). This will be useful if assistance is
%required
%
%   @ebb using orthogonal projections of reference data
%   19-Jun-2015 #212,220@ebb:new input argument for not dispalying the flow
%   field "no_flow_field"
%__________________________________________________________________________
%
%Inputs:
%   data (number of time bins x (dimensionality of neural responses+3) ), and with the following
%                                                                         structure:
%
%   (note: dimensionality of neural responses refers e.g. to the number of simultaneously
%    recorded "neurons" and/or delayed version of th3m)
%
%           -Columns "1:end-3" of "data" matrix:  Must contain activity values over
%                                       time.
%           -Column "end-1" of "data" matrix: Must contain natural numbers>0, they are
%                                      alternative labelling used only for
%                                      display (number of
%                                      labels smaller than 8). If all "epochs"
%                                      are to be displayed, this column has
%                                      to be a copy of "end-2" one.
%                                      NOTE: these labels will determine the groups
%                                      displayed in the smoothed
%                                      trajectory (upper plots). 
%           -Column "end-2" of "data" matrix: Must contain natural numbers>0, labelling
%                                      the different stimulus or behavioral "epochs" in which
%                                      the experimentalist segments the
%                                      task. "-1" encodes "no-labelled"
%                                      time-bins. NOTE: used for colouring
%                                      arrows in lower plots.
%           -Last column of "data" matrix: Must contain natural numbers>0, labelling the
%                                      different trials of the task.
%   order (1x1) Natural number>0. Degree of the product among spike densities across units.
%
%   trial_disp (1x1) Natural."3D" smoothed trajectories display.
%                      Only one trial at a time is allowed to be displayed.
%   fixed_lag (1x1) Natural number, indicating the maximum lag (in time
%           bins units) which should have every axes. If <=0, lags will be
%           obtained as the average/maximum lag across the "first" minimum between cross-correlation 
%           functions (see code below in dcm.m for details).
%
%   do_dcm (1x1) Important note: Only relevant for the flow display, not to the
%       trajectory display (in which there is always a dcm performed). Performs a delay-coordinate map expansion before kernel
%       expansion.
%
%   make_video 1x1) Natural number indicating the trial to be displayed. 
%             If>0 a video of a single trajectory will be displayed
%             instead the static plot of the trial, regardless the value of
%             "trial_disp".
%
%   balance_task_epochs (1x1) This parameters controls the disbalanced in epochs size:
%                 If>0, the number of time bins of the longest
%                 task-epochs is, at maximum "x balance_task_epochs" of the shortest
%                 one.
%
%   trials_flow_disp (1x2) First and last trials "flow" to be displayed in three
%                   maximum discriminating (canonical) axis. If<1, no
%                   display will be produced.

%   regul (1x1) Regularization constant, only fo flow display
%__________________________________________________________________________
figure
set(gcf,'Color',[1,1,1],'name',...
     ['Single-trial complete trajectory and vector field for the original and expanded space (order=',num2str(order),',max. lag ',num2str(fixed_lag),'bins)']),
%
activ=data(:,1:end-3);
trial_labels=data(:,end);
phase_labels=data(:,end-1);%remaining: "phase_labels" are those used onyl for trajectory display.
epoch_labels=data(:,end-2);
%
%I. SMOOTHED TRAJECTORIES OF A SINGLE TRIAL
disp('_____________________________')
disp('*PERFORMING VISUALIZATIONS...*')
if (trial_disp>0)
    %
    %I.1. Checking that such a trial exists
    if trial_disp>max(trial_labels)
        warning('visualization:InvalidTr','This trial does not exists, no trajectory plot will be produced')
        subplot(221), text(0.5,0.5,'This trial does not exists')
        subplot(222), text(0.5,0.5,'This trial does not exists')
    else
    %I.2 Select the activity from this trial
        activ_tr=activ((trial_labels==trial_disp),:);
        phase_labels_tr=phase_labels((trial_labels==trial_disp),:);
        %
        %I.3 Reduced data for activity product order=1
        warning('off','all')
        del_activ=dcm(activ_tr,fixed_lag);
        indexes=balance_epochs(phase_labels_tr(1:length(del_activ(:,1))),balance_task_epochs);%Returns the indexes of the radomly selected labels
        del_activ=del_activ(indexes,:);
        reduced_data=kpca(activ_tr);
        warning('on','all')
        display_trial(reduced_data,phase_labels_tr(1:length(reduced_data(:,1))),trial_disp,1,1);
        %
        %
        %
        %
        %
        %
        %
        %I.4 Using a delay-coordinate map and data reduction for the selected order.
        warning('off','all')
        reduced_data=kpca(del_activ,order);
        warning('on','all')
        %
        %Display a video or a plot for the selected activity expansion
        %order.
        if make_video>0
            video_trial(reduced_data,phase_labels_tr(1:length(reduced_data(:,1))),trial_disp,order,2);
            %
            if do_record>0
                %If recording a trial, create a new fig. and close it
                figure
                video_trial(reduced_data,phase_labels_tr(1:length(reduced_data(:,1))),trial_disp,order,-1,do_record,videoQuality);
                close (gcf);
            end
        else
            display_trial(reduced_data,phase_labels_tr(1:length(reduced_data(:,1))),trial_disp,order,2);
        end
    end
    disp('...3D trajectory displayed')
end
%
%
%
%II. TRAJECTORY FLOW

if length(trials_flow_disp)==2
    %
    %II.1. Checking that there are not too many trials to display
    if (max(trials_flow_disp)>max(trial_labels))||(min(trials_flow_disp<1))
        warning('visualization:InvalidTrRange','Invalid trial range selected, no "flow" plot will be produced')
        subplot(223), text(0.5,0.5,'Invalid trials range')
        subplot(224), text(0.5,0.5,'Invalid trials range')
    else
        disp('...displaying flow')
        %
        %II.2 Select the activity from several epochs
        activ_tr=activ(  ((trial_labels>=trials_flow_disp(1))&(trial_labels<=trials_flow_disp(2))),:);
        labels=epoch_labels(  ((trial_labels>=trials_flow_disp(1))&(trial_labels<=trials_flow_disp(2)))  );
        %trial_labels_disp=trial_labels(  ((trial_labels>=trials_flow_disp(1))&(trial_labels<=trials_flow_disp(2)))  );
        %
        %Use only this map if requested for the statistics
        del_activ=activ_tr;
        if do_dcm>0
            warning('off','all'),
            do_display=1;
            %Use or not fixed lag may improve visualization
            del_activ=dcm(activ_tr,0,incl_subop_lags,do_display,lost_frac);
            %del_activ=dcm(activ_tr,5);
            %del_activ=dcm(activ_tr,7);
            
            %PLaying around
            %del_activ=dcm(activ_tr,2);
            %
           warning('on','all'),
            %
        end  
        l=length(del_activ(:,1));
        labels=labels(1:l,:);
        %
        %II.3 Reduced data in the maximum discriminating subspace for
        %activity product order=1 and for the selected "order" (using multi-class regularized
        %Fisher Discriminant in high dimensions)
        %
        %***** STANDART FUNCTIONING
        warning('off','all'),
        indexes=balance_epochs(labels,balance_task_epochs);%Returns the indexes of the radomly selected labels
        disp(['Balanced number of patterns ',num2str(length(indexes))]),
        del_activ=del_activ(indexes,:);labels=labels(indexes,:);
        %
        %Novelty: othogonal projections of reference data
        %display_flow(reduced_data,labels,trials_flow_disp,1,3);%deprecated
        %but is perfectly ok
        reduced_data=kfd_multiv(activ_tr(indexes,:),labels,1,regul);
        %reduced_data=kfd_multiv_orthogonal(activ_tr(indexes,:),labels,1,regul);
        warning('on','all'),
        display_flow2(reduced_data,labels,trials_flow_disp,1,3,no_flow_field);%
        %
        warning('off','all'),
        %Novelty: othogonal projections of reference data
        reduced_data=kfd_multiv(del_activ,labels,order,regul);
        %reduced_data=kfd_multiv_orthogonal(del_activ,labels,order,regul);
        warning('on','all'),
        %display_flow(reduced_data,labels,trials_flow_disp,order,4);%deprecated
        display_flow2(reduced_data,labels,trials_flow_disp,order,4,no_flow_field);
        pause(5),
     
   
       
    end
end
%Example of figure name, should you want to use it
set(gcf,'Color',[1,1,1],'name',...
     ['Single-trial complete trajectory (order=',num2str(order),',max. lag=',...
     num2str(fixed_lag),'bins, regul ',num2str(regul),')']),
