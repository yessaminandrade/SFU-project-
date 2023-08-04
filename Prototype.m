close all

maxcurrent = 0.030; %set max current in Amps
minvoltage = 8; %set min voltage
maxvoltage = 9; %set max voltage

numberofsteps=18;
numsteps=num2str(numberofsteps+1);
maxv=num2str(maxvoltage);
maxc=num2str(maxcurrent);
stepc=num2str(maxcurrent/numberofsteps);
stepv=num2str((maxvoltage-minvoltage)/numberofsteps);
minv=num2str(minvoltage); 

obj1=serialport('COM4','baudrate',19200,'configureterminator',13);

% Model 2400 Specific Functions
% Sweep current and measure back voltage
serialport(obj1);
fpwriteline(obj1,':*RST')
% setup the 2400 to generate an SRQ on buffer full 
writeline(obj1,':*ESE 0');
writeline(obj1,':*CLS');
writeline(obj1,':STAT:MEAS:ENAB 1024');
writeline(obj1,':*SRE 1');
% buffer set up
writeline(obj1,':TRAC:CLE');
writeline(obj1,[':TRAC:POIN ' numsteps]);    % buffer size
% Set up the Sweep
writeline(obj1,':SOUR:FUNC:MODE VOLT');
writeline(obj1,[':SOUR:VOLT:STAR ' minv]);
writeline(obj1,[':SOUR:VOLT:STOP ' maxv]);
writeline(obj1,[':SOUR:VOLT:STEP ' stepv]);
writeline(obj1,':SOUR:CLE:AUTO ON');
writeline(obj1,':SOUR:VOLT:MODE SWE');
writeline(obj1,':SOUR:SWE:SPAC LIN');
writeline(obj1,':SOUR:DEL:AUTO OFF');
writeline(obj1,':SOUR:DEL 0.10');

writeline(obj1,':SENS:FUNC "CURR"');
writeline(obj1,':SENS:FUNC:CONC ON');
writeline(obj1,':SENS:CURR:RANG:AUTO ON');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT: if the unit goes into compliance, 
% adjust the compliance or the range value
writeline(obj1,[':SENS:CURR:PROT:LEV ' maxc]); % voltage compliance
% if maxvoltage>20
%   fprintf(obj1,':SENS:VOLT:RANG 200')   % volt measurement range
% else
%   fprintf(obj1,':SENS:VOLT:RANG 20')   % volt measurement range
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
writeline(obj1,':SENS:CURR:NPLC 1');
writeline(obj1,':FORM:ELEM:SENS VOLT,CURR');
writeline(obj1,[':TRIG:COUN ' numsteps]);
writeline(obj1,':TRIG:DEL 0.001');
writeline(obj1,':SYST:AZER:STAT OFF');
writeline(obj1,':SYST:TIME:RES:AUTO ON');
writeline(obj1,':TRAC:TST:FORM ABS');
writeline(obj1,':TRAC:FEED:CONT NEXT');
writeline(obj1,':OUTP ON');
writeline(obj1,':INIT');

% Used the serail poll function to wait for SRQ
pause(2);
writeline(obj1,':TRAC:DATA?');
% 
%C=fscanf(obj1,%f%);
B = readline(obj1);
A = str2duble(B);
% 
% % parse the data & plot
Curr=A(2:2:size(A,2));
Volts=A(1:2:size(A,2)-1);
% 
figure(1);
%line([minvoltage maxvoltage],[max(Curr) max(Curr)],'color','g','linewidth',5)
hold on
plot(Volts,Curr,':bo','LineWidth',0.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r',...
                'MarkerSize',5)
ylabel('Measured-current (A)'),xlabel('Source-volts (V)')
title('Keithley 2400: Sweeps V & Measure I');
grid on
% reset all the registers & clean up
% if the registers are not properly reset, 
% subsequent runs will not work!
writeline(obj1,'*RST')
writeline(obj1,':*CLS ')
writeline(obj1,':*SRE 0')
% % make sure STB bit is 0
% STB = query(obj1, '*STB?');
close(obj1)
delete(obj1)
clear obj1