Attribute VB_Name = "db_Main"
'<DATA>: 110221

Option Explicit

'--------------------SEZIONE SETTAGGI FORMS------------------------
Global Const NO_FILE = "Nessun File"
Global gintMargineCaselle As Long
Global gintMargineForm As Long
Global gintFclChiaro As Long
Global gintFclScuro As Long
Global gintFclBCK As Long
Global gintBckColorVerde As Long
Global gintBckColorEdit As Long
Global gintBckColorForms As Long
Global gintForeColorSelezionato As Long

'--------------------SEZIONE SETTAGGI FILES------------------------
Global Const DB_INIFILENAME = "DB.Ini"
Global Const DB_DATI = "db_dati.mdb"

'--------------------SEZIONE LOGIN --------------------------------
Global gstrStartForm As String

'--------------------SEZIONE IMPOSTAZIONI INI----------------------
Global gstrPrgSincronia As String   ' "NO", "SI"
Global gintMultiDBLevel As Integer


'--------------------SEZIONE IMPOSTAZIONI COMANDI -----------------
Global gstrItem As String
Global gstrCommand As String
Global gstrArgument As String
Global gstrParameters As String
Global gstrFormCommandExe As String


'--------------------SEZIONE IMPOSTAZIONI FILE-FORM ---------------
Global gfrmFormAttivo As Form
Global gfrmFormAttivoSf As Form
Global gfrmFormAttivoEdt As Form
Global gfrmFormAttivoEdtSf As Form
Global gstrFormAttivoQuery As String
Global gstrFormIN As String
Global gstrFormOUT As String

Type myFormEdt
    Tabella As Variant
    IDField As Variant
    IDValue As Variant
    IDFieldType As Variant
End Type
Global gMyFormEdt As myFormEdt

Global Const FRECCIA_DX = 9658

Type myCnn
    Source As String
    Type As String
    Path As String
End Type

' todo
' togliere le global leggibili dall'INI


Type myPathAusiliari
    Nome As String
    Path As String
End Type
Global gMyPathAusiliari(100) As myPathAusiliari
Global gstrPathAusiliari As String


'-----110221
Public Sub RunSub(SubName, Optional sPar4 = "")
On Error Resume Next
    Dim iR, iC, upR, lwR, upC, lwC, vList
    
    vList = Split(sPar4, "|")
    
    lwR = LBound(vList, 1)
    upR = UBound(vList, 1)
    
    Select Case upR
    Case -1
        Application.Run SubName
    Case 0
        Application.Run SubName, vList(0)
    Case 1
        Application.Run SubName, vList(0), vList(1)
    Case 3
        Application.Run SubName, vList(0), vList(1), vList(2)
    Case 4
        Application.Run SubName, vList(0), vList(1), vList(2), vList(3)
    End Select
Err.Clear

End Sub

Public Sub Exe_Command(Optional Item = "", Optional Command = "", Optional Argument = "", Optional Parameters = "")
On Error Resume Next
'----------------da settare------------
    If Command = "" Or Command = "-" Then Exit Sub
    
    gstrItem = Trim("" & Item)
    gstrCommand = Trim("" & Command)
    gstrArgument = Trim("" & Argument)
    gstrParameters = Trim("" & Parameters)
    
    Select Case gstrCommand
    Case "LOCKED"
        MsgBox "Funzione " & gstrItem & " bloccata"
    Case "EXESUBPAR"
        RunSub gstrArgument, gstrParameters
        Err.Clear
    Case "EXESUB"
        RunSub gstrArgument
        Err.Clear
    Case "OPENFORM"
        DoCmd.OpenForm gstrArgument
    Case "OPENFORMADD"
        DoCmd.OpenForm gstrArgument, , , , acFormAdd
    Case "OPENEXE"
        
    Case "OPENTABLE"
        DoCmd.OpenTable gstrArgument
    Case "SHOWFORM"
        Dim sC
        sC = Split(gstrParameters, "|")
        On Error Resume Next
        Dim sF As String
        
        With Forms(sC(0)).Controls(sC(1))
            sF = .SourceObject
            .Visible = False
            DoCmd.Close acForm, sF
            .SourceObject = Trim(gstrArgument)
            .Visible = True
        End With
        Err.Clear
    Case "EXE_CreaReplica"
        DB_CreaReplica
    End Select
    
    Err.Clear

    Exit Sub
End Sub



'---------101010
Public Sub CnnLoad()
On Error Resume Next
    Dim t
    Dim cn As myCnn
    
    cn.Source = "Nessuno"
    cn.Type = ""
    cn.Path = ""
    
    Dim s1, s2, s3, s4
    
    Dim sC
    sC = Split(gstrParameters, "|")
    cn.Type = sC(0)
    cn.Source = sC(1)


    If cn.Type = "" Then Exit Sub

    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2

    
    If cn.Type = "Microsoft Access" Then
        s1 = GetApplicationSubPath("DB")
        s2 = GetFilePath(cn.Source)
        If s2 = "" Then
            cn.Source = s1 & "\" & cn.Source
        Else

        End If
    Else
        cn.Type = "ODBC"
    End If


    t = GetDBTabStart
    Obj_Load acLink, acTable, cn.Source, t, t, "", cn.Type, True

    Form_main_Home.SottomascheraForm.SourceObject = ""
    Form_main_Home.Etichetta_Connessioni.Caption = cn.Source

    DoCmd.Close acForm, "main_Attendi"
Err.Clear
End Sub



Sub OpenFile()
Dim s1, s2, s3
    s1 = GetApplicationPath
    s2 = GetFilePath(gstrParameters)
    If s2 = "" Then
        s3 = s1 & "\" & gstrParameters
    Else
        s3 = gstrParameters
    End If
        
    File_Open s3

End Sub
Sub CnnUnload()
On Error Resume Next

    CnnUnloadByEst ""
    
Err.Clear
End Sub

Sub CnnUnloadByEst(Est)
On Error Resume Next
Dim t

    t = GetDBTabStart
    Obj_UnLoad acTable, t, Est
    
Err.Clear
End Sub

Sub CnnLoadDBPredefinito()
On Error Resume Next
Dim t, cn As myCnn
    t = GetDBTabStart
    cn = GetDBPredefinito
    If cn.Source = "NESSUNO" Then Exit Sub

    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2
    
    Obj_Load acLink, acTable, cn.Source, t, t, "", cn.Type, True

    Form_main_Home.SottomascheraForm.SourceObject = ""
    Form_main_Home.Etichetta_Connessioni.Caption = cn.Source

    DoCmd.Close acForm, "main_Attendi"
    
Err.Clear
End Sub
Public Sub CnnLoadMDB()
On Error GoTo Gest_Err

    Dim commonDialog1 As New clsDialog
    Dim sPathFileStart As String
    Dim sFileStart As String
    Dim sIni, sPath, sPathStart
    sIni = GetDBFileIni
    
    commonDialog1.InitDir = GetApplicationSubPath("DB")
    commonDialog1.Filter = "Acces MDB *|*.mdb"
    commonDialog1.ShowOpen 'show the open window
    sPathFileStart = commonDialog1.FileName
    sFileStart = GetFileName(sPathFileStart)
    If sFileStart = "" Then Exit Sub
    sPath = GetApplicationSubPath("DB")
    sPathStart = GetFilePath(sPathFileStart)

    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2
    
Dim t
    t = GetDBTabStart
    Obj_Load acLink, acTable, sPathFileStart, t, t, "", "Microsoft Access", True

    Form_main_Home.SottomascheraForm.SourceObject = ""
    Form_main_Home.Etichetta_Connessioni.Caption = sPathFileStart
    
    DoCmd.Close acForm, "main_Attendi"
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub
Public Sub CnnLoadODBC()
On Error GoTo Gest_Err

    Dim sSource, t
    
    sSource = InputBox("", "Stringa Connessione ODBC")
    If sSource = "" Then Exit Sub

    t = GetDBTabStart
    Obj_Load acLink, acTable, sSource, t, t, "", "ODBC", True
    
    Form_main_Home.SottomascheraForm.SourceObject = ""
    Form_main_Home.Etichetta_Connessioni.Caption = sSource
    Form_main_Attendi.Unload
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub


Public Sub SetDBPredefinitoODBC()
On Error GoTo Gest_Err

    Dim sSource
    Dim sIni
    sIni = GetDBFileIni
    
    sSource = InputBox("", "Stringa Connessione ODBC")
    If sSource = "" Then Exit Sub

    
    WritePrivateProfileString "DB", "DBTipo", "ODBC", sIni
    WritePrivateProfileString "DB", "DBPredefinito", sSource, sIni
    
    
    Form_main_Home.SottomascheraForm.SourceObject = ""
    CnnLoadDBPredefinito
    Form_main_Home.Etichetta_Connessioni.Caption = sPathFileStart
    
    
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub
Public Sub SetDBPredefinitoMDB()
On Error GoTo Gest_Err

    Dim commonDialog1 As New clsDialog
    Dim sPathFileStart As String
    Dim sFileStart As String
    Dim sIni, sPath, sPathStart
    sIni = GetDBFileIni
    
    commonDialog1.InitDir = GetApplicationSubPath("DB")
    commonDialog1.Filter = "Acces MDB *|*.mdb"
    commonDialog1.ShowOpen 'show the open window
    sPathFileStart = commonDialog1.FileName
    sFileStart = GetFileName(sPathFileStart)
    If sFileStart = "" Then Exit Sub
    sPath = GetApplicationSubPath("DB")
    sPathStart = GetFilePath(sPathFileStart)
    
    WritePrivateProfileString "DB", "DBTipo", "Microsoft Access", sIni
    If sPath = sPathStart Then
        WritePrivateProfileString "DB", "DBPredefinito", sFileStart, sIni
    Else
        WritePrivateProfileString "DB", "DBPredefinito", sPathFileStart, sIni
    End If
    
    Form_main_Home.SottomascheraForm.SourceObject = ""
    CnnLoadDBPredefinito
    Form_main_Home.Etichetta_Connessioni.Caption = sPathFileStart
    
    
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub

'-------100617

'----------------------090308-------------------------
Public Function LocalPath_Set() As String
    LocalPath_Set = "Lettura : Local"

    Dim sP, sP1, sP2
    Dim i
    sP = Split(gstrPathAusiliari, "|")
    For i = LBound(sP) To UBound(sP)
        sP1 = Split(sP(i), ",")
        gMyPathAusiliari(i).Nome = sP1(1)
        If sP1(0) < 0 Then
            gMyPathAusiliari(i).Path = sP1(2)
        Else
            gMyPathAusiliari(i).Path = GetDirUP(GetApplicationPath, CInt(sP1(0))) & sP1(2)
        End If
        Debug.Print i, gMyPathAusiliari(i).Nome, gMyPathAusiliari(i).Path
    Next i

End Function

Public Function LocalPath_Get(myPath) As String
Dim i
    LocalPath_Get = ""
    For i = LBound(gMyPathAusiliari) To UBound(gMyPathAusiliari)
        If gMyPathAusiliari(i).Nome = myPath Then
            LocalPath_Get = Trim(gMyPathAusiliari(i).Path)
            Exit Function
        End If

    Next i

End Function

Public Sub Login()
On Error Resume Next
    DoCmd.Close acForm, "Main"
    DoCmd.Close acForm, gstrStartForm
    DoCmd.OpenForm gstrStartForm
End Sub


Public Function Setting_Path() As String
On Error GoTo Gest_Err
Dim bEx As Boolean
'creazione dei path predefiniti
    Setting_Path = "Inizializzazione" & vbCrLf & "Lettura : path"

    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
'controllo path e gestione in caso di anomalie
    If fs.FolderExists(GetApplicationProjectPath & "\DB") = False Then
        MsgBox "La directory DB non esiste. Probabilmente bisogna reinstallare il programma: contatta il sistemista", vbCritical, "Errore"
        Setting_Path = Setting_Path & vbCrLf & "La directory DB contenente i dati non esiste. Il programma non può girare e deve essere reinstallato." & vbCrLf & "Il programma verrà chiuso. Contatta il sistemista"
        Exit Function
    End If

    GetApplicationSubPath "Tmp"
    GetApplicationSubPath "DB"
    GetApplicationSubPath "Fonts"
    GetApplicationSubPath "Sinc"
    GetApplicationSubPath "BCK"
    GetApplicationSubPath "Documenti"
    GetApplicationSubPath "OleDoc"
    GetApplicationSubPath "Report"
    File_Kill GetApplicationSubPath("Tmp") & "\*.*", False
    Err.Clear
    
    Exit Function
Gest_Err: 'On Error GoTo gest_err
    Setting_Path = Err.Description & vbCrLf & "Il programma non può girare. Contatta il sistemista"
    MsgBox Setting_Path, vbCritical, "Errore"
    Err.Clear
End Function


Public Function GetDBFileIni() As String
        GetDBFileIni = GetApplicationPath & "\" & DB_INIFILENAME
End Function


Public Function Setting_DB() As String

Setting_DB = "Lettura : impostazioni di FONT"
    Dim sIni
    sIni = GetDBFileIni
    
    gintMargineCaselle = CLng(GetValoreFromIni("FONT", "MargineCaselle", 20, sIni))
    WritePrivateProfileString "FONT", "MargineCaselle", CStr(gintMargineCaselle), sIni
    
    gintMargineForm = CLng(GetValoreFromIni("FONT", "MargineForm", 600, sIni))
    WritePrivateProfileString "FONT", "MargineForm", CStr(gintMargineForm), sIni

    gintFclChiaro = CLng(GetValoreFromIni("FONT", "FclChiaro", 52479, sIni))
    WritePrivateProfileString "FONT", "FclChiaro", CStr(gintFclChiaro), sIni
    
    gintFclScuro = CLng(GetValoreFromIni("FONT", "FclScuro", 41727, sIni))
    WritePrivateProfileString "FONT", "FclScuro", CStr(gintFclScuro), sIni
    
    gintFclBCK = CLng(GetValoreFromIni("FONT", "FclBCK", 10580563, sIni))
    WritePrivateProfileString "FONT", "FclBCK", CStr(gintFclBCK), sIni
    
    gintBckColorVerde = CLng(GetValoreFromIni("FONT", "BckColorVerde", 13299182, sIni))
    WritePrivateProfileString "FONT", "BckColorVerde", CStr(gintBckColorVerde), sIni
    
    gintBckColorEdit = CLng(GetValoreFromIni("FONT", "BckColorEdit", 13565950, sIni))
    WritePrivateProfileString "FONT", "BckColorEdit", CStr(gintBckColorEdit), sIni
    
    gintBckColorForms = CLng(GetValoreFromIni("FONT", "BckColorForms", 13299182, sIni))
    WritePrivateProfileString "FONT", "BckColorForms", CStr(gintBckColorForms), sIni
    
    gintForeColorSelezionato = CLng(GetValoreFromIni("FONT", "ForeColorSelezionato", 16711680, sIni))
    WritePrivateProfileString "FONT", "ForeColorSelezionato", CStr(gintForeColorSelezionato), sIni
    

Setting_DB = "Lettura : impostazioni di programma"
    gstrPrgSincronia = GetValoreFromIni("PRG", "PRG_SINCRONIA", "NO", sIni)
    WritePrivateProfileString "PRG", "PRG_SINCRONIA", gstrPrgSincronia, sIni

    gintMultiDBLevel = CInt(GetValoreFromIni("PRG", "MULTI_DB_LEVEL", 9, sIni))
    WritePrivateProfileString "OPZIONI", "MULTI_DB_LEVEL", CStr(gintMultiDBLevel), sIni
    
    gstrStartForm = GetValoreFromIni("DB", "START_FORM", "main_Home", sIni)
    WritePrivateProfileString "DB", "START_FORM", gstrStartForm, sIni

    gstrPathAusiliari = GetValoreFromIni("DB", "DBO_PATH", "Nessun Path", sIni)
    WritePrivateProfileString "DB", "DBO_PATH", gstrPathAusiliari, sIni


End Function

Public Function GetDBTabStart() As String
    Dim sIni
    sIni = GetDBFileIni

    Dim sDboTabStart0 As String, sDboTabStart1 As String, sDboTabStart2 As String, sDboTabStart3 As String

    sDboTabStart0 = GetValoreFromIni("DB", "DBO_TAB_START", "Mancano i nomi Tabella", sIni)
    WritePrivateProfileString "DB", "DBO_TAB_START", sDboTabStart0, sIni
    sDboTabStart1 = GetValoreFromIni("DB", "DBO_TAB_START1", "", sIni)
    WritePrivateProfileString "DB", "DBO_TAB_START1", sDboTabStart1, sIni
    sDboTabStart2 = GetValoreFromIni("DB", "DBO_TAB_START2", "", sIni)
    WritePrivateProfileString "DB", "DBO_TAB_START2", sDboTabStart2, sIni
    sDboTabStart3 = GetValoreFromIni("DB", "DBO_TAB_START3", "", sIni)
    WritePrivateProfileString "DB", "DBO_TAB_START3", sDboTabStart3, sIni
    
    GetDBTabStart = Trim(sDboTabStart0 & sDboTabStart1 & sDboTabStart2 & sDboTabStart3)

End Function





Public Function GetDBPredefinito() As myCnn
    Dim sIni, sPath
    sIni = GetDBFileIni
    
    GetDBPredefinito.Source = "Nessuno"
    GetDBPredefinito.Type = ""
    GetDBPredefinito.Path = ""
    
    Dim s1, s2, s3, s4
    s1 = Trim(GetValoreFromIni("DB", "DBPredefinito", "Nessuno", sIni))
    WritePrivateProfileString "DB", "DBPredefinito", CStr(s1), sIni
    If s1 = "Nessuno" Or s1 = "" Then Exit Function
    
    
    GetDBPredefinito.Type = GetValoreFromIni("DB", "DBTipo", "Microsoft Access", sIni)
    WritePrivateProfileString "DB", "DBTipo", GetDBPredefinito.Type, sIni
    
    If GetDBPredefinito.Type = "Microsoft Access" Then
        sPath = GetApplicationSubPath("DB")
        s2 = GetFilePath(s1)
        If s2 = "" Then
            GetDBPredefinito.Source = sPath & "\" & s1
            GetDBPredefinito.Path = sPath
        Else
            'caso di path assoluto!!!!!
            GetDBPredefinito.Source = s1
            GetDBPredefinito.Path = s2
        End If
    Else
        GetDBPredefinito.Type = "ODBC"
        GetDBPredefinito.Source = s1
    End If

End Function
