function lags=multivar_lags(i_data,relax_minimum,pre_proccesing,do_display,name)
%Private, auxiliary function, not to be modified.
%The code is NOT designed for a smooth reading unlike the main functions of this package,
%Can be subject to improvements.
%
%Please contact eb-ballester@bournemouth.ac.uk if you experience any error
%message pointing to this function
%
%Method for creating a delay coordinate map, very simple, for multivariate time
%series.Finds de delta tau_i which provides the minimum averaged
%cross-correlation across axes. 
%Note: "Demo1.mat" file provided already contains a disambiguation of
%trajectories as provided by this script, thus no need to use it again.
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
%@ebalaguer: First minimum of acf in axe #1 is not reported
%in the output. Therefore dimensionality of ouput is just equal to the number of varibles
%
%__________________________________________________________________________
%
%
%Inputs:
%   i_data (time bins x number of variable)
%
%   pre_proccesing (binary) If yes, outliners removal, consecutive samples
%                           de-correlation and normalization is required.
%   name, Just a string for hypothetical figures.
%   do_display
%   relax_minimum: if >0, minium criterion will be relaxed, for very
%   problematic animals/subjects. Activate when time series are particulary short.
%
%Outputs:
%   lags vector, of size number of variables.
%
%__________________________________________________________________________
%
if nargin<2,relax_minimum=1; end
if nargin<5, name=' '; end
if nargin<4, do_display=0; end
if nargin<3, pre_proccesing=0; end
if (relax_minimum>0)&&(do_display>0)
    disp('***PRIVATE WARNING FOR DEVELOPER. PLEASE CONTACT AUTHOR IF YOU SEE THIS')
    disp('IS THIS AN UNUSALLY SHORT TIME SERIES? ELSE PLEASE SET THE HARD-CODED VARIABLE relax_minimum=0 (now is >1, activated)'),
end
fraction_lost=.15;%This had-code limits the maximum available lag: By default, a maximum of 15% of the original
%                 time series can be lost during the embedding.
n_variables=length(i_data(1,:));
%
%I-PRE-PROCESSING
%Pre-processing: Whithin-channels outlines removing,de-correlation
%of consecutive values, making positive and normalization.
if do_display>0
    disp(['     Linear delay coordinate map...',name]),
    disp(' ');
end
if pre_proccesing>0
    dev_limit=3;
    %data=zeros(length(i_data(:,1))-1,n_variables); %1-d differentiation
    data=zeros(length(i_data(:,1)),n_variables);
    for i=1:n_variables
        dev=std(i_data(:,i));
        average=mean(i_data(:,i));
        singleVariable=i_data(:,i);
        outliners1=find( singleVariable>(dev_limit*dev+average));
        singleVariable(outliners1)=average+dev_limit*dev;
        removed1=length(outliners1);
        outliners2=find(singleVariable<(average-dev_limit*dev));
        singleVariable(outliners2)=average-dev_limit*dev;
        removed2=length(outliners2);
        if do_display>0
            disp('');
            disp(['     Series ',num2str(i)]),
            if (removed1+removed2)>0
                disp(['     *WARNING: ',num2str(removed1+removed2),...
                    ' values exceeding ',num2str(dev_limit),...
                    ' standart deviations has been replaced *']);
            end
            %disp(' 1-st Differencing series ');
            %singleVariable=singleVariable(2:end)-...
            %    singleVariable(1:end-1);
            %disp(' Making positive ');
            %singleVariable=singleVariable+abs(min(singleVariable));
            %univ_data= singleVariable./max( abs(singleVariable));
            disp('     Divide by standard dev. ');
        end
        dev=std(singleVariable);
        univ_data= singleVariable./dev;
        data(:,i)=univ_data;
    end
else
    data=i_data;
end

% %Order time series from more to less responsive.
% response=sum(data); %size 1 x n_variables
% [sorted,index]=sort(response);
% sorted=sorted(end:-1:1); index=index(end:-1:1);
% data=data(:,index);
%Rutine for automatising delays selection in the axes.
lags=ones(n_variables+1,1); %Criterion is lags(1)=tau1_2(in samples),
%                           which is the second minimum of  the
%                           autocorrelation of the first time series.
%                            lags(2)=tau1; first minimum of  the  autocorrelation;
%                            lags(3)=tau2; average of the first minimum of  the  cross
%                            correlation form series 2 with series 1
%                            (delayed and undelayed).
%                           After that, the  next axes are "ortogonal" to those
%                           three initial ones.
%if do_display>0
%     disp(' '),
%     disp([' Re-ordering time series from more to less responsive. Order is ',...
%         num2str(index)]);
%     disp(' '),
%end
%II-ALGORITHM
for i=1:n_variables
    if do_display>0
        disp(' ')
        disp(['     *** CHANNEL (reordered) ',num2str(i),' ***']),
        disp(' ')
    end
    %
    taus_this_series=zeros(i,1); %Will contain all lags per unit
    for j=0:i-1
        actual=data(:,i); %Actual unit. Previous', in contrast, reffers to the previous axes and they have
        %alrready a proper lag previously computed. The first axis is special:
        if (i==1)
            previous=actual;
        else
            if j==0
                previous=data( :,1); 
            else
                previous=data(   lags(j+1):end,j); 
            end
        end
        %
        actual=actual(1:length(previous));
        crossCorr=xcorr(previous,actual,'coeff');%Important, it has to be in this order (see xcorr help)
        crossCorr=crossCorr(round(length(crossCorr)/2):end);
        
        if do_display>0
            figure, plot(crossCorr);
            if j==0, title(['Cross-correlation (reordered) channels  ', num2str(1),...
                    ' undelayed x ',num2str(i)]);
            else
                title(['Cross-correlation (reordered) channels   ',...
                    num2str(j),' x ',num2str(i)]);
            end
        end
        %
        %Inicialization of comparison of unit i versus unit j
        data_index=1;
        minimum=abs(crossCorr(1));
        significance=3.09/sqrt(length(crossCorr));%99 %
        low_significance=1.96/sqrt(length(crossCorr));%95 perhaps
        position1=1;
        position2=-1;soft_minimum=-1; super_soft_minimum=-1;
        soft_minimum_reached=0;%See later on what does it means these variables
        super_soft_minimum_reached=0;
        first_min=0; file_list=0;second_min=0;
        while (data_index<length(crossCorr))
            data_index=data_index+1;
            %
            %I.1-Seeking for the first minimum or for a sufficently low
            %value
            if first_min==0
                if abs(crossCorr(data_index))<=(minimum)
                    minimum=abs(crossCorr(data_index));
                    if (minimum<(max(crossCorr)-significance))&&(soft_minimum_reached<1)
                        soft_minimum=data_index-1;soft_minimum_reached=1;
                    elseif (minimum<(max(crossCorr)-low_significance))&&(super_soft_minimum_reached<1)
                        super_soft_minimum=data_index-1;super_soft_minimum_reached=1;
                    end
                else
                    position1=data_index-1;
                    if do_display>0
                        if j>0
                            disp(['     First lag (with channel ',num2str(j),') is ',num2str(position1),...
                                ' whith cross-correlation ',num2str(minimum) ]);
                        else
                            disp(['     First lag (with undelayed channel ',num2str(1),') is ',...
                                num2str(position1),' whith cross-correlation ',num2str(minimum) ]);
                        end
                    end
                    first_min=1;
                    %But now check that the first lag does not occur too far, its
                    %bad to loose too many vectors in the embedding.
                    if (position1>length(crossCorr)*fraction_lost)
                        position1=soft_minimum;position2=position1;
                        if do_display>0
                            disp('');
                            disp(['Minimum would produce too many data lost, ',...
                                ' then first lag crossCorrelation is ',num2str(position1),' ***']);
                        end
                        %Safety proccedure
                        if (position1>length(crossCorr)*fraction_lost)&&(relax_minimum>0) %we can't loose too many vectors in the
                            %                                                                                                               embedding in rat C
                            position1=super_soft_minimum;position2=position1;
%                             disp(['     ***WARNING ! WARNING CHECK CHANNEL ',num2str(i),' DATA LENGTH: Significant level would produce too many data lost, ',...
%                                 ' then first lag crossCorrelation is ',num2str(position1),' acf: ',num2str(crossCorr(position1)),' ***']);
                        end
                    end
                end%if abs(crossCorr(data_index))<=minimum
            end% if first_min==0,
            
            
            %I-2 Now, only for the first axis and only if  he first lag does not occur too far,
            %(its is bad to loose too many vector in the embedding),
            %search for the second minimum.
            if (position1<length(crossCorr)*fraction_lost)&&(i==1)&&(first_min==1)&&...
                    (second_min==0)
                %After that, the autcorrelation grows for some time. When start to
                %decrease again, we have been reach the maximum:
                if (abs(crossCorr(data_index))<=abs(crossCorr(data_index-1)))&&...
                        (file_list==0)
                    file_list=1; minimum=abs(crossCorr(data_index));
                end
                %if (abs(crossCorr(data_index))>abs(crossCorr(data_index-1)))&&...
                %(file_list==1)%&&(minimum<crossCorr(position1)-significance)
                %And then, again we seek for the second minimum
                if (abs(crossCorr(data_index))<=(minimum))&& (file_list==1)
                    minimum=abs(crossCorr(data_index));
                else
                    if (position1>0) && (minimum<crossCorr(position1)-significance)&&(file_list==1)
                        position2=data_index-1;
                        if do_display>0
                            disp(['     Second lag is ',num2str(position2),...
                                ' whith crossCorrelation ',num2str(minimum) ]);
                        end
                        second_min=1;
                    end
                end
                
                %But now check also that the second lag does not occur too far, its in
                %bad to loose too many vectors in the embedding.
                if (position2>length(crossCorr)*fraction_lost), position2=position1; end
            end%if (position1<length(crossCorr)*fraction_lost)&&(i==1)&&(first_min==1)&&...
            %     (second_min==0)
            
        end%End of while
        if position1<0, position1=1; end
        
        if (i==1)
            if position2<0, position2=position1; end
            lags(1)=position2; lags(2)=position1; %No any average for the first time series.
        else
            taus_this_series(j+1)=position1;
        end
        
    end%End of j
    if do_display
        pause; close all;
    end
    if i>1
        %lags(i+1)=round(mean(taus_this_series));%This is a too crude aproxmation. Perhpas it
        %would be better to retain the maximum lag instead, which is as
        %well very crude indeed (23-jan-09).
        lags(i+1)=max(taus_this_series);
    end %Only after the second time series there is an average.
end %end of i
lags=lags([1,3:end]);% Feb 011.
%Retained the second, more conservative minimum for axe 1 and first, average minimums fot the rest of them
%Thus dimensionality of the ouput is now = n_variables.



