function [total_CE1,total_DIV1,total_JS1,total_othersCE,total_othersDIV,total_othersJS]=global_stats()
figure; clear;clc; %close all
%Example of decoding with all ensembles e.g., Figure 4
%1-Global stats and plots for all animals 
total_CE1=[];total_DIV1=[];total_JS1=[];
total_othersCE=[];total_othersDIV=[];total_othersJS=[];n_units=0;

load('Summary_Specific_92_10_1_lagDCMHardcoded_parfor_issues_4Class_92_10at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+6;


load('Summary_Specifc_92_11_NoDCMHardcoded_parfor_issues_4Class_92_11at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+5;


load('Summary_Specific_95_23_3_classes_NoDCMHardcoded_parfor_issues_3Class_95_23at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+5;


load('Summary_Specific_95_24_3_classes_NoDCMHardcoded_parfor_issues_3Class_95_24at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+8;


load('Summary_unbalanced_movement_latency_3Class_92_23at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+5;


load('Summary_unbalanced_movement_latency_3Class_92_24at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+5;


load('Summary_unbalanced_movement_latency_3Class_95_27at0.08Bin40Trials-block_Blocks4_Order3.mat');
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+7;


%New ones 


load('Summary_balanced_classes2019_4Class_92_15at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+4;


load('Summary_balanced_classes2019_4Class_92_25at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+4;



%95

load('Summary_balanced_classes2019_4Class_95_25at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+4;


load('no_lag_Summary_balanced_classes2019_4Class_95_31at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+4;


%96


load('Summary_balanced_classes2019_4Class_96_22at0.08Bin40Trials-block_Blocks4_Order3.mat');%EQUAL-
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+4;


load('Summary_balanced_classes2019_4Class_96_23at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;


load('Summary_balanced_classes2019_4Class_96_26at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;


%Further new

load('Summary_balanced_classes2019_4Class_92_19at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK -
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;

load('Summary_balanced_classes2019_4Class_92_31at0.08Bin40Trials-block_Blocks4_Order3.mat');%EQUAL
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;

load('Summary_balanced_classes2019_4Class_95_35at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;

load('Summary_balanced_classes2019_4Class_95_36at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;

load('Summary_balanced_classes2019_4Class_95_43at0.08Bin40Trials-block_Blocks4_Order3.mat');%OK
total_CE1=[total_CE1;CE1];total_DIV1=[total_DIV1;DIV1];%total_JS1=[total_JS1;JS1];
total_othersCE=[total_othersCE;othersCE];
total_othersDIV=[total_othersDIV;othersDIV];
%total_othersJS=[total_othersJS;othersJS];
n_units=n_units+3;



disp(['Number units=',num2str(n_units)]),



%2-Error bar plots

means_CE1=nanmean(total_CE1);eb_CE1=nanstd(total_CE1)./sqrt(length(total_CE1));
means_DIV1=nanmean(total_DIV1);eb_DIV1=nanstd(total_DIV1)./sqrt(length(total_DIV1));
%means_JS1=nanmean(total_JS1);eb_JS1=nanstd(total_JS1)./sqrt(length(total_JS1));

means_othersCE=nanmean(total_othersCE);eb_othersCE=nanstd(total_othersCE)./sqrt(length(total_othersCE));
means_othersDIV=nanmean(total_othersDIV);eb_othersDIV=nanstd(total_othersDIV)./sqrt(length(total_othersDIV));
%means_othersJS=nanmean(total_othersJS);eb_othersJS=nanstd(total_othersJS)./sqrt(length(total_othersJS));


%subplot(234),
subplot(223),
errorbar(1,means_CE1,eb_CE1,'Color',[0,0,.7],'Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
errorbar(2,means_othersCE,eb_othersCE,'Color','k','Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
bar(1,means_CE1,'LineWidth',1.5,'EdgeColor',[0,0,.7],'FaceColor','none');hold on;bar(2,means_othersCE,'LineWidth',1.5,'FaceColor','none');
xl=xlabel('Class');
yl=ylabel('Segregation error (%)');
tit=title('Cross-validated trials 1 to 160');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(gcf,'color',[1 1 1],'Name',['Average all data=',num2str(n_units),' units']);
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

%subplot(235),
subplot(224),
errorbar(1,means_DIV1,eb_DIV1,'Color',[0,0,.7],'Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
errorbar(2,means_othersDIV,eb_othersDIV,'Color','k','Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
bar(1,means_DIV1,'LineWidth',1.5,'EdgeColor',[0,0,.7],'FaceColor','none');hold on;bar(2,means_othersDIV,'LineWidth',1.5,'FaceColor','none');
xl=xlabel('Class');
yl=ylabel('Incoherent (%)');
tit=title('Cross-validated trials 1 to 160');
set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
set(xl,'FontName','Arial','FontSize',10);
set(yl,'FontName','Arial','FontSize',10);

% subplot(236),
% errorbar(1,means_JS1,eb_JS1,'Color',[0,0,.7],'Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
% errorbar(2,means_othersJS,eb_othersJS,'Color','k','Marker','none','LineWidth',1.5,'LineStyle','none');hold on;
% bar(1,means_JS1,'LineWidth',1.5,'EdgeColor',[0,0,.7],'FaceColor','none');hold on;bar(2,means_othersJS,'LineWidth',1.5,'FaceColor','none');
% xl=xlabel('Class)');
% yl=ylabel('Jensen-Shannon');
% tit=title('Cross-validated trials 1 to 160');
% set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
% set(xl,'FontName','Arial','FontSize',10);
% set(yl,'FontName','Arial','FontSize',10);

%3-Stats. Class 1 compared with the rest of them:

[p,~,stats]=ranksum(total_CE1,total_othersCE);
disp(['Ranksum CE class 1 with the rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);

[p,~,stats]=ranksum(total_DIV1,total_othersDIV);
disp(['Ranksum DIV class 1 with the rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);
% 
% [p,~,stats]=ranksum(total_JS1,total_othersJS);
% disp(['Ranksum JS class 1 with the  rest: U=',num2str(stats.ranksum),',p=',num2str(p)]);



