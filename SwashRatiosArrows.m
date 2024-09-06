%==========================================================================
%                 Interactions ratios construction
% Reads and plots wave-swash interactions indicating transitions from CP_{1} to CP_{2} 
% Must select files from the folder: ../ManuscriptData/1-Space parameter files 
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
fileName = 'SwashRatiosConstruction_arrows';

data = readmatrix([fileName,'.xlsx']);
data = data(1:end,:);

loc = {'CP_{1}'};
loc = loc{1};
% Save plots
sav = 1; % 0:No ; 1:Yes
%% Measured cases
H1a = data(:,4) ; H2a = data(:,5) ; Tsepa = data(:,6) ;
H1b = data(:,7) ; H2b = data(:,8) ; Tsepb = data(:,9) ;
Tsw = data(:,10) ;
code = data(:,12);
h   = 0.3;
g   = 9.81;
Hsta = H2a./H1a;
Tsta = Tsepa./Tsw;

Hstb = H2b./H1b;
Tstb = Tsepb./Tsw;

p1 = [Hsta Tsta];
p2 = [Hstb Tstb];

dp = p2-p1;
%% Plotting
headWidth = 10;
headLength = 10;
LineLength = 1;

close all;
sz = 100;
fig1 = figure('units','normalized','outerposition',[0 0 1 1],'Position',[0.13,0.15,0.775,0.79734506148141]);
for i = 1:numel(code)
    hold on
    if code(i) == 1
        h1 = scatter(Hsta(i),Tsta(i),sz,'filled','o','MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor','k','Marker','d');
        hold on
        % arrow3([p1(i,1) p1(i,2)],[p2(i,1) p2(i,2)],'color',[0.8500 0.3250 0.0980],3);
        h11 = quiver(p1(i,1),p1(i,2),dp(i,1),dp(i,2),0,'Color',[0.8500 0.3250 0.0980],'LineWidth',1.5);
        h11.ShowArrowHead = 'off';
    elseif code(i) == 2
        h2 = scatter(Hsta(i),Tsta(i),sz,'filled','o','MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkerEdgeColor','k','Marker','>');
        hold on
        h22 = quiver(p1(i,1),p1(i,2),dp(i,1),dp(i,2),0,'Color',[0.9290 0.6940 0.1250],'LineWidth',1.5);
        h22.ShowArrowHead = 'off';
    elseif code(i) == 3
        h3 = scatter(Hsta(i),Tsta(i),sz,'filled','o','MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k');
        hold on
        h33 = quiver(p1(i,1),p1(i,2),dp(i,1),dp(i,2),0,'Color',[0 0.4470 0.7410],'LineWidth',1.5);
        h33.ShowArrowHead = 'off';
    elseif code(i) == 4
        h4 = scatter(Hsta(i),Tsta(i),sz,'sq','MarkerEdgeColor','k');
        hold on
        h44 = quiver(p1(i,1),p1(i,2),dp(i,1),dp(i,2),0,'Color','k','LineWidth',1.5);
        h44.ShowArrowHead = 'off';
    elseif isnan(code(i))
        h5 = [];
    end
end
scatter(0.4,0.15,100,'MarkerEdgeColor','none')%Fake data to improve plotting
plot([0 5],[0.45 1.82],'--','Color',[0.7 0.7 0.7]);
plot([0 5],[0.31 0.65],'--','Color',[0.7 0.7 0.7]);
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
return
%% Saving files
if sav == 1
    mkdir(fileName);
    cd(fileName)
    saveas(fig1,['1-H_vs_TsepTswash_','Arrows','.fig'])
end
cd ..