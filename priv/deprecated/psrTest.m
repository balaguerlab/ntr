%The Priestley-Subba Rao (PSR) Test of non-stationarity
%Priestley and Subba Rao (1969) and Nason (2013)
%E {Y(t, w)} = log{ft(w)}, where ft is the fourier transform for each trial
%we assume that variance of Y is constant and will check for the constancy
%of the mean.
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
clear; clc,
figure
%load('dataSample10Steps.mat')
load('data_drift_init_cond_preserv_smoothest'),
ntrials=data(end,5);
trial_size=2500;
freqs=zeros(trial_size,ntrials);
limit_trial=7;%Last trial to be tested/displayed
distances=zeros(1,limit_trial);
intervalStep=0.001;%increments of alpha .002
initStep=0.25;%Init alpha
beta=-0.6;
for i=1:limit_trial
    distances(i)=distanceBetweenAttractors(initStep+i*intervalStep,beta);
end
axes=1;%x_axes=1, y_axes=2
for i=1:limit_trial %tyically 11 trials, 300 init cond each
    
  lower_limit=((i-1)*trial_size)+1;
  upper_limit=i*trial_size;
  freqs(:,i)=log(abs(fft(data(lower_limit:upper_limit,axes))));
  if (i>1)&&(i<=limit_trial)
      disp('__________________________')
      disp('__________________________')
      
      for j=i-1:i-1%j=1:i-1,%j=i-1:i-1,%
          disp('***********************')
          disp(' ')
          disp(['PSR test comparison ',num2str(i),'-',num2str(j)])
          pre_freq=freqs(:,j);now_freq=freqs(:,i);
          [H_freq,P_freq,CI_freq,STATS_freq]=ttest2(pre_freq,now_freq);
          [h_freq,p_freq]=lillietest(pre_freq);
          
          if h_freq>0
              [h2_freq,p2_freq]=lillietest(now_freq);
              disp(['Warning normality rejected at p<',num2str(max(p2_freq,p_freq))])
              [Prs_freq,Hrs_freq,STATSrs_freq]=ranksum(pre_freq,now_freq);
              disp(['ranksum p=',num2str(Prs_freq),'; U(',num2str(STATS_freq.df),')=',num2str(STATSrs_freq.ranksum)])
          else
               disp(['Ttest2 p=',num2str(P_freq),'; T(',num2str(STATS_freq.df),')=',num2str(STATS_freq.tstat)])
          end
          
     
      end
  end  
end
disp(' ')

disp('***********************')
% disp(['Anova up to trial ',num2str(limit_trial)']),
% [p,table,stats]=anova1(freqs(:,1:limit_trial))
ntrials2=limit_trial;
subplot(211)
errorbar(distances(1:ntrials2),mean(freqs(:,1:ntrials2)),(std(freqs(:,1:ntrials2))./sqrt(trial_size)))
subplot(212)
bar(distances(1:ntrials2),mean(freqs(:,1:ntrials2)))
  