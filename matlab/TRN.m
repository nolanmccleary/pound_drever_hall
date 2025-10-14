function Sring = TRN(f)
    T=300;%temp
    Kb=1.38e-23;%boltz
    

    Circ=15e-3;%circumfrence
    R=Circ/2/pi;%effective radius
    

    %from diagram
    Aeff=3e-12;
    dx=1e-6; %mode width hwhm by intensity
    dy=0.5e-6; %mode height
    
    %elipse area dx*dy*pi
    
    Veff=Aeff*Circ; %mode volume

    k=68; %thermal conductivity W/m/k %wikipedia
    rho=4.81e2; %density %wikipedia
    C=45.4/.145792; %heat capacity J/kg/k %wiki
    f0=193e12; %optical frequency
    neff=3;
    dndT=2.45e-5;%dont have a source for this, the phase shifter is 80mW for pi, seems similar to silicon

    
    Td=(pi/4)^(1/3)*rho*C*dx^2/k;
    omega=2*pi*f;

    Sring=(f0/neff*dndT)^2.*Kb.*T^2./sqrt(pi^3*k*rho*C*omega)./R./sqrt(dx^2-dy^2)./(1+(omega*Td).^0.75).^2;
end