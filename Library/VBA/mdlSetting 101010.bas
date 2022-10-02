Attribute VB_Name = "mdlSetting"
''<DATA>: 101010
'Option Compare Database
Option Compare Text
Option Explicit

'--------------------SEZIONE SETTAGGI FILES ----------------------
Global Const DEFAULT_INIFILENAME = "DefaultOption.Ini"
Private mstrDefaultSetting(5) As String

'--------------------SEZIONE LOGIN ----------------------
Global gstrProgammaNome As String
Global gstrProgammaAutori As String
Global gstrProgammaVersione As String
Global gstrUserID As String
Global gintUserLevel As Integer
Global gstrPrgLivelloDiAccesso As String  ' "9sy"   ' "User" ' "PWD" '"PowerUser" "DEBUG"
Global gintKillLevel As Integer
Global gintEditLevel As Integer
'--------------------SEZIONE IMPOSTAZIONI INI----------------------


'--------------------SEZIONE SETTAGGI INTERNAZIONALI----------------------
Global Const SECTION_NUMERI = "NUMERI"
Global Const SECTION_VALUTA = "VALUTA"
Global Const SECTION_TIME = "TIME"
Global Const DECIMAL_SEPARATOR = "SeparatoreDecimale"
Global Const RAGGRUPPAMENTO_CIFRE = "RaggruppamentoCifre"
Global Const TIME_SEPARATOR = "SeparatoreTempo"

'--------------------SEZIONE COSTANTI ----------------------
Global Const LOCALE_SDECIMAL = &HE         '  decimal separator
Global Const LOCALE_STHOUSAND = &HF        '  thousand separator
Global Const LOCALE_SMONDECIMALSEP = &H16  '  monetary decimal separator
Global Const LOCALE_SMONTHOUSANDSEP = &H17 '  monetary thousand separator

Global Const LOCALE_STIME = &H1E           'separatore ore minuti
Global Const LOCALE_SLIST = &HC            'separatore elenchi

Global Const WM_SETTINGCHANGE = &H1A 'same as the old WM_WININICHANGE
Global Const HWND_BROADCAST = &HFFFF&
Global Const SMTO_ABORTIFHUNG = &H2

Public Declare Function SendMessageTimeout Lib "user32" Alias "SendMessageTimeoutA" (ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long, ByVal fuFlags As Long, ByVal uTimeout As Long, lpdwResult As Long) As Long
Public Declare Function GetLocaleInfo Lib "kernel32" Alias "GetLocaleInfoA" (ByVal Locale As Long, ByVal LCType As Long, ByVal lpLCData As String, ByVal cchData As Long) As Long
Public Declare Function SetLocaleInfo Lib "kernel32" Alias "SetLocaleInfoA" (ByVal Locale As Long, ByVal LCType As Long, ByVal lpLCData As String) As Boolean
Public Declare Function GetSystemDefaultLCID Lib "kernel32" () As Long
Public Declare Function GetUserDefaultLCID% Lib "kernel32" ()

'--------------------SEZIONE FILE INI----------------------
Public Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Public Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long

'--------------------SEZIONE VIDEO----------------------
'variabili settaggio risoluzione video
Global Const WM_DISPLAYCHANGE = &H7E
'''' Global Const HWND_BROADCAST = &HFFFF& ' presente in settaggi-internazionali
Global Const EWX_LOGOFF = 0
Global Const EWX_SHUTDOWN = 1
Global Const EWX_REBOOT = 2
Global Const EWX_FORCE = 4
Global Const CCDEVICENAME = 32
Global Const CCFORMNAME = 32
Global Const DM_BITSPERPEL = &H40000
Global Const DM_PELSWIDTH = &H80000
Global Const DM_PELSHEIGHT = &H100000
Global Const CDS_UPDATEREGISTRY = &H1
Global Const CDS_TEST = &H4
Global Const DISP_CHANGE_SUCCESSFUL = 0
Global Const DISP_CHANGE_RESTART = 1
Global Const BITSPIXEL = 12

Public Type DEVMODE
  dmDeviceName As String * CCDEVICENAME
  dmSpecVersion As Integer
  dmDriverVersion As Integer
  dmSize As Integer
  dmDriverExtra As Integer
  dmFields As Long
  dmOrientation As Integer
  dmPaperSize As Integer
  dmPaperLength As Integer
  dmPaperWidth As Integer
  dmScale As Integer
  dmCopies As Integer
  dmDefaultSource As Integer
  dmPrintQuality As Integer
  dmColor As Integer
  dmDuplex As Integer
  dmYResolution As Integer
  dmTTOption As Integer
  dmCollate As Integer
  dmFormName As String * CCFORMNAME
  dmUnusedPadding As Integer
  dmBitsPerPel As Integer
  dmPelsWidth As Long
  dmPelsHeight As Long
  dmDisplayFlags As Long
  dmDisplayFrequency As Long
End Type

Public Declare Function EnumDisplaySettings Lib "user32" Alias "EnumDisplaySettingsA" (ByVal lpszDeviceName As Long, ByVal iModeNum As Long, lpDevMode As DEVMODE) As Boolean
Public Declare Function ChangeDisplaySettings Lib "user32" Alias "ChangeDisplaySettingsA" (lpDevMode As DEVMODE, ByVal dwFlags As Long) As Long
Public Declare Function ExitWindowsEx Lib "user32" (ByVal uFlags As Long, ByVal dwReserved As Long) As Long
Public Declare Function GetDeviceCaps Lib "gdi32" (ByVal hdc As Long, ByVal nIndex As Long) As Long
Public Declare Function CreateDC Lib "gdi32" Alias "CreateDCA" (ByVal lpDriverName As String, ByVal lpDeviceName As String, ByVal lpOutput As String, lpInitData As Long) As Long
Public Declare Function DeleteDC Lib "gdi32" (ByVal hdc As Long) As Long

Global gChgEnd As Boolean
Private DevM As DEVMODE, ScInfo As Long, lEDS As Long, lEDSAct As Long, sMsg As VbMsgBoxResult

'.....101010..dpe


'--------------------SEZIONE VIDEO----------------------
Private Function Resolution_Get(x As Long, Y As Long)
On Error Resume Next
    Dim nDC
    Dim sDsp
    Dim i As Integer, j As Integer
    Dim mDev(255) As DEVMODE

    Dim Bits As Long, rc As Long
    Dim ListRis, Response
    
    nDC = CreateDC("DISPLAY", vbNullString, sDsp, ByVal 0&)
    lEDS = EnumDisplaySettings(0&, 0&, DevM)
   
    lEDSAct = EnumDisplaySettings(0&, -1, DevM)
    Bits = DevM.dmBitsPerPel
    x = DevM.dmPelsWidth
    Y = DevM.dmPelsHeight
Err.Clear
End Function



Private Function Resolution_Set()
On Error Resume Next

    Dim nDC
    Dim sDsp
    Dim i As Integer, j As Integer
    Dim mDev(255) As DEVMODE

    Dim x As Long, Y As Long
    Dim XDefault As Long, YDefault As Long
    Dim XM As Long, YM As Long, iM As Long

    Dim Bits As Long, rc As Long
    Dim ListRis, Response
    Dim sDefaultOptionFileIni As String
    
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    nDC = CreateDC("DISPLAY", vbNullString, sDsp, ByVal 0&)
    lEDS = EnumDisplaySettings(0&, 0&, DevM)
    XM = 0
    YM = 0
    iM = 0
    
    For i = 0 To 255
        If EnumDisplaySettings(0&, i, mDev(i)) = False Then GoTo fineEnum1
'        selelzione a predominanza X e controllo su y
''''        Debug.Print "----", i, mDev(i).dmPelsWidth, mDev(i).dmPelsHeight
        If mDev(i).dmPelsWidth > XM Then
            XM = mDev(i).dmPelsWidth
        End If
    Next i
fineEnum1:

    YM = 0
    For i = 0 To 255
        If EnumDisplaySettings(0&, i, mDev(i)) = False Then GoTo fineEnum2
' controlla YM
''''        Debug.Print "----", i, mDev(i).dmPelsWidth, mDev(i).dmPelsHeight
        If (mDev(i).dmPelsHeight > YM) And (mDev(i).dmPelsWidth = XM) Then
            YM = mDev(i).dmPelsHeight
            iM = i
        End If
    Next i
fineEnum2:
    

    XM = mDev(iM).dmPelsWidth
    YM = mDev(iM).dmPelsHeight
''''    Debug.Print "fine", iM, XM, YM

    lEDSAct = EnumDisplaySettings(0&, -1, DevM)
    Bits = DevM.dmBitsPerPel
    x = DevM.dmPelsWidth
    Y = DevM.dmPelsHeight
    
    XDefault = CLng(GetValoreFromIni("Risoluzione Minima", "XDefault", 1280, sDefaultOptionFileIni))
    WritePrivateProfileString "Risoluzione Minima", "XDefault", CStr(XDefault), sDefaultOptionFileIni
    YDefault = CLng(GetValoreFromIni("Risoluzione Minima", "YDefault", 1024, sDefaultOptionFileIni))
    WritePrivateProfileString "Risoluzione Minima", "YDefault", CStr(YDefault), sDefaultOptionFileIni

    rc = WritePrivateProfileString("Risoluzione utente", "X", CStr(x), sDefaultOptionFileIni)
    rc = WritePrivateProfileString("Risoluzione utente", "Y", CStr(Y), sDefaultOptionFileIni)

    If x >= XDefault And Y >= YDefault Then

    ElseIf XDefault >= XM Or YDefault >= YM Then
        'caso in cui la ris. non è sufficiente
        Response = MsgBox("La risoluzione del tuo PC non è sufficiente e potranno esserci problemi di visualizzazione" & CStr(XM) & "x" & CStr(YM) & "." & vbCrLf & _
        "La risoluzione richiesta dall'applicazione è " & XDefault & "x" & YDefault & "! " & vbCrLf & vbCrLf & _
        "<SI>       per impostare la risoluzione massima: X=" & XM & " Y=" & YM & vbCrLf & _
        "<NO>       per lasciare l'attuale risoluzione" & vbCrLf & _
        "<Annulla>  per uscire", vbYesNoCancel)
        Select Case Response
        Case vbYes
            sDsp = Resolution_Change(XM, YM, GetDeviceCaps(nDC, BITSPIXEL))
            If sDsp = -1 Then
                MsgBox "Errore " & Err.Description & " l'applicazione sarà chiusa"
                Err.Clear
                Application.Quit
            End If
        Case vbNo

        Case vbCancel
            Application.Quit
            Err.Clear
        End Select
    Else
        Response = MsgBox("La risoluzione attuale è " & CStr(x) & "x" & CStr(Y) & "." & vbCrLf & _
        "La risoluzione richiesta dall'applicazione è " & XDefault & "x" & YDefault & "! " & vbCrLf & vbCrLf & _
        "<SI>       per impostare tale risoluzione" & vbCrLf & _
        "<NO>       per lasciare l'attuale risoluzione" & vbCrLf & _
        "<Annulla>  per uscire", vbYesNoCancel)
        Select Case Response
        Case vbYes
            sDsp = Resolution_Change(XDefault, YDefault, GetDeviceCaps(nDC, BITSPIXEL))
            If sDsp = -1 Then
                MsgBox "Errore " & Err.Description & " l'applicazione sarà chiusa"
                Err.Clear
                Application.Quit
            End If
        Case vbNo

        Case vbCancel
            Application.Quit
            Err.Clear
        End Select
    End If

Err.Clear
End Function

Private Function Resolution_Change(x As Long, Y As Long, Bits As Long)
On Error Resume Next
    'Get the info into DevM
    lEDS = EnumDisplaySettings(0&, 0&, DevM)
    'This is what we're going to change
    DevM.dmFields = DM_PELSWIDTH Or DM_PELSHEIGHT Or DM_BITSPERPEL
    DevM.dmPelsWidth = x 'ScreenWidth
    DevM.dmPelsHeight = Y 'ScreenHeight
    DevM.dmBitsPerPel = Bits '(can be 8, 16, 24, 32 or even 4)
    
    'Now change the display and check if possible
    lEDS = ChangeDisplaySettings(DevM, CDS_TEST) 'Check if succesfull
    
    Select Case lEDS&
       Case DISP_CHANGE_RESTART
            sMsg = MsgBox("You've to reboot", vbYesNo + vbSystemModal, "Info")
            If sMsg = vbYes Then
               lEDS& = ExitWindowsEx(EWX_REBOOT, 0&)
            End If
            Resolution_Change = DISP_CHANGE_RESTART
       Case DISP_CHANGE_SUCCESSFUL
            Resolution_Change = DISP_CHANGE_SUCCESSFUL
            lEDS = ChangeDisplaySettings(DevM, CDS_UPDATEREGISTRY)
            ScInfo = Y * 2 ^ 16 + x
            'Notify all the windows of the screen resolution change
'             SendMessage HWND_BROADCAST, WM_DISPLAYCHANGE, ByVal Bits, ByVal ScInfo ??? non funzionava sul mio
             'MsgBox "Everything's ok", vbOKOnly + vbSystemModal, "It worked!"
        Case Else
             MsgBox "La risoluzione " & x & " x " & Y & " non è supportata", vbOKOnly + vbSystemModal, "Error"
             Resolution_Change = -1
    End Select

Err.Clear
End Function

Private Sub Resolution_Reset(x As Long, Y As Long)
On Error Resume Next
    Dim nDC
    nDC = CreateDC("DISPLAY", vbNullString, vbNullString, ByVal 0&)
    Resolution_Change x, Y, GetDeviceCaps(nDC, BITSPIXEL)

Err.Clear
End Sub

'--------------------SEZIONE SETTAGGI INTERNAZIONALI----------------------
Private Function GetUserLocalS(Locale As Long, LOCALCONST As Long) As String
On Error Resume Next
    Dim Symbol As String
    Dim iRet1 As Long
    Dim iRet2 As Long
    Dim lpLCDataVar As String
    Dim Pos As Integer
   
    Locale = GetUserDefaultLCID()
    iRet1 = GetLocaleInfo(Locale, LOCALCONST, lpLCDataVar, 0)
   
    Symbol = String$(iRet1, 0)
    iRet2 = GetLocaleInfo(Locale, LOCALCONST, Symbol, iRet1)
    Pos = InStr(Symbol, Chr$(0))
    If Pos > 0 Then
        Symbol = Left$(Symbol, Pos - 1)
    End If
    GetUserLocalS = Symbol

Err.Clear
End Function


Public Function GetValoreFromIni(sezione, entry, Default, FileName) As String
On Error Resume Next
    Dim buffer As String
    Dim lenbuffer As Long
    Dim rc As Long
    lenbuffer = 512
    buffer = Space(lenbuffer)
    
    rc = GetPrivateProfileString(CStr(sezione), CStr(entry), CStr(Default), buffer, lenbuffer, CStr(FileName))
    If Len(RTrim(buffer)) = 0 Then
        GetValoreFromIni = ""
        Exit Function
    End If
    GetValoreFromIni = Mid(buffer, 1, Len(RTrim(buffer)) - 1)

Err.Clear
End Function


Private Function MathInternationalOption_Set()
On Error Resume Next
    Dim dwLCID As Long
    Dim rc As Long
    Dim sDefaultOptionFileIni As String
    
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    mstrDefaultSetting(1) = ""
    mstrDefaultSetting(2) = ""
    mstrDefaultSetting(3) = ""
    mstrDefaultSetting(4) = ""
    mstrDefaultSetting(5) = ""
    
    'carica in memoria il settaggio corrente
    dwLCID = GetSystemDefaultLCID()
    mstrDefaultSetting(1) = GetUserLocalS(dwLCID, LOCALE_SDECIMAL)          'NUMERI, separatore decimale
    mstrDefaultSetting(2) = GetUserLocalS(dwLCID, LOCALE_STHOUSAND)          'NUMERI, Raggruppamento cifre
    mstrDefaultSetting(3) = GetUserLocalS(dwLCID, LOCALE_SMONDECIMALSEP)          'NUMERI, separatore decimale
    mstrDefaultSetting(4) = GetUserLocalS(dwLCID, LOCALE_SMONTHOUSANDSEP)          'NUMERI, Raggruppamento cifre
    mstrDefaultSetting(5) = GetUserLocalS(dwLCID, LOCALE_STIME)          'separatore time
    
    '   salvataggio su file delle informazioni correnti
    rc = WritePrivateProfileString("Numeri", "SeparatoreDecimale", mstrDefaultSetting(1), sDefaultOptionFileIni)
    rc = WritePrivateProfileString("Numeri", "RaggruppamentoCifre", mstrDefaultSetting(2), sDefaultOptionFileIni)
    rc = WritePrivateProfileString("Valuta", "SeparatoreDecimale", mstrDefaultSetting(3), sDefaultOptionFileIni)
    rc = WritePrivateProfileString("Valuta", "RaggruppamentoCifre", mstrDefaultSetting(4), sDefaultOptionFileIni)
    rc = WritePrivateProfileString("TIME", "SeparatoreTempo", mstrDefaultSetting(5), sDefaultOptionFileIni)

    
    '   settaggio nuove impostazioni internazionali
    dwLCID = GetSystemDefaultLCID()

Err.Clear
    If SetLocaleInfo(dwLCID, LOCALE_SDECIMAL, ".") = False Then
     MsgBox "Failed LOCALE_SDECIMAL"
     Err.Clear
     Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_STHOUSAND, "'") = False Then
     MsgBox "Failed LOCALE_STHOUSAND"
     Err.Clear
     Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_SMONDECIMALSEP, ".") = False Then
     MsgBox "Failed LOCALE_SMONDECIMALSEP"
     Err.Clear
     Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_SMONTHOUSANDSEP, "'") = False Then
     MsgBox "Failed LOCALE_SMONTHOUSANDSEP"
     Err.Clear
     Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_STIME, ":") = False Then
     MsgBox "Failed LOCALE_SDECIMAL"
     Err.Clear
     Exit Function
    End If
    
    
End Function

Private Function MathInternationalOption_Reset()
On Error Resume Next
    Dim dwLCID As Long
    Dim rc As Long
    Dim sDefaultOptionFileIni As String
    
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    mstrDefaultSetting(1) = ""
    mstrDefaultSetting(2) = ""
    mstrDefaultSetting(3) = ""
    mstrDefaultSetting(4) = ""
    mstrDefaultSetting(5) = ""

'carica in memoria il settaggio corrente
'per una precedente uscita per errore, le informazioni corrette sono salvate su file
    mstrDefaultSetting(1) = GetValoreFromIni("Numeri", "SeparatoreDecimale", ".", sDefaultOptionFileIni)
    mstrDefaultSetting(2) = GetValoreFromIni("Numeri", "RaggruppamentoCifre", "'", sDefaultOptionFileIni)
    mstrDefaultSetting(3) = GetValoreFromIni("Valuta", "SeparatoreDecimale", ".", sDefaultOptionFileIni)
    mstrDefaultSetting(4) = GetValoreFromIni("Valuta", "RaggruppamentoCifre", "'", sDefaultOptionFileIni)
    mstrDefaultSetting(5) = GetValoreFromIni("TIME", "SeparatoreTempo", ":", sDefaultOptionFileIni)

    '   settaggio nuove impostazioni internazionali
    dwLCID = GetSystemDefaultLCID()
    
Err.Clear
    If SetLocaleInfo(dwLCID, LOCALE_SDECIMAL, mstrDefaultSetting(1)) = False Then
        MsgBox "Failed LOCALE_SDECIMAL"
        Err.Clear
        Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_STHOUSAND, mstrDefaultSetting(2)) = False Then
        MsgBox "Failed LOCALE_STHOUSAND"
        Err.Clear
        Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_SMONDECIMALSEP, mstrDefaultSetting(3)) = False Then
        MsgBox "Failed LOCALE_SMONDECIMALSEP"
        Err.Clear
        Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_SMONTHOUSANDSEP, mstrDefaultSetting(4)) = False Then
        MsgBox "Failed LOCALE_SMONTHOUSANDSEP"
        Err.Clear
        Exit Function
    End If
    If SetLocaleInfo(dwLCID, LOCALE_STIME, mstrDefaultSetting(5)) = False Then
        MsgBox "Failed LOCALE_SDECIMAL"
        Err.Clear
        Exit Function
    End If
    
End Function


'--------------esecuzione ini--------------------------

Public Function Exe_IniIn() As String
On Error Resume Next
    Dim sDefaultOptionFileIni As String

    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    Exe_IniIn = "Settaggio dati DefaultOption.ini" & vbCrLf & LoginInfo_Get & vbCrLf
     '   access forzato da user standard
    LivelliDiAccesso_Get gstrPrgLivelloDiAccesso
    Exe_IniIn = Exe_IniIn & vbCrLf & "Accesso: " & gstrPrgLivelloDiAccesso

    Exe_IniIn = Exe_IniIn & vbCrLf & "Settaggio per i valori decimali/formato ora"
    MathInternationalOption_Set

    Exe_IniIn = Exe_IniIn & vbCrLf & "Controllo/Settaggio della risoluzione del monitor"
    Resolution_Set

Err.Clear
End Function
Public Function LoginInfo_Get() As String
On Error Resume Next
LoginInfo_Get = "Lettura : Nomi" & vbCrLf & "Lettura : Accesso"
    Dim sDefaultOptionFileIni As String
    
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    gstrProgammaNome = GetValoreFromIni("NOMI", "PROGRAMMA_NOME", "<programma>", sDefaultOptionFileIni)
    WritePrivateProfileString "NOMI", "PROGRAMMA_NOME", gstrProgammaNome, sDefaultOptionFileIni

    gstrProgammaVersione = GetValoreFromIni("NOMI", "PROGRAMMA_VERSIONE", "<Versione>", sDefaultOptionFileIni)
    WritePrivateProfileString "NOMI", "PROGRAMMA_VERSIONE", gstrProgammaVersione, sDefaultOptionFileIni

    gstrProgammaAutori = GetValoreFromIni("NOMI", "PROGRAMMA_AUTORE", "<autore>", sDefaultOptionFileIni)
    WritePrivateProfileString "NOMI", "PROGRAMMA_AUTORE", gstrProgammaAutori, sDefaultOptionFileIni
    
    
    gstrPrgLivelloDiAccesso = GetValoreFromIni("PRG", "PRG_ATTIVO", "USER", sDefaultOptionFileIni)
    WritePrivateProfileString "PRG", "PRG_ATTIVO", gstrPrgLivelloDiAccesso, sDefaultOptionFileIni
    
    gintKillLevel = CInt(GetValoreFromIni("PRG", "KILL_LEVEL", 5, sDefaultOptionFileIni))
    WritePrivateProfileString "PRG", "KILL_LEVEL", CStr(gintKillLevel), sDefaultOptionFileIni

    gintEditLevel = CInt(GetValoreFromIni("PRG", "EDIT_LEVEL", 5, sDefaultOptionFileIni))
    WritePrivateProfileString "PRG", "EDIT_LEVEL", CStr(gintEditLevel), sDefaultOptionFileIni
    
    
Err.Clear
End Function

Public Sub LivelliDiAccesso_Get(Optional Accesso = "USER")
Dim sPwd
    Select Case Accesso
    Case "Debug"
        gstrUserID = "SY"
        gintUserLevel = 9
    Case "PowerUser"
        gstrUserID = "us"
        gintUserLevel = gintKillLevel
    Case "User"
        gstrUserID = "us"
        gintUserLevel = 5
    Case "pwd"
        PwdGet
    Case Else
        PwdSplit Accesso
    End Select
    gChgEnd = True
End Sub
Public Sub LivelliDiAccesso_Change()
On Error Resume Next
Dim Response
    Dim sDefaultOptionFileIni As String
    
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME
    
    PwdGet
    Response = MsgBox("Vuoi salvare il nuovo accesso?", vbYesNo)
    If Response = vbYes Then
        WritePrivateProfileString "PRG", "PRG_ATTIVO", CStr(gintUserLevel) & gstrUserID, sDefaultOptionFileIni
    End If
Err.Clear
End Sub
Private Sub PwdGet()
Dim sPwd
    sPwd = InputBox("Dammi la pwd di accesso", "PWD")
    If sPwd = "" Then Exit Sub
    PwdSplit sPwd
    PwdCheck
    gstrPrgLivelloDiAccesso = sPwd
End Sub
Private Sub PwdCheck()

End Sub

Private Sub PwdSplit(sPwd)
    gintUserLevel = CInt(Left(sPwd, 1))
    gstrUserID = Right(sPwd, Len(sPwd) - 1)
End Sub


Private Function PwdGetFromUser(UserID) As String
On Error GoTo Gest_Err
'-------------------------------------------------------------------------------------------
' codice per il controllo della PWD a partire dallo USER
'-------------------------------------------------------------------------------------------
Dim lPwd As Long
Dim i As Integer
'______________ALGORITMO_________________________
    PwdGetFromUser = 0
    lPwd = 1
    For i = 1 To Len(Trim(UserID))
        ' il meno i fa scendere il valore della
        ' lettera a seconda della posizione
        lPwd = lPwd * (Asc(Mid(Trim(UserID), i, 1)))
    Next i
'______________ALGORITMO FINE____________________
    PwdGetFromUser = Trim(CStr(lPwd))
    Exit Function
Gest_Err:   'On Error GoTo Gest_Err
    MsgBox "Err> " & Me.Name & " FUN: PwdGetFromUser  N° " & Err.Number & " " & Err.Description
    Err.Clear
End Function

Public Sub Exe_IniOut()
On Error GoTo Gest_Err
    Dim XUs As Long, YUs As Long
    Dim x As Long, Y As Long
    Dim Response
    Dim ChgRes As String
    Dim ChgMat As String
    
    Dim sDefaultOptionFileIni As String
    sDefaultOptionFileIni = GetApplicationPath & "\" & DEFAULT_INIFILENAME

    ChgRes = GetValoreFromIni("SETTAGGIO INI", "INI_RESET_RISOLUZIONE", "USER", sDefaultOptionFileIni)
    ChgMat = GetValoreFromIni("SETTAGGIO INI", "INI_RESET_MAT", "USER", sDefaultOptionFileIni)
    
    WritePrivateProfileString "SETTAGGIO INI", "INI_RESET_RISOLUZIONE", ChgRes, sDefaultOptionFileIni
    WritePrivateProfileString "SETTAGGIO INI", "INI_RESET_MAT", ChgMat, sDefaultOptionFileIni

    If ChgMat = "USER" Then
        MathInternationalOption_Reset
    End If

    If ChgRes = "USER" Then
        XUs = CDbl(GetValoreFromIni("Risoluzione utente", "X", " ", sDefaultOptionFileIni))
        YUs = CDbl(GetValoreFromIni("Risoluzione utente", "Y", " ", sDefaultOptionFileIni))
        Resolution_Get x, Y
        If XUs <> x Or YUs <> Y Then Resolution_Reset XUs, YUs
    End If
    
    Exit Sub
Gest_Err: 'On Error GoTo gest_err

    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub

