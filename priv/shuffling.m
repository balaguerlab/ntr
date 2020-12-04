function shuffled_data=shuffling(ordered_data,n_corr)
%Private, simple utility for cleaning the code. Shuffles rows
%(and columns by uncommenting the corresponding code lines)
%of the ordered data. n_corr simply reffers to the number of consecutive
%time bins that has to be preserved during the shuffling.
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
%
%__________________________________________________________________________
%
[n_patterns,n_units]=size(ordered_data);
%Calculate groups, lower bound
n_groups=floor(n_patterns/n_corr);
%rand('state',0);

a=randperm(n_groups);%a permutation of the groups of 'n_corr' elements
shuffled_data=zeros(n_patterns,n_units);
for i=1:n_groups,
   b=randperm(n_units);
        shuffled_data(  (i-1)*n_corr+1 : i*n_corr , : )=...
            ordered_data( (a(:,i)-1)*n_corr+1 : a(:,i)*n_corr ,  b );
    %warning('shuffling:colShuff','Columns unshuffled'), %
%                   shuffled_data(  (i-1)*n_corr+1 : i*n_corr , : )=...
%                       ordered_data( (a(:,i)-1)*n_corr+1 : a(:,i)*n_corr ,:);
end
%Latest elements in 'shuffled_data_1' (if any) take the value of the last event stored in previous
%loop, i.e. shuffled_data_1(n_groups*n_corr,:
remaining=n_patterns-n_groups*n_corr;
if remaining>0
    %remaining=ceil(remaining);% Upper integer rounded
    shuffled_data(end-remaining+1:end,:)= ...
        repmat(shuffled_data(n_groups*n_corr,:),remaining,1);
end