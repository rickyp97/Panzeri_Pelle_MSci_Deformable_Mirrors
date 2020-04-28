object Form1: TForm1
  Left = 228
  Top = 138
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 493
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 679
    Top = 185
    Width = 44
    Height = 13
    Caption = 'Exposure'
  end
  object Label2: TLabel
    Left = 656
    Top = 40
    Width = 76
    Height = 13
    Caption = 'Camera Number'
  end
  object Label3: TLabel
    Left = 653
    Top = 96
    Width = 22
    Height = 13
    Caption = 'Gain'
  end
  object lbFPS: TLabel
    Left = 680
    Top = 141
    Width = 35
    Height = 13
    Caption = '??? fps'
  end
  object Label4: TLabel
    Left = 653
    Top = 120
    Width = 21
    Height = 13
    Caption = 'Freq'
  end
  object ViewFrame: TPanel
    Left = 8
    Top = 8
    Width = 640
    Height = 480
    BorderStyle = bsSingle
    Caption = 'Stopped'
    TabOrder = 0
  end
  object btRun: TButton
    Left = 656
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btRunClick
  end
  object trExp: TTrackBar
    Left = 688
    Top = 197
    Width = 25
    Height = 290
    Max = 1024
    Orientation = trVertical
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 2
    ThumbLength = 15
    TickMarks = tmBottomRight
    TickStyle = tsNone
    OnChange = trExpChange
  end
  object cbCameraNo: TComboBox
    Left = 672
    Top = 60
    Width = 41
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = '0'
    OnChange = cbCameraNoChange
    Items.Strings = (
      '0'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9')
  end
  object cbGain: TComboBox
    Left = 678
    Top = 92
    Width = 59
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = '1 dB'
    OnChange = cbGainChange
    Items.Strings = (
      '1 dB'
      '1.125 dB'
      '1.25 dB'
      '1.375 dB'
      '1.5 dB'
      '1.625 dB'
      '1.75 dB'
      '1.875 dB'
      '2 dB'
      '2.125 dB'
      '2.25 dB'
      '2.375 dB'
      '2.5 dB'
      '2.625 dB'
      '2.75 dB'
      '2.875 dB'
      '3 dB'
      '3.125 dB'
      '3.25 dB'
      '3.375 dB'
      '3.5 dB'
      '3.625 dB'
      '3.75 dB'
      '3.875 dB'
      '4 dB'
      '4.25 dB'
      '4.5 dB'
      '4.75 dB'
      '5 dB'
      '5.25 dB'
      '5.5 dB'
      '5.75 dB'
      '6 dB'
      '6.25 dB'
      '6.5 dB'
      '6.75 dB'
      '7 dB'
      '7.25 dB'
      '7.5 dB'
      '7.75 dB'
      '8 dB'
      '9 dB'
      '10 dB'
      '11 dB'
      '12 dB'
      '13 dB'
      '14 dB'
      '15 dB')
  end
  object cbFreq: TComboBox
    Left = 678
    Top = 116
    Width = 67
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 2
    TabOrder = 5
    Text = '24 MHz'
    OnChange = cbFreqChange
    Items.Strings = (
      '48 MHz'
      '40 MHz'
      '24 MHz'
      '20 MHz'
      '16 MHz'
      '13.3 MHz'
      '12 MHz'
      '10 MHz'
      '8 MHz'
      '6.6 MHz')
  end
  object Button1: TButton
    Left = 663
    Top = 156
    Width = 73
    Height = 25
    Caption = 'Auto Exp'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 712
    Top = 56
  end
end
