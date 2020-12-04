function example_optimize(file_name,evaluation_blocks,order,special)

%Batch procces script, example to show the optimization of the decoder on any individual data file
%'file_name'. 'evaluation_blocks' are groups of 40 trials for
%cross-validating, 'order' is the correlation order. 'special' uses a
%selection of regularization constant that proven appopiated in previous optimizations, just to save computational cost.
%For instance:
%example_optimize('4Class_92_11at0.08Bin40Trials-block.mat',4,3,0) 
%example_optimize('4Class_92_10at0.08Bin40Trials-block.mat',4,3,0)
%etc.
%Iterates over different configurations (nonlinear orders of the kernel,
%regularization constants). Requires at least 200 iiterations to optimize,
%but with a limited range as in the example below often provides a robust
%generalization
%
%I-Basic parameters
if nargin<4
    special=1;
    disp('*Alert: Limited range of special values used*'),
end
%This is new dec 2017. By default, specual values are used. Otheriwse
%all of them,
parameter_name='';

%Number of Configurations:
n_configs=20;%400 for an optimal regularization;

nlabs=4;%12;%5;%6 %12% Physical cores in the machine

%Min/aximum  regularization constants to test
min_value=0;%0.005;%0.1;%0.001;%0.01;
max_value=0.4;%0.6;%0.6% 0.48; is a good one%0.5;%0,4;%0.48;%0.8;%0.51;

load(file_name); 
EstimationData=DataSet(DataSet(:,end)<evaluation_blocks+1,:);

%EstimationData=zscoreTrials(EstimationData);

%Removing the column indicating onsets and offset of tones
%Also removing the trials columns

EstimationData=[EstimationData(:,1:end-4),...
    EstimationData(:,end-2),EstimationData(:,end-2),EstimationData(:,end)];
file_name=file_name(1:end-4);%Remove the .mat from the name.
%LFP prevents the matrix from going singular, is  a useful regularization
%-no effect on results


tic
array_vals=config_values(n_configs,min_value,max_value);
delete(gcp('nocreate'));
pause(4)
poolobj = parpool(nlabs);
poolsize = poolobj.NumWorkers

%disp(['Estimated time ',num2str(n_configs*0.507),' hours']),%typical
%
%
%II-Configurations

%Example of favorable configurations for O=3
%Generic

%special_values=array_vals;

special_values= [];%Here we can specify values form a previous optimization batch to reduce the computationla cost
 basic_conf=setup_config(order,min_value,0,0,0,0,[],1,0,5,0,20,4,0,1,1,6,0);% Another example For '4Class_92_11at0.08Bin40Trials-block.mat', were the delay-coordinate map is not used, etc.
%basic_conf=setup_config(order,min_value,0,0,0,0,[],1,0,5,0,20,4,1,1,1,2,0); %e.g. for file  '4Class_92_10at0.08Bin40Trials-block.mat' 4 classes, 1 lag dcm hardcoded in "kfd_cross_val"

if special<1
    special_values=(1:length(array_vals));
    %disp('*Alert: Full range of values used*'),
end


n_configs=length(special_values);

global_multiv_CE=zeros(n_configs,1);
eb_global_multiv_CE=zeros(n_configs,1);
%global_multiv_JS=zeros(n_configs,1);
%eb_global_multiv_JS=zeros(n_configs,1);
global_multiv_DIV=zeros(n_configs,1);
eb_global_multiv_DIV=zeros(n_configs,1);


%Class one
global_multiv_CE_class_one=zeros(n_configs,1);
eb_global_multiv_CE_class_one=zeros(n_configs,1);
%global_multiv_JS_class_one=zeros(n_configs,1);
%eb_global_multiv_JS_class_one=zeros(n_configs,1);
global_multiv_DIV_class_one=zeros(n_configs,1);
eb_global_multiv_DIV_class_one=zeros(n_configs,1);

ALL_CE_class_one=[];%of size cross-val iterations x n configs
%ALL_JS_class_one=[];%of size cross-val iterations x n configs
ALL_DIV_class_one=[];%of size cross-val iterations x n configs

%Class two
global_multiv_CE_class_two=zeros(n_configs,1);
eb_global_multiv_CE_class_two=zeros(n_configs,1);
%global_multiv_JS_class_two=zeros(n_configs,1);
%eb_global_multiv_JS_class_two=zeros(n_configs,1);
global_multiv_DIV_class_two=zeros(n_configs,1);
eb_global_multiv_DIV_class_two=zeros(n_configs,1);

ALL_CE_class_two=[];
%ALL_JS_class_two=[];
ALL_DIV_class_two=[];

%Class three
global_multiv_CE_class_three=zeros(n_configs,1);
eb_global_multiv_CE_class_three=zeros(n_configs,1);
%global_multiv_JS_class_three=zeros(n_configs,1);
%eb_global_multiv_JS_class_three=zeros(n_configs,1);
global_multiv_DIV_class_three=zeros(n_configs,1);
eb_global_multiv_DIV_class_three=zeros(n_configs,1);

ALL_CE_class_three=[];
%ALL_JS_class_three=[];
ALL_DIV_class_three=[];

%Class four
global_multiv_CE_class_four=zeros(n_configs,1);
eb_global_multiv_CE_class_four=zeros(n_configs,1);
%global_multiv_JS_class_four=zeros(n_configs,1);
%eb_global_multiv_JS_class_four=zeros(n_configs,1);
global_multiv_DIV_class_four=zeros(n_configs,1);
eb_global_multiv_DIV_class_four=zeros(n_configs,1);

ALL_CE_class_four=[];
%ALL_JS_class_four=[];
ALL_DIV_class_four=[];

%twoClass_CE=zeros(n_configs,15); twoClass_DIV=zeros(n_configs,15);

%III-Optimization. Remember that is not the same using a for and a parfor,
%computatiosn can be very different
%parfor
parfor current_config=1:length(special_values)
    disp(' ')
    disp('***********************************')
    disp('**'), disp(['Config. ',num2str(current_config),'/',num2str(n_configs)]),disp('**')
    disp('***********************************')
    disp(' ')
    conf=basic_conf;
    conf.regul=array_vals(special_values(current_config));
    
    results=ntr(EstimationData,conf);
    
    all_CE=results.cum_multi_stats(:,:,1);
    all_DIV=results.cum_multi_stats(:,:,2);
    %all_JS=results.cum_multi_stats(:,:,3);
    
    %Class one
    CE_multiv_class_one=  mean(all_CE(:,1));
    eb_CE_class_one=std(all_CE(:,1))/sqrt(length(all_CE(:,1)));
    %JS_multiv_class_one=  nanmean(all_JS(:,1));
    %eb_JS_class_one=sqrt(nanvar(all_JS(:,1)))/sqrt(length(all_JS(:,1)));
    DIV_multiv_class_one=mean(all_DIV(:,1));
    eb_DIV_class_one=std(all_DIV(:,1))/sqrt(length(all_DIV(:,1)));
    
    global_multiv_CE_class_one(current_config)=CE_multiv_class_one;
    eb_global_multiv_CE_class_one(current_config)= eb_CE_class_one;
    %global_multiv_JS_class_one(current_config)=JS_multiv_class_one;
    %eb_global_multiv_JS_class_one(current_config)= eb_JS_class_one;
    global_multiv_DIV_class_one(current_config)=DIV_multiv_class_one;
    eb_global_multiv_DIV_class_one(current_config)= eb_DIV_class_one;
    
    ALL_CE_class_one=[ALL_CE_class_one,all_CE(:,1)];
    %ALL_JS_class_one=[ALL_JS_class_one,all_JS(:,1)];
    ALL_DIV_class_one=[ALL_DIV_class_one,all_DIV(:,1)];
    
    %Class two
    CE_multiv_class_two=  mean(all_CE(:,2));
    eb_CE_class_two=std(all_CE(:,2))/sqrt(length(all_CE(:,2)));
   % JS_multiv_class_two=  nanmean(all_JS(:,2));
   % eb_JS_class_two=sqrt(nanvar(all_JS(:,2)))/sqrt(length(all_JS(:,2)));
    DIV_multiv_class_two=mean(all_DIV(:,2));
    eb_DIV_class_two=std(all_DIV(:,2))/sqrt(length(all_DIV(:,2)));
    
    global_multiv_CE_class_two(current_config)=CE_multiv_class_two;
    eb_global_multiv_CE_class_two(current_config)= eb_CE_class_two;
    %global_multiv_JS_class_two(current_config)=JS_multiv_class_two;
    %eb_global_multiv_JS_class_two(current_config)= eb_JS_class_two;
    global_multiv_DIV_class_two(current_config)=DIV_multiv_class_two;
    eb_global_multiv_DIV_class_two(current_config)= eb_DIV_class_two;
    
    ALL_CE_class_two=[ALL_CE_class_two,all_CE(:,2)];
    %ALL_JS_class_two=[ALL_JS_class_two,all_JS(:,2)];
    ALL_DIV_class_two=[ALL_DIV_class_two,all_DIV(:,2)];
    
    %Class three
    CE_multiv_class_three=  mean(all_CE(:,3));
    eb_CE_class_three=std(all_CE(:,3))/sqrt(length(all_CE(:,3)));
    %JS_multiv_class_three=  nanmean(all_JS(:,3));
   % eb_JS_class_three=sqrt(nanvar(all_JS(:,3)))/sqrt(length(all_JS(:,3)));
    DIV_multiv_class_three=mean(all_DIV(:,3));
    eb_DIV_class_three=std(all_DIV(:,3))/sqrt(length(all_DIV(:,3)));
    
    global_multiv_CE_class_three(current_config)=CE_multiv_class_three;
    eb_global_multiv_CE_class_three(current_config)= eb_CE_class_three;
   % global_multiv_JS_class_three(current_config)=JS_multiv_class_three;
  %  eb_global_multiv_JS_class_three(current_config)= eb_JS_class_three;
    global_multiv_DIV_class_three(current_config)=DIV_multiv_class_three;
    eb_global_multiv_DIV_class_three(current_config)= eb_DIV_class_three;
    
    ALL_CE_class_three=[ALL_CE_class_three,all_CE(:,3)];
    %ALL_JS_class_three=[ALL_JS_class_three,all_JS(:,3)];
    ALL_DIV_class_three=[ALL_DIV_class_three,all_DIV(:,3)];
    
    
    %Comment if we have 3 or less classes
    if length(all_CE(1,:))>3
        %Class four
        CE_multiv_class_four=  mean(all_CE(:,4));
        eb_CE_class_four=std(all_CE(:,4))/sqrt(length(all_CE(:,4)));
      %  JS_multiv_class_four=  nanmean(all_JS(:,4));
      %  eb_JS_class_four=sqrt(nanvar(all_JS(:,4)))/sqrt(length(all_JS(:,4)));
        DIV_multiv_class_four=mean(all_DIV(:,4));
        eb_DIV_class_four=std(all_DIV(:,4))/sqrt(length(all_DIV(:,4)));
        
        global_multiv_CE_class_four(current_config)=CE_multiv_class_four;
        eb_global_multiv_CE_class_four(current_config)= eb_CE_class_four;
        %global_multiv_JS_class_four(current_config)=JS_multiv_class_four;
       % eb_global_multiv_JS_class_four(current_config)= eb_JS_class_four;
        global_multiv_DIV_class_four(current_config)=DIV_multiv_class_four;
        eb_global_multiv_DIV_class_four(current_config)= eb_DIV_class_four;
        
        ALL_CE_class_four=[ALL_CE_class_four,all_CE(:,4)];
        %ALL_JS_class_four=[ALL_JS_class_four,all_JS(:,4)];
        ALL_DIV_class_four=[ALL_DIV_class_four,all_DIV(:,4)];
        
    end
    
    CE_multiv_other_classes=  mean(mean(all_CE(:,2:end)));
    %JS_multiv_other_classes=nanmean(nanmean(all_JS(:,2:end)));
    DIV_multiv_other_classes=mean(mean(all_DIV(:,2:end)));
    global_multiv_CE_other_classes(current_config)=CE_multiv_other_classes;
    %global_multiv_JS_other_classes(current_config)=JS_multiv_other_classes;
    global_multiv_DIV_other_classes(current_config)=DIV_multiv_other_classes;
    
    CE_multiv=results.multiClass_err; DE_multiv=results.multiClass_diver;
    
    global_multiv_CE(current_config)=CE_multiv;
    global_multiv_DIV(current_config)=DE_multiv;
    
    % pair_CE_two=results.twoClass_mean_err; pair_DE_two=results.twoClass_mean_div;
    %twoClass_CE(current_config,:)=pair_CE_two';
    %twoClass_DIV(current_config,:)=pair_DE_two';
end
%save('in case of an emergency')

[min_multi_CE,posCE]=min(global_multiv_CE);
[min_multi_DIV,posDIV]=min(global_multiv_DIV);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE: ',num2str(min_multi_CE),', ',parameter_name,':',num2str(array_vals(special_values(posCE)))]);
disp(['Min DIV: ',num2str(min_multi_DIV),', ',parameter_name,':',num2str(array_vals(special_values(posDIV)))]);
%
disp('***************')
disp('***************')
disp('Class one'),
[min_multi_CE_class_one,posCE_class_one]=min(global_multiv_CE_class_one);
%min_multi_JS_class_one=global_multiv_JS_class_one(posCE_class_one);
[min_multi_DIV_class_one,posDIV_class_one]=min(global_multiv_DIV_class_one);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE class one: ',num2str(min_multi_CE_class_one),', ',parameter_name,':',num2str(array_vals(special_values(posCE_class_one)))]);
disp(['Min DIV class one: ',num2str(min_multi_DIV_class_one),', ',parameter_name,':',num2str(array_vals(special_values(posDIV_class_one)))]);
%     %Now define errorbars
eb_min_multi_CE_class_one=eb_global_multiv_CE_class_one(posCE_class_one);
%eb_min_multi_JS_class_one=eb_global_multiv_JS_class_one(posCE_class_one);
eb_min_multi_DIV_class_one=eb_global_multiv_DIV_class_one(posDIV_class_one);

disp(' '),
disp('Class two'),
[min_multi_CE_class_two,posCE_class_two]=min(global_multiv_CE_class_two);
%min_multi_JS_class_two=global_multiv_JS_class_two(posCE_class_two);
[min_multi_DIV_class_two,posDIV_class_two]=min(global_multiv_DIV_class_two);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE class two: ',num2str(min_multi_CE_class_two),', ',parameter_name,':',num2str(array_vals(special_values(posCE_class_two)))]);
disp(['Min DIV class two: ',num2str(min_multi_DIV_class_two),', ',parameter_name,':',num2str(array_vals(special_values(posDIV_class_two)))]);
%     %Now define errorbars
eb_min_multi_CE_class_two=eb_global_multiv_CE_class_two(posCE_class_two);
%eb_min_multi_JS_class_two=eb_global_multiv_JS_class_two(posCE_class_two);
eb_min_multi_DIV_class_two=eb_global_multiv_DIV_class_two(posDIV_class_two);

disp(' '),
disp('Class three'),
[min_multi_CE_class_three,posCE_class_three]=min(global_multiv_CE_class_three);
%min_multi_JS_class_three=global_multiv_JS_class_three(posCE_class_three);
[min_multi_DIV_class_three,posDIV_class_three]=min(global_multiv_DIV_class_three);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE class three: ',num2str(min_multi_CE_class_three),', ',parameter_name,':',num2str(array_vals(special_values(posCE_class_three)))]);
disp(['Min DIV class three: ',num2str(min_multi_DIV_class_three),', ',parameter_name,':',num2str(array_vals(special_values(posDIV_class_three)))]);
%     %Now define errorbars
eb_min_multi_CE_class_three=eb_global_multiv_CE_class_three(posCE_class_three);
%eb_min_multi_JS_class_three=eb_global_multiv_JS_class_three(posCE_class_three);
eb_min_multi_DIV_class_three=eb_global_multiv_DIV_class_three(posDIV_class_three);

disp(' '),
%Comment if we have 3 or less classes
disp('Class four'),
[min_multi_CE_class_four,posCE_class_four]=min(global_multiv_CE_class_four);
%min_multi_JS_class_four=global_multiv_JS_class_four(posCE_class_four);
[min_multi_DIV_class_four,posDIV_class_four]=min(global_multiv_DIV_class_four);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE class four: ',num2str(min_multi_CE_class_four),', ',parameter_name,':',num2str(array_vals(special_values(posCE_class_four)))]);
disp(['Min DIV class four: ',num2str(min_multi_DIV_class_four),', ',parameter_name,':',num2str(array_vals(special_values(posDIV_class_four)))]);
%     %Now define errorbars
eb_min_multi_CE_class_four=eb_global_multiv_CE_class_four(posCE_class_four);
%eb_min_multi_JS_class_four=eb_global_multiv_JS_class_four(posCE_class_four);
eb_min_multi_DIV_class_four=eb_global_multiv_DIV_class_four(posDIV_class_four);


disp(' '),
disp('Other classes'),
[min_multi_CE_other_classes,posCE_other_classes]=min(global_multiv_CE_other_classes);
[min_multi_DIV_other_classes,posDIV_other_classes]=min(global_multiv_DIV_other_classes);
disp(['Explored ',num2str(n_configs),' ',parameter_name,' of file ',file_name]),
disp(['Min CE class 2-X: ',num2str(min_multi_CE_other_classes),', ',parameter_name,':',num2str(array_vals(posCE_other_classes))]);
disp(['Min DIV class 2-X: ',num2str(min_multi_DIV_other_classes),', ',parameter_name,':',num2str(array_vals(posDIV_other_classes))]);

%
%Two-class
%twoCE=mean(twoClass_CE,2);twoDIV=mean(twoClass_DIV,2);
%[min_2_CE,pos2CE]=min(twoCE);
%[min_2_DIV,pos2DIV]=min(twoDIV);
%
%Mean errorbars
%auxiliar=twoClass_CE(pos2CE,:); twoCEeb=std(auxiliar)/sqrt(length(auxiliar));
%auxiliar=twoClass_DIV(pos2DIV,:); twoDIVeb=std(auxiliar)/sqrt(length(auxiliar));
%disp(['Min Pair-of-classes CE: ',num2str(min_2_CE),'(',num2str(mean(twoCEeb)),'); ',parameter_name,':',num2str(array_vals(pos2CE))]);
%disp(['Min Pair-of-classes DIV: ',num2str(min_2_DIV),'(',num2str(mean(twoDIVeb)),'); ', parameter_name,':',num2str(array_vals(pos2DIV))]);

% basic_conf.regul=array_vals(special_values(posDIV));
% save([parameter_name,'_',file_name,'_Blocks',num2str(evaluation_blocks),'_Order',num2str(order),'.mat']);

%IV-PLots and stats

%Silly bar plots of CE, DIV and JS for the multivariate discriminant,
%cross-validated in (likely 4) blocks of (likely 40) trials

CE=[min_multi_CE_class_one,min_multi_CE_class_two,min_multi_CE_class_three,min_multi_CE_class_four];
eb_CE=[eb_min_multi_CE_class_one,eb_min_multi_CE_class_two,eb_min_multi_CE_class_three,eb_min_multi_CE_class_four];
% JS=[min_multi_JS_class_one,min_multi_JS_class_two,min_multi_JS_class_three,min_multi_JS_class_four];
% eb_JS=[eb_min_multi_JS_class_one,eb_min_multi_JS_class_two,eb_min_multi_JS_class_three,eb_min_multi_JS_class_four];
DIV=[min_multi_DIV_class_one,min_multi_DIV_class_two,min_multi_DIV_class_three,min_multi_DIV_class_four];
eb_DIV=[eb_min_multi_DIV_class_one,eb_min_multi_DIV_class_two,eb_min_multi_DIV_class_three,eb_min_multi_DIV_class_four];
x=(1:4);
subplot(231),
errorbar(x,CE,eb_CE,'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
bar(1,CE(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,CE(2),'FaceColor',[.1,.1,.1],'LineWidth',2);hold on;
bar(3,CE(3),'FaceColor',[.6,.6,.6],'LineWidth',2);hold on;bar(4,CE(4),'FaceColor',[0,.7,0],'LineWidth',2);hold on;
xl=xlabel('Class');
yl=ylabel('Segregation error (%)');
tit=title('Cross-validated trials 1 to ...');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(gcf,'color',[1 1 1]);
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

subplot(232),
errorbar(x,DIV,eb_DIV,'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
bar(1,DIV(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,DIV(2),'FaceColor',[.1,.1,.1],'LineWidth',2);hold on;
bar(3,DIV(3),'FaceColor',[.6,.6,.6],'LineWidth',2);hold on;bar(4,DIV(4),'FaceColor',[0,.7,0],'LineWidth',2);hold on;
xl=xlabel('Class');
yl=ylabel('Incoherent (%)');
tit=title('Cross-validated trials 1 to ...');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(gcf,'color',[1 1 1]);
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

% subplot(233),
% errorbar(x,JS,eb_JS,'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
% bar(1,JS(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,JS(2),'FaceColor',[.1,.1,.1],'LineWidth',2);hold on;
% bar(3,JS(3),'FaceColor',[.6,.6,.6],'LineWidth',2);hold on;bar(4,JS(4),'FaceColor',[0,.7,0],'LineWidth',2);hold on;
% xl=xlabel('Class)');
% yl=ylabel('Jensen-Shannon');
% tit=title('Cross-validated trials 1 to 160');
% set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
% set(gcf,'color',[1 1 1]);
% set(xl,'FontName','Arial','FontSize',10);
% set(yl,'FontName','Arial','FontSize',10);


%Grouping classes

subplot(234),
errorbar(1,CE(1),eb_CE(1),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
errorbar(2,mean(CE(2:end)),mean(eb_CE(2:end)),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
bar(1,CE(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,mean(CE(2:end)),'FaceColor',[.1,.1,.1],'LineWidth',2);
xl=xlabel('Class');
yl=ylabel('Segregation error (%)');
tit=title('Cross-validated trials 1 to ...');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(gcf,'color',[1 1 1]);
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

subplot(235),
errorbar(1,DIV(1),eb_DIV(1),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
errorbar(2,mean(DIV(2:end)),mean(eb_DIV(2:end)),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
bar(1,DIV(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,mean(DIV(2:end)),'FaceColor',[.1,.1,.1],'LineWidth',2);
xl=xlabel('Class');
yl=ylabel('Incoherent (%)');
tit=title('Cross-validated trials 1 to 160');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(gcf,'color',[1 1 1]);
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

% subplot(236),
% errorbar(1,JS(1),eb_JS(1),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
% errorbar(2,mean(JS(2:end)),mean(eb_JS(2:end)),'Color','k','Marker','none','LineWidth',2,'LineStyle','none');hold on;
% bar(1,JS(1),'FaceColor',[0,0,.7],'LineWidth',2);hold on;bar(2,mean(JS(2:end)),'FaceColor',[.1,.1,.1],'LineWidth',2);
% xl=xlabel('Class)');
% yl=ylabel('Jensen-Shannon');
% tit=title('Cross-validated trials 1 to 160');
% set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
% set(gcf,'color',[1 1 1]);
% set(xl,'FontName','Arial','FontSize',10);
% set(yl,'FontName','Arial','FontSize',10);

%Stats. Class 1 compared with the rest of them:
othersCE=[ALL_CE_class_two(:,posCE_class_two);ALL_CE_class_three(:,posCE_class_three);ALL_CE_class_four(:,posCE_class_four)];
%In columns, because signed rank test requires to compare vectors with
%the same number of elements
othersCEBIS=[ALL_CE_class_two(:,posCE_class_two),ALL_CE_class_three(:,posCE_class_three),ALL_CE_class_four(:,posCE_class_four)];
othersCEBIS=mean(othersCEBIS');
othersDIV=[ALL_DIV_class_two(:,posDIV_class_two);ALL_DIV_class_three(:,posDIV_class_three);ALL_DIV_class_four(:,posDIV_class_four)];
othersDIVBIS=[ALL_DIV_class_two(:,posDIV_class_two),ALL_DIV_class_three(:,posDIV_class_three),ALL_DIV_class_four(:,posDIV_class_four)];
othersDIVBIS=mean(othersDIVBIS');
% othersJS=[ALL_JS_class_two(:,posCE_class_two);ALL_JS_class_three(:,posCE_class_three);ALL_JS_class_four(:,posCE_class_four)];
% othersJSBIS=[ALL_JS_class_two(:,posCE_class_two),ALL_JS_class_three(:,posCE_class_three),ALL_JS_class_four(:,posCE_class_four)];
% othersJSBIS=mean(othersJSBIS');

CE1=ALL_CE_class_one(:,posCE_class_one);DIV1=ALL_DIV_class_one(:,posDIV_class_one);
%JS1=ALL_JS_class_one(:,posCE_class_one);

%Saving specifically two variables for beign used in agregatted stats:

%savefig([parameter_name,'_',file_name,'.fig']);

%save(['Full_',parameter_name,'_',file_name,'_Blocks',num2str(evaluation_blocks),'_Order',num2str(order),'.mat']);
%save(['Summary_',parameter_name,'_',file_name,'_Blocks',num2str(evaluation_blocks),'_Order',num2str(order),'.mat'],...
 %  'CE1','DIV1','JS1','othersCE','othersDIV','othersJS');
%

hold off;

%Stats. Class 1 compared with class two (usually the one associated to the larger error):
[p,~,stats]=ranksum(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));
disp(['Ranksum CE class 1 with class ',num2str(2),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));
disp(['Signrank CE class 1 with class ',num2str(2),': W=',num2str(stats.signedrank),',p=',num2str(p)]);

[p,~,stats]=ranksum(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));
disp(['Ranksum DIV class 1 with class ',num2str(2),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));
disp(['Signrank DIV class 1 with class ',num2str(2),': W=',num2str(stats.signedrank),',p=',num2str(p)]);

% [p,~,stats]=ranksum(ALL_JS_class_one(:,posCE_class_one),ALL_JS_class_two(:,posCE_class_two));
% disp(['Ranksum JS class 1 with class ',num2str(2),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
% [p,~,stats]=signrank(ALL_JS_class_one(:,posCE_class_one),ALL_JS_class_two(:,posCE_class_two));
% disp(['Signrank JS class 1 with class ',num2str(2),': W=',num2str(stats.signedrank),',p=',num2str(p)]);



%disp(['Results saved in: ',which(name)]),
delete(gcp('nocreate'))
h=floor(toc/3600); m=floor(toc/60)-(h*60);s=round(toc-(h*3600)-(m*60));
disp(['Total time ',num2str(h),':',num2str(m),':',num2str(s)]),
% %
[p,~,stats]=ranksum(CE1,othersCE);
disp(['Ranksum CE class 1 with the rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(CE1,othersCEBIS);
disp(['signrank CE class 1 with the mean of the rest: W=',num2str(stats.signedrank),',p=',num2str(p)]);

[p,~,stats]=ranksum(DIV1,othersDIV);
disp(['Ranksum DIV class 1 with the rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(DIV1,othersDIVBIS);
disp(['signrank DIV class 1 with the mean of the rest: W=',num2str(stats.signedrank),',p=',num2str(p)]);
% 
% [p,~,stats]=ranksum(JS1,othersJS);
% disp(['Ranksum JS class 1 with the  rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);
% [p,~,stats]=signrank(JS1,othersJSBIS);
% disp(['signrank JS class 1 with the the mean of the rest: W=',num2str(stats.signedrank),',p=',num2str(p)]);
