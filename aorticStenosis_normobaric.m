%This model has been adapted from the MATLAB code presented in Hoppensteadt and Peskin 
%"Modeling and Simulation in Medicine and the Life Sciences"
clear
close all
clc

%Time parameters 
T = 0.0125;                      %Duration of heartbeat: min
Ts = 0.0050;                     %Duration of systole: min       
dt = .00005*T;                   %This choice implies 20,000 timesteps 
                                 %per cardiac cycle
Beats=16*T;                      % 16 heart beats displayed
%Compliance and resistance parameters. Note that valve resistances are not
%supposed to be realistic, just small enough to be negligible
Csa = .00175;  %Systemic arterial compliance: L/mmHg, original=0.0175

Rs = 15.1125;    %Systemic resistance: mmHg/(L/min) - initial value 17.28
%from https://www.sciencedirect.com/science/article/pii/0735109796002185

Rmi =0.01;     %mitral valve resistance: mmHg/(L/min) - initial value 0.01
RAo = 1;     %Aortic valve resistance: mmHg/(L/min)
AoBkflo=0.00;   % 1/Resistance to back flow in the aortic valve
               % Normally zero (1/infinity)- no back flow allowed
Vlvd = .027;   %Left ventricular volume when PLV=0 (ESV) 
Vsad = .825;   %Systemic arterial volume when Psa=diastol 
Pla = 5;       %Left atrial pressure:  mmHg Initially 5 mmHg

%Parameters for Clv(t)
CLVD =0.0146;     %Max (diastolic) value of CLV: L/mmHg Initially 0.0146 
CLVS = 5e-5;      %Min (systolic) value of CLV: L/mmHg initially 5e-5
tauS = .0025;     %CLV time constant during systole: min (0.0025)
tauD = .001;      %CLV time constant during diastole: min (0.001)

%Initialization parameters
Plvi = 5;         %Initial value of Plv: mmHg
Psai = 80;        %initial value of Psa: mmHg
Sys=round(Ts/dt); % Timesteps systole
Cycle=round(T/dt); % Timesteps complete cycle
Diastole=Cycle-Sys; % Timestep for diastole
PatientData = struct();

sim('Cardio_SA_LV')

t=BloodFlows.time;

% figure('color','white')
% subplot(3,1,1)
% plot(t,BloodFlows.signals.values,'linewidth',1)
% legend('Qmi','QAo','Qs')
% title('Blood Flows, Qmi,QAo,Qs')
% xlabel('Time')
% ylabel('l/min')
% subplot(3,1,2)
% plot(t,PSA,'linewidth',2);hold on;plot(t,PLV,'linewidth',2);hold off
% legend('PSA','PLV')
% xlabel('Time')
% ylabel('Pressure - mmHg')
% subplot(3,1,3)
% plot(t,CLV,'linewidth',2)
% xlabel('Time')
% ylabel('Vent. Compl.-l/mm Hg')
% 
% figure('color','white')
% plot(t,PSA,'linewidth',2);hold on;plot(t,PLV,'linewidth',2);hold off
% legend('PSA','PLV')
% xlabel('Time')
% ylabel('Pressure - mmHg')
% axis([0 max(t) 0 max(PLV)+10])
% 
% figure('color','white'); plot(t,BloodFlows.signals.values(:,1),'linewidth',2)
% title('Mitral Blood Flow')
% xlabel('Time')
% ylabel('l/min')
% 
% figure('color','white'); plot(t,BloodFlows.signals.values(:,2),'linewidth',2)
% title('Aortic Blood Flow')
% xlabel('Time')
% ylabel('l/min')
% 
% figure('color','white'); plot(t,BloodFlows.signals.values(:,3),'linewidth',2)
% title('Venous Blood Flow')
% xlabel('Time')
% ylabel('l/min')

figure('color','white')
plot(VLV(300000:end),PLV(300000:end),'linewidth',2);
title('Cardiac Cycle')
xlabel('Ventricular Volume - Liters')
ylabel('Ventricular Pressure - mm Hg')
axis([0.01 max(VLV)+0.01 0 max(PLV)+10])

% figure('color','white')
% plot(VSA,PSA)
% title('Systemic Volume v. Systemic Pressure')
% xlabel('Volume of Systemic Arteries - Liters')
% ylabel('Arterial Pressure - mmHG')

F=5*trapz(t,BloodFlows.signals.values(:,:));    % Blood Flow using Riemann Sum
PatientData.mitralValveFlow = F(1); %L/min
PatientData.aorticVavleFlow = F(2); %L/min
PatientData.pulmonaryVenousFlow = F(3); %L/min

EDV=VLV(end-Cycle); % End diastolic volume
ESV=VLV(end-Cycle+Sys); % End systolic volume
SV=EDV-ESV; % Stroke Volume
HR=T^-1; % Heart Rate
Q=HR*SV; % Cardiac Output 
SV=SV*1000; % L to mL

PatientData.cardiacOutput = Q; %L/min
PatientData.strokeVolume = SV; %mL

dP=diff(PLV(end-T/dt:end));  % Work done in 1 heartbeat
work=0;
for i=1:20000
    work=(work+((VLV(i+300000)+VLV(i+300001))/2).*dP(i));
end
workMin=(work/T)*0.13332;
workBeat=workMin/HR;

PatientData.workPerHeartBeat = workBeat; %joules
PatientData.workPerMin = workMin; %joules

disp(PatientData)





