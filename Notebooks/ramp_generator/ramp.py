import numpy as np
from pynq.mmio import MMIO
from pynq import PL, Overlay
class RampGenerator():
    """requires a base overlay object as an argument.
    """
    def __init__(self,f = 1e9, a = 1.0, overlay='main.bit',):
        self._overlay = Overlay(overlay)
        ramp_gen_mmio= MMIO(PL.ip_dict["ramp_params"]['phys_addr'],
                                    PL.ip_dict["ramp_params"]['addr_range'])
        self._ram = ramp_gen_mmio.array
        
        # The DAC clock is running at the following frequency:
        self._clk_freq = 9.8304e9 #Hertz
        
        # That corresponds to a period of:
        self._clk_period = 1 / self._clk_freq
        
        # Yes data is still interpolated 1:2 therefore the period for data is:
        self._data_actual_period = self._clk_period
        
        # The DDS accumulator runs at 32 bits
        self._DDS_scale_factor = 2**32-1 
        
        #If I want to have a ramp freqyency of f that means that I want the
        # accumulator to overflow every 1/f seconds
        # so ( _DDS_scale_factor / increment ) * _data_actual_period = 1/f
        #
        # rearranging...
        # increment = round (_data_actual_period * f * _DDS_scale_factor)
        self.frequency = f
        self.amplitude = a
        
    
    @property
    def frequency(self):
        return self._f
    
    @property
    def increment(self):
        return self._ram[0]
    
    @frequency.setter
    def frequency(self,f):
        increment = round(self._data_actual_period * f * self._DDS_scale_factor)
        if (increment > self._DDS_scale_factor):
            raise ValueError("frequency is too large")
        self._ram[0] = increment
        self._f = increment / (self._data_actual_period * self._DDS_scale_factor)
    
    @property
    def amplitude(self):
        return self._a * 1/(2**16-1)
    
    @property
    def amplitude_mu(self):
        return self._a
    
    @amplitude.setter
    def amplitude(self,a):
        self._a = int(a * (2**16-1))
        if (self._a > (2**16-1) or self._a < 0):
            raise ValueError("Amplitude range is 0.0 to 1.0")
        self._ram[2] = self._a