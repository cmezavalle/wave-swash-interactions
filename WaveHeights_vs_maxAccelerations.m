%==========================================================================
% Wave heights vs. maximum accelerations
% Plot the distribution of accelerations for different wave heights
%==========================================================================
%%
clear; close all; clc
format long
letsz = 24; %Font Size
lw    = 1.5;%Line width
sz = 150;
%--------------------------------------------------------------------------
%Data
H = [0.1,0.2,0.3,0.4];
maxSingleAcc = [0.0939,0.226762,0.536108,0.919977]; 
coeff = polyfit(H',maxSingleAcc',1);
%Data log
Hlog = log10(H);
maxSingleAcclog = log10(maxSingleAcc);
coeffx = polyfit(Hlog,maxSingleAcclog,1);
%--------------------------------------------------------------------------
% Plots
fig1 = figure;
scatter(H,maxSingleAcc,sz,'filled','MarkerFaceColor','m','MarkerEdgeColor','k','Marker','d')
xlim([0 0.45])
ylim([0 1])
xlabel('H/h')
ylabel('max.$\rm \big(\frac{Dw/Dt}{g}\big)$')
axis square
ax1 = gca;
ax1.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
set(gca, 'FontSize', letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
%Inset figure
axes('Position',[0.360416666666667,0.561151079136691,0.178645833333333,0.352517985611511])
box on
% linear plot
scatter(H,maxSingleAcc,sz,'filled','MarkerFaceColor','m','MarkerEdgeColor','k','Marker','d');
xlim([0 0.45]);
ylim([0 1]);
% power law fit
Hlog = log10(H);
maxSingleAcclog = log10(maxSingleAcc);
coeffs = polyfit(Hlog,maxSingleAcclog,1);
% log plot
loglog(H,maxSingleAcc,'LineStyle','none','LineWidth',0.5,'Marker','d','MarkerFaceColor','m','MarkerEdgeColor','k','MarkerSize',12)
hold on;
loglog([0.1:0.1:0.45],(10^coeffs(2))*(0.1:0.1:0.45).^coeffs(1),'--','Color',[0.6 0.6 0.6])
xlabel('H/h')
ylabel('max.$\rm \big(\frac{Dw/Dt}{g}\big)$')
axis square
ax1 = gca;
ax1.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
set(gca, 'FontSize', letsz)
set(gcf,'color','w');
box on
