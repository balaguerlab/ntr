function display_class_results(data1,e1,data2,e2,order,fig_title,combi)
%Private, auxiliar file, displaying means and SEM per class or
%pairwise comparisons.
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
%Inputs
%   data1 (n_comparisons x 2) = Each column is the % missclassified vectors
%                              for two specified "orders".
%                              If only one column specified, it correspond
%                              to O="order".
%   e1 (n_comparisons x 2) = Error bars corresponding to data1 columns
%   data2 (n_comparisons x 2) = Same for the % of divergent trajectories
%   e2 (n_comparisons x 2) = Error bars corresponding to data2 columns
%   order (1x1) = Nonlinear expansion order
%   title (string)= Text describing the figure
%

[n_comp,n_orders]=size(data1);%Number of comparisons
XTickLabels=cell(1,n_comp);
for i=1:n_comp,
    if (nargin<7),
        XTickLabels{i}=num2str(i);
    else
        if ~any(isletter(combi))
            XTickLabels=combi;
        else
            current_pair=combi(i,:);
            XTickLabels{i}=[num2str(current_pair(1)),'-',num2str(current_pair(2))];
        end
    end
end
if (length(data2(:,1))~=n_comp)||(length(e1(:,1))~=n_comp)||(length(e2(:,1))~=n_comp),
    warning('display_class_results:data_mismatch','Mismatch between data length, figure not produced'),
else
    figure
    if n_orders>1,
        long_title=[fig_title,': original and expanded space (order=',num2str(order),')'];
    else
        long_title=[fig_title,': expanded space (order=',num2str(order),')'];
    end
        set(gcf,'Color',[1,1,1],'Name',long_title),
        %
        %Missclasified vectors
        subplot(1,2,1),errorbar(data1(:,1),e1(:,1),'bo');
        if n_orders>1, hold on,errorbar(data1(:,2),e2(:,2),'ro'); end
        xl=xlabel('Task-epoch (or task-epoch-pair comparison)');
        yl=ylabel('Segregation error (%)');
        set(gca,'XTick',(1:n_comp),'XTickLabelMode','manual','XTickLabel',XTickLabels,...
            'FontSize',8);
        tit=title([fig_title,': Missclasified (%)']);
        if n_orders>1, 
            leg=legend('Activity space',['Expanded space of order ',num2str(order)]);
            set(leg,'FontName','Arial','FontSize',10);
        end
        set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
        set(xl,'FontName','Arial','FontSize',10);
        set(yl,'FontName','Arial','FontSize',10);
        set(gca,'FontName','Arial','FontSize',8);
        view(90,90);
        %
        %Divergent trajectories
        subplot(1,2,2),errorbar(data2(:,1),e2(:,1),'go');
        if n_orders>1, hold on, errorbar(data2(:,2),e2(:,2),'co'); end
        xl=xlabel('Task-epoch (or task-epoch-pair comparison)');
        yl=ylabel('Divergent trajectories (%)');
        set(gca,'XTick',(1:n_comp),'XTickLabelMode','manual','XTickLabel',XTickLabels,...
            'FontSize',8);
        tit=title([fig_title,': Divergent trajectories (%)']);
        if n_orders>1, 
            leg=legend('Activity space',['Expanded space of order ',num2str(order)]); 
            set(leg,'FontName','Arial','FontSize',10);
        end
        set(tit,'FontName','Arial','FontSize',10,'FontAngle','Italic');
        set(xl,'FontName','Arial','FontSize',10);
        set(yl,'FontName','Arial','FontSize',10);
        set(gca,'FontName','Arial','FontSize',8);
        view(90,90);
end