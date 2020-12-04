function boot_lab_indexes=balance_epochs(epoch_labels,factor_disprop)
%Private, auxiliar file. Size of the longest epoch cannot exceed x "factor_disprop" the
%size of the shortest epoch.
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
%@ebalaguer: corrected april 012
%
%__________________________________________________________________________
%
%warning('on','equilibrating_epochs:Eq')
warning('off','equilibrating_epochs:Eq')
if nargin<2
    factor_disprop=10;
elseif factor_disprop<=0
    factor_disprop=inf;
    disp('Task-epochs retain their original size during analyses'),
end
m_lab=max(epoch_labels);min_lab=min(epoch_labels(epoch_labels>-1));l_lab=length(epoch_labels);
set_labs=[];n_bins_lab=[];
counter_labs=0;
%This code is very silly an histo would do but is OK
for i=min_lab:m_lab
    if ~(all(i.*ones(l_lab,1)-epoch_labels))
        set_labs=[set_labs,i];
        counter_labs=counter_labs+1;
        n_bins_lab=[n_bins_lab,length(epoch_labels(epoch_labels==set_labs(counter_labs)))];
    end
end
n_lab=length(set_labs);
%
min_length=min(n_bins_lab); boot_lab_indexes=[];time_order=(1:l_lab)';
allowed_l=factor_disprop*min_length;
%
%Remove entire trajectories when needed
for i=1:n_lab
    lab_indexes=time_order(epoch_labels==set_labs(i));%Real order corresponding to this label
    frac=n_bins_lab(i)/min_length;
    if (abs(frac)>factor_disprop)
        warning('equilibrating_epochs:Eq',['Epoch ',num2str(set_labs(i)),' length limited to x ',num2str(factor_disprop),' the smallest epoch']),
        %Removing the ones who exceed the criterion.
        %for that means, only entire trajectories can be randomly taken
        %out. Number of removed vectors have to be the same for each trial.
        removed=round( (n_bins_lab(i)-allowed_l) );
        lab_index_X_trial=time_order(epoch_labels==set_labs(i));
        %shuff_ind=shuff_data(lab_index_X_trial);%Randomly re-ordering but preserving consecutive vectors.unncmented 29 aug 17
        %shuff_ind=shuff_ind(removed:end);
        %shuff_ind=shuff_ind(1:(end-removed));
        shuff_ind=lab_index_X_trial(1:(end-removed));%Commented 29 aug 17
        remain_ind=sort(shuff_ind);
        boot_lab_indexes=[boot_lab_indexes;remain_ind];
    else
        boot_lab_indexes=[boot_lab_indexes;lab_indexes];
    end
end
boot_lab_indexes=sort(boot_lab_indexes);
