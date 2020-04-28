object Form1: TForm1
  Left = 278
  Top = 42
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 224
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 95
    Top = 10
    Width = 64
    Height = 13
    Caption = 'Timeout (sec)'
  end
  object Message: TLabel
    Left = 2
    Top = 206
    Width = 8
    Height = 13
    Caption = '?'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 99
    Top = 32
    Width = 50
    Height = 13
    Caption = 'CameraNo'
  end
  object Label3: TLabel
    Left = 100
    Top = 55
    Width = 50
    Height = 13
    Caption = 'Frequency'
  end
  object lbExp: TLabel
    Left = 6
    Top = 120
    Width = 47
    Height = 13
    Caption = 'Exposure:'
  end
  object Label4: TLabel
    Left = 100
    Top = 78
    Width = 22
    Height = 13
    Caption = 'Gain'
  end
  object lbC: TLabel
    Left = 5
    Top = 151
    Width = 42
    Height = 13
    Caption = 'Contrast:'
  end
  object lbB: TLabel
    Left = 5
    Top = 136
    Width = 52
    Height = 13
    Caption = 'Brightness:'
  end
  object btSnapshot: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btSnapshotClick
  end
  object btCancelSnapshot: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Cancel'
    Enabled = False
    TabOrder = 1
    OnClick = btCancelSnapshotClick
  end
  object cbExtTrgEnabled: TCheckBox
    Left = 260
    Top = 7
    Width = 124
    Height = 17
    Caption = 'External Trigger'
    TabOrder = 2
  end
  object spnTimeout: TSpinEdit
    Left = 166
    Top = 6
    Width = 50
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 3
  end
  object GroupBox1: TGroupBox
    Left = 248
    Top = 29
    Width = 137
    Height = 65
    Caption = ' External Trigger Polarity '
    TabOrder = 4
    object rbPositive: TRadioButton
      Left = 35
      Top = 18
      Width = 73
      Height = 17
      Caption = 'Positive'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbNegative: TRadioButton
      Left = 34
      Top = 40
      Width = 73
      Height = 17
      Caption = 'Negative'
      TabOrder = 1
    end
  end
  object ComboBox1: TComboBox
    Left = 166
    Top = 29
    Width = 49
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 5
    Text = '0'
    OnChange = ComboBox1Change
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
  object ComboBox2: TComboBox
    Left = 166
    Top = 51
    Width = 67
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 1
    TabOrder = 6
    Text = '24 MHz'
    OnChange = ComboBox2Change
    Items.Strings = (
      '40 MHz'
      '24 MHz'
      '20 MHz'
      '16 MHz'
      '13.33 MHz'
      '12 MHz'
      '10 MHz'
      '8 MHz'
      '6.66 MHz')
  end
  object tbExposure: TTrackBar
    Left = 128
    Top = 120
    Width = 281
    Height = 25
    Max = 4095
    Min = 11
    Orientation = trHorizontal
    Frequency = 1
    Position = 11
    SelEnd = 0
    SelStart = 0
    TabOrder = 7
    ThumbLength = 10
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = tbExposureChange
  end
  object cbSave: TCheckBox
    Left = 324
    Top = 199
    Width = 93
    Height = 17
    Caption = 'Save To disk'
    TabOrder = 8
  end
  object cbGain: TComboBox
    Left = 166
    Top = 74
    Width = 67
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 9
    Text = '0.0'
    OnChange = cbGainChange
    Items.Strings = (
      '0.0'
      '1.37'
      '1.62'
      '1.96'
      '2.33'
      '2.76'
      '3.50'
      '4.25'
      '5.20'
      '6.25'
      '7.89'
      '9.21'
      '11.00'
      '11.37'
      '11.84'
      '12.32'
      '12.42')
  end
  object trB: TTrackBar
    Left = 128
    Top = 136
    Width = 281
    Height = 25
    Max = 127
    Min = -127
    Orientation = trHorizontal
    Frequency = 1
    Position = 11
    SelEnd = 0
    SelStart = 0
    TabOrder = 10
    ThumbLength = 10
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = trBChange
  end
  object trC: TTrackBar
    Left = 127
    Top = 152
    Width = 281
    Height = 25
    Max = 127
    Min = -127
    Orientation = trHorizontal
    Frequency = 1
    Position = 11
    SelEnd = 0
    SelStart = 0
    TabOrder = 11
    ThumbLength = 10
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = trCChange
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 216
    Top = 8
  end
end
