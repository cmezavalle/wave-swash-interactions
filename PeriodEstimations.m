%==========================================================================
% Estimation of period for a single wave case
%   - at constant depth
%   - at the toe of the beach
%   - at the measuring point CP2
% Must open the folder: ../ManuscriptData/0-Time series measurements/Single wave cases
% Note: This code also calculate the separation time at the toe of the beach
%==========================================================================
clear; close all; clc
format long
letsz = 24;     %Font Size
lw    = 2;   %Line width
%% ========================================================================
% Smoothing option
alt = 2;
%% ========================================================================
% Parameters
g = 9.8;%m/s2
h = 0.3;%m
%% ========================================================================
% Measured data
%==========================================================================
[file,path] = uigetfile({'*.csv'},'MultiSelect','on');
if ischar(file)
    file = {file};
end
cd(path)
for f = 1:numel(file)
    fid  = fopen([path,file{f}],'r+');
    data_info = textscan(fid,repmat('%s',1,12),4,'Delimiter',',','CollectOutput',1);
    data_full = cell2mat(textscan(fid,repmat('%f',1,12),'Delimiter',',', 'HeaderLines',1));
    fclose(fid);

    wGaugeVolt{f}  = data_full(:,[2,4,6,8,10]);
    pSensorVolt{f} = data_full(:,12);

    WG_names{f}  = {'Acous WG - CD';'Wire WG - CD';'Acous WG - MP';'Wire WG - MP'};
    etaAcousVoltCP1{f} = -wGaugeVolt{f}(:,1);
    etaWireVoltCP1{f}  = wGaugeVolt{f}(:,2);
    etaAcousVoltToe{f} = -wGaugeVolt{f}(:,3);
    etaAcousVoltCP2{f} = -wGaugeVolt{f}(:,4);
    etaWireVoltCP2{f}  = wGaugeVolt{f}(:,5);
    pSensorVolt{f}     = pSensorVolt{f};
end
t = data_full(:,1); %time
WG_time = t;
%--------------------------------------------------------------------------
% Acoustic wave gauge - Conversion according to the manual
p   = 1000;
volt = 0:10/p:10;
cmWG   = 4.4:(61-4.4)/p:61;
%Interpolate measured volt data between min. and max. values of volt and cm stated in TS3 manual
%Note: From the wave gauge
%0V  = 4.4cm (1.75in)
%10V = 61cm (24in)

for n = 1:f %Number of time series to process
    % WG location: CD=1, Toe=3, MP=4 (in the order of the CSV file)
    WG_elev = wGaugeVolt{n}(:,[1,3,4]);%Time series construction for measurement
    WG_id   = [1,2,3];
    for i = WG_id
        B(:,i)      = interp1(volt,cmWG,WG_elev(1:2500,i));
        B_fil(:,i)  = -B(:,i);
        avg         = mean(B_fil(1:500,i));
        desniv(:,i) = (B_fil(1:2500,i) - avg);
    end

    etaCD{n,1}  = desniv(:,1)./100;%WG at constant depth
    etaToe{n,1} = desniv(:,2)./100;%WG at Toe
    etaMP{n,1}  = desniv(:,3)./100;%WG at measurement point
end
%--------------------------------------------------------------------------
%% Wire wave gauge
for n = 1:f
    % Calibration for Wire WG at constant depth (CD) - Wire WG No.2
    etaWireCD{n,1} = (etaWireVoltCP1{n}(:,1)+0.42557)/0.19076;
    %-----
    etaWireMP{n,1} = (etaWireVoltCP2{n}(:,1)+0.30228)/0.20225; %Calibration 1 - Wire WG No. 2
    %-----
    %eta wire to cm
    etaWireCD{n,1} = etaWireCD{n,1}(1:2500)./100;
    etaWireMP{n,1} = etaWireMP{n,1}(1:2500)./100;
end

% Normalizing to zero
for i = 1:numel(file)
    etaWireCD{i}(:,1) = etaWireCD{i}(:,1)-mean(etaWireCD{i}(1:100,1));
    etaWireMP{i}(:,1) = etaWireMP{i}(:,1)-mean(etaWireMP{i}(1:100,1));
end

desniv = [etaWireCD,etaToe,etaWireMP];

for n = 1:f %Number of time series to process
    for p = 1:numel(desniv(1,:))

        if alt == 1
            % Alternative 1 - Simple data smothing
            desniv_smth{n,p} = 1.09.*smoothdata(desniv{n,p}(:),'loess');

        elseif alt == 2
            % Alternative 2 - Gaussian filter
            sigma = 3;
            sz    = 5; % length of gaussFilter vector
            x = linspace(-sz/2, sz/2,sz);
            gaussFilter = exp(-x.^2/(2*sigma^2));
            gaussFilter = gaussFilter/sum(gaussFilter); % normalize
            desniv_smth{n,p} = conv(desniv{n,p}(:),gaussFilter,'same');
        end
        %------------------
        % Find peaks in the smoothed signal
        idxPeaks{n,p} = find(islocalmax(desniv_smth{n,p}));
        maxDesniv{n,p} = desniv_smth{n,p}(idxPeaks{n,p});

        [sortedPeaks,idxSortedPeaks] = sort(maxDesniv{n,p},'descend');
        idxSorted = idxPeaks{n,p}(idxSortedPeaks);

        diff = idxSorted(1)-idxSorted(1:end);
        [idxFiltered,val] = find(abs(diff)>50);
        idxAux = idxSorted(idxFiltered(1));

        if idxSorted(1)<idxAux(1)
            Tpeak1 = WG_time(idxSorted(1));
            peak1  = sortedPeaks(1);
            Tpeak2 = WG_time(idxAux(1));
            peak2  = sortedPeaks(idxFiltered(1));
        else
            Tpeak1 = WG_time(idxAux);
            peak1  = sortedPeaks(idxFiltered(1));
            Tpeak2 = WG_time(idxSorted(1));
            peak2  = sortedPeaks(1);
        end

        Tsep(n,p) = abs(Tpeak1-Tpeak2);

        [maxim(n,p),imax(n,p)] = max(desniv_smth{n,p});
        desAux{n,p} = flip(desniv_smth{n,p}(1:imax(n,p)),1);
        iaa{n,p} = find(desAux{n,p}(1:end)<0.002);
        ia{n,p}  = imax(n,p)-iaa{n,p}(1);
        if strcmp(file{n}(13:end-5),'0.4') == 1 &&  p==2
            tol = 0.004;
        else
            tol = 0.0025;
        end
        ibb{n,p} = find(desniv_smth{n,p}(imax(n,p):end)<tol);
        ib{n,p} = imax(n,p)+ibb{n,p}(1);

        T(n,p) = abs(WG_time(ia{n,p})-WG_time(ib{n,p}));
    end
end

% Single wave periods at different locations
T_CD  = T(:,1);
T_Toe = T(:,2);
T_CP2 = T(:,3);

%Separation times at different locations
TsepCD  = Tsep(:,1);
TsepToe = Tsep(:,2);
TsepMP  = Tsep(:,3);

%% Plotting
close all
H   = [0.1,0.2,0.3,0.4];
Tsw = [4.20,4.47,4.77,5.13];

mark = {'o','^','sq','v'};
sz = 50;
figure('Renderer', 'painters', 'Position', [20 20 1000 700])
subplot(4,4,[1 6])
hold on
scatter(H,T_CD,sz,'Marker',mark{1},'LineWidth',1.5)
scatter(H,T_Toe,sz,'Marker',mark{2},'LineWidth',1.5)
scatter(H,T_CP2,sz,'Marker',mark{3},'LineWidth',1.5)
scatter(H,Tsw,sz,'Marker',mark{4},'LineWidth',1.5)
xlim([0 0.5]);
ylim([0 6]);
legend('CP$_{1}$','Toe','CP$_{2}$','Swash','numColumns',4,'Location','Northoutside')
grid on ; grid minor
xlabel('H/h')
ylabel('T (s)')
ax1 = gca;
ax1.LineWidth = 1.5;
set(gca,'TickDir','out')
set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
set(gca, 'FontSize', letsz)
set(gcf,'color','w');
box on

%%
leg = {'CP$_{1}$','Toe','CP$_{2}$'};
sz = 80;
for i = 1:numel(desniv(:,1)) %Number of locations
    fig1 = figure
    for ii = 1:numel(desniv(1,:)) %Number of files
        subplot(numel(desniv(1,:)),1,ii)
        hold on
        if ii == 1
            title(file{i}(11:end-4))
        end
        plot(WG_time(:,1),desniv_smth{i,ii},'LineWidth',2)
        scatter(WG_time(ia{i,ii}),desniv_smth{i,ii}(ia{i,ii}),sz,'filled','Marker','v','MarkerFaceColor','k')
        scatter(WG_time(ib{i,ii}),desniv_smth{i,ii}(ib{i,ii}),sz,'filled','Marker','v','MarkerFaceColor','k')
        hold off
        legend(leg{ii})
        xlim([10 24]);
        ylim([-0.05 0.15]);
        grid on ; grid minor
        xlabel('time (s)')
        ylabel('$\eta$ (m)')
        ax1 = gca;
        ax1.LineWidth = 1.5;
        set(gca,'TickDir','out')
        set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
        set(gca, 'FontSize', letsz)
        set(gcf,'color','w');
        box on
    end
    % saveas(fig1,['Periods_',file{i}(11:end-4),'.fig'])
end




