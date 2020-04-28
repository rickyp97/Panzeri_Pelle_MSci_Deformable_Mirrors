object Form1: TForm1
  Left = 328
  Top = 115
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 183
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
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 95
    Top = 12
    Width = 64
    Height = 13
    Caption = 'Timeout (sec)'
  end
  object Message: TLabel
    Left = 10
    Top = 150
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
    Top = 36
    Width = 50
    Height = 13
    Caption = 'CameraNo'
  end
  object Label3: TLabel
    Left = 100
    Top = 61
    Width = 50
    Height = 13
    Caption = 'Frequency'
  end
  object lbExp: TLabel
    Left = 133
    Top = 96
    Width = 47
    Height = 13
    Caption = 'Exposure:'
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
    Top = 8
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
    Top = 33
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
    Top = 57
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
    Orientation = trHorizontal
    Frequency = 1
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 7
    ThumbLength = 10
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = tbExposureChange
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 216
    Top = 8
  end
end
