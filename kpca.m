function projec_data=kpca(data,order,data_valid)
%Kernel principal components (Schölkopf et al., 1998). v4.0b. Adapted for multiple single-unit recordings.
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
%
%
%__________________________________________________________________________
%Inputs:
%   order (1x1) = Polynomial order of activity products
%   data (n_time x n_dimensions (e.g. neurons)) = Must contain neural responses values over
%                                                 time.
%   data_valid (n_time x n_dimensions (e.g. neurons)) = Same for the validation data which
%                                     will be then projected into the reference
%                                     eigenvectors (please see comments in the
%                                     code).
%Outputs
%
%   projec_data =  n_patterns_valid x n_axes, reduced data.
%__________________________________________________________________________

if nargin<3, data_valid=data; end
if nargin<2, order=1; warning('kpca:noPolyOrder','Polynomial order not specified, set to 1'); end
if nargin<1
    error('At least, the data matrix have to be specified'),
end
disp(['   Performing kernel principal components projection of order ',num2str(order),'...']),
%
%I-COMPUTE "GRAM" MATRIX. See for example Scholkoff & Smola
%"Learning with Kernels", Springer 2002, chapter 14 pags 429-31.
n_patterns=length(data(:,1));
K=zeros(n_patterns,n_patterns);
n_axes=3;% This is just for qualitative visualization, therefore we would always retain only
%         the projection of data into the three main eigenvectors.
if n_axes>length(data(1,:)), n_axes=length(data(1,:)); end
%
for i=1:n_patterns
    for j=i:n_patterns
        %The kernel is the inner porduct of all posible pair of hIgh-dim axes
        K(i,j)=multinom_kernel(data(i,:),order,data(j,:));
        %K(i,j)=exponential_kernel(delta,sigma,data,data);
        K(j,i) = K(i,j); %Introducing this symmetry condition is correct
        %                because kernel function is symmetric with respect
        %                to i, j (data pattern indexes).
    end
end
%
%II-CENTERING IN HIGH-DIM, FEATURE SPACE
K=K./n_patterns;
unit = ones(n_patterns, n_patterns)/n_patterns;
K_n = K- unit*K - K*unit + unit*K*unit;
%
%III-DIAGONALIZE THE CENTERED MATRIX
[evecs,evals] = eig(K_n);
evals = real(diag(evals));
%Order them in descending order
[~,index]=sort(abs(evals));
evals=evals(index(end:-1:1));
evecs=evecs(:,index(end:-1:1));
%Very small eigenvalues can be rejected.
positive=find(  evals>1E-15 );
evals=evals(positive);
evecs=real(evecs(:,positive));
%The next condition induces normalization in the real (high-dim)
%eigenvectors. Is not compelling. See e.g Braun et al., (2008).
for i=1:length(evals)
    evecs(:,i) = evecs(:,i)/(sqrt(abs(evals(i))));
end
%
%IV- EXTRACTING FEATURES: expanding validation dataset vectors into the
%reference high-dimensional eigenvectors.
n_patterns_valid=length(data_valid(:,1));
%Projection of validation set into the reference set. Note:
%kernel matrix "K2" is no longer an  a representration of a Mercer operator;
%is not symetric and only serves as a "kernel trick" (see
%e.g. Schölkopf et al., 2002).
%
K2=zeros(n_patterns_valid,n_patterns);
if nargin>2
    for i=1:n_patterns_valid
        for j=1:n_patterns %Note: no mercer kernel symmetry condition introduced here
            %              (i.e K2(i,j) <> K2(j,i), in general. Thus,
            %               "j" index starts with "1" and not with "i").
            K2(i,j)=multinom_kernel(data(j,:),order,data_valid(i,:));
            %K(i,j)=exponential_kernel(delta,sigma,data,data);
        end
    end
    %Same centering and normalization (in high-dim space) steps as in upper lines.
    %Note, however, that eigenvalues and eigenvectors are not re-computed.
    K2=K2./n_patterns_valid;
    unit2 = ones(n_patterns_valid, n_patterns)/n_patterns_valid;
    K2_n = K2- unit2*K2 - K2*unit2 + unit2*K2*unit2;
else
    K2_n=K_n;
end
%
projec_data = K2_n*evecs(:,1:n_axes); %Projection of the high-dim validation
%                                         vectors into the "n_axes" main eigenvectors.
disp(['   KPCA of order ',num2str(order),' finished']),
disp('____   ____   ____')
disp(' '),