
function global_2class_stats_report(order,global_pair_stats_nonlin,global_pair_tests,tr_global_pair_tests,global_pair_stats_lin)
%Private, auxiliar file, displaying a global statistical report for
%two-class discriminant analyses. Display will depend wether or not the "linear"
%results are provided for comparison
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
%April 2020.
%
%
%Log of changes: Please specify here your code modifications
%(#Line@author: Change description). This will be useful if assistance is
%required
%
%
%__________________________________________________________________________
%
if nargin>4
    disp('   #Original space of neural activity:'),
    disp(['      Double-Mean missclasified (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_lin(1)),'[',num2str(global_pair_stats_lin(2)),']%']),
    %disp(['         [Double-Mean outliers (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_lin(3)),'[',num2str(global_pair_stats_lin(4)),']%']),
    disp(['      Double-Mean divergent trajec. (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_lin(5)),'[',num2str(global_pair_stats_lin(6)),']%']),
    %disp(['         [Double-Mean outliner trajec. (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_lin(7)),'[',num2str(global_pair_stats_lin(8)),']%']),
end
disp(['   #Expanded space of interactions order ',num2str(order)]),
disp(['       Double-Mean missclasified (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_nonlin(1)),'[',num2str(global_pair_stats_nonlin(2)),']%']),
%disp(['          [Double-Mean outliers (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_nonlin(3)),'[',num2str(global_pair_stats_nonlin(4)),']%']),
disp(['       Double-Mean divergent trajec.(across validation sets and epochs)[SEM]=',num2str(global_pair_stats_nonlin(5)),'[',num2str(global_pair_stats_nonlin(6)),']%']),
%disp(['          [Double-Mean outliner trajec. (across validation sets and epochs)[SEM]=',num2str(global_pair_stats_nonlin(7)),'[',num2str(global_pair_stats_nonlin(8)),']%']),
disp(' ')
if ~all(all(isnan(global_pair_tests))),
    %Misscla. (%)
    disp('    #Normality tests across-epochs means missclas. (%). p(df,statistic):'),
    disp('       Chi2            Kolmog.-Smirnov            Lilliefords')
    disp(['      ',num2str(global_pair_tests(1,1)),'(',num2str(global_pair_tests(2,1)),',',num2str(global_pair_tests(3,1)),')',...
        '      ',num2str(global_pair_tests(1,2)),'(',num2str(global_pair_tests(2,2)),',',num2str(global_pair_tests(3,2)),')',...
        '      ',num2str(global_pair_tests(1,3)),'(',num2str(global_pair_tests(2,3)),',',num2str(global_pair_tests(3,3)),')']),
    %Comparisons between O=1 and O=order
    if nargin>4
        disp(['  T-test(O=1,O). p(df,t):',num2str(global_pair_tests(1,4)),'(',num2str(global_pair_tests(2,4)),',',num2str(global_pair_tests(3,4)),')']),
        disp(['  Wilcoxon rank-sum(O=1,O). p(n,ranksum):',num2str(global_pair_tests(1,5)),'(',num2str(global_pair_tests(2,5)),',',num2str(global_pair_tests(3,5)),')']),
    end
    disp(' ')
    %
    %Div.trajec. (%). Global percent.
    disp('    #Task-epoch averaged % divergent trajec. Normality tests. p(df,statistic):'),
    disp('       Chi2            Kolmog.-Smirnov            Lilliefords')
    disp(['      ',num2str(tr_global_pair_tests(1,1)),'(',num2str(tr_global_pair_tests(2,1)),',',num2str(tr_global_pair_tests(3,1)),')',...
        '      ',num2str(tr_global_pair_tests(1,2)),'(',num2str(tr_global_pair_tests(2,2)),',',num2str(tr_global_pair_tests(3,2)),')',...
        '      ',num2str(tr_global_pair_tests(1,3)),'(',num2str(tr_global_pair_tests(2,3)),',',num2str(tr_global_pair_tests(3,3)),')']),
    %Comparisons between O=1 and O=order
    if nargin>4
        disp(['   T-test(O=1,O). p(df,t):',num2str(tr_global_pair_tests(1,4)),'(',num2str(tr_global_pair_tests(2,4)),',',num2str(tr_global_pair_tests(3,4)),')']),
        disp(['   Wilcoxon rank-sum(O=1,O). p(n,ranksum):',num2str(tr_global_pair_tests(1,5)),'(',num2str(tr_global_pair_tests(2,5)),',',num2str(tr_global_pair_tests(3,5)),')']),
    end
end