function basic_stats=fill_predic(basic_stats,set_lab_ref,set_lab)
%Private, auxiliar file for cleaning code. Do not modify.
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
%@ebalaguer: corrected april 012
%
%_________________________________________________________________
%
n_epochs=length(set_lab_ref);
%Real values
true_se=basic_stats.cum_misscla_class;
true_bins=basic_stats.n_bins_per_class;
true_div=basic_stats.cum_diverg_trajec_class;
true_tr=basic_stats.cum_trajec_class;
true_prob=basic_stats.posterior_probs_vectors;
true_lik=basic_stats.lik_vectors;
true_class_js=basic_stats.class_js;
n_patterns=length(true_prob(1,:));
%
%Next vectors will be filled with real or averaged predictions
fill_se_class=zeros(1,n_epochs);fill_bins_class=zeros(1,n_epochs);
fill_diverg_trajec_class=zeros(1,n_epochs);fill_trajec_class=zeros(1,n_epochs);
fill_prob=zeros(n_epochs,n_patterns); fill_lik=zeros(n_epochs,n_patterns);
fill_class_js=zeros(1,n_epochs);
%
count=1;
for i=1:length(set_lab_ref),
    if any(set_lab==set_lab_ref(i)),
        fill_se_class(i)=true_se(count);
        fill_bins_class(i)=true_bins(count);
        fill_diverg_trajec_class(i)=true_div(count);
        fill_trajec_class(i)=true_tr(count);
        fill_prob(i,:)=true_prob(count,:);
        fill_lik(i,:)=true_lik(count,:);
         fill_class_js(i)=true_class_js(count);
        count=count+1;
    else
        messag=['Class number ',num2str(i),' is not present, replaced by an average']; 
        warning('fill_predic:Missing class',messag);
        fill_se_class(i)=mean(true_se);
        fill_bins_class(i)=mean(true_bins);
        fill_diverg_trajec_class(i)=mean(true_div);
        fill_trajec_class(i)=mean(true_tr);
        fill_prob(i,:)=zeros(1,n_patterns);
        fill_lik(i,:)=zeros(1,n_patterns);
        fill_class_js(i)=min(true_class_js);
    end
end
basic_stats.cum_misscla_class=fill_se_class;
basic_stats.n_bins_per_class=fill_bins_class;
basic_stats.cum_diverg_trajec_class=fill_diverg_trajec_class;
basic_stats.cum_trajec_class=fill_trajec_class;
basic_stats.posterior_probs_vectors=fill_prob;
basic_stats.lik_vectors=fill_lik;
basic_stats.class_js=fill_class_js;