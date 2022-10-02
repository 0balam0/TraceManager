Attribute VB_Name = "SDS_DB_Formule"
'<DATA> 110526
Option Compare Text

Global Const OPEN_FILE = 1 '.....110324..dpe
Global Const LIST_STATUS = "LIST:Test;Uff;Kill" '.....110324..dpe
Global Const LIST_LINK_VHC = "eng|mot|pqm|trs|gbr|axr|trb"


Option Explicit
Dim Trasmissione As String, Grappolatura As String, Motore As String, Applicazione As String, Pneumatico As String, Progetto As String
Dim r1, r2, r3, r4, r5, r6, r7, rp, NMarce, TipoCambio, VersioneCambio, FamigliaCambio, MarchioCambio, Trazione
Dim FamigliaMotore, MarchioMotore, Combustibile, Cilindrata, IniezioneMotore
Dim AspirazioneMotore, NumValvole, Cilindri, PotenzaMax, PotenzaUM, CoppiaMax, Emissioni, TecnologiaMotore, VersioneMotore
Dim Marchio, Veicolo, Carrozzeria, VersioneApplicazione, VersioneProgetto
Dim Taglia, VersionePneumatico, Sviluppo
Dim Status

'.....110526..dpe
Public Function NomeVersione(sVersione) As String
On Error Resume Next
    Dim s, sSubst, sPurge As String
    Dim j, ilenpu
    
''''    sSubst = "_"
    sSubst = " "
    sPurge = "!?@#$%^&*|[]{}'`/\<>,:;-()+" & Chr(34)
    
    NomeVersione = ""
    s = sVersione
    
    ilenpu = Len(sPurge)
    For j = 1 To ilenpu
        s = Replace(s, Mid(sPurge, j, 1), sSubst)
    Next j
    s = Replace(s, "uff", " ")
    s = Replace(s, "test", " ")
    s = string_ReplaceSpace(s)
    NomeVersione = s
Err.Clear
End Function
'.....110526..dpe
Public Sub NomeRidotto(sFileNew, Optional sNew = "", Optional sNewRid = "", Optional sNewEst = "", Optional sNewStatus = "", Optional sNewRidNoVers = "")
On Error GoTo Gest_Err
    Dim ivers
    sFileNew = NullToString(sFileNew)
    If sFileNew = "" Then Exit Sub
    sNew = Trim(GetFileNameNoExt(sFileNew, False))
    sNewEst = Trim(GetFileExtension(sFileNew))
    
    If InStr(1, sNew, "(uff)") > 0 Then
        sNewStatus = "(uff)"
        sNewRid = Trim(Replace(sNew, "(uff)", ""))
    ElseIf InStr(1, sNew, "(kill)") > 0 Then
        sNewStatus = "(kill)"
        sNewRid = Trim(Replace(sNew, "(kill)", ""))
    Else
        sNewStatus = "(Test)"
        sNewRid = Trim(Replace(sNew, "(Test)", ""))
    End If
    'toglie la versione
    sNewRidNoVers = sNewRid
    ivers = InStrRev(sNewRidNoVers, " - ")
    If ivers > 0 Then
        sNewRidNoVers = Trim(Left(sNewRidNoVers, ivers - 1))
    End If


    Exit Sub
Gest_Err:
    Debug.Print "Errore in", "NomeRidotto"
    Err.Clear
    Resume Next
End Sub
'.....110526..dpe
Public Function NomeVhcAnagr(sNomeEng, sNomeTrs, sNomeGbr, sNomeAxr, Optional SEP = " + ")
    
    Dim sv1, sv2, sv3, sv4, svtrs
    NomeRidotto sNomeEng, , , , , sv1
    NomeRidotto sNomeTrs, , , , , sv2
    NomeRidotto sNomeGbr, , , , , sv3
    NomeRidotto sNomeAxr, , , , , sv4
    
    If sv3 <> "" Then
        svtrs = sv3
        If sv4 <> "" Then svtrs = svtrs & SEP & sv4
    Else
        svtrs = sv2
    End If
    NomeVhcAnagr = svtrs
    If sv1 <> "" Then NomeVhcAnagr = sv1 & SEP & svtrs
    If NomeVhcAnagr = SEP Then NomeVhcAnagr = ""
    
End Function

'.....110518..rgr
Public Function WorkBookNames_ListParametri()

Dim sSheet, s, s1, s2, s3, i, sH, iDx, iDy
Dim mEdtSheet As myEdtSheet
Dim mDatSheet As myDatSheet

    Dim ir, ic, upR, lwR, upC, lwC, iIndex

    
    Dim ws As Worksheet
    
    WorkBookNames_ListParametri = ""
    s = "Tabella" & vbTab & "ControlSource" & vbTab & "Obbligatorio" & vbTab & "CaptionGroup" & vbTab & "Caption" & vbTab & "UnM" & vbTab & "BackColor" & vbTab & "RowSource" & vbTab & "IDNomeFile" & vbTab & "Index"
    For Each ws In Worksheets
        sSheet = ws.Name
        iDx = 0
            If Left(sSheet, 3) = "Dat" Then
                mDatSheet = GetDat(sSheet)
                For ir = mDatSheet.RStart To mDatSheet.REnd
                    If mDatSheet.RStart > 0 And mDatSheet.REnd > 0 Then
                        s2 = WorkBookNames_ListParametriRow(sSheet, ir, iIndex)
                        If s2 = "" Then
                            Debug.Print sSheet, ir
                        Else
                            iDx = iDx + iIndex
                            If iIndex = 1 Then
                                iDy = iDx
                            Else
                                iDy = 0
                            End If
                            s2 = s2 & vbTab & CInt(iDy)
                            s = s & vbCrLf & s2
                        End If
                    Else
                        s = s & vbCrLf & sSheet & vbTab & "rstart / rend mal definite"
                    End If
                Next ir
            ElseIf Left(sSheet, 3) = "Edt" Then
                mEdtSheet = GetEdt(sSheet)
                For ir = mEdtSheet.RStart To mEdtSheet.REnd
                    If mEdtSheet.RStart > 0 And mEdtSheet.REnd > 0 Then
                        s2 = WorkBookNames_ListParametriRow(sSheet, ir, iIndex)
                        If s2 = "" Then
                            Debug.Print sSheet, ir
                        Else
                            iDx = iDx + iIndex
                            If iIndex = 1 Then
                                iDy = iDx
                            Else
                                iDy = 0
                            End If
                            s2 = s2 & vbTab & CInt(iDy)
                            s = s & vbCrLf & s2
                        End If
                    Else
                        s = s & vbCrLf & sSheet & vbTab & "rstart / rend mal definite"
                    End If
                Next ir
                
            Else
            
            End If

    Next ws

    WorkBookNames_ListParametri = s

    s2 = GetFileNameNoExt(ActiveWorkbook.Name, False)
    s1 = s2 & ".par"
    String_ToFile GetApplicationPath & "\" & s1, WorkBookNames_ListParametri

End Function

'.....110506..rgr
Public Function GetVersione(sVersione) As String
On Error Resume Next
    Dim s As String
    
    s = NomeVersione(sVersione)
''''    s = sVersione
''''    s = Replace(s, "-", " ")
''''    s = Replace(s, "(", " ")
''''    s = Replace(s, ")", " ")
''''    s = Replace(s, "uff", " ")
''''    s = Replace(s, "test", " ")
''''    s = string_ReplaceSpace(s)
    
    
    Select Case s
    Case ""
        GetVersione = ""
''''    Case "-"
''''        GetVersione = "-" ' caso dei file mss vecchi
    Case Else
        GetVersione = "- " & s
    End Select
    
Err.Clear
End Function


'.....110419..dpe
Public Sub FieldsUpdate_SheetRST(Optional sSheet, Optional sTable, Optional sNomeFile)
Dim s, s1, s2, s3, s4

    If isExcel = True Then
        Select Case sSheet
        Case "EdtTrs", "EdtGbr"
            NomeGrappolatura_FromSheet sSheet
        Case "EdtVhc"
            NomeVhcTraction_FromSheet sSheet
            NomeVhcStatus_FromSheet sSheet
            NomeVhcTBD_FromSheet sSheet
            MemoVhcAnagr sSheet
            NomeVhcAnagr_FromSheet sSheet
        Case Else
        End Select
    Else
        Select Case sTable
        Case "T_CmpTrs", "T_CmpGbr"
            NomeGrappolatura_FromRst sTable, sNomeFile
        Case "T_CmpVhc"
            NomeVhcTraction_FromRST sTable, sNomeFile
            NomeVhcStatus_FromRST sTable, sNomeFile
            NomeVhcTBD_FromRST sTable, sNomeFile
            NomeVhcAnagr_FromRST sTable, sNomeFile
        Case Else

        End Select
    End If

End Sub
'.....110419..dpe
Public Function NomeVhcStatus_FromSheet(sSheet)
    On Error Resume Next
    Dim sStatus, sString
    sStatus = Range(sSheet & "_" & "vhc_Status").Value

    Dim sTmpArr, i, uB
    sTmpArr = Split(LIST_LINK_VHC, "|")
    uB = UBound(sTmpArr)
    NomeVhcStatus_FromSheet = sStatus
    For i = 0 To uB
        NomeRidotto Range(sSheet & "_" & sTmpArr(i) & "_file").Value, , , , sStatus
        If UCase(sStatus) = "(TEST)" Or UCase(sStatus) = "(KILL)" Then
            NomeVhcStatus_FromSheet = "Test"
        End If
    Next i
    Range(sSheet & "_" & "vhc_Status").Value = NomeVhcStatus_FromSheet

    Err.Clear
End Function
'.....110419..dpe
Public Function NomeFileTBD(sValue)
    sValue = NullToString(sValue)
    NomeFileTBD = sValue
    If Trim(sValue) = "" Then NomeFileTBD = "TBD"
End Function

'.....110419..dpe
Public Sub NomeVhcTBD_FromRST(sTabella, sNomeFile)
'funzione commentata perchè non si può assegnare il TBD per problemi di integrità referenziale

''''    Dim vTrs, vGbr, vAxr
''''    Const sNull = ""
''''    Const sTBD = "TBD"
''''
''''    Dim s, s1, s2, s3, i, vz(1 To 7)
''''    Dim iR, iC, upR, lwR, upC, lwC
''''
''''    If sTabella = "" Then
''''        Exit Sub
''''    End If
''''    If sNomeFile = "" Then
''''        Exit Sub
''''    End If
''''
''''    Dim myTabella As myStrutturaTabella
''''    myTabella = GetStrutturaTabella(, sTabella)
''''
''''    Dim Cnn As New ADODB.Connection
''''    Dim rstDati As ADODB.Recordset
''''    Dim strCnn As String
''''    Dim strSQL As String
''''
''''    Set Cnn = Application.CurrentProject.Connection
''''    Set rstDati = New ADODB.Recordset
''''    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
''''    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic
''''
''''    If rstDati.RecordCount > 0 Then
''''        rstDati("eng_file").Value = NomeFileTBD(rstDati("eng_file").Value)
''''        rstDati("mot_file").Value = NomeFileTBD(rstDati("mot_file").Value)
''''        rstDati("pqm_file").Value = NomeFileTBD(rstDati("pqm_file").Value)
''''        rstDati("tyr_file").Value = NomeFileTBD(rstDati("tyr_file").Value)
''''
''''        vTrs = NullToString(rstDati("trs_File").Value)
''''        vGbr = NullToString(rstDati("gbr_File").Value)
''''        vAxr = NullToString(rstDati("axr_File").Value)
''''
''''        NomeTrasmissioneTBD vTrs, vGbr, vAxr
''''
''''        rstDati("gbr_File").Value = vGbr
''''        rstDati("axr_File").Value = vAxr
''''    Else
''''        rstDati.Close
''''        Cnn.Close
''''        Set Cnn = Nothing
''''        Exit Sub
''''    End If
''''    On Error Resume Next
''''    rstDati.Update
''''    Debug.Print Err.Description
''''    rstDati.Close
''''    Cnn.Close
''''    Set Cnn = Nothing
''''    Exit Sub

    
End Sub


'.....110419..dpe
Public Function NomeVhcTraction_FromRST(sTabella, sNomeFile)
    On Error Resume Next
    
    
    Dim s, s1, s2, s3, sTmpArr, i, uB, sStatus
    Dim ir, ic, upR, lwR, upC, lwC
    
    NomeVhcTraction_FromRST = ""

    If sTabella = "" Then
        Exit Function
    End If
    If sNomeFile = "" Then
        Exit Function
    End If

    Dim myTabella As myStrutturaTabella
    myTabella = GetStrutturaTabella(, sTabella)

    Dim Cnn As New ADODB.Connection
    Dim rstDati As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String

    Set Cnn = Application.CurrentProject.Connection
    Set rstDati = New ADODB.Recordset
    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

    Dim sTrs, sGbr, sTrb, sTrac, iTract


    If rstDati.RecordCount > 0 Then
        sTrs = Trim(rstDati("trs_file").Value)
        sGbr = Trim(rstDati("gbr_file").Value)
        sTrb = Trim(rstDati("trb_file").Value)
        sTrac = rstDati("vhc_Traction").Value

        NomeVhcTraction_FromRST = NomeVhcTraction(sTrs, sGbr, sTrb, sTrac)

    Else
        rstDati.Close
        Cnn.Close
        Set Cnn = Nothing
        Exit Function
    End If
updateRST:
    rstDati("vhc_Traction").Value = NomeVhcTraction_FromRST
    rstDati.Update
    rstDati.Close
    Cnn.Close
    Set Cnn = Nothing
    Exit Function

End Function

Public Function NomeVhcTraction(sTrs, sGbr, sTrb, sTrac)
    On Error Resume Next
    
    
    Dim s, s1, s2, s3, sTmpArr, i, uB, iTract
    Dim ir, ic, upR, lwR, upC, lwC
    
    NomeVhcTraction = ""

    iTract = InStr(sTrs, "WD")
    If iTract > 0 Then
        If InStr("ARF", Mid(sTrs, iTract - 1, 1)) > 0 Then
            NomeVhcTraction = Mid(sTrs, iTract - 1, 3)
        End If
    Else
        If sTrb <> "" Then
            NomeVhcTraction = "AWD"
        ElseIf IsNomeFileTBD(sGbr) Then
            NomeVhcTraction = "RWD"
        Else
            NomeVhcTraction = sTrac
        End If
    End If

End Function


'.....110419..dpe
Public Function NomeVhcStatus_FromRST(sTabella, sNomeFile)

    Dim s, s1, s2, s3, sTmpArr, i, uB, sStatus
    Dim ir, ic, upR, lwR, upC, lwC
    
    NomeVhcStatus_FromRST = ""

    If sTabella = "" Then
        Exit Function
    End If
    If sNomeFile = "" Then
        Exit Function
    End If

    Dim myTabella As myStrutturaTabella
    myTabella = GetStrutturaTabella(, sTabella)

    Dim Cnn As New ADODB.Connection
    Dim rstDati As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String

    Set Cnn = Application.CurrentProject.Connection
    Set rstDati = New ADODB.Recordset
    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

    If rstDati.RecordCount > 0 Then
        sStatus = rstDati("vhc_Status").Value
        sTmpArr = Split(LIST_LINK_VHC, "|")
        uB = UBound(sTmpArr)
        NomeVhcStatus_FromRST = sStatus
        For i = 0 To uB
            s1 = sTmpArr(i) & "_file"
            s = rstDati(s1).Value
            NomeRidotto s, , , , sStatus
            If UCase(sStatus) = "(TEST)" Or UCase(sStatus) = "(KILL)" Then
                NomeVhcStatus_FromRST = "Test"
                GoTo updateRST
            End If
        Next i
    Else
        rstDati.Close
        Cnn.Close
        Set Cnn = Nothing
        Exit Function
    End If
updateRST:
    rstDati("vhc_Status").Value = NomeVhcStatus_FromRST
    rstDati.Update
    rstDati.Close
    Cnn.Close
    Set Cnn = Nothing
    Exit Function

    
End Function



'.....110419..dpe
Public Sub FullName_ToRst(sTabella, sNomeFile, Optional sNomeOut = "", Optional sNomeRidOut = "", Optional bShowMsg As Boolean = False, Optional bUpdate As Boolean = True)
On Error Resume Next
    'controlla nome
    Dim nRec, s, s1
    
    Dim sMsg

    Dim sFileNew, sNew, sNewRid, sNewEst, sNewStatus
    Dim sFileOld, sOld, sOldRid, sOldEst, sOldStatus
    Dim myStrutturaTab As myStrutturaTabella
    myStrutturaTab = GetStrutturaTabella(, sTabella)

    sNomeOut = ""
    sNomeRidOut = ""
    
    sOld = Trim("" & sNomeFile)
    If sOld = "" Then Exit Sub
    sFileOld = sOld & "." & myStrutturaTab.Estensione
    NomeRidotto sFileOld, sOld, sOldRid, sOldEst, sOldStatus
    
    On Error GoTo GestErr
    sNew = FullName_FromRST(myStrutturaTab.Tabella, sOld)
    If sNew = "" Then Exit Sub
    
    sFileNew = sNew & "." & myStrutturaTab.Estensione
    NomeRidotto sFileNew, sNew, sNewRid, sNewEst, sNewStatus
    
    If sNewRid = sOldRid Then
''''        MsgBox "sovrascrivi"
        
    Else
''''        MsgBox "controlla rec"
        nRec = Rec_GetNum(myStrutturaTab.Tabella, "Nome", sNewRid)
        If nRec > 0 Then
            If bShowMsg = True Then
                'èun nuovo record che si sovrappone ad uno esistente
                sMsg = "Il file " & vbCrLf & sNew & vbCrLf & "esiste già: cambia la versione!"
                MsgBox sMsg, vbCritical, "Controllo record"
            End If
            Exit Sub
        Else
        
        End If
    End If
    
''''    sNew = UCase(sNew)
''''    sNewRid = UCase(sNewRid)
    
    If sNew <> sOld Then
        If bUpdate = True Then
            Rec_UPDate myStrutturaTab.Tabella, myStrutturaTab.CampoFile, sOld, "Nome", sNewRid
            Rec_UPDate myStrutturaTab.Tabella, myStrutturaTab.CampoFile, sOld, myStrutturaTab.CampoFile, sNew
        End If
    Else
        'il rec ha gli stessi nomi: no action
    End If

    sNomeOut = sNew
    sNomeRidOut = sNewRid
    

    Exit Sub
GestErr:
    MsgBox Err.Description
    Resume Next
End Sub

'.....110417..dpe
Public Sub FullName_ToSheetRST(Optional sSheet, Optional sTable, Optional sNomeFile)
Dim s, s1, s2, s3, s4
'update di tutto PerFECTS

    If isExcel = True Then
        FullName_ToSheet sSheet
    Else
        FullName_ToRst sTable, sNomeFile, , , True
    End If

End Sub






'.....110415..rgr
Public Function NomeVhcTraction_FromSheet(sSheet)
    On Error Resume Next
    Dim sTrs, sGbr, sTrb, sTrac, iTract, s
    sTrs = Trim(Range(sSheet & "_" & "trs_file").Value)
    sGbr = Trim(Range(sSheet & "_" & "gbr_file").Value)
    sTrb = Trim(Range(sSheet & "_" & "trb_file").Value)
    sTrac = Range(sSheet & "_" & "vhc_Traction").Value
    
    NomeVhcTraction_FromSheet = NomeVhcTraction(sTrs, sGbr, sTrb, sTrac)
    Range(sSheet & "_" & "vhc_Traction").Value = NomeVhcTraction_FromSheet
    
    Err.Clear
End Function


'.....110415..rgr
Public Sub NomeVhcTBD_FromSheet(sSheet)
    Dim vTrs, vGbr, vAxr
    Const sNull = ""
    Const sTBD = "TBD"

    Range(sSheet & "_" & "eng_file").Value = NomeFileTBD(Range(sSheet & "_" & "eng_file").Value)
    Range(sSheet & "_" & "mot_file").Value = NomeFileTBD(Range(sSheet & "_" & "mot_file").Value)
    Range(sSheet & "_" & "pqm_file").Value = NomeFileTBD(Range(sSheet & "_" & "pqm_file").Value)
    Range(sSheet & "_" & "tyr_file").Value = NomeFileTBD(Range(sSheet & "_" & "tyr_file").Value)

    vTrs = NullToString(Range(sSheet & "_" & "trs_File").Value)
    vGbr = NullToString(Range(sSheet & "_" & "gbr_File").Value)
    vAxr = NullToString(Range(sSheet & "_" & "axr_File").Value)

    NomeTrasmissioneTBD vTrs, vGbr, vAxr

    Range(sSheet & "_" & "gbr_File").Value = vGbr
    Range(sSheet & "_" & "axr_File").Value = vAxr
    
End Sub
'.....110415..rgr
Public Sub NomeTrasmissioneTBD(vTrs, vGbr, vAxr)
    Dim vTrs1, vGbr1, vAxr1
    Const sNull = ""
    Const sTBD = "TBD"

    
    vTrs1 = vTrs
    vGbr1 = NomeFileTBD(vGbr)
    vAxr1 = NomeFileTBD(vAxr)

    If IsNomeFileTBD(vGbr) = False And IsNomeFileTBD(vAxr) = False Then
        If IsNomeFileTBD(vTrs) = True Then
            vGbr1 = sNull
            vAxr1 = sNull
        Else
            vGbr1 = sTBD
            vAxr1 = sTBD
        End If
    End If
    vTrs = vTrs1
    vGbr = vGbr1
    vAxr = vAxr1
    
End Sub

'.....110415..rgr
Public Function IsNomeFileTBD(sValue) As Boolean
    IsNomeFileTBD = False
    If Trim(sValue) <> "" And Trim(sValue) <> "TBD" Then IsNomeFileTBD = True
End Function



'.....110415..dpe
Public Sub MemoVhcAnagr(sSheet)
    On Error Resume Next
    Dim sString, sString2
    sString2 = "Vhcanagr"
    sString = "eng|mot|pqm|trs|gbr|axr"
    GetNomiAnagr sSheet, sString, sString2
    Err.Clear
End Sub
'.....110415..dpe
Public Function NomeVhcAnagr_FromSheet(sSheet)
    NomeVhcAnagr_FromSheet = NomeVhcAnagr( _
            Range(sSheet & "_" & "eng_file").Value, _
            Range(sSheet & "_" & "trs_file").Value, _
            Range(sSheet & "_" & "gbr_file").Value, _
            Range(sSheet & "_" & "axr_file").Value)
    Range(sSheet & "_" & "vhc_Anagr").Value = NomeVhcAnagr_FromSheet
End Function










'.....110413..dpe
Public Function NomeVhcAnagr_FromRST(sTable, sNomeFile)
Dim sNomeEng, sNomeTrs, sNomeGbr, sNomeAxr
    NomeVhcAnagr_FromRST = ""
    If sTable = "" Then
        Exit Function
    End If
    If sNomeFile = "" Then
        Exit Function
    End If
    If sTable <> "T_CmpVhc" Then
        Exit Function
    End If
    
    Dim myTabella As myStrutturaTabella
    myTabella = GetStrutturaTabella(, sTable)

    Dim Cnn As New ADODB.Connection
    Dim rstDati As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String
    
    Set Cnn = Application.CurrentProject.Connection
    Set rstDati = New ADODB.Recordset
    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic
    
    sNomeEng = rstDati("eng_File").Value
    sNomeTrs = rstDati("trs_File").Value
    sNomeGbr = rstDati("gbr_File").Value
    sNomeAxr = rstDati("axr_File").Value
    
    NomeVhcAnagr_FromRST = NomeVhcAnagr(sNomeEng, sNomeTrs, sNomeGbr, sNomeAxr)
    
    rstDati("vhc_Anagr").Value = NomeVhcAnagr_FromRST
    rstDati.Update
    rstDati.Close
    Cnn.Close
    Set Cnn = Nothing

End Function

'.....110413..dpe
Public Function NomeGrappolatura_FromRst(sTable, sNomeFile)
    Dim s, s1, s2, s3, i, vz(1 To 7)
    Dim ir, ic, upR, lwR, upC, lwC

    If sTable = "" Then
        Exit Function
    End If
    If sNomeFile = "" Then
        Exit Function
    End If
        
    Dim myTabella As myStrutturaTabella
    myTabella = GetStrutturaTabella(, sTable)

    Dim Cnn As New ADODB.Connection
    Dim rstDati As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String
    
    Set Cnn = Application.CurrentProject.Connection
    Set rstDati = New ADODB.Recordset
    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

'    Debug.Print rstDati.RecordCount
    If rstDati.RecordCount > 0 Then
        For i = 1 To 7
            s = myTabella.prefix & "_zm" & CStr(i)
            vz(i) = rstDati(s).Value
        Next i
    Else
        rstDati.Close
        Cnn.Close
        Set Cnn = Nothing
        Exit Function
    End If
    
    NomeGrappolatura_FromRst = NomeGrappolatura(vz)
    s = myTabella.prefix & "_Grappolatura"
    rstDati(s).Value = NomeGrappolatura_FromRst
    rstDati.Update
    rstDati.Close
    Cnn.Close
    Set Cnn = Nothing

End Function

'.....110407..rgr
Public Function NomeVhcStatusSet(sSheet, sString, sStatus)
    On Error Resume Next
    Dim sTmpArr, i, uB
    sTmpArr = Split(sString, "|")
    uB = UBound(sTmpArr)
    NomeVhcStatusSet = sStatus
    For i = 0 To uB
        NomeRidotto Range(sSheet & "_" & sTmpArr(i) & "_file").Value, , , , sStatus
        If InStr(UCase(sStatus), "TEST") > 0 Then
            NomeVhcStatusSet = "Test"
            Exit Function
        End If
    Next i
    Err.Clear
End Function
'.....110407..rgr
Public Sub GetNomiAnagr(sSheet, sStringFile, sStringAnagr)
    On Error Resume Next
    Dim sTmpArrFile, i, uB, rw, cl, v
    sTmpArrFile = Split(sStringFile, "|")
    uB = UBound(sTmpArrFile)
    ReDim sTmpArrAnagr(0 To uB)
    For i = 0 To uB
        NomeAnagr sSheet & "_" & sStringAnagr & "_" & sTmpArrFile(i), sSheet & "_" & sTmpArrFile(i) & "_File", True
    Next i
    Err.Clear
End Sub

'.....110407..rgr
Public Sub NomeAnagr(sVarAnagr, sVarFile, Optional wEtichetta = False)
    Dim rw, cl, v
    Range(sVarAnagr).Value = IIf(Range(sVarFile).Value = "TBD", "", Range(sVarFile).Value)
    If wEtichetta Then
        v = RangeG(sVarAnagr, rw, cl)
        If v <> "" Then
            Cells(rw, cl - 1).Value = Right(sVarAnagr, 3) & " "
        Else
            Cells(rw, cl - 1).Value = ""
        End If
    End If
End Sub



'.....110405..rgr
Public Function PRF_Status(sSheet)
    On Error Resume Next
    Dim sName
    sName = Right(sSheet, Len(sSheet) - 3)
    PRF_Status = Range(sSheet & "_" & sName & "_Status").Value
    Err.Clear
End Function

'.....110328..dpe
Public Sub FullName_ToSheet(sMySheet)
Dim sSheet, sFile
    sSheet = sMySheet & "_" & Right(sMySheet, Len(sMySheet) - 3)
    Range(sSheet & "_Versione").Value = NomeVersione(RangeG(sSheet & "_Versione"))
    sFile = FullName_FromSheet(sMySheet) '110316 rgr
    Range(sMySheet & "_" & "sh_NomeFile").Value = sFile
    Range(sSheet & "_File").Value = sFile
End Sub
'.....110328..dpe
Public Function NomeGrappolatura_FromSheet(sSheet)
Dim s, i, vz(1 To 7)
    s = sSheet & "_" & Right(sSheet, Len(sSheet) - 3)
    For i = 1 To 7
        vz(i) = Range(s & "_zm" & CStr(i)).Value
    Next i

    NomeGrappolatura_FromSheet = NomeGrappolatura(vz)
    Range(s & "_Grappolatura").Value = NomeGrappolatura_FromSheet
    
End Function
'.....110328..dpe
Public Function NomeGrappolatura(r())
    Dim num, tronc, prefix, i

    NomeGrappolatura = ""
    For i = 1 To 7
        r(i) = NullToNum(r(i))
    Next i

    r(1) = CDbl(CStr(Left(r(1), 3)))

    If r(5) = 0 Then r(5) = 1
    If r(6) = 0 Then r(6) = 1
    If r(7) = 0 Then r(7) = 1
    num = r(1) * r(2) * r(3) * r(4) * r(5) * r(6) * r(7)

    If num > 100 Then
        tronc = 5
    Else
        tronc = 4
    End If
    NomeGrappolatura = Left(CStr(num), tronc)
    NomeGrappolatura = Trim(string_ReplaceSpace(NomeGrappolatura))

End Function
'.....110325..dpe
Public Function WorkBookNames_ListParametriRow(sSheet, iRow, iIndex)
On Error Resume Next
    WorkBookNames_ListParametriRow = ""
    Dim sPar, sObbl, sEtich, sEtich1, sColor, sFormula1, sUnMi, sH, sIDNomeFile

    Dim s1, s2, s3, s4, sF, sC
    sH = Right(sSheet, Len(sSheet) - 3)
    
    If sSheet = "EdtEng" Then
        s1 = ""
    End If
    
    
    If Left(sSheet, 3) = "Dat" Then
        Dim mDatSheet As myDatSheet
        mDatSheet = GetDat(sSheet)
        sH = "T_Map" & sH
        With Worksheets(sSheet)
            sPar = .Cells(iRow, mDatSheet.CParametro).Value
            sObbl = .Cells(iRow, mDatSheet.CObbligatorio).Value
            sEtich = Trim(.Cells(iRow, mDatSheet.CEtichette).Value)
            sEtich1 = Trim(.Cells(iRow, mDatSheet.CEtichette - 1).Value)
            sUnMi = .Cells(iRow, mDatSheet.CEtichette + 1).Value
            sColor = CStr(.Cells(iRow, mDatSheet.CValore).Interior.ColorIndex)
            sIDNomeFile = CStr(.Cells(iRow, mDatSheet.CIDNomeFile).Value)
            sFormula1 = .Range(.Cells(iRow, mDatSheet.CValore), .Cells(iRow, mDatSheet.CValore)).Validation.Formula1
        End With
        Err.Clear
    ElseIf Left(sSheet, 3) = "Edt" Then
        Dim mEdtSheet As myEdtSheet
        mEdtSheet = GetEdt(sSheet)
        sH = "T_Cmp" & sH
        With Worksheets(sSheet)
            sPar = .Cells(iRow, mEdtSheet.CParametro).Value
            sObbl = .Cells(iRow, mEdtSheet.CObbligatorio).Value
            sEtich = .Cells(iRow, mEdtSheet.CEtichette).Value
            sEtich1 = Trim(.Cells(iRow, mEdtSheet.CEtichette - 1).Value)
            sUnMi = .Cells(iRow, mEdtSheet.CEtichette + 1).Value
            sColor = CStr(.Cells(iRow, mEdtSheet.CValore).Interior.ColorIndex)
            sIDNomeFile = CStr(.Cells(iRow, mEdtSheet.CIDNomeFile).Value)
            sFormula1 = .Range(.Cells(iRow, mEdtSheet.CValore), .Cells(iRow, mEdtSheet.CValore)).Validation.Formula1
        End With
        Err.Clear
    Else
        Exit Function
    End If

    sEtich = Trim(Replace(sEtich, vbCrLf, " "))
    sEtich = Trim(Replace(sEtich, vbLf, " "))
    
    sUnMi = Trim(Replace(sUnMi, vbCrLf, " "))
    sUnMi = Trim(Replace(sUnMi, vbLf, " "))
    
    If sSheet = "EdtVhc" Then
        Debug.Print iRow, sColor
    End If
    
    If sUnMi = OPEN_FILE Then
        sUnMi = "File"
    End If
 
    
    Select Case sColor
    Case "6"
        sC = "10092543"
    Case "48"
        sC = "12632256"
    Case Else
    End Select
    
    
    If sFormula1 <> "" Then
'''''                Debug.Print sFormula1
        If Left(sFormula1, 1) = "=" Then
            s1 = Right(sFormula1, Len(sFormula1) - 1)
            sF = "QUERY:SELECT Value FROM T_File_ELE WHERE (((Technology)=""" & s1 & """)) ORDER BY Value;"
        Else
            If Right(sPar, Len("_Status")) = "_Status" Then
                sF = LIST_STATUS
            Else
                sF = "LIST:" & sFormula1
            End If
        End If
    Else
        sF = ""
    End If
    
    Dim sPrefix   '.....110322..dpe

    
    sPrefix = Right(sSheet, Len(sSheet) - 3) & "_"
    If sPar <> sPrefix & "Note" And sPar <> sPrefix & "File" And sPar <> sPrefix & "Status" And sPar <> sPrefix & "Versione" Then
        iIndex = 1
    Else
        iIndex = 0
    End If
    
    
    If Right(sPar, 4) = "NULL" Then
        WorkBookNames_ListParametriRow = ""
    Else
        WorkBookNames_ListParametriRow = sH & vbTab & sPar & vbTab & sObbl & vbTab & sEtich1 & vbTab & sEtich & vbTab & sUnMi & vbTab & sC & vbTab & sF & vbTab & sIDNomeFile
    End If
    
End Function


'.....110323..dpe
Public Function FullName(sVE, sST, sMA, vName())
Dim s, s1, s2, s3, i, sH, iDx

    Dim ir, ic, upR, lwR, upC, lwC

    Dim sFullName

    FullName = ""
''''    If sST = "" Then Exit Function '110323 rgr

    If sMA = "FPT" Then sMA = ""
    sFullName = ""
    For i = 1 To 20
        sFullName = sFullName & vName(i)
    Next i
    
    sFullName = Trim(sFullName)
''''    If sFullName = "" Then Exit Function '110323 rgr
     
'    Debug.Print sMA, sST, sVE, sFullName

    sFullName = Trim(sMA & " " & sFullName)
''''    sFullName = Replace(sFullName, "-", "_") 'da rivedere

    Dim Status
    Dim Versione
 
    Status = GetStatus(sST)
    Versione = GetVersione(sVE)

    
    sFullName = Trim(sFullName & " " & Versione)
    sFullName = Trim(string_ReplaceSpace(sFullName) & Status)

    FullName = sFullName



End Function

'.....110323..dpe
Public Sub FullName_Formula(sVal, sID, sVE, sST, sMA, vName())
    Dim s, s1, s2, s3, i, sH, iDx
    Dim iNome, sSpace, iSpace, sPos, sDx, sPrefix, sSuffix
    If sID <> "" Then
        Select Case sID
            Case "VE"
                sVE = sVal
            Case "ST"
                sST = sVal
            Case "MA"
                sMA = sVal
            Case Else
                iNome = CInt(Left(sID, 2))
                iSpace = CInt(Mid(sID, 3, 1))
                sSpace = IIf(iSpace = 1, " ", "")
                sDx = IIf(sVal <> "", Right(sID, Len(sID) - 3), "") '110315 rgr
                
                '.....110323 rgr
                sPrefix = FullName_PrefixSuffix(sDx, "<")
                sSuffix = FullName_PrefixSuffix(sDx, ">")
                vName(iNome) = sSpace & sPrefix & sVal & sSuffix
        End Select
    End If
End Sub

'.....110323..rgr
Public Function FullName_PrefixSuffix(sStr, sCh)
''''Public Function FullName_PrefixSuffix(sStr, sCh, Optional sCh2 = "")

    Dim i1, i2, sTmp
    FullName_PrefixSuffix = ""
    i1 = InStr(sStr, sCh)
    If i1 <= 0 Then Exit Function
    FullName_PrefixSuffix = Mid(sStr, i1 + 1)
    
''''    If sCh2 = "" Then
''''        FullName_PrefixSuffix = Mid(sStr, i1 + 1)
''''    Else
''''        i2 = InStr(sStr, sCh2)
''''        If i2 > 0 Then
''''            FullName_PrefixSuffix = Mid(sStr, i1 + 1, i2 - i1 - 1)
''''        Else
''''            FullName_PrefixSuffix = Mid(sStr, i1 + 1)
''''        End If
''''    End If
        
End Function


'.....110322..dpe
Public Function FullName_FromRST(sTable, sNomeFile)
    Dim s, s1, s2, s3, i, sH, iDx

    Dim ir, ic, upR, lwR, upC, lwC
    Dim iCID, iCVal, sVal, sID
    Dim sVE, sST, sMA, vName(1 To 20), iNome, sSpace, iSpace, sDx, sFullName

    FullName_FromRST = ""

    If sTable = "" Then
        Exit Function
    End If
    
    Dim myTabella As myStrutturaTabella
    myTabella = GetStrutturaTabella(, sTable)
    
    
    If sNomeFile = "" Then
        Exit Function
    End If
    
    If myTabella.Tabella = "T_CmpApp" Then
        FullName_FromRST = sNomeFile
        Exit Function
    End If
    
    
    
    Dim myEdt As myStrutturaEditor

    Dim Cnn As New ADODB.Connection
    Dim rstDati As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String
    
    Set Cnn = Application.CurrentProject.Connection
    Set rstDati = New ADODB.Recordset
    strSQL = "SELECT * FROM " & myTabella.Tabella & " WHERE ((([" & myTabella.CampoFile & "])='" & sNomeFile & "'));"
    rstDati.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

'    Debug.Print rstDati.RecordCount
    If rstDati.RecordCount > 0 Then
        For ic = 0 To rstDati.Fields.Count - 1

            myEdt = GetStrutturaEdt(myTabella.Tabella, rstDati.Fields(ic).Name)
    
            sVal = NullToString(rstDati.Fields(ic).Value)
            sID = myEdt.IDNomeFile
            FullName_Formula sVal, sID, sVE, sST, sMA, vName()
    
        Next ic

    Else
        rstDati.Close
        Cnn.Close
        Set Cnn = Nothing
        Exit Function
    End If
    
    rstDati.Close
    Cnn.Close
    Set Cnn = Nothing
    
''''    Debug.Print sMA, sST, sVE, sFullName

    sFullName = FullName(sVE, sST, sMA, vName)
    FullName_FromRST = sFullName

End Function


'.....110322..dpe
Public Function FullName_FromSheet(sSheet)
On Error Resume Next
Dim s, s1, s2, s3, i, sH, iDx
Dim mEdtSheet As myEdtSheet
Dim mDatSheet As myDatSheet
Dim nPrPos

    Dim ir, ic, upR, lwR, upC, lwC

    Dim iCID, iCVal, sVal, sID
    Dim sVE, sST, sMA, vName(1 To 20), sFullName


    FullName_FromSheet = ""
    
    If Left(sSheet, 3) = "Dat" Then
        
        mDatSheet = GetDat(sSheet)
        iCID = mDatSheet.CIDNomeFile
        iCVal = mDatSheet.CValore
        For ir = mDatSheet.RStart To mDatSheet.REnd
            If NullToString(Worksheets(sSheet).Cells(ir, iCID).Value) <> "" Then
                sVal = Worksheets(sSheet).Cells(ir, iCVal).Value
                sID = Worksheets(sSheet).Cells(ir, iCID).Value
                FullName_Formula sVal, sID, sVE, sST, sMA, vName()
            End If
            
        Next ir
            
    ElseIf Left(sSheet, 3) = "Edt" Then
        
        mEdtSheet = GetEdt(sSheet)
        iCID = mEdtSheet.CIDNomeFile
        iCVal = mEdtSheet.CValore
        For ir = mEdtSheet.RStart To mEdtSheet.REnd
            If NullToString(Worksheets(sSheet).Cells(ir, iCID).Value) <> "" Then
                sVal = Worksheets(sSheet).Cells(ir, iCVal).Value
                sID = Worksheets(sSheet).Cells(ir, iCID).Value
                FullName_Formula sVal, sID, sVE, sST, sMA, vName()
            End If
        Next ir
    
    End If

'    Debug.Print sMA, sST, sVE, sFullName

    sFullName = FullName(sVE, sST, sMA, vName)
    FullName_FromSheet = sFullName


    Err.Clear
End Function

'.....110315..dpe
Public Function GetStatus(Status) As String
On Error Resume Next
    Dim s As String
    GetStatus = ""

    Select Case Status
    Case "Uff"
        GetStatus = "  (UFF)"
    Case "TEST"
        GetStatus = " (TEST)"
    Case "Kill"
        GetStatus = " (Kill)"
    End Select

Err.Clear
End Function

'.....101026 rgr
Public Function Aggiorna_PRJLink(spath, sFileCMPNew, sFileCMPOld) As Boolean
'sFileCMPOld == sFileComponenteOLD
On Error GoTo Gest_Err
Dim prjV, i, response
Dim sPathFilePRJOld As String
Dim sPathFilePRJNew As String
Dim sFilePRJOld As String
Dim sFilePRJNew As String
Dim sCMPOld As String
Dim sCMPNew As String
Dim sCMPOldRid As String
Dim sCMPNewRid As String

Dim sParFile, sDati
Dim myMatrixFile(), rw, cl
    Aggiorna_PRJLink = False
    
    
    NomeRidotto sFileCMPOld, sCMPOld, sCMPOldRid
    NomeRidotto sFileCMPNew, sCMPNew, sCMPNewRid

    prjV = Aggiorna_ElencoPRJ(spath, sCMPOld)
    
    Debug.Print "--------- AGGIONAMENTO PRJ COLLEGATI AL COMPONENTE -----------"
    Debug.Print sCMPOld
    Debug.Print "..... controllo collegamenti ....."
    
    For i = LBound(prjV) To UBound(prjV)
        Debug.Print "    ---> applicato su    :", prjV(i)
        'rimpiazzo il riferimento interno al CMP
        sFilePRJOld = prjV(i)
        sPathFilePRJOld = spath & "\" & sFilePRJOld
        
        'trovo il parametro  "..._File" nel vhc e rimpiazzo il vecchio nome file con il nuovo
        sParFile = LCase(GetFileExtension(sPathFilePRJOld)) & "_File"
        myMatrixFile = Matrix_GetFromFile(sPathFilePRJOld)
        Matrix_FindString sParFile, myMatrixFile(), rw, cl
        If rw >= 0 And cl >= 0 Then
            If myMatrixFile(rw, cl + 1) = sCMPOld Then
                myMatrixFile(rw, cl + 1) = sCMPNew
                Matrix_PutInString myMatrixFile, sDati
                String_ToFile sPathFilePRJOld, sDati
            End If
        End If
''''        File_ReplaceString sPathFilePRJOld, sCMPOld, sCMPNew

        'rinomino il file vhc
        sFilePRJNew = Replace(sFilePRJOld, sCMPOldRid, sCMPNewRid)
        sPathFilePRJNew = spath & "\" & sFilePRJNew


        If File_exist(sPathFilePRJNew) = True Then
            Debug.Print "         !? Aggiornamento di ", sFilePRJOld, "Impossibile perchè il file aggiornato è già presente!", sFilePRJNew
            response = MsgBox("Attenzione!" & vbCrLf & "Il file " & sFilePRJNew & " è già presente!" & vbCrLf & "Sovrascrivo?", vbYesNoCancel)
            If response = vbNo Then
                Exit Function
            ElseIf response = vbYes Then
                kill sFilePRJNew
            End If
        End If
    
        Debug.Print "    >>   Aggiornato a --->", sFilePRJNew
  '      File_ReplaceString sPathFileCMPOld, sCMPOld, sCMPNew
        Name sPathFilePRJOld As sPathFilePRJNew
        Aggiorna_PRJLink = True
        Aggiorna_LNCLink spath, sFilePRJNew, sFilePRJOld
        Next i
        
    Exit Function
Gest_Err:
    Debug.Print "Errore in", "Aggiorna_PRJLink"
    Err.Clear
    Resume Next
End Function

Public Function Calcolo_Classe(PesoSTDA) As Integer
    Dim NewPeso
    
    NewPeso = PesoSTDA / 1.05 + 100
    
    Select Case NewPeso
        Case Is <= 480: Calcolo_Classe = 455
        Case Is <= 540: Calcolo_Classe = 510
        Case Is <= 595: Calcolo_Classe = 570
        Case Is <= 650: Calcolo_Classe = 625
        Case Is <= 710: Calcolo_Classe = 680
        Case Is <= 765: Calcolo_Classe = 740
        Case Is <= 850: Calcolo_Classe = 800
        Case Is <= 965: Calcolo_Classe = 910
        Case Is <= 1080: Calcolo_Classe = 1020
        Case Is <= 1190: Calcolo_Classe = 1130
        Case Is <= 1305: Calcolo_Classe = 1250
        Case Is <= 1420: Calcolo_Classe = 1360
        Case Is <= 1530: Calcolo_Classe = 1470
        Case Is <= 1640: Calcolo_Classe = 1590
        Case Is <= 1760: Calcolo_Classe = 1700
        Case Is <= 1870: Calcolo_Classe = 1810
        Case Is <= 1980: Calcolo_Classe = 1930
        Case Is <= 2100: Calcolo_Classe = 2040
        Case Is <= 2210: Calcolo_Classe = 2150
        Case Is <= 2380: Calcolo_Classe = 2270
        Case Else: Calcolo_Classe = 2270
    End Select

End Function

Public Function Aggiorna_ElencoPRJ(sDirDati, sComponente) As Variant
On Error GoTo Gest_Err
Dim prjV, i, sComponenteRid
    
    sComponenteRid = Replace(sComponente, "(UFF)", "")
    sComponenteRid = Trim(Replace(sComponenteRid, "(test)", ""))
    Aggiorna_ElencoPRJ = File_ListToArray(sDirDati, , False, "*" & sComponenteRid & "*.vhc")
    Exit Function
Gest_Err:
    Debug.Print "Errore in", "Aggiorna_ElencoPRJ"
    Err.Clear
    Resume Next
End Function





Public Function Aggiorna_ElencoLNC(sDirDati) As Variant
    Aggiorna_ElencoLNC = File_ListToArray(sDirDati, , False, "*.lnc")
End Function



Public Function Aggiorna_LNCLink(sPathFile, sFileNew, sFileOld) As Boolean
On Error GoTo Gest_Err
Dim lncV, i, response, sFileLNCOld
Dim sPathFileLNCOld As String
Dim sPathFileLNCNew As String
Dim sFileLNCNew As String
Dim IsPresente As Boolean

    Aggiorna_LNCLink = False
    lncV = Aggiorna_ElencoLNC(sPathFile)
    Debug.Print "--------- AGGIONAMENTO LNC -----------"
    Debug.Print sFileOld
    
    For i = LBound(lncV) To UBound(lncV)
         
        'rimpiazzo il riferimento interno al VHC
        sFileLNCOld = lncV(i)
        sPathFileLNCOld = sPathFile & "\" & sFileLNCOld
        File_ReplaceString sPathFileLNCOld, sFileOld, sFileNew, IsPresente
        If IsPresente = True Then
            Debug.Print "         ", lncV(i), "AGGIORNATO"
            Aggiorna_LNCLink = True
        Else
            Debug.Print "         ", lncV(i), "FILE NON PRESENTE"
        End If

    Next i

    Exit Function
Gest_Err:
    Debug.Print "Errore in", "Aggiorna_LNCLink"
    Err.Clear
    Resume Next
End Function
