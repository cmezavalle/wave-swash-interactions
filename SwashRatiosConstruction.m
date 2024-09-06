%==========================================================================
%                 Interactions ratios construction
% Reads and plots different wave-swash interactions parameters 
%Must select files from the folder: ../ManuscriptData/1-Space parameter files 
%==========================================================================
clear all; close all; clc

% Format
format long
letsz = 24;     %Font Size
lw    = 2.5;   %Line width
fonts = listfonts;
set(0,'defaultAxesFontName', 'Times New Roman')
set(0,'defaultTextFontName', 'Times New Roman')
%--------------------------------------------------------------------------
[file,path] = uigetfile({'*.xlsx'},'MultiSelect','on');
fileName = {file};

data = readmatrix([path,fileName{1}]);
data = data(1:end,:);

% Save plots
sav = 0; % 0:No ; 1:Yes
if sav == 1;
    mkdir(fileName);
    cd(fileName)
end

%% Measured cases
H1       = data(:,3); 
H2       = data(:,4); 
Tsep     = data(:,5); 
Tsw      = data(:,6);
code     = data(:,8);
h        = 0.3;
g        = 9.81;
Hst      = H2./H1;
Tst      = Tsep./Tsw;
DwDt     = data(:,11)./g;
lag      = data(:,12);
lagnd    = data(:,13);
u        = data(:,14); 
w        = data(:,15); 
maxu     = data(:,16); 
maxw     = data(:,17);
deltat_u = data(:,20); 
deltat_w = data(:,21);
dTsep    = lagnd./Tsep;

%% Plotting
close all;
sz = 100;
fig1 = figure('units','normalized','outerposition',[0 0 1 1],'Position',[0.13,0.15,0.775,0.79734506148141]);
for i = 1:numel(code)
    hold on
    if code(i) == 1
        h1 = scatter(Hst(i),Tst(i),sz,'filled','o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k','Marker','d');
    elseif code(i) == 2
        h2 = scatter(Hst(i),Tst(i),sz,'filled','o','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor','k','Marker','>');
    elseif code(i) == 3
        h3 = scatter(Hst(i),Tst(i),sz,'filled','o','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(Hst(i),Tst(i),sz,'sq','MarkerEdgeColor','k');
    elseif isnan(code(i))
        h4 = [];
    end
end
scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Fake data to improve plotting
% plot(([0 5]),([0.3 2.6]),'--','Color',[0.7 0.7 0.7]);
% plot([0 5],[0.25 0.88],'--','Color',[0.7 0.7 0.7]);

Hstlog1 = log10(Hst(1:10));
Tstlog1 = log10(Tst(1:10));
coeffs1 = polyfit(Hstlog1,Tstlog1,1);
% log plot
hold on;
x1 = [0.4:0.1:6];
coeffs1(1) = coeffs1(1)+0.12;%slope
coeffs1(2) = coeffs1(2)+0.08;%intercept
p1 = plot(x1,(10^coeffs1(2))*x1.^coeffs1(1),'--','Color',[0.6 0.6 0.6]);
%--------------------------------------------------------------------------
Hstlog2 = log10(Hst(40:46));
Tstlog2 = log10(Tst(40:46));
coeffs2 = polyfit(Hstlog2,Tstlog2,1);
% log plot
hold on;
x2 = [0.4:0.1:6];
coeffs2(1) = coeffs2(1)-0.01;%slope
coeffs2(2) = coeffs2(2)-0.10; %intercept
p2 = plot(x2,(10^coeffs2(2))*x2.^coeffs2(1),':','Color',[0.6 0.6 0.6]);
legend([p1,p2],['$',num2str(coeffs1(2),'%.3f'),'*(H_{2}/H_{1})^{',num2str(coeffs1(1),'%.3f'),'}$'],...
               ['$',num2str(coeffs2(2),'%.3f'),'*(H_{2}/H_{1})^{',num2str(coeffs2(1),'%.3f'),'}$'],'Location','southeast','Box','off')

grid on ; grid minor
% legend([h1,h2,h3,h4],'Wave-upwash interaction','Weak wave-backwash interaction','Strong wave-backwash interaction','No interaction',...
%     'Orientation','horizontal','Location','northoutside','Fontsize',18,'NumColumns',2)
ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel(['$\rm (H_{2}/H_{1})_{',loc,'}$']);
ylabel(['$\rm (T_{sep}/T_{swash})_{',loc,'}$']);
xlim([-0.1 5])
ylim([-0.1 1.7])
xticks([-0.1 0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0])
xticklabels({'-0.1','0.5','1.0','1.5','2.0','2.5 ','3.0','3.5','4.0'})
yticks([-0.1 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig2 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(Hst(i),Tst(i),sz,DwDt(i),'filled','Marker','d','MarkerEdgeColor','k');
    elseif code(i) == 2
        h2 = scatter(Hst(i),Tst(i),sz,DwDt(i),'filled','Marker','>','MarkerEdgeColor','k');
    elseif code(i) == 3
        h3 = scatter(Hst(i),Tst(i),sz,DwDt(i),'filled','MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(Hst(i),Tst(i),sz,'sq','MarkerEdgeColor','k','MarkerFaceColor','g');
    end
end
clim([0 6])
cb = colorbar('northoutside');
colormap hot
ylabel(cb,['max. $\rm \big(\frac{Dw/Dt}{g}\big)$'],'FontSize',letsz,'Rotation',0,'Interpreter','latex')

scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
plot([0 5],[0.45 1.82],'--','Color',[0.7 0.7 0.7]);
plot([0 5],[0.31 0.65],'--','Color',[0.7 0.7 0.7]);
grid on ; grid minor

ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('$\rm H_{2}/H_{1}$');
ylabel('$\rm T_{sep}/T_{swash}$');
xlim([-0.1 5])
ylim([-0.1 1.7])
xticks([-0.1 0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0])
xticklabels({'-0.1','0.5','1.0','1.5','2.0','2.5 ','3.0','3.5','4.0'})
yticks([-0.1 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig3 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(Hst(i),Tst(i),sz,lagnd(i),'filled','Marker','d','MarkerEdgeColor','k');
    elseif code(i) == 2
        h2 = scatter(Hst(i),Tst(i),sz,lagnd(i),'filled','Marker','>','MarkerEdgeColor','k');
    elseif code(i) == 3
        h3 = scatter(Hst(i),Tst(i),sz,lagnd(i),'filled','MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(Hst(i),Tst(i),sz,'sq','MarkerEdgeColor','k','MarkerFaceColor','g');
    end
end
clim([0.9 1.2])
c = colorbar('northoutside');
colormap parula
c.Label.String = 'T_{peak}/T_{swash}';

scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
plot([0 5],[0.45 1.82],'--','Color',[0.7 0.7 0.7]);
plot([0 5],[0.31 0.65],'--','Color',[0.7 0.7 0.7]);
grid on ; grid minor

ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('$\rm H_{2}/H_{1}$');
ylabel('$\rm T_{sep}/T_{swash}$');
xlim([-0.1 5])
ylim([-0.1 1.7])
xticks([-0.1 0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0])
xticklabels({'-0.1','0.5','1.0','1.5','2.0','2.5 ','3.0','3.5','4.0'})
yticks([-0.1 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 120;
fig4 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(DwDt(i),lagnd(i),sz,'filled','o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k','Marker','d');
    elseif code(i) == 2
        h2 = scatter(DwDt(i),lagnd(i),sz,'filled','o','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor','k','Marker','>');
    elseif code(i) == 3
        h3 = scatter(DwDt(i),lagnd(i),sz,'filled','o','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(DwDt(i),lagnd(i),sz,'sq','MarkerEdgeColor','k');
    end
end
scatter(7,1.1,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
grid on ; grid minor

ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('max. $\rm \big(\frac{Dw/Dt}{g}\big)$');
ylabel('$\rm T_{peak}$');
ylim([0.8 1.3])
xticks([0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 2 3 4 5 6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig5 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(DwDt(i),w(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k','Marker','d');
    elseif code(i) == 2
        h2 = scatter(DwDt(i),w(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor','k','Marker','>');
    elseif code(i) == 3
        h3 = scatter(DwDt(i),w(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(DwDt(i),w(i)./sqrt(g.*h),sz,'sq','MarkerEdgeColor','k');
    elseif isnan(code(i))
        h4 = [];
    end
end
scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
grid on ; grid minor

ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
xlabel('max. $\rm \big(\frac{Dw/Dt}{g}\big)$');
ylabel('$\rm w/max. (w)$');

xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig6 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(DwDt(i),u(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k','Marker','d');
    elseif code(i) == 2
        h2 = scatter(DwDt(i),u(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor','k','Marker','>');
    elseif code(i) == 3
        h3 = scatter(DwDt(i),u(i)./sqrt(g.*h),sz,'filled','o','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(DwDt(i),u(i)./sqrt(g.*h),sz,'sq','MarkerEdgeColor','k');
    elseif isnan(code(i))
        h4 = [];
    end
end
scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
grid on ; grid minor

ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
xlabel('max. $\rm \big(\frac{Dw/Dt}{g}\big)$');
ylabel('$\rm u/max. (u)$');
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig7 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(Hst(i),Tst(i),sz,deltat_w(i),'filled','Marker','d','MarkerEdgeColor','k');
    elseif code(i) == 2
        h2 = scatter(Hst(i),Tst(i),sz,deltat_w(i),'filled','Marker','>','MarkerEdgeColor','k');
    elseif code(i) == 3
        h3 = scatter(Hst(i),Tst(i),sz,deltat_w(i),'filled','MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(Hst(i),Tst(i),sz,'sq','MarkerEdgeColor','k','MarkerFaceColor','g');
    end
 end
clim([-0.01 0.005])
c = colorbar('northoutside');
colormap parula
c.Label.String = '\Delta\rm T_{peak}/T_{swash} (for w)';

scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
plot([0 5],[0.45 1.82],'--','Color',[0.7 0.7 0.7]);
plot([0 5],[0.31 0.65],'--','Color',[0.7 0.7 0.7]);
grid on ; grid minor
ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('$\rm H_{2}/H_{1}$');
ylabel('$\rm T_{sep}/T_{swash}$');
xlim([-0.1 5])
ylim([-0.1 1.7])
xticks([-0.1 0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0])
xticklabels({'-0.1','0.5','1.0','1.5','2.0','2.5 ','3.0','3.5','4.0'})
yticks([-0.1 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
sz = 100;
fig8 = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,[1 4])
for i = 1:numel(code)-2
    hold on
    if code(i) == 1
        h1 = scatter(Hst(i),Tst(i),sz,deltat_u(i),'filled','Marker','d','MarkerEdgeColor','k');
    elseif code(i) == 2
        h2 = scatter(Hst(i),Tst(i),sz,deltat_u(i),'filled','Marker','>','MarkerEdgeColor','k');
    elseif code(i) == 3
        h3 = scatter(Hst(i),Tst(i),sz,deltat_u(i),'filled','MarkerEdgeColor','k');
    elseif code(i) == 4
        h4 = scatter(Hst(i),Tst(i),sz,'sq','MarkerEdgeColor','k','MarkerFaceColor','g');
    end
end
clim([-0.01 -0.001])
c = colorbar('northoutside');
colormap parula
c.Label.String = '\Delta\rm T_{peak}/T_{swash} (for u)';

scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Dummy data to improve plotting
plot([0 5],[0.45 1.82],'--','Color',[0.7 0.7 0.7]);
plot([0 5],[0.31 0.65],'--','Color',[0.7 0.7 0.7]);
grid on ; grid minor
ax = gca;
ax.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('$\rm H_{2}/H_{1}$');
ylabel('$\rm T_{sep}/T_{swash}$');
xlim([-0.1 5])
ylim([-0.1 1.7])
xticks([-0.1 0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0])
xticklabels({'-0.1','0.5','1.0','1.5','2.0','2.5 ','3.0','3.5','4.0'})
yticks([-0.1 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6])
xtickangle(45)
axis square
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'FontSize',letsz)
set(gcf,'color','w');
box on
%--------------------------------------------------------------------------
%% Saving files
if sav == 1;
    saveas(fig1,['1-H_vs_TsepTswash','.fig'])
    saveas(fig2,['2-H_vs_TsepTswash_vs_MaxAcc','.fig'])
    saveas(fig3,['3-H_vs_TsepTswash_vs_Top_nd','.fig'])
    saveas(fig4,['4-MaxAcc_vs_Top','.fig'])
    saveas(fig5,['5-MaxAcc_vs_w','.fig'])
    saveas(fig6,['6-MaxAcc_vs_u','.fig'])
    saveas(fig7,['7-H_vs_TsepTswash_vs_deltawmax','.fig'])
    saveas(fig8,['8-H_vs_TsepTswash_vs_deltaumax','.fig'])
end

cd ..