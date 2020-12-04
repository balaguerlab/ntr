function display_flow_2D(data,labels,trial_range,order,index_plot,trLim)
%Auxiliary, private file, which displays two
%groups flow in two dimensions (e.g. the most discriminating one plus a
%second one, perhaps delayed, perhaps orthogonal=
%
%For clarity, only a maximum of eigth groups will be displayed in three axes.
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
if nargin<6, trLim=50; end
max_groups_trajec_display=2;
scale=1;%Srinkage of the derivatived module (arrows) plotted using "quver3.m"
%        for scale=1, arrows are automatically scaled such that they do not
%       overlap and then unmmodified. scale=0 does not tmodify original arrows
%       (not advisale) and other values compress or expand all vectors afther such
%       automatical scaling.
%
m_labels=max(labels);l_labels=length(labels);min_labels=min(labels);
n_labels=m_labels-min_labels+1;
%
n=length(data(:,1));%Number of patterns
if ~(n==l_labels), error('Labels to be displayed does not match the number of patterns'), end
%
if n_labels>max_groups_trajec_display,
    warning('display_flow:maxEvents',['Maximum number of events displayed will be ',num2str(max_groups_trajec_display),' (hard-coded, easy to be changed)'])
end
%
%Normalization before plotting: +1 will be the maximum for each axis
%Small loop, no need to use 'repmat' for speed.
%Note that just the three first dimensions of the maximum discriminating subspace
%will be used, the rest are irrelevant
normalized=zeros(n,2);derivative=zeros(n-1,2);
for j=1:2,
    d=data(:,j); d_d=diff(data(:,j));
    m_d=mean(d);m_dd=mean(d_d);
    %m_d=0;m_dd=0;
    normalized(:,j)=(d-m_d)./std(d);%max(abs(d-m_d));%zscore(d);
    derivative(:,j)=(d_d-m_dd)./std(d_d);%max(abs(d_d-m_dd));%zscore(d_d);%
end
%
%Check out that all labels are present, either thrown an error. create
%legend text.
%legend_text={};
for j=min_labels:m_labels,
    current_label_vector=j.*ones(l_labels,1)-labels;
    if all(current_label_vector)
        error('Labels are not natural number increasing by "1". Please create consecutive labels in previous-to-last column of input data'),
    end
end
%Refining the derivative: when a new trajectory starts the derivarive is zero.
newInitCond=find(max((abs(derivative))')>1);%two-three std dev.
%Add each one of the trajectory limits
%newInitCond=[newInitCond,1:trLim:n];newInitCond=sort(newInitCond);
derivative(newInitCond,:)=zeros(length(newInitCond),2);
labels=labels(2:end);normalized=normalized(2:end,:);n=length(labels);
%
%Next variables are just for plotting the legend. Please see code below.
low_lim=-2.*ones(1,2); up_lim=2.*ones(1,2);
margin_1=0.1*(up_lim(1)-low_lim(1));
up_lim(1)=up_lim(1)-margin_1;%Leaving space for z-axis of the rigth plot
for j=1:2,
    [val,ind]=min(normalized(:,j));
    low_lim(j)=val+derivative(ind,j);
    [val,ind]=max(normalized(:,j));
    up_lim(j)=val+derivative(ind,j);
end

flags=ones(1,n_labels);
prev_label=labels(1);
i=1; count=1;
x_prev=normalized(1,1);y_prev=normalized(1,2);
x_d_prev=derivative(1,1);y_d_prev=derivative(1,2);
thisOneCounter=1;
while count<n,
    if labels(count)==1
        if (prev_label==1)&&(thisOneCounter<trLim),
            x=x_prev;y=y_prev;
            x_d=x_d_prev;y_d=y_d_prev;
        else
            x=normalized(i,1);y=normalized(i,2);
            x_d=0;y_d=0;thisOneCounter=1;
        end
        while (i<n)&&(labels(i)==1),
            if (derivative(i,1)~=0),
                x=[x;normalized(i,1)];y=[y;normalized(i,2)];
                x_d=[x_d;derivative(i,1)];y_d=[y_d;derivative(i,2)];
            end
            i=i+1;
            thisOneCounter=thisOneCounter+1;
        end
        count=i;
        subplot(2,2,index_plot)
        quiver(x,y,x_d,y_d,scale,'Marker','o','MarkerSize',0.5,...
            'Color',[0,0,.7]);
        plot(x,y,'Color',[.8,.8,1],'LineStyle','none','LineWidth',.1);
        x_prev=x(end);y_prev=y(end);
        x_d_prev=x_d(end);y_d_prev=y_d(end);
        hold on
        if flags(1),
            title(['Expanded space of order ',num2str(order),' for trials ',...
                num2str(trial_range(1)),' to ',num2str(trial_range(2))]),
            xlabel('DC 1');ylabel('DC 2');zlabel('DC 3');
            text(up_lim(1),low_lim(2)/2,'Epoch 1','Color',[0,0,.7],'FontName','Arial','FontSize',8);
            disp('     Flow of task-epoch 1...'),
            flags(1)=0;
        end
        prev_label=1;
    elseif labels(count)==2,
        if (prev_label==2)&&(thisOneCounter<trLim),
            x=x_prev;y=y_prev;
            x_d=x_d_prev;y_d=y_d_prev;
        else
            x=normalized(i,1);y=normalized(i,2);
            x_d=0;y_d=0;
            thisOneCounter=1;
        end
        while (i<n)&&(labels(i)==2),
            if (derivative(i,1)~=0),
                x=[x;normalized(i,1)];y=[y;normalized(i,2)];
                x_d=[x_d;derivative(i,1)];y_d=[y_d;derivative(i,2)];
            end
            i=i+1;
            thisOneCounter=thisOneCounter+1;
        end
        count=i;
        subplot(2,2,index_plot)
        quiver(x,y,x_d,y_d,scale,'Marker','o','MarkerSize',0.5,...
            'Color',[.7,0,0]);
        plot(x,y,'Color',[1,.8,.8],'LineStyle','none','LineWidth',.1);
        x_prev=x(end);y_prev=y(end);
        x_d_prev=x_d(end);y_d_prev=y_d(end);
        hold on
        if flags(2),
            text(up_lim(1),low_lim(2)/2,'Epoch 2','Color',[.2,.2,.2],'FontName','Arial','FontSize',8);
            disp('     Flow of task-epoch 2...'),
            flags(2)=0;
        end
        prev_label=2;
    elseif labels(count)==-1
        x=x_prev;y=y_prev;
        x_d=x_d_prev;y_d=y_d_prev;z_
        while (i<=n)&&(labels(i)==-1),
            i=i+1;
            x=[x;normalized(i,1)];y=[y;normalized(i,2)];
            x_d=[x_d;derivative(i,1)];y_d=[y_d;derivative(i,2)];
        end
        %
        %Plot in ligth gray, but not during delay period
        if all(labels(count:i,end-1)~=2),
            subplot(2,2,index_plot)
            quiver(x,y,x_d,y_d,scale,'Marker','o','MarkerSize',1.5,...
                'Color',[0.8,0.8,0.8]);
            plot3(x,y,'Color',[.8,.8,.8],'LineStyle','-','LineWidth',.1);
            hold on
        end
        count=i;
        x_prev=x(end);y_prev=y(end);
        x_d_prev=x_d(end);y_d_prev=y_d(end);
    else
        error(['Task-phase number not recognized. It has to be either -1 (no any phase) or ',...
            'a natural number from 1 to ',num2str(m_labels)]),
    end
end
set(gca,'FontName','Arial','FontSize',8);
%xlim([low_lim(1) up_lim(1)]);ylim([low_lim(2) up_lim(2)]);
hold off
