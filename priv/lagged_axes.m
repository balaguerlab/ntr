function d_data=lagged_axes(data,lags)
%A minimal embedding can be acheived just by substituting original axis  with
%the optimum delayed ones ("whitening by using delays"). It migth be useful
%in cases where axes are correlated but none can be really discardedand
%dimensionality do not have to be increased
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
[n_patterns,n_channels]=size(data);
d_data=zeros(n_patterns,n_channels+1); %Includes the undelayed first axis and the 2-delayed one (in lags(1)).                                                                                     after that (lags(2)...lags(n_channels+1)
%                                      % After that (lags(2)...lags(n_channels+1)contains a 1-delay for each lag.
%
d_data(:,1)=data(1:n_patterns,1);%1st column of 'd_data' matrix is the first time series undelayed.
lost_vectors=zeros(n_channels,1);
for j=2:n_channels+1,
    lost_vectors(j-1)=lags(j-1)-1;
    d_data(1:n_patterns-lost_vectors(j-1),j)=data(   lags(j-1):n_patterns,j-1    );
end
d_data=d_data(1:n_patterns-max(lost_vectors),:);

    