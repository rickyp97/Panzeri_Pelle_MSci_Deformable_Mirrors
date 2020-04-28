import SMXM7X
import matplotlib.pyplot as plt
from PIL import Image
import time

camera = SMXM7X.Cam()
camera.OpenDevice(0)
print(camera.GetCameraInfo())
print(camera.GetFrameParams())
camera.SetStreamMode(0)
camera.SetAllGain(0)
camera.SetExposure(0.35)
snap = camera.GetSnapshot()
#print(snap.shape)
#plt.imshow(snap)
for i in range(10):
    print(i)
    camera.SaveSnapshot("", "test.bmp")
camera.CloseDevice()

