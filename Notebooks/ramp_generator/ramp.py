import numpy as np
from pynq.mmio import MMIO
from pynq import PL, Overlay
class RampGenerator():
    """requires a base overlay object as an argument.
    """
    def __init__(self,f=1e9, overlay='main.bit',):
        self._overlay = Overlay(overlay)
        ramp_gen_mmio= MMIO(PL.ip_dict["ramp_params"]['phys_addr'],
                                    PL.ip_dict["ramp_params"]['addr_range'])
        self._ram = ramp_gen_mmio.array
        
        # The DAC clock is running at the following frequency:
        self._clk_freq = 9.8304e9 #Hertz
        
        # That corresponds to a period of:
        self._clk_period = 1 / self._clk_freq
        
        # This can be used to add amultiplicative factor in case there is interpolation (2x 3x etc...)
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
