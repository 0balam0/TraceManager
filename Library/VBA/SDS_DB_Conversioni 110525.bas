Attribute VB_Name = "SDS_DB_Conversioni"
'<DATA>: 110525
Option Compare Text
Option Explicit

'.....110525..rgr new
Public Sub Perfects_Versione2011()

    Dim oldDirPerf, newDirPerf, oldDirDefLocal, newDirDefLocal, oldDirDati, newDirDati, Dir_PWT_TOOLS
    Dim FnameFirst, Dname, iuff, atr
    On Error Resume Next
    
    newDirPerf = GetApplicationProjectPath
    FnameFirst = newDirPerf & "\PerFECTS0203.txt"
    
    'controlla se è stato effetuato il primo avvio di perfects
    atr = GetAttr(FnameFirst)
    If atr <> "" Then Exit Sub
    
    oldDirPerf = GetApplicationSubPathParallelo("") & "\perfects 2.3"
    
    If Dir(oldDirPerf, vbDirectory) = "" Then Exit Sub

    oldDirDati = oldDirPerf & "\Dati\"
    oldDirDefLocal = oldDirPerf & "\DefaultLocal"
    newDirDati = newDirPerf & "\Dati\"
    newDirDefLocal = newDirPerf & "\DefaultLocal"
   
'   copia i file singoli dalla dir ...\dati
    Dname = Dir(oldDirDati & "*.*", vbNormal)
    Do While Dname <> ""
        File_Copy oldDirDati & Dname, newDirDati & Dname
        Dname = Dir
    Loop
    
'   copia le sottodirectory della dir ..\dati tranne ......\ufficiali
    Dname = Dir(oldDirDati, vbDirectory)
    Do While Dname <> ""
        ' Ignora la directory corrente e quella di livello superiore.
        If Dname <> "." And Dname <> ".." Then
            ' Usa il confronto bit per bit per verificare se Dname è una directory.
            If (GetAttr(oldDirDati & Dname) And vbDirectory) = vbDirectory Then
                'Debug.Print Dname
                iuff = InStr(LCase(Dname), "ufficiali")
                If iuff <= 0 Then
                     Folder_Copy oldDirDati & Dname, newDirDati & Dname
                End If
            End If
        End If
        Dname = Dir
    Loop
    
'   copia la directory ..\DefaultLocal
     Folder_Copy oldDirDefLocal, newDirDefLocal 'se oldDirDefLocal non esiste non effettua la copia
    
    'crea un file nascosto che segnala che il primo avvio di perfects è stato effetuato
    String_ToFile FnameFirst, "File da non cancellare" & vbCrLf & "Perfects, al primo lancio ha trasferito le dir ""DATI"" e ""DefaultLocal""  dalla vecchia versione alla nuova"
    SetAttr FnameFirst, vbHidden
    Err.Clear

End Sub


'---------101028 rgr
Sub Converti_Dir2xx(Optional sDir = "", Optional TipoDir = "NewFolder")

Dim sName, sList, vList, sPathFileStart, sDirConvertita, sLogDir, sLogFile, s, s1, s2
    If sDir = "" Then
        'sDir = GetApplicationPath
        sDir = GetPath.Dati
        sDir = GetFolderName("Scelta Working Dir...", sDir)
    End If
    If sDir = "" Then Exit Sub
    

    Select Case TipoDir
    Case "NewFolder"
        sDirConvertita = sDir & "-Convertita"
        Folder_Copy sDir, sDirConvertita
    Case "SubFolder"
        sDirConvertita = sDir & "\Convertita"
        Folder_Copy sDir, sDirConvertita
    Case "Folder"
        sDirConvertita = sDir
    Case Else
        MsgBox "Valore TIPODIR : " & TipoDir & " non corretto", vbCritical
        Exit Sub
    End Select
    



    sList = File_List(sDirConvertita & "\", "|", False, "*.*")

    Dim iR, iC, upR, lwR, upC, lwC
    
    vList = Split(sList, "|")
    
    lwR = LBound(vList, 1)
    upR = UBound(vList, 1)
    Dim sMsg
    
    sMsg = "---------- Conversione --------------" & vbCrLf & sDir
    
    For iR = lwR To upR
        sPathFileStart = sDirConvertita & "\" & vList(iR)
        Converti_File2xx sPathFileStart, s1
        If NullToString(s1) <> "" Then sMsg = sMsg & vbCrLf & s1
    Next iR

    Dim sDirUp
    s = GetDirUP(sDir, 1, sDirUp)
    sLogDir = GetApplicationSubPath("Log")
    s = "Dir Convertita - " & sDirUp & ".log"
    
    sLogFile = sLogDir & "\" & s
    String_ToFile sLogFile, sMsg
    
    sLogFile = sDirConvertita & "\" & s
    String_ToFile sLogFile, sMsg
    
    
End Sub

'........101028 rgr
Sub Converti_File2xx(sPathFileStart, Optional sMsg)
On Error Resume Next
    Dim sExt, sTmp, sTesto, sFname, sFileNewName, sFileNew, sPathFileNew, spath, bIsPresente As Boolean
    Dim Trs, NewTrs, NewName, OldName
    Dim s1, s2, s3
    
    bIsPresente = False
    sFileNewName = GetFileNameNoExt(sPathFileStart, False)
    spath = GetFilePath(sPathFileStart)
    sExt = GetFileExtension(sPathFileStart)
    If InStr(UCase(sFileNewName), "(UFF)") = 0 And InStr(UCase(sFileNewName), "(TEST)") = 0 Then
        sFileNewName = Trim(sFileNewName) & "  (UFF)"
    End If
    
    Select Case LCase(sExt)
    Case "mss"

        If Left(sFileNewName, 1) = "-" Then
            sFileNewName = Right(sFileNewName, Len(sFileNewName) - 1)
'''            Debug.Print sFileNewName
            sTmp = "-  (UFF)"
            If Right(sFileNewName, Len(sTmp)) = sTmp Then
                sFileNewName = Left(sFileNewName, Len(sFileNewName) - Len(sTmp)) & "  (UFF)"
            End If
            sTmp = "- (TEST)"
            If Right(sFileNewName, Len(sTmp)) = sTmp Then
                sFileNewName = Left(sFileNewName, Len(sFileNewName) - Len(sTmp)) & " (TEST)"
            End If
        End If
    
    Case "aux"
        'ci sono tre campi con perfisso "vhc" che nella nuova struttura non ci devono essere
        File_ReplaceString sPathFileStart, "vhc_", "aux_", bIsPresente
    Case "ped"
    
    Case "gbm"
        File_ReplaceString sPathFileStart, "trs_", "gbm_", bIsPresente
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
        
    Case "pqm"
        File_ReplaceString sPathFileStart, "_OilGrade", "_OilFile", bIsPresente
        File_ReplaceString sPathFileStart, "eng_", "pqm_", bIsPresente
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
        
    
    Case "mot"
        File_ReplaceString sPathFileStart, "_OilGrade", "_OilFile", bIsPresente
        File_ReplaceString sPathFileStart, "eng_", "mot_", bIsPresente
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    
    Case "con"
        File_ReplaceString sPathFileStart, "trs_", "con_", bIsPresente
    
    Case "pn"
        File_ReplaceString sPathFileStart, "tyr_Name", "tyr_Sigla", bIsPresente
        sExt = "tyr"
        
    Case "gbx"
        File_ReplaceString sPathFileStart, "vhc_", "trs_", bIsPresente
        Trs = GetFileName(sPathFileStart)
        ConvertiNomeTRS Trs, NewTrs, NewName, OldName
        File_ReplaceString sPathFileStart, OldName, NewName, bIsPresente
        File_ReplaceString sPathFileStart, " ZP", " FDR", bIsPresente
        File_Rename sPathFileStart, spath & "\" & NewTrs, False
        sFileNewName = NewName
        sPathFileStart = spath & "\" & sFileNewName & ".gbx"
        sExt = "trs"
        
    Case "eng"
        File_ReplaceString sPathFileStart, "_OilGrade", "_OilFile", bIsPresente
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
        s1 = File_GetRow(sPathFileStart, "_OilFile")
        s2 = Split(s1, vbTab)
        NomeRidotto s2(1), , s3
        If s3 <> "" Then
            s3 = s2(0) & vbTab & "Standard " & s3 & "  (uff)"
            File_ReplaceString sPathFileStart, s1, s3, bIsPresente
        End If

    Case "prj"
        File_ReplaceString sPathFileStart, "tyr_Tr0", "vhc_Tr0", bIsPresente
        File_ReplaceString sPathFileStart, "tyr_Tr1", "vhc_Tr1", bIsPresente
        File_ReplaceString sPathFileStart, "tyr_Name", "tyr_Sigla", bIsPresente
        File_ReplaceString sPathFileStart, "vhc_Weigthdc", "vhc_Weightdc", bIsPresente
        File_ReplaceString sPathFileStart, "/", "-", bIsPresente
        File_ReplaceString sPathFileStart, "\", "-", bIsPresente
        
        File_ReplaceString sPathFileStart, ".eng", "", bIsPresente
        File_ReplaceString sPathFileStart, ".gbx", "", bIsPresente
        File_ReplaceString sPathFileStart, ".pn", "", bIsPresente
        
        
        
        s1 = File_GetRow(sPathFileStart, "trs_File")
        s2 = Split(s1, vbTab)
        If NullToString(s2(1)) <> "" Then
            Trs = s2(1) & ".trs"
            ConvertiNomeTRS Trs, NewTrs, NewName, OldName
            File_ReplaceString sPathFileStart, OldName, NewName, bIsPresente
        End If
        
        sExt = "vhc"
    Case "vhc"
        File_ReplaceString sPathFileStart, ".eng", "", bIsPresente
        File_ReplaceString sPathFileStart, ".trs", "", bIsPresente
        File_ReplaceString sPathFileStart, ".tyr", "", bIsPresente
        File_ReplaceString sPathFileStart, ".aux", "", bIsPresente
        File_ReplaceString sPathFileStart, ".alt", "", bIsPresente
        File_ReplaceString sPathFileStart, ".btr", "", bIsPresente
        File_ReplaceString sPathFileStart, ".idr", "", bIsPresente
        File_ReplaceString sPathFileStart, ".ped", "", bIsPresente
        File_ReplaceString sPathFileStart, ".gsi", "", bIsPresente
        File_ReplaceString sPathFileStart, ".cm", "", bIsPresente
        File_ReplaceString sPathFileStart, ".mot", "", bIsPresente
        File_ReplaceString sPathFileStart, ".pqm", "", bIsPresente
        File_ReplaceString sPathFileStart, ".axr", "", bIsPresente
        File_ReplaceString sPathFileStart, ".gbr", "", bIsPresente
        File_ReplaceString sPathFileStart, ".axm", "", bIsPresente
        File_ReplaceString sPathFileStart, ".gbm", "", bIsPresente
        File_ReplaceString sPathFileStart, ".trb", "", bIsPresente
        File_ReplaceString sPathFileStart, ".con", "", bIsPresente
        File_ReplaceString sPathFileStart, ".ret", "", bIsPresente
    
    Case "trs"
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    Case "trb"
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    Case "axr"
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    Case "gbr"
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    Case "axm"
        File_ReplaceString sPathFileStart, ".vsc", "", bIsPresente
    Case ""
        Exit Sub
    Case Else
        Exit Sub
    End Select
    
    sPathFileNew = spath & "\" & sFileNewName & "." & sExt

    If bIsPresente = True Then
        sMsg = "campi > cambiati"
    Else
        sMsg = "campi > ok"
    End If
    
    If UCase(sPathFileStart) <> UCase(sPathFileNew) Then
        File_Rename sPathFileStart, sPathFileNew, False
        sMsg = sMsg & vbTab & "Rinominato > SI" & vbTab & sPathFileStart
    Else
        sMsg = sMsg & vbTab & "Rinominato > NO" & vbTab & sPathFileStart
    End If
    
Err.Clear
End Sub

'---------101013
Sub ConvertiNomeTRS(Trs, NewTrs, NewName, Optional OldName = "")
Dim s1, s2, s3, s4, s5, i, j
Dim sEst, sStatus, sOldRid

    NomeRidotto Trs, OldName, sOldRid, sEst, sStatus

    NewTrs = ""
    s1 = Split(sOldRid, " ")
    s2 = ""

    For i = LBound(s1) To UBound(s1)
        If Left(s1(i), 2) = "zp" Then
            j = i
            s3 = s1(i)
            s4 = s1(i + 1)
        End If
    Next i
    s1(j) = s4
    s1(j + 1) = s3
    For i = LBound(s1) To UBound(s1)
        s2 = s2 & " " & s1(i)
    Next i
    s2 = Trim(s2)
    If sStatus = "(uff)" Then
        s2 = s2 & "  " & sStatus
    Else
        s2 = s2 & " " & sStatus
    End If
    
    NewName = s2
    NewTrs = s2 & "." & sEst

End Sub





