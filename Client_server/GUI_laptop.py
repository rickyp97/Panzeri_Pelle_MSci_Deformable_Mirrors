
import tkinter as tk
from tkinter import ttk
import time

#import sys
#sys.path.append('/home/pi/deformable_mirrors/client server')

import pc_client_functions as client


#------------------ Functions ---------------------------------------------

def setvalue(value, Dac, channel, valueflag, fastoff_flag):
        client.sendconfig([value],[channel],[Dac],valueflag,fastoff_flag)
        return

def setall(channellist, Dac, valueflag,fastoff_flag):
    values = []
    channels = []
    Daclist = []
    zero = []
    for i in range(len(channellist)):
        values.append(int(channellist[i].get()))
        Daclist.append(boardflag.get())
        channels.append(i+1)
        zero.append(0)
    if fastoff_flag == "On":
        client.send_all_config(values,channels,Daclist,valueflag,fastoff_flag)
    else:    
        client.sendconfig(values,channels,Daclist,valueflag) 
    return

def plus5(value, Dac, channel, valueflag, channellist):
    value = value + 5
    channellist[channel-1].set(str(value))
    setvalue(value,Dac, channel, valueflag)
    return

def plus10(value, Dac, channel, valueflag, channellist):
    value = value + 10
    channellist[channel-1].set(str(value))
    setvalue(value,Dac,channel, valueflag)
    return    


def alloff(channellist, Dac, valueflag):
    values = []
    channels = []
    Daclist = []
    for i in range(0,len(channellist),1):
        channellist[i].set('0')
        values.append(int(channellist[i].get()))
        Daclist.append(boardflag.get())
        channels.append(i+1)
    client.sendconfig(values,channels,Daclist,valueflag)     
    return

def sendconfig2server(channellist):
#    values = []
#    for x in range(0,len(channellist),1):
#        values.append(channellist[x].get())
#    _ = '_'    
#    string =_.join(values) 
#    client.sendconfig(string)
    return

def snapcommand(channellist, folder):
#    values = []
#    for x in range(0,len(channellist),1):
#        values.append(channellist[x].get())
#    _ = '_'    
#    string =_.join(values)
#    client.snaprequest(folder,string)
    return

def callGA(channellist, iters, pop, parents, variability):
#    values = []
#    for x in range(0,len(channellist),1):
#        values.append(int(channellist[x].get()))
#    client.GAstuff(iters,pop,parents,variability,values)
    return
        
    

def choose_chan_numb(event):                        #spaghettissimus totalis
    n = chan_numb.get()
    global channellist 
    if n == '1':
        channellist = [ch1]
    elif n == '5':
        channellist = [ch1,ch2,ch3,ch4,ch5]  
    return
        
if __name__ == "__main__":    
    #---------------------- main start + column and row config --------------------------------------------------------

    main=tk.Tk()
    main.title('Main')
    main.columnconfigure(1, minsize = 50)
    main.columnconfigure(8, minsize = 50)
    main.rowconfigure(9, minsize = 50)

    #--------------------------Voltage or duty cycle buttons ------------------------------------
    fastoff_flag = tk.StringVar()
    fastoff_flag.set("Off")
    valueflag = tk.StringVar()
    valueflag.set("Voltage")
    boardflag = tk.StringVar()
    boardflag.set("DAC1")

    buttonvoltage = tk.Radiobutton(main, text = "Voltage", variable = valueflag, value = "Voltage")
    buttonduty = tk.Radiobutton(main, text = "duty cycle", variable = valueflag, value = "Duty")
    buttondac1 = tk.Radiobutton(main, text = "DAC1", variable = boardflag, value = "DAC1")
    buttondac2 = tk.Radiobutton(main, text = "DAC2", variable = boardflag, value = "DAC2", state = 'disable')
    buttonfastoff_off = tk.Radiobutton(main, text = "fastoff disabled", variable = fastoff_flag, value = "Off")
    buttonfastoff_on = tk.Radiobutton(main, text = "fastoff enabled", variable = fastoff_flag, value = "On")
    buttonvoltage.grid(row = 0,column = 0, sticky = 'W')
    buttonduty.grid(row = 1, column = 0, sticky = 'W')
    buttondac1.grid(row = 2,column = 0, sticky = 'W')
    buttondac2.grid(row = 3,column = 0, sticky = 'W')
    buttonfastoff_off.grid(row = 4,column = 0, sticky = 'W')
    buttonfastoff_on.grid(row = 5,column = 0, sticky = 'W')

    #---------------------------------- channels number and settings ---------------------



    ch1 = tk.StringVar()
    ch1.set('0')
    ch2 = tk.StringVar()
    ch2.set('0')
    ch3 = tk.StringVar()
    ch3.set('0')
    ch4 = tk.StringVar()
    ch4.set('0')
    ch5 = tk.StringVar()
    ch5.set('0')

    channellist = [ch1,ch2,ch3,ch4,ch5]
    #--------------------------------- channels input and set buttons ---------------------------------

    chan_numb = ttk.Combobox(main, values = ['1','5'])
    chan_numb.grid(row = 1, column = 4)
    chan_numb.set('5')
    chan_numb.bind("<<ComboboxSelected>>", choose_chan_numb)

    tk.Entry(main, textvariable = ch1).grid(row = 2, column = 4)
    tk.Entry(main, textvariable = ch2).grid(row = 3, column = 4)
    tk.Entry(main, textvariable = ch3).grid(row = 4, column = 4)
    tk.Entry(main, textvariable = ch4).grid(row = 5, column = 4)
    tk.Entry(main, textvariable = ch5).grid(row = 6, column = 4)

    tk.Label(main , text = "Number of channels").grid(row = 1, column = 2)
    tk.Label(main , text = "channel 1").grid(row = 2, column = 2)
    tk.Label(main , text = "channel 2").grid(row = 3, column = 2)
    tk.Label(main , text = "channel 3").grid(row = 4, column = 2)
    tk.Label(main , text = "channel 4").grid(row = 5, column = 2)
    tk.Label(main , text = "channel 5").grid(row = 6, column = 2)

    tk.Button(text = 'set', command = lambda: setvalue(int(ch1.get()),boardflag.get() ,1,valueflag.get(),fastoff_flag.get())).grid(row = 2, column = 5)
    tk.Button(text = 'set', command = lambda: setvalue(int(ch2.get()),boardflag.get() ,2,valueflag.get(),fastoff_flag.get())).grid(row = 3, column = 5)
    tk.Button(text = 'set', command = lambda: setvalue(int(ch3.get()),boardflag.get() ,3,valueflag.get(),fastoff_flag.get())).grid(row = 4, column = 5)
    tk.Button(text = 'set', command = lambda: setvalue(int(ch4.get()),boardflag.get() ,4,valueflag.get(),fastoff_flag.get())).grid(row = 5, column = 5)
    tk.Button(text = 'set', command = lambda: setvalue(int(ch5.get()),boardflag.get() ,5,valueflag.get(),fastoff_flag.get())).grid(row = 6, column = 5)

    tk.Button(text = 'set all', command = lambda: setall(channellist, boardflag.get(),valueflag.get(),fastoff_flag.get())).grid(row = 7, column = 4)
    tk.Button(text = 'all off', command = lambda: alloff(channellist, boardflag.get(),valueflag.get())).grid(row = 8, column = 4)
    #------------------------- +5 buttons -------------------------------------------------

    # tk.Button(text = '+5', command = lambda: plus5(int(ch1.get()),boardflag.get() ,1,valueflag.get(), channellist)).grid(row = 2, column = 6)
    # tk.Button(text = '+5', command = lambda: plus5(int(ch2.get()),boardflag.get() ,2,valueflag.get(), channellist)).grid(row = 3, column = 6)
    # tk.Button(text = '+5', command = lambda: plus5(int(ch3.get()),boardflag.get() ,3,valueflag.get(), channellist)).grid(row = 4, column = 6)
    # tk.Button(text = '+5', command = lambda: plus5(int(ch4.get()),boardflag.get() ,4,valueflag.get(), channellist)).grid(row = 5, column = 6)
    # tk.Button(text = '+5', command = lambda: plus5(int(ch5.get()),boardflag.get() ,5,valueflag.get(), channellist)).grid(row = 6, column = 6)

    # #------------------- +10 buttons -----------------------------------

    # tk.Button(text = '+10', command = lambda: plus10(int(ch1.get()),boardflag.get() ,1,valueflag.get(), channellist)).grid(row = 2, column = 7)
    # tk.Button(text = '+10', command = lambda: plus10(int(ch2.get()),boardflag.get() ,2,valueflag.get(), channellist)).grid(row = 3, column = 7)
    # tk.Button(text = '+10', command = lambda: plus10(int(ch3.get()),boardflag.get() ,3,valueflag.get(), channellist)).grid(row = 4, column = 7)
    # tk.Button(text = '+10', command = lambda: plus10(int(ch4.get()),boardflag.get() ,4,valueflag.get(), channellist)).grid(row = 5, column = 7)
    # tk.Button(text = '+10', command = lambda: plus10(int(ch5.get()),boardflag.get() ,5,valueflag.get(), channellist)).grid(row = 6, column = 7)

    #---------------------------------- Server-client connection -----------------------------------------------
    folder = tk.StringVar()
    folder.set('...')

    sendconfigbutton = tk.Button(text = 'Send channel config', command = lambda: sendconfig2server(channellist)).grid(row = 4, column = 10)

    save_snap = tk.Button(text = 'Take snap', command = lambda: snapcommand(channellist,folder.get())).grid(row = 5, column = 10)

    shutdown_server = tk.Button(text = 'Shutdown server', command = lambda: client.sendstop()).grid(row = 6, column = 10)

    tk.Label(main, text = "folder name").grid(row = 2, column = 9)
    tk.Entry(main, textvariable = folder).grid(row = 2, column = 10)
    tk.Button(text = 'select/create folder', command = lambda: client.folderselect(folder.get())).grid(row = 2, column = 11)


    #----------------------------------------- GA part --------------------------------------------------------------------

    iters = tk.StringVar()
    iters.set('0')
    pop = tk.StringVar()
    pop.set('0')
    parents = tk.StringVar()
    parents.set('0')
    variability = tk.StringVar()
    variability.set('0')

    
    tk.Entry(main, textvariable = iters).grid(row = 11, column = 4)
    tk.Entry(main, textvariable = pop).grid(row = 12, column = 4)
    tk.Entry(main, textvariable = parents).grid(row = 13, column = 4)
    tk.Entry(main, textvariable = variability).grid(row = 14, column = 4)
    
    tk.Label(main , text = "GA STUFF BELOW").grid(row = 10, column = 4)
    tk.Label(main , text = "Nunmber of iterations").grid(row = 11, column = 2)
    tk.Label(main , text = "Population size").grid(row = 12, column = 2)
    tk.Label(main , text = "Number of parents").grid(row = 13, column = 2)
    tk.Label(main , text = "variability").grid(row = 14, column = 2)

    tk.Button(text = 'Run GA', command = lambda: callGA(channellist,iters.get(),pop.get(),parents.get(),variability.get())).grid(row = 15, column = 2)

    
    #--------------------------------- end loop ----------------------------------------------------------------------------
    main.mainloop()
