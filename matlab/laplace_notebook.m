clearvars
model = laplace_model();

s = tf('s');
n = 10000;
f = logspace(0,12,n);
w = f*2*pi;
%[text] 
%[text] Cavity-Diode cascaded reponse (A/Hz - Hz represents detune speed)
%[text] Frequency Discriminator: Optical power gain / Frequency detune spectrum
%[text] Responsivity: Diode output current / optical power
%[text] The assumption here is that photodiode output power scales linearly WRT frequency offset about our capture range while incurring a small delay. This delay will only induce a noticeable phase shift in very high detune harmonics.
diode_response = model.fn.diode_response(s); 

%Plot diode output current gain WRT detune spectrum
figure;
t = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
nexttile(t,1);
bode(diode_response, w); grid on; title('Diode response');

%[text] 
%[text] TIA Response (V/A):
tia_response = model.fn.tia_response(s);
chain = diode_response * tia_response;

figure;
t = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
nexttile(t,1);
bode(tia_response, w); grid on; title('TIA response');
nexttile(t,2);
bode(chain, w); grid on; title('Current chain response');
%[text] 
%[text] Filter (Mixer + LPF) Response (V/V):
filter_response = model.fn.filter_response(s);
chain = chain * filter_response;

figure;
t = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
nexttile(t,1);
bode(filter_response, w); grid on; title('Filter response');
nexttile(t,2);
bode(chain, w); grid on; title('Current chain response');
%[text] 
%[text] Controller (currently PID) Response (A/V):
controller_response = model.fn.controller_response(s);
chain = chain * controller_response;

figure;
t = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
nexttile(t,1);
bode(controller_response, w); grid on; title('Controller response');
nexttile(t,2);
bode(chain, w); grid on; title('Current chain response');
%[text] 
%[text] Laser response (Jitter spectrum to input current spectrum) + open/closed-loop gain:
laser_response = model.fn.laser_response(f);
alpha = chain * laser_response;

figure;
t = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

nexttile(t,1);
bode(laser_response, w); grid on; title('Laser response');

nexttile(t,2);
bode(alpha, w); grid on; title('Open-loop response');

nexttile(t, 3);
closed_loop = feedback(alpha, 1); %alpha/(1 + alpha)
bode(closed_loop, w); grid on; title('Closed-loop response');

[GM, PM, Wcg, Wcp] = margin(alpha)
disp(['Gain Margin: ', num2str(20*log10(GM)), ' dB']);
disp(['Phase Margin: ', num2str(PM), ' degrees']);

%[text] Noise Rejection Performance:
O = diode_response;
T = tia_response;
F = filter_response;
C = controller_response;
L = laser_response;
H = O*T*F*C*L/(O*T*F*C*L+1); %closed-loop response

S_o = TRN(f); %Thermorefractive noise from resonator, should definitely validate this part
sen_trn = H;
[mag, ~] = bode(sen_trn);
mag = squeeze(mag);
S_TRN = transpose(mag.^2) .* S_o;

figure;
t = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

%PSD after correction
nexttile(t, 1);
loglog(f, S_TRN, 'g-', 'LineWidth', 1.5);

H_TIA = T*F*C*L/(1 + O*T*F*C*L);

S_t = model.tia.noise
[mag, ~] = bode(H_TIA);
mag = squeeze(mag);
S_TIA = transpose(mag.^2).* S_t;


%PSD after correction
nexttile(t, 2);
loglog(f, S_TIA, 'g-', 'LineWidth', 1.5);





%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":22.6}
%---
