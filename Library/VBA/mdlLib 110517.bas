Attribute VB_Name = "mdlLib"
'<DATA> : 110517
Option Explicit
Dim sComponentiInstallati '101027

'.....110517..rgr
Public Sub Components_LoadModule(sComponente, spath, Optional bLoadNewModules = False)
    
    Dim sTmp, sC, i, iarr, sPathTmp

    If bLoadNewModules Then
    'esporta moduli di perfects (bas, cls, frm) in una dir temporanea .....110513..rgr
        sTmp = LoadComponentVBToString()
        If sTmp <> "" Then
            sPathTmp = spath & "tmp"
            If Dir(sPathTmp, vbDirectory) = "" Then MkDir sPathTmp
            sC = Split(sTmp, ";")
            iarr = UBound(sC)
            For i = 0 To iarr
                ComponentSave GetFileNameNoExt(sC(i)), False, True, sPathTmp
            Next i
        End If
    End If
    
    Workbooks.Open spath & sComponente
    
    If bLoadNewModules Then
        If sTmp = "" Then Exit Sub
        'importa nel componente i moduli esportati da Pesrfects
            For i = 0 To iarr
                If ComponentFind(GetFileNameNoExt(sC(i)), sComponente) Then
                    ModuleDelete GetFileNameNoExt(sC(i)), sComponente 'delete modulo esistente per ricaricare quello nuovo
                    SendKeys "+", True
                End If
            Next i
            For i = 0 To iarr
                ComponentImport sC(i), sPathTmp, sComponente 'carica i componenti
            Next i
        kill sPathTmp & "\*.*"
        RmDir sPathTmp
    End If
End Sub

'.....110516..rgr
Public Function ComponentFind(sComponente, Optional WBName = "") As Boolean
    Dim icount, i
    ComponentFind = False
    If WBName = "" Then
        icount = ActiveWorkbook.VBProject.VBComponents.Count
        For i = 1 To icount
            If ActiveWorkbook.VBProject.VBComponents.Item(i).Name = sComponente Then
                ComponentFind = True
                Exit Function
            End If
        Next i
    Else
        icount = Workbooks(WBName).VBProject.VBComponents.Count
        For i = 1 To icount
            Debug.Print Workbooks(WBName).VBProject.VBComponents.Item(i).Name
            If Workbooks(WBName).VBProject.VBComponents.Item(i).Name = sComponente Then
                ComponentFind = True
                Exit Function
            End If
        Next i
    End If
End Function
        

'.....110516..rgr
Public Function ComponentImport(sComponente, Optional spath = "", Optional WBName = "") As String
    
    On Error Resume Next
    
    Dim sFile
    
    If sComponente = "" Then Exit Function
    
    If spath = "" Then spath = GetPathLib(True, spath)
    If Right(spath, 1) <> "\" Then spath = spath & "\"
    sFile = spath & sComponente
    If ComponentFind(GetFileNameNoExt(sComponente), WBName) Then Exit Function
    If WBName = "" Then
        ActiveWorkbook.VBProject.VBComponents.Import sFile
    Else
        Workbooks(WBName).VBProject.VBComponents.Import sFile
    End If
    
    
End Function

'.......110513 rgr
Public Sub ModuleDelete(sNomeModulo, Optional WBName = "")
    On Error Resume Next
    'Dim VBComp As VBComponent
    Dim VBComp
    If WBName = "" Then
        Set VBComp = ThisWorkbook.VBProject.VBComponents(sNomeModulo)
        ThisWorkbook.VBProject.VBComponents.Remove VBComp
    Else
''''        Set VBComp = Workbooks(WBName).VBProject.VBComponents(sNomeModulo)
''''        Workbooks(WBName).VBProject.VBComponents.Remove VBComp
        Workbooks(WBName).VBProject.VBComponents.Remove Workbooks(WBName).VBProject.VBComponents(sNomeModulo)
    End If
    VBComp = Nothing
    Err.Clear
End Sub

'.....110513..rgr
Public Function ComponentUpdate(sComponente, Optional bLibVBA As Boolean = True, Optional bOverWrite As Boolean = True, Optional sLibPath = "", Optional WBName = "") As String
On Error Resume Next

    Dim spath, sFile, InternalCodeUpdate

    InternalCodeUpdate = ""
    If sComponente = "" Then
        InternalCodeUpdate = "Componente non valido"
        Exit Function
    End If
    

    spath = GetPathLib(bLibVBA, sLibPath)
    If spath = "" Then
        ComponentUpdate = "percorso non valido"
        Exit Function
    End If

    Select Case ActiveWorkbook.VBProject.VBComponents.Item(sComponente).Type
    Case 1
        sFile = spath & sComponente & ".bas"
    Case 2
        sFile = spath & sComponente & ".cls"
    Case 3
        sFile = spath & sComponente & ".frm"
    Case Else
        Exit Function
    End Select
    
''''    Debug.Print sFile

    If sFile = "" Then
        InternalCodeUpdate = "Componente non trovato"
        Exit Function
    End If

    If File_exist(sFile) = False Then
        InternalCodeUpdate = "File Componente non trovato"
        Exit Function
    End If
    
    InternalCodeUpdate = sComponente
    If bOverWrite = True Then
        ModuleDelete sComponente, WBName
        InternalCodeUpdate = InternalCodeUpdate & " / rimosso"
    End If
    
    If WBName = "" Then
        ActiveWorkbook.VBProject.VBComponents.Import sFile
    Else
        Workbooks(WBName).VBProject.VBComponents.Import sFile
    End If
    InternalCodeUpdate = InternalCodeUpdate & " / Importato"
    
    Err.Clear
End Function

'.....110512..rgr
Public Function GetLibVBAPath() As String
On Error Resume Next
Dim s, i
    GetLibVBAPath = ""
    s = Trim(GetRunPath)
    If s = "" Then Exit Function
    i = InStrRev(s, "\")
    s = Left(s, i - 1)
    i = InStrRev(s, "\")
    GetLibVBAPath = Left(s, i - 1) & "\Library\Sviluppo\OnWorks\VBA"
''''    GetLibVBAPath = Left(s, i - 1) & "\Library\Sviluppo\VBA"
    
    Err.Clear
End Function
'......110512 rgr
Public Sub LocalAutoLoad()
On Error Resume Next


    Dim i
    'Dim sComponentiInstallati '101021 rgr
    'Static sComponentiInstallati '101021 rgr
    Dim spath, sFile, sPathFile, sEst, sTmp
    
    
    spath = ""
    If InStr(1, Application.Name, "Acces") > 1 Then
        spath = Trim(Application.CurrentProject.Path)
    ElseIf InStr(1, Application.Name, "Excel") > 1 Then
        spath = Trim(Application.ThisWorkbook.Path)
    Else
        Exit Sub
    End If
    If spath = "" Then Exit Sub
    spath = spath & "\"
''''    Debug.Print sPath
    Err.Clear
    
    If sComponentiInstallati <> "" Then Exit Sub 'se il componente è già stato caricato esce
    sComponentiInstallati = LoadComponentVBToString()
    

    sFile = Dir(spath & "*.Bas", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        sTmp = Split(sFile, " ")
        If InStr(1, sComponentiInstallati, sFile) > 0 Or InStr(1, sComponentiInstallati, sTmp(0) & ".bas") > 0 Then
''''            Debug.Print sFile, "gia installato"
        Else
''''            Debug.Print sFile, "da installare"
            
            ActiveWorkbook.VBProject.VBComponents.Import sPathFile
            sComponentiInstallati = sComponentiInstallati & sPathFile
        End If
        sFile = Dir
    Loop

    sFile = Dir(spath & "*.cls", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        If InStr(1, sComponentiInstallati, sFile) > 0 Then
''''            Debug.Print sFile, "gia installato"
        Else
''''            Debug.Print sFile, "da installare"
            ActiveWorkbook.VBProject.VBComponents.Import sPathFile
            sComponentiInstallati = sComponentiInstallati & sPathFile
        End If
        sFile = Dir
    Loop

    sFile = Dir(spath & "*.frm", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        If InStr(1, sComponentiInstallati, sFile) > 0 Then
''''            Debug.Print sFile, "gia installato"
        Else
''''            Debug.Print sFile, "da installare"
            ActiveWorkbook.VBProject.VBComponents.Import sPathFile
            sComponentiInstallati = sComponentiInstallati & sPathFile
        End If
        sFile = Dir
    Loop
    
    
    Err.Clear

End Sub


'.....110111 rgr
Public Function LoadComponentVBToString()
    Dim i, sComp
    sComp = ""
    'sComponentiInstallati = "" '101021 rgr
    For i = 1 To ActiveWorkbook.VBProject.VBComponents.Count
        Select Case ActiveWorkbook.VBProject.VBComponents.Item(i).Type
        Case 1
            sComp = sComp & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".bas;"
        Case 2
            sComp = sComp & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".cls;"
        Case 3
            sComp = sComp & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".frm;"
        Case Else
            
        End Select
    Next i
    LoadComponentVBToString = sComp
''''    Debug.Print sComponentiInstallati
End Function

'......101027 rgr
Public Sub LocalAutoRemove()
On Error Resume Next


    Dim i
    Dim sCompInst
    Dim spath, sFile, sFile1, sFile2, sF
    
    
    spath = ""
    If InStr(1, Application.Name, "Acces") > 1 Then
        spath = Trim(Application.CurrentProject.Path)
    ElseIf InStr(1, Application.Name, "Excel") > 1 Then
        spath = Trim(Application.ThisWorkbook.Path)
    Else
        Exit Sub
    End If
    If spath = "" Then Exit Sub
    spath = spath & "\"
    
    sFile = Dir(spath & "*.Bas", vbNormal)
    sF = sFile
    Do While sF <> ""
        sF = Dir
        If sF <> "" Then sFile = sFile & vbCrLf & sF
    Loop
    sFile1 = Dir(spath & "*.cls", vbNormal)
    sF = sFile1
    Do While sF <> ""
        sF = Dir
        If sF <> "" Then sFile1 = sFile1 & vbCrLf & sF
    Loop
    sFile2 = Dir(spath & "*.frm", vbNormal)
    sF = sFile2
    Do While sF <> ""
        sF = Dir
        If sF <> "" Then sFile2 = sFile2 & vbCrLf & sF
    Loop
    sFile = sFile & vbCrLf & sFile1 & vbCrLf & sFile2

    For i = 1 To ActiveWorkbook.VBProject.VBComponents.Count
        sCompInst = ActiveWorkbook.VBProject.VBComponents.Item(i).Name
        Debug.Print sCompInst
        If InStr(1, sFile, sCompInst) > 0 Then
            ModuleDelete (sCompInst)
            sComponentiInstallati = ""
        End If
    Next i

    Err.Clear

End Sub

Public Function GetRunPath()
On Error Resume Next
Dim objApll As Object

    Set objApll = Application
    GetRunPath = ""
    If InStr(1, objApll.Name, "Acces") > 1 Then
        GetRunPath = Trim(objApll.CurrentProject.Path)
        Exit Function
    End If
    If InStr(1, objApll.Name, "Excel") > 1 Then
        GetRunPath = Trim(objApll.ThisWorkbook.Path)
        Exit Function
    End If
Err.Clear

End Function

Public Function GetPathLib(Optional bLibVBA As Boolean = True, Optional sLibPath = "") As String
On Error Resume Next

    GetPathLib = ""
    If sLibPath = "" Then
        If bLibVBA = True Then
            GetPathLib = GetLibVBAPath & "\"
        Else
            GetPathLib = GetRunPath & "\"
        End If
    Else
        GetPathLib = sLibPath & "\"
    End If
    
    Dim FSO As FileSystemObject
    Set FSO = New FileSystemObject
    If FSO.FolderExists(GetPathLib) = False Then
        'codice di ricerca
        GetPathLib = ""
    End If
    Set FSO = Nothing
    
Err.Clear
End Function

Public Function ComponentSave(sComponente, Optional bLibVBA As Boolean = True, Optional bOverWrite As Boolean = True, Optional sLibPath = "") As String
On Error Resume Next

    Dim spath, sFile

    ComponentSave = ""
    If sComponente = "" Then
        ComponentSave = "Componente non valido"
        Exit Function
    End If
    
    spath = GetPathLib(bLibVBA, sLibPath)
    If spath = "" Then
        ComponentSave = "percorso non valido"
        Exit Function
    End If

    Select Case ActiveWorkbook.VBProject.VBComponents.Item(sComponente).Type
    Case 1
        sFile = spath & sComponente & ".bas"
    Case 2
        sFile = spath & sComponente & ".cls"
    Case 3
        sFile = spath & sComponente & ".frm"
    Case Else
        Exit Function
    End Select
    
''''    Debug.Print sFile

    If sFile = "" Then
        ComponentSave = "Componente non trovato"
        Exit Function
    End If

    If File_exist(sFile) = True And bOverWrite = False Then
        ComponentSave = "File Componente è già presente"
        Exit Function
    End If
    
    ComponentSave = sComponente
    If bOverWrite = True Then
        ComponentSave = ComponentSave & " / esportato e sovrascritto"
    Else
        ComponentSave = ComponentSave & " / esportato"
    End If
    
    ActiveWorkbook.VBProject.VBComponents(sComponente).Export sFile
    
    Err.Clear
End Function



Public Function InternalCodeUpdate(Optional bLibVBA As Boolean = True, Optional bOverWrite As Boolean = True, Optional sLibPath = "") As String
On Error Resume Next

    Dim spath, sFile, sPathFile, sEst
    Dim i
    Dim sComponente


    InternalCodeUpdate = ""
    
    
    spath = GetPathLib(bLibVBA, sLibPath)
    If spath = "" Then
        InternalCodeUpdate = "percorso non valido"
        Exit Function
    End If
    

    sFile = Dir(spath & "*.bas", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        sComponente = Left(sFile, Len(sFile) - 4)
        
        InternalCodeUpdate = sComponente
        If bOverWrite = True Then
            If sComponente = "mdlLib" Then
                ModuleRename sComponente, sComponente & "1"
                ModuleDelete sComponente & "1"
            Else
                ModuleDelete sComponente
            End If
            
            InternalCodeUpdate = InternalCodeUpdate & " / rimosso"
        End If
        
        ActiveWorkbook.VBProject.VBComponents.Import sPathFile
        InternalCodeUpdate = InternalCodeUpdate & " / Importato"
    
        sFile = Dir
    Loop

    sFile = Dir(spath & "*.cls", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        sComponente = Left(sFile, Len(sFile) - 4)
        
        InternalCodeUpdate = sComponente
        If bOverWrite = True Then
            ModuleDelete sComponente
            InternalCodeUpdate = InternalCodeUpdate & " / rimosso"
        End If
        
        ActiveWorkbook.VBProject.VBComponents.Import sPathFile
        InternalCodeUpdate = InternalCodeUpdate & " / Importato"
    
        sFile = Dir
    Loop

    sFile = Dir(spath & "*.frm", vbNormal)
    Do While sFile <> ""
        sPathFile = spath & sFile
        sComponente = Left(sFile, Len(sFile) - 4)
        
        InternalCodeUpdate = sComponente
        If bOverWrite = True Then
            ModuleDelete sComponente
            InternalCodeUpdate = InternalCodeUpdate & " / rimosso"
        End If
        
        ActiveWorkbook.VBProject.VBComponents.Import sPathFile
        InternalCodeUpdate = InternalCodeUpdate & " / Importato"
    
        sFile = Dir
    Loop
    

    
    
    Err.Clear
End Function

Public Sub ModuleRename(sNomeOld, sNomeNew)
    On Error Resume Next
    Dim VBComp As VBComponent
    Set VBComp = ThisWorkbook.VBProject.VBComponents(sNomeOld)
    VBComp.Name = sNomeNew
    VBComp = Nothing
    Err.Clear
End Sub

Public Sub LibAutoSave(Optional bAllModule As Boolean = False)
On Error Resume Next


    Dim i
    Dim sComponentiInstallati, sComp
    Dim spath, sFile
    spath = GetLibVBAPath & "\"

    

    For i = 1 To ActiveWorkbook.VBProject.VBComponents.Count
        sComp = ActiveWorkbook.VBProject.VBComponents.Item(i).Name
        Select Case ActiveWorkbook.VBProject.VBComponents.Item(i).Type
        Case 1
            sFile = spath & sComp & ".bas"
        Case 2
            sFile = spath & sComp & ".cls"
        Case 3
            sFile = spath & sComp & ".frm"
        Case Else
            sFile = ""
        End Select

        If (Left(sComp, 3) = "cls" Or Left(sComp, 3) = "frm" Or Left(sComp, 3) = "mdl") Or bAllModule = True Then
            If sFile <> "" Then ActiveWorkbook.VBProject.VBComponents(i).Export (sFile)
        End If
        
    Next i
    Err.Clear
    
    Exit Sub
End Sub






Public Sub LocalAutoSave()
On Error Resume Next


    Dim i
    Dim sComponentiInstallati
    Dim spath

    
    
    spath = ""
    If InStr(1, Application.Name, "Acces") > 1 Then
        spath = Trim(Application.CurrentProject.Path)
    ElseIf InStr(1, Application.Name, "Excel") > 1 Then
        spath = Trim(Application.ThisWorkbook.Path)
    Else
        Exit Sub
    End If
    If spath = "" Then Exit Sub
    spath = spath & "\"
    Debug.Print spath
    Err.Clear

    For i = 1 To ActiveWorkbook.VBProject.VBComponents.Count
        Select Case ActiveWorkbook.VBProject.VBComponents.Item(i).Type
        Case 1
            ActiveWorkbook.VBProject.VBComponents(i).Export (spath & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".bas")
        Case 2
            ActiveWorkbook.VBProject.VBComponents(i).Export spath & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".cls"
        Case 3
            ActiveWorkbook.VBProject.VBComponents(i).Export spath & ActiveWorkbook.VBProject.VBComponents.Item(i).Name & ".frm"
        Case Else
            
        End Select
    Next i
    Err.Clear
    
    Exit Sub
End Sub

