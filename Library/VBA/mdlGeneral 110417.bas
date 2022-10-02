Attribute VB_Name = "mdlGeneral"
'<DATA>: 110417
'librerie
'access,excel,powerpoint, active x 2.1, dao, ole automation, scripting, vba, office
'Option Compare Database
Option Compare Text
Option Explicit

'-----------------------FOLDER------------------------------
Public Type BROWSEINFOTYPE
    hOwner As Long
    pidlRoot As Long
    pszDisplayName As String
    lpszTitle As String
    ulFlags As Long
    lpfn As Long
    lParam As Long
    iImage As Long
End Type

Public Declare Function SHBrowseForFolder Lib "shell32.dll" Alias "SHBrowseForFolderA" (lpBROWSEINFOTYPE As BROWSEINFOTYPE) As Long
Public Declare Function SHGetPathFromIDList Lib "shell32.dll" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
Public Declare Sub CoTaskMemFree Lib "ole32.dll" (ByVal pv As Long)
Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Public Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (pDest As Any, pSource As Any, ByVal dwLength As Long)

Public Const WM_USER = &H400

Public Const BFFM_SETSELECTIONA As Long = (WM_USER + 102)
Public Const BFFM_SETSELECTIONW As Long = (WM_USER + 103)

'.......101216 rgr
Public Const BIF_NEWDIALOGSTYLE As Long = &H40
Public Const BIF_RETURNONLYFSDIRS As Long = &H1
Public Const BIF_BROWSEFILEJUNCTIONS As Long = &H10000
Public Const BIF_BROWSEINCLUDEFILES As Long = &H4000
Public Const BIF_EDITBOX As Long = &H10
Public Const BIF_SHAREABLE As Long = &H8000
Public Const BIF_UAHINT As Long = &H100

'.................

Public Declare Function LocalAlloc Lib "kernel32" (ByVal uFlags As Long, ByVal uBytes As Long) As Long
Public Declare Function LocalFree Lib "kernel32" (ByVal hMem As Long) As Long
Public Const LPTR = (&H0 Or &H40)


'"-----------------------shell------------------------------"
Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hWnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long



'.....110417..dpe
Public Function NullToNum(Value, Optional Default = 0)
On Error GoTo Gest_Err
Dim s
    s = Trim(" " & Value)
    If s = "" Then
        NullToNum = Default
    Else
        NullToNum = CDbl(s)
    End If
    Exit Function
Gest_Err:
    Err.Clear
    NullToNum = Default
End Function

'.....110415..rgr
Public Function GetFolderName(Optional Title = "Select directory...", Optional StartPath = "", Optional wStyle = "FULL") As String
    Dim Browse_for_folder As BROWSEINFOTYPE
    Dim itemID As Long
    Dim StartPathPointer As Long
    Dim tmpPath As String * 260
    Dim sTitle As String, sStartPath As String
    
    sTitle = CStr(Title)
    sStartPath = CStr(StartPath)
    
    With Browse_for_folder
        .hOwner = 0
        .lpszTitle = sTitle ' Titolo dialogo
        Select Case UCase(wStyle)
            Case "NEW" 'aggiunge bottone "crea nouova cartella"
            .ulFlags = BIF_NEWDIALOGSTYLE + BIF_RETURNONLYFSDIRS + BIF_BROWSEFILEJUNCTIONS + BIF_SHAREABLE + BIF_UAHINT
            Case "FILES" 'per visualizzare i file nelle cartelle
            .ulFlags = BIF_RETURNONLYFSDIRS + BIF_BROWSEINCLUDEFILES + BIF_BROWSEFILEJUNCTIONS + BIF_SHAREABLE + BIF_UAHINT
            Case "FULL" 'aggiunge bottone "crea nouova cartella" e visualizza i file nelle cartelle
            .ulFlags = BIF_NEWDIALOGSTYLE + BIF_RETURNONLYFSDIRS + BIF_BROWSEINCLUDEFILES + BIF_BROWSEFILEJUNCTIONS + BIF_SHAREABLE + BIF_UAHINT
        End Select
        .lpfn = FunctionPointer(AddressOf BrowseCallbackProcStr) ' Funzione di callback per la preselezione cartella
        StartPathPointer = LocalAlloc(LPTR, Len(sStartPath) + 1) ' Allocamento stringa
        CopyMemory ByVal StartPathPointer, ByVal sStartPath, Len(sStartPath) + 1
        .lParam = StartPathPointer ' Cartella preselezionata
    End With
    itemID = SHBrowseForFolder(Browse_for_folder) ' Apertura finestra di dialogo
    If itemID Then
        If SHGetPathFromIDList(itemID, tmpPath) Then
            GetFolderName = Left$(tmpPath, InStr(tmpPath, vbNullChar) - 1) ' Elimina gli spazi nulli
        End If
        Call CoTaskMemFree(itemID)
    End If
    Call LocalFree(StartPathPointer)
End Function

'.....110414..dpe
Public Sub Folder_Open(sDir)
    sDir = Trim(sDir)
    If sDir = "" Then
        Exit Sub
    End If
On Error GoTo Gest_Err
Dim x, d

    x = ShellExecute(0, "open", "explorer.exe", Chr(34) & sDir & Chr(34), Chr(34) & sDir & Chr(34), 1)
    Exit Sub
Gest_Err:   'On Error GoTo Gest_Err
    MsgBox "Errore inatteso nella sub File_Apri  N° " & Err.Number & " " & Err.Description
    Err.Clear
End Sub

'.....110315..dpe
Public Function NullToString(Value) As String
On Error Resume Next  '.....110315..dpe
    NullToString = Trim(" " & Value)
    Err.Clear
End Function


'......101123 rgr
'101123
Public Function GetFileName(PathFileName) As String
    Dim i As Long
    If PathFileName = "" Then Exit Function
    If GetFilePath(PathFileName) = "" Then '101119
        GetFileName = PathFileName
        Exit Function
    End If
    
    For i = Len(PathFileName) To 1 Step -1
        Select Case Mid$(PathFileName, i, 1)
            Case ":"
                ' colons are always included in the result
                GetFileName = Right$(PathFileName, Len(PathFileName) - i)
                Exit For
            Case "\"
                ' backslash aren't included in the result
                GetFileName = Right$(PathFileName, Len(PathFileName) - i)
                Exit For
        End Select
    Next
End Function

'.........101122 rgr
Public Function File_List(StartPath, Optional Sep = ";", Optional Path As Boolean = True, Optional Est = "*.*", Optional FindIn = "") As Variant
On Error GoTo Gest_Err
Dim i, sPath As String, sFile As String, sPathFile As String, sFileList As String
Dim bFind As Boolean, nFind As Long

Sep = CStr(Sep)
Est = CStr(Est)

If Est = "" Then Est = "*.*"
If StartPath = "" Then Exit Function
If FindIn <> "" Then bFind = True

Est = Replace(Est, "**", "*")
sPath = IIf(Right(StartPath, 1) = "\", StartPath, StartPath & "\")
File_List = ""

    'sFile = Dir(spath & Est, vbDirectory)
    sFile = Dir(sPath & Est, vbNormal)
    Do While sFile <> ""
        sPathFile = sPath & sFile
        If Path Then
            sFileList = sPathFile
        Else
            sFileList = sFile
        End If
        
        If bFind = True Then
            If File_SearchString(sPathFile, FindIn) > 0 Then
                File_List = File_List & sFileList & Sep
            Else
                
            End If
        Else
            File_List = File_List & sFileList & Sep
        End If
        sFile = Dir
    Loop

File_List = Trim(File_List)
If File_List <> "" Then File_List = Left(File_List, Len(File_List) - 1)

Exit Function
    
Gest_Err:
    Debug.Print "File_List", Err.Description
    Err.Clear
    Resume Next
End Function


'.....101104
'101104
Public Function GetNewID(Optional Prefisso = "") As String
Dim Y, m, d, h, mi, s, sTime
Prefisso = CStr(Prefisso)

    sTime = Format(Date, "yyyymmdd") & "-" & Format(Time, "hhmmss")
    GetNewID = Trim(Prefisso & sTime)
    
''''    Y = Year(Now)
''''    If Day(Now) < 10 Then
''''        d = "0" & Day(Now)
''''    Else
''''        d = Day(Now)
''''    End If
''''    If Month(Now) < 10 Then
''''        m = "0" & Month(Now)
''''    Else
''''        m = Month(Now)
''''    End If
''''    If Hour(Now) < 10 Then
''''        h = "0" & Hour(Now)
''''    Else
''''        h = Hour(Now)
''''    End If
''''    If Minute(Now) < 10 Then
''''        mi = "0" & Minute(Now)
''''    Else
''''        mi = Minute(Now)
''''    End If
''''    If Second(Now) < 10 Then
''''        s = "0" & Second(Now)
''''    Else
''''        s = Second(Now)
''''    End If
''''
''''    GetNewID = Trim(Prefisso & CStr(Y & m & d & "-" & h & mi & s))
    
End Function

'.....101028 rgr
Public Sub File_ReplaceString(sFile, sFind, sReplace, Optional IsPresente As Boolean = False)
On Error Resume Next
Dim sDati, sDatiNew
    String_FromFile sFile, sDati
    IsPresente = False
    If InStr(1, LCase(sDati), LCase(sFind)) > 0 Then '101028 rgr
        IsPresente = True
        sDatiNew = Replace(sDati, sFind, sReplace, , , vbTextCompare) '101028 rgr
        String_ToFile sFile, sDatiNew
    End If
Err.Clear
End Sub

'....101027  rgr
Public Sub ArraySort(myArr)
    Dim lB, uB, i, j, sTmp
    
    lB = LBound(myArr)
    uB = UBound(myArr)
    If uB - lB = 0 Then Exit Sub
    
    For i = lB To uB
        For j = i + 1 To uB
            If myArr(i) > myArr(j) Then
                sTmp = myArr(j)
                myArr(j) = myArr(i)
                myArr(i) = sTmp
            End If
        Next j
    Next i


End Sub

'---------101010
Public Function File_GetRow(sFile, sFind, Optional iRow = -1)
On Error Resume Next
Dim sDati, sDatiNew, sRows

    Dim ir, ic, upR, lwR, upC, lwC, upC1, lwC1
    String_FromFile sFile, sDati

    sRows = Split(sDati, vbCrLf)

    lwR = LBound(sRows)
    upR = UBound(sRows)
    lwC = 0
    upC = 0
    File_GetRow = ""
    For ir = lwR To upR
        If InStr(1, sRows(ir), sFind) Then
            iRow = ir
            File_GetRow = sRows(ir)
            Exit Function
        End If
    Next ir
Err.Clear
End Function

Public Sub File_Copy(Source, Destination, Optional OverWrite As Boolean = True)
    On Error Resume Next
    Dim FSO As FileSystemObject
    
    Set FSO = New FileSystemObject
    
    FSO.CopyFile Source, Destination, OverWrite

    DoEvents
    Err.Clear

    Set FSO = Nothing

End Sub



Public Function GetApplicationSubPath(SubDir, Optional sub2 = "", Optional sub3 = "") As String
On Error Resume Next
Dim s
    GetApplicationSubPath = ""
    s = Trim(GetApplicationProjectPath)
    If s = "" Then Exit Function

    If SubDir = "" Then
        GetApplicationSubPath = s
    Else
        GetApplicationSubPath = s & "\" & SubDir
    End If
    
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    If fs.FolderExists(GetApplicationSubPath) = False Then MkDir GetApplicationSubPath

    If sub2 <> "" Then
        GetApplicationSubPath = GetApplicationSubPath & "\" & sub2
        If fs.FolderExists(GetApplicationSubPath) = False Then MkDir GetApplicationSubPath
        
        If sub3 <> "" Then
            GetApplicationSubPath = GetApplicationSubPath & "\" & sub3
            If fs.FolderExists(GetApplicationSubPath) = False Then MkDir GetApplicationSubPath
        End If
        
    End If

    
    Set fs = Nothing
    Err.Clear
End Function

'------100927
Public Function GetDateFromID(ID) As Date
On Error Resume Next
    Dim s, s1, s2, s3, s4, s5, s6, s7

    s1 = Mid(ID, 1, 4)
    s2 = Mid(ID, 5, 2)
    s3 = Mid(ID, 7, 2)
    
    s4 = Mid(ID, 10, 2)
    s5 = Mid(ID, 12, 2)
    s6 = Mid(ID, 14, 2)
    
    s7 = s1 & "/" & s2 & "/" & s3 & " " & s4 & ":" & s5 & ":" & s6
    
    GetDateFromID = CDate(s7)
    
    Err.Clear
    
End Function

Public Sub CocomoRows()
On Error GoTo Gest_Err

    Dim commonDialog1 As New clsDialog
    Dim sPathFileStart As String
    Dim sFileStart As String
    commonDialog1.InitDir = "C:\"
    commonDialog1.Filter = "Files *|*.*"
    commonDialog1.ShowOpen 'show the open window
    sPathFileStart = commonDialog1.FileName
    sFileStart = GetFileName(sPathFileStart)
    If sFileStart = "" Then Exit Sub
    
    Dim t, sC, s, i, nRCode, nRBlank, nRCommento
    String_FromFile sPathFileStart, t
    
    sC = Split(t, vbCrLf)
    nRCode = 0
    nRBlank = 0
    nRCommento = 0
    For i = LBound(sC) To UBound(sC)
        s = Trim(sC(i))
        If s = "" Then
            nRBlank = nRBlank + 1
        ElseIf Left(s, 1) = "'" Then
            nRCommento = nRCommento + 1
        Else
            nRCode = nRCode + 1
        End If
    Next i
    
    
    Debug.Print nRCode, nRBlank, nRCommento

    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub


'----------100923
Public Function GetDirUP(sPathDir, n, Optional RestDir) As String
On Error Resume Next
    If sPathDir = "" Then Exit Function
    Dim sEndString, i, s, s1
    s = Trim(sPathDir)
    sEndString = Right(s, 1)
    If sEndString = "\" Then
        sEndString = Replace(sEndString, "\", "")
    End If
    s = Trim(s)

    For i = 1 To n
        s = Left(s, InStrRev(s, "\") - 1)
    Next i
    GetDirUP = s
    RestDir = Right(sPathDir, Len(sPathDir) - Len(s) - 1)
    
Err.Clear
End Function

'----------100630
Public Sub File_Rename(strFileOldName, strFileNewName, Optional Conferma As Boolean = True)
' Grasso 28/06/2010
    Dim sTmp
    Dim fs As Object
    If Conferma = True Then
        If MsgBox("Vuoi davvero rinominare il file " & strFileOldName & " -> " & strFileNewName & " ?", vbYesNo, "Elimina") = vbNo Then Exit Sub
    End If
    sTmp = strFileOldName & strFileNewName
    If InStr(sTmp, "*") = 0 And InStr(sTmp, "?") = 0 Then
        Set fs = CreateObject("Scripting.FileSystemObject")
        If fs.FileExists(strFileOldName) And Not fs.FileExists(strFileNewName) Then
            fs.MoveFile strFileOldName, strFileNewName
        End If
        Set fs = Nothing
    Else
        MsgBox "Nei file " & strFileOldName & " + " & strFileNewName & " ci sono dei caratteri *** /??? non ammessi. Operazione annullata!"
    End If

End Sub

'-----------100425-----------------------------


Public Sub PauseTime(Pause)
Dim Start, Finish, TotalTime

    Start = Timer    ' Imposta l'ora di inizio.
    Do While Timer < Start + Pause
        DoEvents        ' Passa il controllo ad altri processi.
    Loop
    Finish = Timer    ' Imposta l'ora di fine della pausa.
    TotalTime = Finish - Start    ' Calcola il tempo totale.
End Sub

Public Sub File_ConvertiEstensione(sDir, sEst, sEstNew)
On Error Resume Next
Dim sList, vList, sPathFileNew, bErr As Boolean

    If sDir = "" Or sEst = "" Or sEstNew = "" Then Exit Sub
    
    
    sList = File_List(sDir & "\", "|", True, "*" & sEst)

    Dim ir, ic, upR, lwR, upC, lwC
    
    vList = Split(sList, "|")
    
    lwR = LBound(vList, 1)
    upR = UBound(vList, 1)
    If upR < 0 Then
        Debug.Print "Nessun file trovato con estensione", sEst
    Else
        Debug.Print "Rinomina dei file da", sEst, sEstNew
        For ir = lwR To upR
            sPathFileNew = Left(vList(ir), Len(vList(ir)) - Len(sEst)) & sEstNew
            On Error GoTo NoRename
            bErr = False
            Name vList(ir) As sPathFileNew
            If bErr = False Then Debug.Print "      Rinominato --->", sPathFileNew
        Next ir
    End If

    Err.Clear
    Exit Sub
NoRename:
    Debug.Print "      Impossibile rinominare --->", Err.Description
    bErr = True
    Err.Clear
    Resume Next

End Sub


'----------- 090706 ----------------------------
Public Function Matrix_GetFromFile(File, Optional Sep = vbTab)
Dim Testo, myArray()

    String_FromFile File, Testo
    Matrix_GetFromString Testo, myArray, Sep
    Matrix_GetFromFile = myArray

Err.Clear
End Function



'----------- 090424 ----------------------------
Public Sub DeleteSubFolder(sFolder)
On Error Resume Next
    'OLE - Microsoft Scripting Runtime
    sFolder = Trim(sFolder)
    If sFolder = "" Then Exit Sub
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    
    If Not fs.FolderExists(sFolder) Then
        Set fs = Nothing
        Exit Sub
    End If
    fs.DeleteFolder sFolder & "\*"

    Set fs = Nothing
    
'If Err.Description Then Debug.Print "DeleteFolder", Err.Description
Err.Clear
End Sub

Public Sub DeleteAllIntoFolder(sFolder)
On Error Resume Next
    'OLE - Microsoft Scripting Runtime
    
    sFolder = Trim(sFolder)
    If sFolder = "" Then Exit Sub
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    
    If Not fs.FolderExists(sFolder) Then
        Set fs = Nothing
        Exit Sub
    End If
    fs.DeleteFolder sFolder & "\*"
    fs.DeleteFile sFolder & "\*"

    Set fs = Nothing
    
'If Err.Description Then Debug.Print "DeleteFolder", Err.Description
Err.Clear
End Sub

Public Sub DeleteFolder(sFolder)
On Error Resume Next
    'OLE - Microsoft Scripting Runtime
    
    sFolder = Trim(sFolder)
    If sFolder = "" Then Exit Sub
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    
    If Not fs.FolderExists(sFolder) Then
        Set fs = Nothing
        Exit Sub
    End If
    fs.DeleteFolder sFolder
    
    Set fs = Nothing
    
'If Err.Description Then Debug.Print "DeleteFolder", Err.Description
Err.Clear
End Sub



'------------ 090415 -----------------------------
Public Function isDB() As Boolean
Dim i
    i = InStr(1, Application.Name, "access")
    If i > 0 Then
        isDB = True
    Else
        isDB = False
    End If
End Function

Public Function isExcel() As Boolean
Dim i
    i = InStr(1, Application.Name, "Excel")
    If i > 0 Then
        isExcel = True
    Else
        isExcel = False
    End If
End Function


Public Function interpola_estrapola(x, xx, YY, Optional No) As Double
'Interpolazione,estrapolazione (inf e sup) di una data funzione y=f(x)in forma tabellare

'----------------------------------Input----------------------------------
'x:  valore per il quale si vuole conoscere la y=f(x)
'XX: vettore (1 to n) della variabile indipendente in ordine crescente
'YY: vettore (1 to n) della variabile dipendente
'no: opzionale; numero delle componenti del vettore XX e YY da considerare
'    a partire dalla prima componente
'-------------------------------------------------------------------------
Dim n, i, nx, ny
On Error GoTo Gest_Err

    If IsMissing(No) Then
        If IsObject(xx) Then
            nx = UBound(xx.Value)
            ny = UBound(YY.Value)
            If nx <> ny Then GoTo ErroreDimensioni
            If (xx(1) = "" Or YY(1) = "" Or xx(nx) = "" Or YY(ny) = "") Then GoTo ErroreRange
            n = nx
        Else
            n = UBound(xx)
        End If
    Else
        n = No
    End If

    interpola_estrapola = 0
    Select Case x
        
        Case Is < xx(1) 'Estrapolazione inferiore
            interpola_estrapola = (((x - xx(1)) / (xx(2) - xx(1))) * (YY(2) - YY(1))) + YY(1)
        
        Case Is > xx(n) 'Estrapolazione superiore
            interpola_estrapola = (((x - xx(n)) / (xx(n) - xx(n - 1))) * (YY(n) - YY(n - 1))) + YY(n)
        
        Case Else       'Interpolazione
            For i = 1 To n
                If x = xx(i) Then
                    interpola_estrapola = YY(i)
                    Exit Function
                ElseIf x < xx(i) Then
                    interpola_estrapola = (((x - xx(i - 1)) / (xx(i) - xx(i - 1))) * (YY(i) - YY(i - 1))) + YY(i - 1)
                    Exit Function
                End If
            Next i
            
    End Select
    Exit Function

Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Exit Function

ErroreDimensioni:
    MsgBox "Dimensioni non omogenee dei vettori XX e YY "
    Err.Clear
    Exit Function

ErroreRange:
    MsgBox "Anomalia Range selezionati"
    Err.Clear
    Exit Function
    
End Function



Public Function BrowseCallbackProcStr(ByVal hWnd As Long, ByVal uMsg As Long, ByVal lParam As Long, ByVal lpData As Long) As Long
    If uMsg = 1 Then
        Call SendMessage(hWnd, BFFM_SETSELECTIONA, True, ByVal lpData)
    End If
End Function

Public Function FunctionPointer(FunctionAddress As Long) As Long
    FunctionPointer = FunctionAddress
End Function

Public Function GetApplicationPath()
On Error Resume Next
    Dim objApll As Object

    Set objApll = Application
    GetApplicationPath = ""
    If InStr(1, objApll.Name, "Acces") > 1 Then
        GetApplicationPath = Trim(objApll.CurrentProject.Path)
        Exit Function
    End If
    If InStr(1, objApll.Name, "Excel") > 1 Then
        GetApplicationPath = Trim(objApll.ThisWorkbook.Path)
        Exit Function
    End If
End Function

Public Function GetApplicationProjectPath() As String
On Error Resume Next
Dim s, i
    GetApplicationProjectPath = ""
    s = Trim(GetApplicationPath)
    If s = "" Then Exit Function
    i = InStrRev(s, "\")
    GetApplicationProjectPath = Left(s, i - 1)

    Err.Clear
End Function

Public Function GetApplicationSubPathParallelo(SubDir) As String
On Error Resume Next
Dim s
    GetApplicationSubPathParallelo = ""
    s = Trim(GetApplicationProjectPath)
    If s = "" Then Exit Function

    s = Left(s, InStrRev(s, "\") - 1)
    
    If SubDir = "" Then
        GetApplicationSubPathParallelo = s
        Exit Function
    Else
        GetApplicationSubPathParallelo = s & "\" & SubDir
    End If
    
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    If fs.FolderExists(GetApplicationSubPathParallelo) = False Then
        MkDir GetApplicationSubPathParallelo
    End If
    Set fs = Nothing
    Err.Clear
End Function

Public Function GetApplicationPathXLS()
On Error Resume Next
    GetApplicationPathXLS = Trim(Application.ThisWorkbook.Path)
End Function

Public Function GetApplicationPathAcces()
On Error Resume Next
    GetApplicationPathAcces = Trim(Application.CurrentProject.Path)
End Function

Public Sub String_ToFile(File, Testo)
    If Trim(Testo) <> "" Then
        Dim objFSO As Scripting.FileSystemObject
        Set objFSO = New Scripting.FileSystemObject
        Dim objSource As Scripting.TextStream
        Set objSource = objFSO.CreateTextFile(File, True)
        objSource.WriteLine Testo
        objSource.Close
    End If
End Sub

Public Sub String_FromFile(File, Testo)
    On Error GoTo FileError
    Dim objFSO As Scripting.FileSystemObject
    Set objFSO = New Scripting.FileSystemObject
    Dim objSource As Scripting.TextStream
    Set objSource = objFSO.OpenTextFile(File, ForReading, False, TristateFalse)
    Testo = ""
    Testo = objSource.ReadAll
    objSource.Close
    Exit Sub
FileError:
    If Err.Number = 62 Then
        
    Else
        Debug.Print "Errore!!! (" & CStr(Err.Number) & ") -> " & "-" & Err.Description
    End If
    Err.Clear
End Sub



Public Function File_AdjustName(sFile)
    Dim sPathFileStart As String
    Dim sFileStart As String
    Dim sPathName As String
    Dim sPurge As String
    Dim sSubst As String
    Dim sTmp As String
    Dim i, j, ilennome, ilenpu
    Dim newstr$, s$, s1$
    
    sSubst = "_"
    sPurge = "!?@#$%^&*|[]{}'`/\<>,:;" & Chr(34)
    
    sFileStart = GetFileName(sFile)
    sPathName = GetFilePath(sFile)
    ilenpu = Len(sPurge)
    ilennome = Len(sFileStart)
    sTmp = sFileStart
    For j = 1 To ilenpu
        sTmp = Replace(sTmp, Mid(sPurge, j, 1), sSubst)
    Next j
    
    newstr$ = Mid(sTmp, 1, 1)
    For j = 2 To ilennome
        s$ = Mid(sTmp, j, 1)
        s1$ = Mid(sTmp, j - 1, 1)
        If s$ = s1$ And s$ = sSubst Then GoTo nextitem
        newstr$ = newstr$ + s$
nextitem:
    Next j
    
    If newstr$ <> "" Then sFileStart = newstr$
    If sPathName <> "" Then sPathName = sPathName & "\"
    File_AdjustName = sPathName & sFileStart
    
End Function

Public Function string_ReplaceSpace(Optional sString = "") As String
Dim s
    sString = CStr(sString)
    s = Replace(sString, "      ", " ")
    s = Replace(s, "     ", " ")
    s = Replace(s, "    ", " ")
    s = Replace(s, "   ", " ")
    s = Replace(s, "  ", " ")
    string_ReplaceSpace = Trim(s)
End Function

Public Function string_ReplaceStrings(Optional sString = "", Optional sReplace = "") As String
    Dim sC, s As String, i
    sString = CStr(sString)
    sReplace = CStr(sReplace)
    
    sC = Split(sReplace, "|")
    s = Trim("" & sString)
    For i = LBound(sC) To UBound(sC)
        s = Replace(s, sC(i), "")
    Next i
    string_ReplaceStrings = Trim(string_ReplaceSpace(s))
End Function


Function GetFileNameNoExt(ByVal FileName, Optional fullpath As Boolean = True) As String
On Error GoTo Gest_Err
    Dim i As Long
    Dim sExt As String
    GetFileNameNoExt = Trim(FileName)
    If fullpath = False Then  'caso in cui s estrae il nome senza il path
        i = InStrRev(GetFileNameNoExt, "\")
        If i > 0 Then GetFileNameNoExt = Right(GetFileNameNoExt, Len(GetFileNameNoExt) - i)
    End If

    For i = Len(FileName) To 1 Step -1
        Select Case Mid$(GetFileNameNoExt, i, 1)
            Case "."
                sExt = Mid$(GetFileNameNoExt, i + 1)
                Exit For
            Case ":", "\", ")", "("
                Exit For
        End Select
    Next
    
    
    
    If Len(sExt) > 0 Then GetFileNameNoExt = Left(GetFileNameNoExt, Len(GetFileNameNoExt) - Len(sExt) - 1)
    Exit Function
Gest_Err:
    MsgBox Err.Description
    Err.Clear
End Function

Public Function Matrix_FindStringSetValue(Find, myMatrix(), Optional ColShift = 1)
On Error Resume Next
Dim r, c
    Matrix_FindStringSetValue = ""
    Matrix_FindString Find, myMatrix, r, c
    Matrix_FindStringSetValue = myMatrix(r, c + ColShift)
End Function

Public Function File_ListToArray(StartPath, Optional Sep = ";", Optional Path As Boolean = True, Optional Est = "*.*") As Variant
On Error Resume Next
Dim sList
    Sep = CStr(Sep)
    Est = CStr(Est)
    
    sList = File_List(StartPath, Sep, Path, Est)
    File_ListToArray = Split(sList, ";")
Err.Clear
End Function

Public Sub Matrix_FindStrings(Find, myMatrix(), r(), c())
    Dim ir, ic, upR, lwR, upC, lwC
    Dim iOccurrence, sInd, spl
    
    If Find = "" Then Exit Sub
    lwR = LBound(myMatrix, 1)
    upR = UBound(myMatrix, 1)
    lwC = LBound(myMatrix, 2)
    upC = UBound(myMatrix, 2)
    sInd = ""
    iOccurrence = 0
    For ir = lwR To upR
        For ic = lwC To upC
            If Find = myMatrix(ir, ic) Then
                iOccurrence = iOccurrence + 1
                sInd = sInd & CStr(ir) & "|"
                'Exit Sub
            End If
        Next ic
    Next ir
    If sInd = "" Then
        ReDim r(0), c(0)
        Exit Sub
    End If
    
    spl = Split(sInd, "|")
    ReDim r(0 To iOccurrence - 1), c(0 To iOccurrence - 1)
    For ir = 0 To iOccurrence - 1
        r(ir) = CInt(spl(ir))
        c(ir) = 0
    Next ir
    
End Sub

Public Sub Matrix_GetCol(myArray(), sFind, iCol, sUM, MyCol())
    On Error Resume Next
    Dim ir, ic, upR, lwR, upC, lwC
    
    lwR = LBound(myArray, 1)
    upR = UBound(myArray, 1)
    lwC = LBound(myArray, 2)
    upC = UBound(myArray, 2)

    ir = lwR
    iCol = -1
    sUM = ""
    For ic = lwC To upC
        If Trim(sFind) = Trim(myArray(ir, ic)) Then
            iCol = ic
            sUM = Trim(myArray(ir + 1, ic))
            ReDim MyCol(lwR To upR)
            For ir = lwR To upR
                MyCol(ir) = myArray(ir, iCol)
            Next ir
            
            Exit Sub
        End If
    Next ic
End Sub

Public Sub Matrix_Duplica(inArray(), outArray())
    On Error Resume Next
    Dim ir, ic, upR, lwR, upC, lwC
    
    lwR = LBound(inArray, 1)
    upR = UBound(inArray, 1)
    lwC = LBound(inArray, 2)
    upC = UBound(inArray, 2)

    ReDim outArray(lwR To upR, lwC To upC)
    
    For ic = lwC To upC
        For ir = lwR To upR
            outArray(ir, ic) = inArray(ir, ic)
        Next ir
    Next ic
End Sub

Public Sub Matrix_FindString(Find, myMatrix(), r, c)
    Dim ir, ic, upR, lwR, upC, lwC
    
    c = -1
    r = -1
    If Find = "" Then Exit Sub
    lwR = LBound(myMatrix, 1)
    upR = UBound(myMatrix, 1)
    lwC = LBound(myMatrix, 2)
    upC = UBound(myMatrix, 2)


    For ir = lwR To upR
        For ic = lwC To upC
            If Find = myMatrix(ir, ic) Then
               c = ic
               r = ir
               Exit Sub
            End If
        Next ic
    Next ir
End Sub

Public Sub Matrix_SetCol(myArray(), iCol, MyCol())
    On Error Resume Next
    Dim ir, ic, upR, lwR, upC, lwC
    
    lwR = LBound(myArray, 1)
    upR = UBound(myArray, 1)
    lwC = LBound(myArray, 2)
    upC = UBound(myArray, 2)
    
    For ir = lwR To upR
        myArray(ir, iCol) = MyCol(ir)
    Next ir

End Sub

Public Sub Matrix_GetFromString(sDati, myArray(), Optional Sep = vbTab)
    On Error Resume Next

    Dim sRows() As String
    Dim sValori() As String
    Dim ir, ic, upR, lwR, upC, lwC, upC1, lwC1

    sRows = Split(sDati, vbCrLf)
    lwR = LBound(sRows)
    upR = UBound(sRows)
    lwC = 0
    upC = 0
    
''''    sValori = Split(sRows(LBound(sRows)), vbTab)
    For ir = lwR To upR
        sValori = Split(sRows(ir), Sep)
        If UBound(sValori) > upC Then upC = UBound(sValori)
    Next ir
    
    ReDim myArray(lwR To upR, lwC To upC)
    
    For ir = lwR To upR
        sValori = Split(sRows(ir), Sep)
        For ic = lwC To upC
            myArray(ir, ic) = sValori(ic)
            Err.Clear
        Next ic
    Next ir

''''    Dim s
''''    For iR = lwR To upR
''''        s = ""
''''        For iC = lwC To upC
''''            s = s & ";" & MyArray(iR, iC)
''''        Next iC
''''        Debug.Print s
''''    Next iR


End Sub

Public Sub Matrix_PutInString(myArray(), sDati)
    On Error Resume Next

    Dim sRows As String
    Dim ir, ic, upR, lwR, upC, lwC
    
    lwR = LBound(myArray, 1)
    upR = UBound(myArray, 1)
    lwC = LBound(myArray, 2)
    upC = UBound(myArray, 2)


'        creo riga 1
    sRows = myArray(lwR, lwC)
    For ic = lwC + 1 To upC
        sRows = sRows & vbTab & myArray(lwR, ic)
    Next ic
    sDati = sRows

    For ir = lwR + 1 To upR
'        creo riga
        sRows = myArray(ir, lwC)
        For ic = lwC + 1 To upC
            sRows = sRows & vbTab & myArray(ir, ic)
        Next ic
        
       sDati = sDati & vbCrLf & sRows
    Next ir


End Sub

Public Sub Matrix_PurgeFirstCol(inArray, outArray(), Purge, Optional sPurge = "")
    On Error Resume Next

    Dim sCol As String
    Dim ir, ic, upR, lwR, upC, lwC
    sPurge = CStr(sPurge)
    
    lwR = LBound(inArray, 1)
    upR = UBound(inArray, 1)
    lwC = LBound(inArray, 2)
    upC = UBound(inArray, 2)
    Purge = False


    If inArray(lwR, lwC) = sPurge Then
        Purge = True
        ReDim outArray(lwR To upR, lwC To upC - 1)
        
        For ir = lwR To upR
            For ic = lwC To upC - 1
                outArray(ir, ic) = inArray(ir, ic + 1)
            Next ic
        Next ir
        
        
        upC = upC - 1
    Else
'        no Action
'
    End If

End Sub

Public Sub Combo_List(Tabella, Campo, Combo As Object)
On Error GoTo Gest_Err

    Dim sQuery As String
    Dim Cnn As New ADODB.Connection
    Dim rsDati As New ADODB.Recordset
    
    'elimina i dati
    sQuery = "SELECT [Tabella].[Campo] , Count([Tabella].[Campo]) AS NumDuplicati " & _
        " FROM [Tabella] " & _
        " GROUP BY [Tabella].[Campo] " & _
        " HAVING (((Count([Tabella].[Campo])) > 0)) " & _
        " ORDER BY [Tabella].[Campo] ASC;"
    
    sQuery = Replace(sQuery, "Tabella", Tabella)
    sQuery = Replace(sQuery, "Campo", Campo)
    
    Combo.RowSourceType = "Tabella/Query"
    Combo.RowSource = sQuery

    Exit Sub
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub


Function GetFileExtension(ByVal FileName) As String
On Error GoTo Gest_Err
    Dim i As Long
    For i = Len(FileName) To 1 Step -1
        Select Case Mid$(FileName, i, 1)
            Case "."
                GetFileExtension = Mid$(FileName, i + 1)
                Exit For
            Case ":", "\", ")", "("
                Exit For
        End Select
    Next
    Exit Function
Gest_Err:
    MsgBox Err.Description
    Err.Clear
End Function

Public Function GetFilePath(PathFileName) As String
    PathFileName = Trim(PathFileName)
    If PathFileName = "" Then
        MsgBox "Missing File", vbCritical, "Error"
        Exit Function
    End If
    Dim i As Long
    For i = Len(PathFileName) To 1 Step -1
        Select Case Mid$(PathFileName, i, 1)
            Case ":"
                ' colons are always included in the result
                GetFilePath = Left$(PathFileName, i)
                Exit For
            Case "\"
                ' backslash aren't included in the result
                GetFilePath = Left$(PathFileName, i - 1)
                Exit For
        End Select
    Next
    Exit Function
Gest_Err:
    MsgBox Err.Description
    Err.Clear
End Function

Public Function File_SearchString(FileName, MyString, Optional Msg As Boolean = False) As Long
    FileName = Trim(FileName)
    If FileName = "" Then
        If Msg = True Then MsgBox "Missing File", vbCritical, "Error"
        Exit Function
    End If
    MyString = Trim(MyString)
    If FileName = "" Then
        If Msg = True Then MsgBox "Missing String", vbCritical, "Error"
        Exit Function
    End If
On Error GoTo Gest_Err
    File_SearchString = 0
    Dim sDati, iPos, iPosNew
    
    String_FromFile FileName, sDati
    
    iPos = 0
start_loop:
    iPosNew = InStr(1 + iPos, sDati, MyString)
    If iPosNew > iPos Then
        File_SearchString = File_SearchString + 1
        iPos = iPosNew
        GoTo start_loop
    End If
    
    Exit Function
Gest_Err:
    MsgBox Err.Description
    Err.Clear
End Function

Public Function GetDirName(PathFileName) As String
    Dim i As Long
    For i = Len(PathFileName) To 1 Step -1
        Select Case Mid$(PathFileName, i, 1)
            Case ":"
                ' colons are always included in the result
                GetDirName = Left$(PathFileName, i - 1)
                Exit For
            Case "\"
                ' backslash aren't included in the result
                GetDirName = Left$(PathFileName, i - 1)
                Exit For
        End Select
    Next
End Function

Public Sub File_Open(FileName, Optional Msg As Boolean = True)
    FileName = Trim(FileName)
    If FileName = "" Then
        If Msg = True Then MsgBox "Missing File", vbCritical, "Error"
        Exit Sub
    End If
On Error GoTo Gest_Err
Dim x, d
    d = GetDirName(FileName)
    x = ShellExecute(0, "open", FileName, "", d, 1)
    Exit Sub
Gest_Err:   'On Error GoTo Gest_Err
    MsgBox "Errore inatteso nella sub File_Apri  N° " & Err.Number & " " & Err.Description
    Err.Clear
End Sub


Public Function GetDataInteger()
    GetDataInteger = 10000000000# * Year(Now) + 100000000 * Month(Now) + 1000000 * Day(Now) + 10000 * Hour(Now) + 100 * Minute(Now) + Second(Now)
End Function

Public Sub File_Kill(sPathFiles, Optional Conferma As Boolean = True)
On Error GoTo Gest_Err

    If Conferma = True Then
        If MsgBox("Vuoi davvero eliminare i file " & sPathFiles & " ?", vbYesNo, "Elimina") = vbNo Then Exit Sub
    End If
    kill sPathFiles
Gest_Err: 'On Error GoTo gest_err
    Err.Clear
    Resume Next
End Sub

Public Function File_exist(ByVal strFileName) As Boolean
    'Determines if a file exists
    Dim fs As Object
    If InStr(strFileName, "*") = 0 And InStr(strFileName, "?") = 0 Then
        Set fs = CreateObject("Scripting.FileSystemObject")
        File_exist = fs.FileExists(strFileName)
        Set fs = Nothing
    Else
        File_exist = Not (Dir(strFileName) = "")
    End If
End Function

Public Function Folder_exist(ByVal strPath) As Boolean
On Error Resume Next
    Folder_exist = False
    Dim FSO As FileSystemObject
    Dim FoldersObj As Folders
    Dim FolderObj As folder
    Set FSO = New FileSystemObject
    Folder_exist = FSO.FolderExists(strPath)
    Set FSO = Nothing
Err.Clear
End Function

Public Sub Folder_DeleteTree(ByVal vFolder)
    Dim FSO As FileSystemObject
    Dim FoldersObj As Folders
    Dim FolderObj As folder
    Set FSO = New FileSystemObject
    If Not FSO.FolderExists(vFolder) Then
        Set FSO = Nothing
        Exit Sub
    End If
    
    Set FolderObj = FSO.GetFolder(vFolder)
    Set FoldersObj = FolderObj.SubFolders
    For Each FolderObj In FoldersObj
        Folder_DeleteTree FolderObj.Path
    Next FolderObj
    
    On Error Resume Next
    
    kill vFolder & "\*.*"
    RmDir vFolder
    
    Err.Clear
    On Error GoTo 0
    
    Set FolderObj = Nothing
    Set FoldersObj = Nothing
    Set FSO = Nothing
End Sub

Public Function Folder_List(Optional vFolder = "c:\") As String
    On Error Resume Next
    Dim FSO As FileSystemObject
    Dim FoldersObj As Folders
    Dim FolderObj As folder
    
    vFolder = CStr(vFolder)
    Set FSO = New FileSystemObject
    If Not FSO.FolderExists(vFolder) Then
        Set FSO = Nothing
        Exit Function
    End If
    
    Set FolderObj = FSO.GetFolder(vFolder)
    Set FoldersObj = FolderObj.SubFolders
    Folder_List = ""
    For Each FolderObj In FoldersObj
        Folder_List = Folder_List & FolderObj.Name & "|"
    Next FolderObj
    Folder_List = Trim(Folder_List)
    Folder_List = Left(Folder_List, Len(Folder_List) - 1)

    Err.Clear
    On Error GoTo 0
    
    Set FolderObj = Nothing
    Set FoldersObj = Nothing
    Set FSO = Nothing

End Function

Public Sub Folder_Copy(DirSource, DirDestination)
    On Error Resume Next
    Dim FSO As FileSystemObject
    
    Set FSO = New FileSystemObject
    If Not FSO.FolderExists(DirSource) Then
        Set FSO = Nothing
        Exit Sub
    End If
    
    FSO.CopyFolder DirSource, DirDestination

    Err.Clear
    On Error GoTo 0
    Set FSO = Nothing

End Sub



Function TokenNum(tmp$, search$) As Integer
'Sostituisce TokenNumOld$ (perche' controlla i token multipli)
    Dim i As Integer
    Dim j As Integer
    Dim k As Integer
    Dim x As Integer
    Dim nt As Integer
    Dim lensearch As Integer, lentmp As Integer
    lensearch = Len(search$)
    lentmp = Len(tmp$)
    If lentmp = 0 Then
        TokenNum = 0
        Exit Function
    End If
    nt = 1
    For i = 1 To lentmp
        x = InStr(1, search$, Mid$(tmp$, i, 1))
        If x > 0 Then
            For j = i + 1 To lentmp%
                x = InStr(1, search$, Mid$(tmp$, j, 1))
                'i = j - 1
                i = j
                If x <= 0 Then
                    nt = nt + 1
                    Exit For
                End If
            Next j
        End If
    Next i
    TokenNum = nt

End Function

Function Token$(tmp$, search$, n%)
'Sostituisce TokenOld$ (perche'controlla i token multipli)
    Dim s$, Ln%, x, i
    s$ = tmp$
    Ln% = Len(tmp$)
    For i = 1 To Ln%
        x = InStr(1, search$, Mid$(tmp$, i, 1))
        If x > 0 Then
            x = i
            Exit For
        End If
    Next
    If x > 0 Then
        Token$ = Mid$(s$, 1, x - 1)
        For i = x + 1 To Ln%
            x = InStr(1, search$, Mid$(s$, i, 1))
            If x <= 0 Then
                x = i
                Exit For
            End If
        Next i
        s$ = Mid$(s$, x)
        
        If n% > 1 Then
                Token$ = Token$(s$, search$, n% - 1)
        End If
    Else
        Token$ = s$
        s$ = ""
    End If
End Function

Public Sub FilterArray(Vettore, search, Optional Index, Optional Include As Boolean, Optional CompareMethod As VbCompareMethod = vbBinaryCompare, Optional EqLike = "Like")
    Dim ID As Long
    Dim Count As Long
    EqLike = CStr(EqLike)
    Index = Vettore
    Count = LBound(Vettore) - 1
    
    If EqLike = "=" Then
        For ID = LBound(Vettore) To UBound(Vettore)
            If StrComp(CStr(Vettore(ID)), CStr(search), CompareMethod) = 0 And Include = True Then
                Count = Count + 1
                Index(Count) = ID
                Vettore(Count) = Vettore(ID)
            ElseIf StrComp(CStr(Vettore(ID)), CStr(search), CompareMethod) <> 0 And Include = False Then
                Count = Count + 1
                Index(Count) = ID
                Vettore(Count) = Vettore(ID)
            End If
        Next ID
    Else
        For ID = LBound(Vettore) To UBound(Vettore)
            If (InStr(1, CStr(Vettore(ID)), CStr(search), CompareMethod) > 0) = Include Then
                ' this item must be included
                Count = Count + 1
                Index(Count) = ID
                If ID <> Count Then
                    ' copy data only if necessary
                    Vettore(Count) = Vettore(ID)
                End If
            End If
        Next ID
    End If
    
    
    
    ' trim items in excess
    If Count < UBound(Vettore) Then
        ReDim Preserve Vettore(LBound(Vettore) To Count)
        ReDim Preserve Index(LBound(Index) To Count)
    End If
    
End Sub

Public Sub Vuota()
On Error GoTo Gest_Err



    Exit Sub

Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub

