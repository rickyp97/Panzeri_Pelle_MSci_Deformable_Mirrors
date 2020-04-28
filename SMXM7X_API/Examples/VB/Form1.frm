VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3075
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   6345
   LinkTopic       =   "Form1"
   ScaleHeight     =   205
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   423
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton btStop 
      Caption         =   "Stop"
      Height          =   375
      Left            =   4920
      TabIndex        =   2
      Top             =   840
      Width           =   975
   End
   Begin VB.CommandButton btStart 
      Caption         =   "Start"
      Height          =   375
      Left            =   4920
      TabIndex        =   1
      Top             =   240
      Width           =   975
   End
   Begin VB.PictureBox Picture1 
      Height          =   3000
      Left            =   0
      ScaleHeight     =   196
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   316
      TabIndex        =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   4800
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub btStart_Click()
    StartVideo
End Sub

Private Sub btStop_Click()
    StopVideo
End Sub


Private Sub Form_Terminate()
    StopVideo
End Sub
