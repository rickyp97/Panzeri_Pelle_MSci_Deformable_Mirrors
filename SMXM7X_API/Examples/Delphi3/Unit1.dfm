object Form1: TForm1
  Left = 258
  Top = 116
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 99
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
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
    Top = 78
    Width = 5
    Height = 13
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
  object btSnapshot: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Snapshot'
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
    Left = 104
    Top = 59
    Width = 97
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
    Left = 224
    Top = 5
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
    Left = 168
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
end
