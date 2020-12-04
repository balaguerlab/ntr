function KL=kl_diverg(observed,expected,min_allowed_prob)
%Private, auxiliary file. version 2018
%Naive information-theoretic test of differences between two pdf's
%Discretized KL(distribution1,distribution2) is defined as
%sum for all 'i' of:  (distribution1(i)*log(distribution1(i)/distribution2(i)).
%Zero if distribution1(i)=distribution2(i) for each 'i'
%Inputs: histograms of both distributions (multi-dim).
%Output: (1x1) scalar contaning the euclidean length of the KL divergence vector. 
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
warning('off','kl_diverg:zeroCounts'),
if nargin<3, min_allowed_prob=1e-6; end 
%Setting the same size of both histograms
[n1,columns_o]=size(observed);[n2,columns_e]=size(expected);
if (n1~=n2), warning(20,'Both histograms forced to have the same length'),
end
 if n1>n2, n=n2;
 else 
     n=n1;
 end
if (columns_o<columns_e), expected=expected(:,1:columns_o); %columns=columns_o;
else
    observed=observed(:,1:columns_e); %columns=columns_e;
end
%
%Shouts if any count is zero
minimum_q=min(min(observed));minimum_p=min(min(expected));
if (minimum_q<min_allowed_prob)||(minimum_p<min_allowed_prob)
    warning('kl_diverg:zeroCounts',['Some counts inferior to the minimum allowed prob=',num2str(min_allowed_prob),' replaced by this value, then histograms are normalized']),
    min_o=min_allowed_prob; min_e=min_allowed_prob;
    observed(observed<min_allowed_prob)=min_o; 
    expected(expected<min_allowed_prob)=min_e; 
end
%
%(re-) normalization for producing proper pdfs per dimension
%i.e. separately nromalizing each column
observed_dist=observed./repmat(sum(observed,1),n,1);
expected_dist=expected./repmat(sum(expected,1),n,1);
KL=norm(observed_dist'*log(observed_dist./expected_dist));
KL=real(KL);
if KL<-0.0001
    warning(['Somethign wrong: KL=',num2str(KL)]); %Remember KL is not upper bounded
end
