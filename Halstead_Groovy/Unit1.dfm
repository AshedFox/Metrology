object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 601
  ClientWidth = 1152
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  DesignSize = (
    1152
    601)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOpen: TButton
    Left = 32
    Top = 64
    Width = 161
    Height = 49
    Caption = 'Open file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnOpenClick
  end
  object btnReNew: TButton
    Left = 32
    Top = 144
    Width = 161
    Height = 49
    Caption = 'Reopen file'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnReNewClick
  end
  object Memo1: TMemo
    Left = 32
    Top = 215
    Width = 185
    Height = 332
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 223
    Top = 0
    Width = 467
    Height = 601
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 3
    object ListView1: TListView
      Left = 1
      Top = 1
      Width = 465
      Height = 599
      Align = alClient
      Columns = <
        item
          Caption = 'j'
          Width = 90
        end
        item
          Caption = 'Operator'
          Width = 250
        end
        item
          Caption = 'f1j'
          Width = 90
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitLeft = 0
    end
  end
  object Panel3: TPanel
    Left = 687
    Top = 0
    Width = 467
    Height = 601
    Anchors = [akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 4
    object ListView2: TListView
      Left = 1
      Top = 1
      Width = 465
      Height = 599
      Align = alClient
      Columns = <
        item
          Caption = 'i'
          Width = 90
        end
        item
          Caption = 'Operand'
          Width = 250
        end
        item
          Caption = 'f2i'
          Width = 90
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Comic Sans MS'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitLeft = 50
      ExplicitTop = 24
      ExplicitWidth = 417
      ExplicitHeight = 523
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 16
    Top = 8
  end
end
