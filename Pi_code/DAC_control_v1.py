from ServoPi import PWM
import time
import numpy as np

"""------------------FUNCTIONS---------------"""

duty = np.arange(0,4096,1)

v = []
for n in duty:
    if n < 50:
        V = 1.045 - 0.011 * n + 0.00091 * (n**2) - 3.187E-6*(n**3)
        v.append(V)
    elif n >= 50:
        V = 0.1023 + 0.04689*n - 2.291E-6*(n**2)-5.021E-11*(n**3)
        v.append(V)

lookup = np.asarray(v)

def setValue(obj, channel, value):
    if value > 4095:
        value = 4095
    obj.set_pwm(channel,0,value)
    return

def setValue_all(obj, value):
    if value > 4095:
        value = 4095
    obj.set_all_pwm(0,value)
    return

def allOff(obj):
    obj.set_all_pwm(0,0)
    return

def scanChannel(obj,channel,start,stop,step,waittime):
    for value in range(start,stop + step,step):
        if value > 4095:
            value = 4095
        obj.set_pwm(channel,0,value)
        print(value)
        time.sleep(waittime)
    return

def setVoltage(obj, channel, v_out):
    if v_out > 150:
        v_out = 150
    if v_out < 0:
        v_out = 0

    idx = (np.abs(lookup-v_out)).argmin()

    setValue(obj, channel, idx)
    return
#---------------SPAGHETTI---------------
DAC1 = PWM(0x40)
DAC2 = PWM(0x60)
allOff(DAC1)
