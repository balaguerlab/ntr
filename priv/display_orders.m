function display_orders(global_multiv_CE,global_multiv_DIV,twoClass_CE,twoClass_DIV,array_vals,name)
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
%
if nargin<5,
    warning('display_orders:no_orders','Eigth orders displayed'),
    array_vals=[1:8]; name='My config';
end
%    
%III.1 Multivariate
figure;
subplot(221)
errorbar(array_vals',global_multiv_CE(:,1),global_multiv_CE(:,2),'Color',[0.1,0.1,0.6],'Marker','o');
hold on
errorbar(array_vals',global_multiv_DIV(:,1),global_multiv_DIV(:,2),'Color',[0.6,0.1,0.1],'Marker','o');
xl=xlabel('Expansion order (O)');
yl=ylabel('Segregation error (%)');
tit=title('Multivariate FDA');
leg=legend('Classification error (CE) (%)','Divergent trajectories (DIV) (%)');
set(leg,'FontName','Helvetica','FontSize',8, 'Box','off','Color','none');
%
set(tit,'FontName','Helvetica','FontSize',10,'FontAngle','Italic');
set(gcf,'name',name,'color',[1 1 1]);
set(xl,'FontName','Helvetica','FontSize',10);
set(yl,'FontName','Helvetica','FontSize',10);
%Setting the minimum/maximum for a better visualization
maCE=max(global_multiv_CE(:,1)+global_multiv_CE(:,2));maDIV=max(global_multiv_DIV(:,1)+global_multiv_DIV(:,2));
top=max(maCE,maDIV);
miCE=min(global_multiv_CE(:,1)-global_multiv_CE(:,2));miDIV=min(global_multiv_DIV(:,1)-global_multiv_DIV(:,2));
bottom=min(miCE,miDIV);
set(gca,'FontName','Helvetica','FontSize',8,'YLim',[bottom top],'YScale','log');
hold off
%
%III.2 Two-class
subplot(222)
twoCE=mean(twoClass_CE,2);twoDIV=mean(twoClass_DIV,2);
twoCEeb=std(twoClass_CE,0,2)/sqrt(length(twoClass_CE(1,:)));
twoDIVeb=std(twoClass_DIV,0,2)/sqrt(length(twoClass_DIV(1,:)));
%
errorbar(array_vals',twoCE,twoCEeb,'Color',[0.1,0.1,0.6],'Marker','s');
hold on
errorbar(array_vals',twoDIV,twoDIVeb,'Color',[0.6,0.1,0.1],'Marker','s');
xl=xlabel('Expansion order (O)');
yl=ylabel('Segregation error (%)');
tit=title('Pairwise FDA');
leg=legend('Classification error (CE) (%)','Divergent trajectories (DIV) (%)');
set(leg,'FontName','Helvetica','FontSize',8,'Box','off','Color','none');
%
set(tit,'FontName','Helvetica','FontSize',10,'FontAngle','Italic');
set(xl,'FontName','Helvetica','FontSize',10);
set(yl,'FontName','Helvetica','FontSize',10);
%Setting the minimum/maximum for a better visualization
maCE=max(twoCE+twoCEeb);maDIV=max(twoDIV+twoDIVeb);
top=max(maCE,maDIV);
miCE=min(twoCE-twoCEeb);miDIV=min(twoDIV-twoDIVeb);
bottom=min(miCE,miDIV);
set(gca,'FontName','Helvetica','FontSize',8,'YLim',[bottom top],'YScale','log');
hold off
%
%__________________________________
%III.3 Same but fixed span for comparison
bottom=8; top=25;%Fixed
%
%Multiv
subplot(223)
errorbar(array_vals',global_multiv_CE(:,1),global_multiv_CE(:,2),'Color',[0.1,0.1,0.6],'Marker','o');
hold on
errorbar(array_vals',global_multiv_DIV(:,1),global_multiv_DIV(:,2),'Color',[0.6,0.1,0.1],'Marker','o');
xl=xlabel('Expansion order (O)');
yl=ylabel('Segregation error (%)');
%leg=legend('Classification error (CE) (%)','Divergent trajectories (DIV) (%)');
%set(leg,'FontName','Helvetica','FontSize',8, 'Box','off','Color','none');
set(gcf,'name',name,'color',[1 1 1]);
set(xl,'FontName','Helvetica','FontSize',10);
set(yl,'FontName','Helvetica','FontSize',10);
set(gca,'FontName','Helvetica','FontSize',8,'YLim',[bottom top],'YScale','log');
hold off
%
%Two-class
subplot(224)
twoCE=mean(twoClass_CE,2);twoDIV=mean(twoClass_DIV,2);
twoCEeb=std(twoClass_CE,0,2)/sqrt(length(twoClass_CE(1,:)));
twoDIVeb=std(twoClass_DIV,0,2)/sqrt(length(twoClass_DIV(1,:)));
errorbar(array_vals',twoCE,twoCEeb,'Color',[0.1,0.1,0.5],'Marker','s');
hold on
errorbar(array_vals',twoDIV,twoDIVeb,'Color',[0.5,0.1,0.1],'Marker','s');
xl=xlabel('Expansion order (O)');
yl=ylabel('Segregation error (%)');
%leg=legend('Classification error (CE) (%)','Divergent trajectories (DIV) (%)');
%set(leg,'FontName','Helvetica','FontSize',8,'Box','off','Color','none');
set(xl,'FontName','Helvetica','FontSize',10);
set(yl,'FontName','Helvetica','FontSize',10);
set(gca,'FontName','Helvetica','FontSize',8,'YLim',[bottom top],'YScale','log');
hold off
