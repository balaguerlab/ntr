function product=multinom_kernel(data_ref,order,data_val,beta,ganma)
%Private, auxiliar function.
%Computes the scalar product of any two vectors of a high-dimensional, feature space.
%High-dimensional space is defined by all possible products between
%original axes (i.e. inhomogenoues polynomial kernel).
%_________________________________________________________________________
%Inputs: 
%   beta, ganmma (1x1) = Constants of little relevance in general. For example, 
%                     expansion order O=2, if one wants to remove the multiplicity in the 
%                     products, choose beta=order.^(1/(order-1)); gannma=order.^(order/(1-order));
%
%   order (1x1) = Polynomial order of activity products.
%
%   data_ref (1 x n_dimensions (e.g. neurons)) = Must contain activity values over
%                                                     time.
%   data_val (1 x n_dimensions (e.g. neurons)) = Same for the validation data which 
%                                     will be then projected into the reference
%                                     eignevectors (please see comments in the 
%                                     code).
%Outputs: 
%   
%   product (1x1)= Value of the scalar product.
%_________________________________________________________________________
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

if nargin<4
    beta=1; ganma=1;
end
if nargin<3
    data_val=data;
end
product=ganma*(   ((1+ beta*data_val*data_ref')^order) - 1     );