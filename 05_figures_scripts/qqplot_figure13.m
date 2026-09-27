%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% qqplot_figure13 - The code is to generate figure 13
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
addpath('../02_functions/')

set(0,'defaulttextinterpreter','latex', 'DefaultLegendInterpreter', 'latex')

%% === First Level Model: ISTVF/IG ===
load ../06_results/TwoLevelSimulation/LevelTwo/SimLevelTwoTest_ISTVF_IG.mat

%%%% --- Setup the plot ---
i=1;
figure(100)
hold on;
qqplot(Ltest(i,:),Lig(i,:));set(gcf,'Visible','off');
ax1 = get(gca,'Children');x1 = get(ax1,'XData');y1 = get(ax1,'YData');
x1 = cell2mat(x1(1)); y1 = cell2mat(y1(1));
qqplot(Ltest(i,:),Lmg(i,:));set(gcf,'Visible','off');
ax2 = get(gca,'Children');x2 = get(ax2,'XData');y2 = get(ax2,'YData');
x2 = cell2mat(x2(1)); y2 = cell2mat(y2(1));
qqplot(Ltest(i,:),Li(i,:));set(gcf,'Visible','off');
ax3 = get(gca,'Children');x3 = get(ax3,'XData');y3= get(ax3,'YData');
x3 = cell2mat(x3(1)); y3 = cell2mat(y3(1));
hold off

%%%% --- This is the desired output ---
xmax = max([max(y1),max(y2),max(y3),max(x1),max(x2),max(x3)]);
xmin = min([min(y1),min(y2),min(y3),min(x1),min(x2),min(x3)]);
f = figure(1);
t = tiledlayout(2,1,"TileSpacing","tight","Padding","tight");
nexttile(1)
hold on;plot(x1,x1,'k-','Linewidth',2);plot(x1,y1,'ro','MarkerSize',10);plot(x2,y2,'b+','MarkerSize',10);plot(x3,y3,'c.','MarkerSize',10);
x_limits = xlim;
ylim(x_limits)
title({'Level One Simulation:', '{\it IS-TVF/SequentialPCA/IG}'}, 'interpreter','latex')
set(gca,'FontSize',16)

%% === First Level Model: SIEM/IG ===
clear x1 x2 x3 y1 y2 y3 xmax xmin
load ../06_results/TwoLevelSimulation/LevelTwo/SimLevelTwoTest_SIEM_IG.mat

%%%% --- Setup the plot ---
i=1;
figure(200)
hold on;
qqplot(Ltest(i,:),Lig(i,:));set(gcf,'Visible','off');
ax1 = get(gca,'Children');x1 = get(ax1,'XData');y1 = get(ax1,'YData');
x1 = cell2mat(x1(1)); y1 = cell2mat(y1(1));
qqplot(Ltest(i,:),Lmg(i,:));set(gcf,'Visible','off');
ax2 = get(gca,'Children');x2 = get(ax2,'XData');y2 = get(ax2,'YData');
x2 = cell2mat(x2(1)); y2 = cell2mat(y2(1));
qqplot(Ltest(i,:),Li(i,:));set(gcf,'Visible','off');
ax3 = get(gca,'Children');x3 = get(ax3,'XData');y3 = get(ax3,'YData');
x3 = cell2mat(x3(1)); y3 = cell2mat(y3(1));
hold off

%%%% --- This is the desired output ---
xmax = max([max(y1),max(y2),max(y3),max(x1),max(x2),max(x3)]);
xmin = min([min(y1),min(y2),min(y3),min(x1),min(x2),min(x3)]);
figure(1);
nexttile(2)
hold on;plot(x1,x1,'k-','Linewidth',2);plot(x1,y1,'ro','MarkerSize',10);plot(x2,y2,'b+','MarkerSize',10);plot(x3,y3,'c.','MarkerSize',10);
title({'Level One Simulation:', '{\it SIEM/SequentialPCA/IG}'},'interpreter','latex')
set(gca,'FontSize',16)

xlabel(t,'LogLikelihood of Test Sequences $\alpha_i^\prime$','FontSize',16,'interpreter','latex')
ylabel(t,'Loglikelihood of Second Level Simulations $\hat{\alpha_i}$','FontSize',16,'interpreter','latex')
LGD = legend({'Test quantiles','{\it IG}','{\it MVG}','PWI'},'Orientation','horizontal');
LGD.Layout.Tile = 'north';
set(f,"Position",[50 50 500 560])
exportgraphics(f,'../06_results/figures/qqplot_test.pdf','Resolution',300) 