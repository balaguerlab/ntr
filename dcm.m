function dcm_data=dcm(data,fixed_lag,incl_subop_lags,display,lost_frac)
%v 4.0b
%Embedding for univariate time series using a delay coordinate map
%(Kantz and Schreiber, 2004, Sauer et al., 1992, Takens 1981).
%This is a variant for multivariate time series. This version does not compute
%the correlation dimension (which is a lower bound of the underlying
%box-counting attractor dimension in deterministic systems, Sauer et al.,
%1992). Therefore, one should e.g. use the smallest number of lags which
%disambiguates trajectories corresponding to different groups
%i.e when all the neural responses have the same value for task-epoch "A"
%and for task-epoch "B"
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
%
%       data (n_time bins x n_dimensions (e.g. neurons)) = Must contain neural responses values over time
%
%       fixed_lag (1x1). Important note: Parameter only used during 3D visualization pruposes, 
%           not for the high-dim statistical analyses. 
%           Natural number, indicating the maximum lag (in time
%           bins units) which should have every axes in a delay-coordinate map. If <=0, lags will be
%           obtained as the average/maximum lag across the "first" minimum between cross-correlation 
%           functions (see code below in dcm.m for details).
%   
%
%       incl_subop_lags (1x1) = Binary, indicating if all lags below the
%                           optimum/maximum one will be included as a
%                           new axes or not.
%       display (1x1) = if>0, comments and warnings will be shown
%
%       lost_frac (1x1) = Real number from 0 to 1, indicating the maximum fraction of the time series
%                   length which can be lost during the embedding (latest vectors
%                   form a time series will be lost during the
%                   delay-embedding). If <=0, no vectors
%
%Outputs:
%  dcm_data (n_time bins- bins of the maximum lag  x (original + delayed dimensions))
%
%__________________________________________________________________________

[n_patterns,dims]=size(data);
%
if nargin<4
    display=1;
end
if display<1
    warning('off','dcm:NoLagLimit');warning('off','dcm:NoSmooth');warning('off','dcm:LagOptim');warning('off','dcm:min_dcm');
end
if display>0, disp('  Performing delay coordinate map...'), end
if (nargin<5)
  lost_frac=0.005;%003,004 are nice
elseif (lost_frac<=0)
    warning('dcm:NoLagLimit','No upper limit for the longer lag: Last time-series vectors lost during the embedding may cause unreliable statistics'),
end
if lost_frac>0
    disp(['     only for discriminant analyses, max fraction of data lost ',num2str(100*lost_frac),'%']),
end
if nargin<3
    incl_subop_lags=1;
elseif (incl_subop_lags<1)
    warning('dcm:NoSmooth','No trajectories "oversmoothing" flow display could be harder to interpret (sub-optimal lags ommited)'),
end
%
%Fixing an informative lag per each one of the axes, when requested. Not
%used by default.


if (nargin<2)||(fixed_lag<=0)
    warning('dcm:LagOptim','Maximum lag optimized by the first minimum of the mean cross-correlation between axes')
    lags=multivar_lags(data);%Produces a vector of dimension = n_neural responses, where lags(1)=second
    %                         minimum of the autocorrelation of the most responsive neural response dimension;
    %                         lags(2..n_neural)=first expected minimums, averaged
    %                         across dimensions.
else
    if display>0,  disp(['     only for trajectory visualization lag fixed to ',num2str(fixed_lag),' time bins for all dimensions']), end
    lags=fixed_lag.*ones(1,dims);
end
%Restrict the maximum available lag
if (lost_frac>0)&&(fixed_lag)<=0
    limited=0;
    max_lag=round(lost_frac*n_patterns);
    for j=1:length(lags)
        if lags(j)>max_lag
            lags(j)=max_lag;
            limited=1;
        end
    end
    if limited
        if display>0
            disp(['     maximum lag limited to ',num2str(max(lags)),' bins, a ',num2str(lost_frac*100),'% of the time series length'])
        end
    end
end
%
%Build up the delay coordinate map
%
%Adding all intermediate lags between the maximum and zero lag.
if incl_subop_lags>0
    %
    dcm_data=data(1:n_patterns,:);%All undelayed axes
    for j=1:dims%All dimensions are used, but note that this slows down the algorithm
        delay_counter=2;%Auxiliar variable
        %Now we are at fixed neuron j and will and all lags from the
        %maximum one to the first one
        for k=1:lags(j)%This can be easily modified in order to add e.g. lags from (lags(j)/2):lags(j)
            prev_length=length(dcm_data(:,1));
            current_length=n_patterns-delay_counter+1;%We have lost one or more vectors
            min_length=min(prev_length,current_length);
            dcm_data=[dcm_data(1:min_length,:),data(delay_counter:min_length+delay_counter-1,j)];
            delay_counter=delay_counter+1;
        end
    end
    if display>0,    disp('     all intermediate lags included'), end
else
    %**************************************************************************
    %Optional. Creates a minimal embedding expansion of just n+1 dimensions
    %It is enough in some cicumstances (see "lagged_axes.m"). This is the one
    %used in Balaguer et al. (2011).
    dcm_data=lagged_axes(data,lags);
    warning('dcm:min_dcm','Minimal delay-coordinate map created')
    %**************************************************************************
end
%
[reduced_n_patterns,expanded_dims]=size(dcm_data);
if display>0
    disp(['     ',num2str(n_patterns-reduced_n_patterns),' patterns lost, ',...
        num2str(reduced_n_patterns),' patterns remain'])
    disp(['     ',num2str(expanded_dims-dims),' dimensions added, ',...
        num2str(expanded_dims),' dimensions in total' ])
    disp(' ')
end
warning('on','dcm:NoLagLimit');warning('on','dcm:NoSmooth');warning('on','dcm:LagOptim');warning('on','dcm:min_dcm');










