clear
clc
load('Specifc_92_11_NoDCMHardcoded_parfor_issues_4Class_92_11at0.08Bin40Trials-block_Blocks4_Order3.mat')

CE_anova=[ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two),ALL_CE_class_three(:,posCE_class_three),ALL_CE_class_four(:,posCE_class_four)];
DIV_anova=[ALL_CE_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two),ALL_DIV_class_three(:,posDIV_class_three),ALL_DIV_class_four(:,posDIV_class_four)];

[h1,p1]=lillietest(CE_anova(:,1));[h2,p2]=lillietest(CE_anova(:,2));[h3,p3]=lillietest(CE_anova(:,3));[h4,p4]=lillietest(CE_anova(:,4));
disp([' lilliefors min p=',num2str(min([p1,p2,p3,p4])),' max h=',num2str(max([h1,h2,h3,h4])),' (non-gauss if h=1, p<0.05)']),
% 
% p_threshold=0.05;
% disp('_______________________________________')
% disp('______________ANOVAS AND POSTHOCS__________________________')
% disp(' ')
% [p,tbl,stats] = anova1(CE_anova);    
% disp(['Anova, F(',num2str(tbl{2,3}),',',num2str(tbl{3,3}),')=',num2str(tbl{2,5}),' p=',num2str(p)]),
% [c,~,~,~] = multcompare(stats,'Alpha',p_threshold,'CType','bonferroni');
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(2),' p=',num2str(c(1,end))])
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(3),' p=',num2str(c(2,end))])
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(4),' p=',num2str(c(3,end))])
% disp(' ')
% disp(' ')
% [p,tbl,stats] = kruskalwallis(CE_anova);
% disp(['Kruskal-Wallis, Chi2(',num2str(tbl{2,3}),',',num2str(tbl{3,3}),')=',num2str(tbl{2,5}),' p=',num2str(p)]),
% [c,~,~,~] = multcompare(stats,'Alpha',p_threshold,'CType','bonferroni');
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(2),' p=',num2str(c(1,end))])
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(3),' p=',num2str(c(2,end))])
% disp(['Bonferroni corrected values: class ',num2str(1), ' vs ',num2str(4),' p=',num2str(c(3,end))])

disp('_______________________________________')
disp('______________UNCORRECTED PAIRSIWE IF ANOVA FAILS__________________________')
disp(' ')
disp('CE')
disp(' ')
%Stats. CE Class 1 compared with class two (usually the one associated to the larger error):
[p,~,stats]=ranksum(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));%p=p*3;
disp(['Ranksum CE class 1 with class ',num2str(2),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));%p=p*3;
disp(['Signrank CE class 1 with class ',num2str(2),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));%p=p*3;
disp(['ttest1 CE class 1 with class ',num2str(2),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_two(:,posCE_class_two));%p=p*3;
disp(['ttest2 CE class 1 with class ',num2str(2),': T=',num2str(stats.tstat),',p=',num2str(p)]);
disp(' ')

%Stats. CE Class 1 compared with class three
[p,~,stats]=ranksum(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_three(:,posCE_class_three));%p=p*3;
disp(['Ranksum CE class 1 with class ',num2str(3),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_three(:,posCE_class_three));%p=p*3;
disp(['Signrank CE class 1 with class ',num2str(3),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_three(:,posCE_class_three));%p=p*3;
disp(['ttest1 CE class 1 with class ',num2str(3),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_three(:,posCE_class_three));%p=p*3;
disp(['ttest2 CE class 1 with class ',num2str(3),': T=',num2str(stats.tstat),',p=',num2str(p)]);
disp(' ')

%Stats. CE Class 1 compared with class four
[p,~,stats]=ranksum(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_four(:,posCE_class_four));%p=p*3;
disp(['Ranksum CE class 1 with class ',num2str(4),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_four(:,posCE_class_four));%p=p*3;
disp(['Signrank CE class 1 with class ',num2str(4),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_four(:,posCE_class_four));%p=p*3;
disp(['ttest1 CE class 1 with class ',num2str(4),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_CE_class_one(:,posCE_class_one),ALL_CE_class_four(:,posCE_class_four));%p=p*3;
disp(['ttest2 CE class 1 with class ',num2str(4),': T=',num2str(stats.tstat),',p=',num2str(p)]);
disp(' ')
disp('_______________________________________')
disp(' ')
disp('DIV')
disp(' ')
%Stats. CE Class 1 compared with class two (usually the one associated to the larger error):
[p,~,stats]=ranksum(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));%p=p*3;
disp(['Ranksum DIV class 1 with class ',num2str(2),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));%p=p*3;
disp(['Signrank DIV class 1 with class ',num2str(2),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));%p=p*3;
disp(['ttest1 DIV class 1 with class ',num2str(2),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_two(:,posDIV_class_two));%p=p*3;
disp(['ttest2 DIV class 1 with class ',num2str(2),': T=',num2str(stats.tstat),',p=',num2str(p)]);
disp(' ')

%Stats. DIV Class 1 compared with class three
[p,~,stats]=ranksum(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_three(:,posDIV_class_three));%p=p*3;
disp(['Ranksum DIV class 1 with class ',num2str(3),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_three(:,posDIV_class_three));%p=p*3;
disp(['Signrank DIV class 1 with class ',num2str(3),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_three(:,posDIV_class_three));%p=p*3;
disp(['ttest1 DIV class 1 with class ',num2str(3),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_three(:,posDIV_class_three));%p=p*3;
disp(['ttest2 DIV class 1 with class ',num2str(3),': T=',num2str(stats.tstat),',p=',num2str(p)]);
disp(' ')

%Stats. DIV Class 1 compared with class three
[p,~,stats]=ranksum(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_four(:,posDIV_class_four));%p=p*3;
disp(['Ranksum DIV class 1 with class ',num2str(4),': U=',num2str(stats.ranksum),',p=',num2str(p)]);
[p,~,stats]=signrank(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_four(:,posDIV_class_four));%p=p*3;
disp(['Signrank DIV class 1 with class ',num2str(4),': W=',num2str(stats.signedrank),',p=',num2str(p)]);
disp(' ')
[~,p,~,stats]=ttest(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_four(:,posDIV_class_four));%p=p*3;
disp(['ttest1 DIV class 1 with class ',num2str(4),': T=',num2str(stats.tstat),',p=',num2str(p)]);
[~,p,~,stats]=ttest2(ALL_DIV_class_one(:,posDIV_class_one),ALL_DIV_class_four(:,posDIV_class_four));%p=p*3;
disp(['ttest2 DIV class 1 with class ',num2str(4),': T=',num2str(stats.tstat),',p=',num2str(p)]);






