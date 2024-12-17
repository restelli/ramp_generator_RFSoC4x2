# Ramp generator for Serrodyne experiments using the RFSoC4x2

We are providing a design for the RFSoC4x2 evaluation board that generates ramps suitable for Serrodyne experiments similar to
the ones descibed in [our paper](https://arxiv.org/abs/2412.05411).

The design requires the installation of [PYNQ](https://www.pynq.io/) on the [RFSoC4x2 board](https://www.realdigital.org/hardware/rfsoc-4x2) and, using the terminology of the PYNQ ecosystem, consists in an overlay that can be synthesized from the source code in [./src](./src/) and a [Jupyter notebook](./Notebooks/ramp_generator.ipynb) that loads the overlay and allows to changing the parameters of the ramp (amplitude and frequency).


Please note that the only available channel is DAC channel B, but the design can be modified to allow using two inependent DAC channels.