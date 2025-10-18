Initial spec for demod block.

IQ demod: ADL5380
LPF: RC 1kOhm + 33nF (roughly, need to fine-tune obviously)
Buffer: OPA1652 (need to mitigate impedance loading)
Multiplier (x2): AD633
Summer: OPA1652
Sign comparator: ADCMP601
Sign multiplier: AD633
Output buffer: OPA1652