
function model = laplace_model()

model.constants.speed_of_light = 3e8;
model.constants.boltzmann = 1.38e-23;

%ALL MODEL PARAMETERS SHOULD BE CONSIDERED PLACEHOLDER VALUES AT THIS TIME

%TODO: 
%1. Lab experiment for ring resonator parameters
%
%2. Try to get a list of every prospective component we need for our
%circuit, then obtain TF approximations via SPICE simulation (use Spectre). I will get
%a spreadsheet started for this.

%HIGH-LEVEL PROCESS: Get list of prospective components, simulate, get TF approximations, optimize laplace model, design rest of circuit to fit laplace model, simulate full circuit, PCB


%Ring Resonator
model.resonator.Plaser = 10e-3/10; %from HHI manual 10% tap
model.resonator.Responsivity = 0.8; %Photodiode responsivity - from HHI manual
model.resonator.freq_discriminator = model.resonator.Plaser * 0.1555 / 68.5e6; %Maps freq delta to power delta
model.resonator.ring_length = 8e-3;
model.resonator.fsr = 5e9;
model.resonator.temp = 300;
model.resonator.neff=3;
model.resonator.f0=193e12; %resonance frequency

%TIA
model.tia.corner = 2*pi*1e9;
model.tia.DC_gain = 123e3 * model.tia.corner;
model.tia.noise = (3.4e-12+4e-12)^2; %pA/vhz TIA+shot noise %paper has more accurate noise model
model.tia.delay = 300e-12; %Can get better estimate from slew rate

%Filter (IQ mixer + LPF)
model.filter.delay = 300e-12;
model.filter.corner = 2*pi*2e7;

%Controller
model.controller.Kd=0; %Kevin Durant
model.controller.Kp = 0.05; %10^(-2.4/10);
model.controller.Ki = 100;
model.controller.delay = 100e-9;
model.controller.driver_conversion_factor = 2e-3; %Assume linear relationship here

%Laser
model.laser.Kth = 1;
model.laser.corner = 1.6e8;
model.laser.b = 5;
model.laser.Kel = model.laser.Kth * model.laser.b;
model.laser.gain_per_mA = 500e6; %500mHz/mA

%Transfer functions
model.fn.diode_response = @(s)(model.resonator.Responsivity * model.resonator.freq_discriminator) * exp(-s * (model.resonator.ring_length / model.constants.speed_of_light)); %Assuming ~zero-delay photodiode, may be innacurate 
model.fn.tia_response = @(s)(exp(-s * model.tia.delay) * (model.tia.DC_gain/(s + model.tia.corner)));
model.fn.filter_response = @(s)(exp(-s * model.filter.delay) * (model.filter.corner / (s + model.filter.corner)));
model.fn.controller_response = @(s)(exp(-s * model.controller.delay) * (model.controller.Kp + s*model.controller.Kd + model.controller.Ki/s));
model.fn.laser_response = @(f)(frd(model.laser.gain_per_mA * 1000 * (-model.laser.Kel + model.laser.Kth ./ (1 + 1j*sqrt(f ./ model.laser.corner))), f, 'Units', 'Hz')); %Empirical frequency response, should verify with a lab test

end
