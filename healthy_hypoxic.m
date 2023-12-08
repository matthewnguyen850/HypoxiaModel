%This Model has been adapted from the MATLAB code presented in Hoppensteadt
%and Peskin "Modling and Simulation in Medicine and the Life Sciences

%BME 4409 - University of Florida
%Cardiovascular Simulation of Aortic Stenosis during Hypoxia
%Contributors: Matthew Nguyen, Gabe Veliz

clc;clear;close all

%Time parameters
T = 0.0125;                      %Duration of heartbeat: min
Ts = 0.0050;                     %Duration of systole: min
dt = .00005*T;                   %This choice implies 20,000 timesteps per cardiac cycle
Sys=round(Ts/dt);                % Timesteps systole | 40% Systole, 60% Diastole
Cycle=round(T/dt);               % Timesteps complete cycle

%Compliance and resistance parameters. Note that valve resistances are not
%supposed to be realistic, just small enough to be negligible
Csa = .00175;                    %Systemic arterial compliance: L/mmHg
Rs = 12.4;                      %Systemic resistance: mmHg/(L/min) %Original: 17.86
Rmi = .01;                       %mitral valve resistance: mmHg/(L/min)
RAo = 0.01;                       %Aortic valve resistance: mmHg/(L/min) %Original: .01

Vlvd = .027;                     %Left ventricular volume when PLV=0: L
Vsad = .825;                     %Systemic arterial volume when Psa+0: L
Pla = 7;                         %Left atrial pressure: mmHg %Original: 5

%Parameters for Clv(t)
CLVD = .0146;                   %Max (diastolic) value of CLV: L/mmHg
CLVS = .00002;                  %Min (systolic) value of CLV: L/mmHg %Original: .00003
tauS = .0025;                   %CLV time constant during systole: min
tauD = .001;                    %CLV time constant during diastole: min

%Initialization parameters
Plvi = 5;                       %Initial value of Plv: mmHg
Psai = 80;                      %initial value of Psa: mmHg

%Don't forget to plot VSA vs. PSA and VLV vs. PLV! The values have
%been exported into the matlab workspace so you can plot them.

sim('Cardio_SA_LV')
%Store the arrays for future plotting:
time=BloodFlows.time;
Vlv=PVClv.signals.values(:,1);
Plv=PVClv.signals.values(:,2);

% LV pressure-volume loop
figure(2)
plot(Vlv,Plv);
%plot(Vlv(300000:end),Plv(300000:end),'linewidth',2);
title('Plv vs Vlv');
ylabel('Plv(mmHg)');
xlabel('Vlv (L)');
axis([0.01 max(VLV)+0.01 0 max(PLV)+10])

EDV=VLV(end-Cycle); % End diastolic volume
ESV=VLV(end-Cycle+Sys); % End systolic volume
SV=EDV-ESV; % Stroke Volume
HR=T^-1; % Heart Rate
Q=HR*SV; % Cardiac Output 
SV=SV*1000; % L to mL

PatientData.cardiacOutput = Q; %L/min
PatientData.strokeVolume = SV; %mL

dP = diff(Plv);
work=0;
workPerCycle = [];

%calculates work per cycle (16 cycles total)
for i = 1:320000
    work=(work+((VLV(i)+VLV(i+1))/2).*dP(i));

    if rem(i,20000) == 0
        workPerCycle = [workPerCycle work];
        work = 0;
    end
end

workMin = mean((workPerCycle/T)*0.13332); %average of all 16 cycles
PatientData.workPerMin = workMin; %joules

disp(PatientData)
