# -*- coding: utf-8 -*-
"""
Created on Thu May 22 22:58:23 2025

@author: jpcoe
"""

import skrf as rf
import numpy as np

# Load measured data
measured = rf.Network('500M_1200M.s1p')
freq = measured.frequency  # Frequency object from the S1P file
f = freq.f  # frequency in Hz
w = 2 * np.pi * f

# Define per-unit-length parameters (example values for RG174)
# Define RLGC values for RG174
R = 0.21      # ohms/m
L = 250e-9    # H/m
G = 0         # S/m
C = 100e-12   # F/m

# Compute gamma and Z0
gamma = np.sqrt((R + 1j*w*L) * (G + 1j*w*C))
z0 = np.sqrt((R + 1j*w*L) / (G + 1j*w*C))

# Create the RLGC-based transmission line
media = rf.DefinedGammaZ0(frequency=freq, gamma=gamma, z0=z0)

# Define 1 meter of cable
coax = media.line(d=1.0, unit='m', name='coax')

antenna =measured.deembed(coax)

# Save result
antenna_only.write_touchstone('antenna_only')
