%==========================================================================
%           Voltage reading - WG and Pressure sensor
% Must select files from folder: 0-Time series measurements
% Code to analize data and generate paper figures
% Code includes ADV analysis to extract:
    % - max. DwDt and associated u and w
    % - \delta t
% Plot surface elevations, accelerations and velocities
%==========================================================================
clear; close all; clc
format long
letsz = 24;     %Font Size
lw    = 1.5;   %Line width
%% ========================================================================
% Measured data
%==========================================================================
[file,path] = uigetfile({'*.csv'},'MultiSelect','on');
if ischar(file)
    file = {file};
end
tic
cd(path)
for f = 1:numel(file)
    fid  = fopen([path,file{f}],'r+');
    data_info = textscan(fid,repmat('%s',1,12),4,'Delimiter',',','CollectOutput',1);
    data_full = cell2mat(textscan(fid,repmat('%f',1,12),'Delimiter',',', 'HeaderLines',1));
    fclose(fid);

    wGaugeVolt{1,f}  = data_full(1:2500,[2,4,6,8,10]);
    pSensorVoltx{1,f} = data_full(1:2500,12);

    WG_names{1,f}  = {'Acous WG - CD';'Wire WG - CD';'Acous WG - MP';'Wire WG - MP'};

    etaAcousVoltCP1(:,f) = -wGaugeVolt{1,f}(:,1);
    etaWireVoltCP1(:,f)  = wGaugeVolt{1,f}(:,2);
    etaAcousVoltToe(:,f) = -wGaugeVolt{1,f}(:,3);
    etaAcousVoltCP2(:,f) = -wGaugeVolt{1,f}(:,4);
    etaWireVoltCP2(:,f)  = wGaugeVolt{1,f}(:,5);
    pSensorVolt(:,f)     = pSensorVoltx{1,f}(:,1);

end
t = data_full(1:2500,1); %time

%Setting Nan values according to a voltage threshold
thre = 0.1;
for i = 1:numel(file)
    etaWireVoltCP2(etaWireVoltCP2(1:end,i) < thre,i) = NaN; %Minimum voltage detetction 0.02375
    idxNan(:,i) = ~isnan(etaWireVoltCP2(:,i));
end

% Tswash
Tsw = [4.20,4.47,4.77,5.13]+15;
TH1 = [2.60,2.18,2.02,1.84];%At the toe

for i = 1:numel(file)
    % Create short names
    i1 = strsplit(file{i}(11:end-4),'-');
    ia = i1{1}(5:5);

    if numel(i1)~=1
        i2 = strsplit(i1{3},'_');
        ib = i1{2}(5:5);
        ic = i2{2}(7:10);
        leg(i) = append('$T_{\textrm{sep}}=$',{ic},'$T_{H_{1}}$');
        sep(i) = str2double(ic);
    else
        leg{i} = file{i}(11:end-4);
        H(i,1) = str2double(leg{i}(3:end-1));
    end
end

if str2double(ia) == 1
    Tswx = Tsw(1);
    TH1x = TH1(1);
elseif str2double(ia) == 2
    Tswx = Tsw(2);
    TH1x = TH1(2);
elseif str2double(ia) == 3
    Tswx = Tsw(3);
    TH1x = TH1(3);
elseif str2double(ia) == 4
    Tswx = Tsw(4);
    TH1x = TH1(4);
end

%--------------------------------------------------------------------------
% Acoustic wave gauge - Conversion according to the manual
nn   = 1000;
volt = 0:10/nn:10;
cmWG   = 4.4:(61-4.4)/nn:61;
% Interpolate measured volt data between min. and max. values of volt and cm stated in TS3 manual
% Note: From the wave gauge
%0V  = 4.4cm (1.75in)
%10V = 61cm (24in)

for ff = 1:f % Number of time series to process
    % WG location: CD=WaveGauge(:,1), MP=WaveGauge(:,3) (in the order of the CSV file)
    WG_elev = wGaugeVolt{1,ff}(:,[1,3,4]);%Time series construction for measurement
    WG_id   = [1,2,3];
    for i = WG_id
        B(:,i)      = interp1(volt,cmWG,WG_elev(:,i));
        B_fil(:,i)  = -B(:,i)./100;
        desniv(:,i) = B_fil(:,i) - mean(B_fil(1:500,i));
    end
    etaCP1(:,ff) = desniv(:,1);%WG at constant depth (CP1)
    etaTOE(:,ff) = desniv(:,2);%WG at the toe of the beach
    etaCP2(:,ff) = desniv(:,3);%WG at measurement point (CP2)
end
%--------------------------------------------------------------------------
% Wire wave gauge
% Calibration for Wire WG at constant depth (CD) - Wire WG No.2
etaWireCP1       = (etaWireVoltCP1+0.42557)/0.19076;
%-----
etaWireCP2       = (etaWireVoltCP2+0.30228)/0.20225; %Calibration 1 - Wire WG No. 2
%-----
% eta wire to cm
etaWireCP1 = etaWireCP1./100;
etaWireCP2 = etaWireCP2./100;
% Normalizing to zero
for i = 1:numel(file)
    etaWireCP1(:,i) = etaWireCP1(:,i)-mean(etaWireCP1(1:500,i),'omitnan');
    etaWireCP2(:,i) = etaWireCP2(:,i)-mean(etaWireCP2(1:500,i),'omitnan');
end

% Local water depth at the measuring point (CP2)
hloc = 0.03;%m
%--------------------------------------------------------------------------
% Pressure sensor
rho   = 1025;%kg/m3
g     = 9.81;%m/s2

inPS  = (pSensorVolt+0.35133)./0.32285;%in
mPS   = inPS.*2.54./100;%m
%--------------------------------------------------------------------------
for i = 1:numel(file)
    % Normalized to zero
    mPS(:,i) = mPS(:,i)-mean(mPS(1:500,i),'omitnan');
    press(:,i) =  rho.*g.*(mPS(:,i)+hloc);
    % Total acceleration calculation
    DwDt(:,i) = press(:,i)./(rho.*(etaWireCP2(:,i)+hloc))-g;
end
%%
%=========
%Nan filter on measured series
idxNan = double(idxNan);
idxNan(idxNan == 0) = NaN;
% mPS = mPS.*idxNan;
% press = press.*idxNan;
DwDt = DwDt.*idxNan;

for i = 1:numel(file)
    if strcmp(file{i}(13:end-35),'0.1') == 1
        Tswa = Tsw(1);
        TH1a = TH1(1);
    elseif strcmp(file{i}(13:end-35),'0.2') == 1
        Tswa = Tsw(2);
        TH1a = TH1(2);
    elseif strcmp(file{i}(13:end-35),'0.3') == 1
        Tswa = Tsw(3);
        TH1a = TH1(3);
    elseif strcmp(file{i}(13:end-35),'0.4') == 1
        Tswa = Tsw(4);
        TH1a = TH1(4);
    else
        Tswa = Tswx;
        TH1a = TH1x;
    end
    Tswaxx(i,1) = Tswa;

    if i == 19
        idxtaux_a = t/Tswa > 0.95;
        idxtaux_b = t/Tswa < 1.3;
        indextime(:,i) = logical(idxtaux_a.*idxtaux_b);
        tTrim = t(indextime(:,i),1);
        [maxDwDt(i,1),maxIdx(i)] = max(DwDt(indextime(:,i),i)./g);%Max. Accelerations
        tmax(i,1) = tTrim(maxIdx(i),1)./Tswa;%Time of max. Accelerations
    elseif i == 25
        tTrim = t(t./Tswa > 0.95);
        [maxDwDt(i,1),maxIdx(i)] = max(DwDt(t./Tswa > 0.95,i)./g);%Max. Accelerations
        tmax(i,1) = tTrim(maxIdx(i),1)./Tswa;%Time of max. Accelerations
    else
        tTrim = t(t./Tswa > 0.855);
        [maxDwDt(i,1),maxIdx(i)] = max(DwDt(t./Tswa > 0.855,i)./g);%Max. Accelerations
        tmax(i,1) = tTrim(maxIdx(i),1)./Tswa;%Time of max. Accelerations
    end
        tmaxdim(i,1) = tmax(i,1).*Tswa;%Time of max. Accelerations
end
%% File ADV construction
locs = {'SWL'};%Change locs in string name: 'CD','Toe','SWL','other'
for ff = 1:numel(file)
    fileADVit{ff,1} = ['ADV_',locs{1},file{ff}(10:end-4),'.vna'];
end
fileADV = fileADVit;
%==========================================================================
% ADV Data
ADV = cell(zeros(1));
fileADVaux = fileADV;
if ischar(fileADV)
    fileADVaux = {fileADVaux};
end
ff = 1;
for nx=1:numel(fileADV)%Number of ADV files
    fid = fopen([path,fileADVaux{nx}],'r+');
    if exist([path,fileADVaux{nx}], 'file') == 0
        % File does not exist
        % Skip to bottom of loop and continue with the loop
        disp(['File missing: ',[fileADVaux{nx}]])
        break;
    end
    ADV{nx,1} = textscan(fid,repmat('%f',1,20),'delimiter','\n');
    fclose(fid);

    for nn = 1:numel(ADV{nx,1}{1,1})
        for nnn = 1:20
            ADV_Data{nx,1}(nn,nnn) = ADV{nx,1}{1,nnn}(nn);
        end
    end

    %Time
    ADV_time{ff,nx}(:,1) = ADV_Data{nx,1}(:,2);

    %Velocities
    ADV_xVel{ff,nx}(:,1) = ADV_Data{nx,1}(:,5);
    ADV_yVel{ff,nx}(:,1) = ADV_Data{nx,1}(:,6);
    ADV_zVel{ff,nx}(:,1) = ADV_Data{nx,1}(:,7);

    %SNR
    ADV_xSNR{ff,nx}(:,1) = ADV_Data{nx,1}(:,13);
    ADV_ySNR{ff,nx}(:,1) = ADV_Data{nx,1}(:,14);
    ADV_zSNR{ff,nx}(:,1) = ADV_Data{nx,1}(:,15);

    %Correlation
    ADV_xCOR{ff,nx}(:,1) = ADV_Data{nx,1}(:,17);
    ADV_yCOR{ff,nx}(:,1) = ADV_Data{nx,1}(:,18);
    ADV_zCOR{ff,nx}(:,1) = ADV_Data{nx,1}(:,19);

    %Filtering
    thre_SNR = 17;%Set to 17 as default
    thre_COR = 70;%Set to 70 as default
    for pp = 1:numel(ADV_xVel{ff,nx}(:,1))
        if ADV_xSNR{ff,nx}(pp)<thre_SNR && ADV_xCOR{ff,nx}(pp)<thre_COR
            ADV_xVel{ff,nx}(pp)=NaN;
        end
        if ADV_ySNR{ff,nx}(pp)<thre_SNR && ADV_yCOR{ff,nx}(pp)<thre_COR
            ADV_yVel{ff,nx}(pp)=NaN;
        end
        if ADV_zSNR{ff,nx}(pp)<thre_SNR && ADV_zCOR{ff,nx}(pp)<thre_COR
            ADV_zVel{ff,nx}(pp)=NaN;
        end
    end
end

%% Accelerations calculated from ADV info
for i = 1:numel(file)
    u(:,i) = ADV_xVel{i}(1:2500) ; w(:,i) = ADV_zVel{i}(1:2500); tADV(:,i) = ADV_time{i}(1:2500);
end
u = u.*idxNan;
w = w.*idxNan;

for i = 1:numel(file)

    if strcmp(file{i}(13:end-35),'0.1') == 1
        Tswa = Tsw(1);
        TH1a = TH1(1);
    elseif strcmp(file{i}(13:end-35),'0.2') == 1
        Tswa = Tsw(2);
        TH1a = TH1(2);
    elseif strcmp(file{i}(13:end-35),'0.3') == 1
        Tswa = Tsw(3);
        TH1a = TH1(3);
    elseif strcmp(file{i}(13:end-35),'0.4') == 1
        Tswa = Tsw(4);
        TH1a = TH1(4);
    else
        Tswa = Tswx;
        TH1a = TH1x;
    end
    Tswaxx(i,1) = Tswa;

    uu(:,i) = u(:,i) ; ww(:,i) = w(:,i); tt(:,i) = tADV(:,i);

    del1 = 0.25;
    if i == 11
        del2 = 0.5;
    else
        del2 = del1;
    end
    aLim = tmax(i).*Tswa - del1;
    bLim = tmax(i).*Tswa + del2;
    idxtaux_a = tt(:,1)>=aLim;
    idxtaux_b = tt(:,1)<=bLim;
    indextime(:,i) = logical(idxtaux_a.*idxtaux_b);
    taux{i,1}(:,1) = tt(indextime(:,i),i);
    uaux{i,1}(:,1) = uu(indextime(:,i),i);
    waux{i,1}(:,1) = ww(indextime(:,i),i);
    tauxnd{i,1}(:,1) =  taux{i,1}(:,1)./Tswa;
end
%% Extraction of maximum values
for i = 1:numel(file)
    [maxu(i,1),maxIdxu(i)] = max(uaux{i}(:,1));
    [maxw(i,1),maxIdxw(i)] = max(waux{i}(:,1));

    tmaxu(i,1) = taux{i}(maxIdxu(i),1);%Time of max. horizontal velocities
    tmaxw(i,1) = taux{i}(maxIdxw(i),1);%Time of max. vertical velocities

    deltat_u(i,1) = tmaxdim(i,1) - tmaxu(i,1);% delta time between max. DwDt vs. max. u
    deltat_w(i,1) = tmaxdim(i,1) - tmaxw(i,1);% delta time between max. DwDt vs. max. w

    [ttaux(i,1),idxtaux(i,1)] = min(abs((tauxnd{i}(:,1)-tmax(i,1))));% Find time (in tAvg) at which max DwDt happens

    u_at_maxDwDt(i,1) = uaux{i}(idxtaux(i,1),1);% value of u at max. DwDt
    w_at_maxDwDt(i,1) = waux{i}(idxtaux(i,1),1);% value of w at max. DwDt
end
maxVals = [maxu,tmaxu,maxw,tmaxw,maxDwDt.*g,tmax];

%% Plotting individual time series
close all
for i = 1:numel(file)
    fig(i) = figure('Renderer', 'painters', 'Position', [20 20 1000 700],'Visible','on');

    if strcmp(file{i}(13:end-35),'0.1') == 1
        Tswa = Tsw(1);
        TH1a = TH1(1);
    elseif strcmp(file{i}(13:end-35),'0.2') == 1
        Tswa = Tsw(2);
        TH1a = TH1(2);
    elseif strcmp(file{i}(13:end-35),'0.3') == 1
        Tswa = Tsw(3);
        TH1a = TH1(3);
    elseif strcmp(file{i}(13:end-35),'0.4') == 1
        Tswa = Tsw(4);
        TH1a = TH1(4);
    else
        Tswa = Tswx;
        TH1a = TH1x;
    end

    subplot(3,2,[1 2])
    hold on
    plot(t./Tswa,etaWireCP2(:,i)+hloc)
    plot(t./Tswa,mPS(:,i)+hloc,'Color','m')
    xlim([0.8 1.2])
    ylim([-0.05 0.22])
    legend('$\eta + \rm h_{CP_{2}}$','$p_{bed}/(\rm{\rho} g)$','Location','Northeast')
    grid on ; grid minor
    ylabel('depth (m)')
    ax1 = gca;
    ax1.LineWidth = 1.5;
    set(gca,'TickDir','out')
    set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
    set(gca, 'FontSize', letsz)
    set(gcf,'color','w');
    box on

    subplot(3,2,[3 4])
    hold on
    plot(t/Tswa,DwDt(:,i),'Color',[0.9290 0.6940 0.1250])
    xlim([0.8 1.2])
    ylim([-15 25])
    yticklabels([0 5 10 15 20 25])
    grid on ; grid minor
    ylabel('max.$\rm \big(Dw/Dt\big) (m/s^{2})$')
    ax1 = gca;
    ax1.LineWidth = 1.5;
    set(gca,'TickDir','out')
    set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
    set(gca, 'FontSize', letsz)
    set(gcf,'color','w');
    box on

    subplot(3,2,[5 6])
    hold on
    plot(tADV(:,i)./Tswa,u(:,i),'Color',[0.4660 0.6740 0.1880])
    plot(tADV(:,i)./Tswa,w(:,i),'r')
    xlim([0.8 1.2])
    ylim([-2 2])
    grid on ; grid minor
    xlabel('$\rm t/T_{swash}$');
    ylabel('m/s')
    legend('u','w')
    ax1 = gca;
    ax1.LineWidth = 1.5;
    set(gca,'TickDir','out')
    set(gca,'XMinorTick','on','YMinorTick','on','ZMinorTick','on')
    set(gca, 'FontSize', letsz)
    set(gcf,'color','w');
    box on

    a = exist('sep','var');
    if a == 1;
        sgtitle([file{i}(11),'$_{1}$',file{i}(12:end-34),' ; ',file{i}(18),'$_{2}$',file{i}(19:end-27),...
            ' ; ',leg{i},'=',num2str(sep(i).*TH1a./Tswa,'%2.3f'),'$T_{swash}$'],'FontSize',20);
    else
        sgtitle([file{i}(11),'$_{1}$',file{i}(12:end-4)],'FontSize',20);
    end

    % saveas(fig1,[num2str(i),' - ',file{i}(11:end-4),'.fig'])
    % close(fig1)
end

% cd ..

