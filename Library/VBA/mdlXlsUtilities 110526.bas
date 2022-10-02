Attribute VB_Name = "mdlXlsUtilities"
'<DATA>: 110526
Option Explicit
Option Compare Text

Global Const XLS_MAX_ROWS = 56000
Global Const XLS_MAX_COLS = 250
Global bCh As Boolean

Type myRange '090621
    Value As Variant
    Row As Integer
    Col As Integer
End Type

'......110526..dpe
Public Function CmdBAR_DeleteUser(Optional MyNomeBar = "")
On Error Resume Next
    Dim vNomeBar, Status, uB, ib, sFile, nPulsantiOnBar
    
    CmdBAR_DeleteUser = 0

    If MyNomeBar = "" Then
        MyNomeBar = GetFileNameNoExt(ThisWorkbook.Name, False)
    End If
    
    Application.CommandBars(MyNomeBar).Delete
    Err.Clear

End Function

'......110526..dpe
Public Function CmdBAR_LoadUser(Optional MyNomeBar = "", Optional SEP = "|")
    On Error Resume Next
    'carica eventuali comandi definite in file esterni .bar da caricare nella Barra CBAR_PERFECTS
    Dim vNomeBar, sNomeBar, Status, uB, ib, sFile, nPulsantiOnBar
    CmdBAR_LoadUser = 0

    If MyNomeBar = "" Then
        MyNomeBar = GetFileNameNoExt(ThisWorkbook.Name, False)
    Else
        
    End If

    sNomeBar = File_List(GetApplicationPath, SEP, False, "*.bar")  'la lista file contiene solo il nome senza path
    vNomeBar = Split(sNomeBar, SEP)
    
    CmdBAR_DeleteUser MyNomeBar
    
    uB = UBound(vNomeBar)
    If uB < 0 Then Exit Function

    For ib = 0 To uB
        sFile = GetApplicationPath & "\" & vNomeBar(ib)
        Debug.Print vNomeBar(ib)
        nPulsantiOnBar = nPulsantiOnBar + CmdBAR_LoadBAR(MyNomeBar, sFile)
    Next ib
    CmdBAR_LoadUser = uB + 1
End Function

'.....110520..dpe
Public Sub RangeToArray(sheet As Worksheet, StartRow, EndRow, DataCols, myArray(), r(), c())

    Dim ir, ic, upC, lwC, nRow, kR, myCols()
    If IsArray(DataCols) = True Then
        myCols = DataCols
    Else
        ReDim myCols(0)
        myCols(0) = DataCols
    End If

    
    lwC = LBound(myCols)
    upC = UBound(myCols)
    nRow = EndRow - StartRow + 1
    
    kR = 0
    ReDim myArray(kR To nRow - 1, lwC To upC)
    ReDim r(kR To nRow - 1, lwC To upC)
    ReDim c(kR To nRow - 1, lwC To upC)

    For ir = StartRow To EndRow
        For ic = lwC To upC
            myArray(kR, ic) = sheet.Cells(ir, myCols(ic)).Value
            c(kR, ic) = myCols(ic)
            r(kR, ic) = ir
''''            Debug.Print myArray(kR, iC), r(kR, iC), c(kR, iC)
        Next ic
        kR = kR + 1
    Next ir

End Sub


'.....110126 rgr
Public Sub RefreshFormule()
    SendKeys "{ENTER}"
    SendKeys "{UP}"
End Sub



'.......110107 rgr
Public Function CmdBAR_LoadBAR(BarName, FileBar)
    Dim ListFileBar, ArrFileBar
    Dim foundFlag
    Dim nPulsanti
    Dim i
    Dim bar As CommandBar


    CmdBAR_LoadBAR = 0
    
    If Dir(FileBar, vbNormal) = "" Then Exit Function
    
'verifica se esiste la commandbar BARNAME
    foundFlag = False
    For Each bar In Application.CommandBars
        If bar.Name = BarName Then 'esiste
            foundFlag = True
            bar.Visible = True
        End If
    Next
    
    'non esiste, viene creata
    If Not foundFlag Then
        Application.CommandBars.Add(Name:=BarName, Position:=msoBarRight).Visible = True
    End If
    
    'da FileBar , legge le info dei pulsanti per inserirli sulla barra "BarName"
     nPulsanti = CmdBAR_LoadPulsanti(BarName, FileBar)
    
    CmdBAR_LoadBAR = CmdBAR_LoadBAR + nPulsanti

End Function


'.........110104 rgr
'erano in sds_main
Public Sub Matrix_Section(sTag, myMatrixIn(), myMatrixOut(), bFind As Boolean)
    Dim r1, C1, r2, C2, iR1, ir, cl, cU, ic
    bFind = False
    Matrix_FindString "<" & sTag & ">", myMatrixIn(), r1, C1
    Matrix_FindString "</" & sTag & ">", myMatrixIn(), r2, C2
    r1 = r1 + 1
    r2 = r2 - 1
    If r2 < r1 Then r2 = r1 '110104 rgr
    cl = LBound(myMatrixIn, 2)
    cU = UBound(myMatrixIn, 2)
    If r1 < 0 Or r2 < 0 Then
        bFind = False
        Exit Sub
    End If
    ReDim myMatrixOut(0 To r2 - r1, cl To cU)
    
    bFind = True
    iR1 = 0
    For ir = r1 To r2
        For ic = cl To cU
            myMatrixOut(iR1, ic) = myMatrixIn(ir, ic)
        Next ic
        iR1 = iR1 + 1
    Next ir
    
End Sub


'........101206
Public Sub Sheet_ClearContents(FoglioAttivo)
    On Error Resume Next
    Worksheets(FoglioAttivo).Activate
    Sheets(FoglioAttivo).Range("A1", ActiveCell.SpecialCells(xlLastCell)).ClearContents 'cancella il contenuto di tutte le celle di MY_SHEET
    Sheets(FoglioAttivo).Range("A1").Select
    Err.Clear
End Sub

'.........101102 dpe
'trasferito 2 func. in sds_main


'---------101010
Public Function GetIntestazioneCol(nColonna)
    Const nmaxcol = 26
    Dim iCol
    Dim iResto
    GetIntestazioneCol = ""
    If nColonna < 1 Then Exit Function
    iCol = Int(nColonna / nmaxcol)
    iResto = nColonna Mod nmaxcol
    
    If nColonna > nmaxcol Then
        If iCol > 1 And iResto = 0 Then
            iCol = iCol - 1
            iResto = nmaxcol
        End If
        
        GetIntestazioneCol = Chr(iCol + 64) + Chr(iResto + 64)
        
    Else
        GetIntestazioneCol = Chr(nColonna + 64)
    End If
    
End Function

'---------------------- 100525 ------------------------------------
Public Function CmdBAR_LoadPulsanti(BarName, FileBar)
    Dim cMyBar, newItem, newSubItem1, newSubItem2, newSubItem3, newSubItem4, newSubItem5, newSubItem6, newSubItem7, newSubItem8
    Dim nFirst, nLast, ListCaption(), ListAction(), ListStyle(), ListFaceId(), ListBeginGroup(), ListSubGroup()
    Dim matrix_pulsanti(), iCol, sUM
    Dim i
    
    On Error Resume Next
    
    CmdBAR_LoadPulsanti = 0
    'carica la matrice con le info dei pulsanti da inserire sulla commandbar "barname"
    matrix_pulsanti = Matrix_GetFromFile(FileBar)
    
    Matrix_GetCol matrix_pulsanti, "CAPTION", iCol, sUM, ListCaption()
    Matrix_GetCol matrix_pulsanti, "ACTION", iCol, sUM, ListAction()
    Matrix_GetCol matrix_pulsanti, "STYLE", iCol, sUM, ListStyle()
    Matrix_GetCol matrix_pulsanti, "FACEID", iCol, sUM, ListFaceId()
    Matrix_GetCol matrix_pulsanti, "BEGINGROUP", iCol, sUM, ListBeginGroup()
    Matrix_GetCol matrix_pulsanti, "SOTTOGRUPPO", iCol, sUM, ListSubGroup()
    
    nFirst = 1
    nLast = UBound(ListCaption)
    If nLast <= nFirst Then GoTo esci
    
    For i = nFirst To nLast
        'If i = nLast And Trim(ListCaption(i)) = "" Then Exit For
        If Trim(ListCaption(i)) <> "" Then
            If CInt(ListSubGroup(i)) < 0 Then 'in questo caso non ci sono sottogruppidi appartenenza a questo pulsante
                Set newItem = CommandBars(BarName).Controls.Add(Type:=msoControlButton)
            ElseIf CInt(ListSubGroup(i)) = 0 Then 'in questo caso il pulsante contiene un sottomenù
                Set newItem = CommandBars(BarName).Controls.Add(Type:=msoControlPopup)
            End If
            If CInt(ListSubGroup(i)) <= 0 Then 'caricamento pulsanti principali
                With newItem
                    .Caption = ListCaption(i)
                    If Trim(ListStyle(i)) <> "" Then .Style = CInt(ListStyle(i))
                    If Trim(ListFaceId(i)) <> "" Then .FaceId = CInt(ListFaceId(i))
                    If Trim(ListAction(i)) <> "" Then .OnAction = ListAction(i)
                End With
                CmdBAR_LoadPulsanti = CmdBAR_LoadPulsanti + 1
            End If
        
            If CInt(ListSubGroup(i)) > 0 Then 'caricamento sottomenu a forma di popup
                'Set newSubItem1 = newItem.Controls.Add(Type:=msoControlButton, ID:=2950, Before:=1)
                Set newSubItem1 = newItem.Controls.Add(Type:=msoControlButton, ID:=2950)
                With newSubItem1
                    .Caption = ListCaption(i)
                    If Trim(ListFaceId(i)) <> "" Then .FaceId = CInt(ListFaceId(i))
                    .OnAction = ListAction(i)
                End With
            End If
        End If
    Next i
esci:
    Err.Clear
    
    
End Function


'--------------091116------------------------------
Public Function IsChart() As Boolean
Dim sName
    On Error GoTo sheet
    sName = Trim(ActiveChart.Name)
    IsChart = True
    
    Exit Function
sheet:
    IsChart = False
    Err.Clear
End Function


Public Sub SelectSheetChart(sSheetChart)
   
    On Error GoTo sheet
    Charts(sSheetChart).Select
    
    Exit Sub
sheet:
    Sheets(sSheetChart).Select
    Err.Clear
End Sub



'--------------090710------------------------------
Public Function Col_GetAllValori(sheet, RowStart, RowEnd, CValori)
Dim i, vManovre, s1, s2, s3

    s1 = ""
    s2 = ""
    For i = RowStart To RowEnd
        s1 = Worksheets(sheet).Cells(i, CValori).Value
        s2 = s2 & s1 & ";"
    Next i
    s2 = Left(s2, Len(s2) - 1)
    Col_GetAllValori = Split(s2, ";")


End Function
Public Function Col_GetValoriNonRipetuti(sheet, RowStart, RowEnd, CValori)
Dim i, vManovre, s1, s2, s3

    s1 = ""
    s2 = ""
    s3 = ""
    For i = RowStart To RowEnd
        s1 = Worksheets(sheet).Cells(i, CValori).Value
        If s2 <> s1 Then
            s3 = s3 & s1 & ";"
            s2 = s1
        End If
    Next i
    s3 = Left(s3, Len(s3) - 1)
    Col_GetValoriNonRipetuti = Split(s3, ";")


End Function


'--------------090621------------------------------
Public Function RangeGet(SheetField) As myRange
On Error Resume Next
    Dim Row, Col
    RangeGet.Value = RangeG(SheetField, Row, Col)
    RangeGet.Col = Col
    RangeGet.Row = Row
Err.Clear
End Function



'--------------090424------------------------------
Public Sub RangeS(Optional SheetField = "", Optional Value = "")
On Error Resume Next
    If SheetField = "" Then Exit Sub

    Dim f
    f = Split(SheetField, ".")
    
    If UBound(f) = 0 Then
        Range(f(0)).Value = Value
    Else
        Worksheets(f(0)).Range(f(1)).Value = Value
    End If
Err.Clear
End Sub

'----------------090402-------------------------------
Sub CopyColDaA(rS, rE, cS, cE)

    Range(Cells(rS, cS), Cells(rE, cS)).Select
    Selection.Copy
    Range(Cells(rS, cE), Cells(rE, cE)).Select
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False

End Sub

'----------------090401--------------------------------

Sub WorkBookName_Kill(sName, Optional kill As Boolean = False)
    Dim ns As Name
    For Each ns In ActiveWorkbook.Names
        If InStr(1, ns.Name, sName) > 0 Then
            Debug.Print ns.Name, ns.RefersTo
            If kill = True Then ns.Delete
        End If
    Next ns
End Sub

Public Sub WorkBookName_Set(sSheet As String, sName As String, sReferTo As String)
On Error Resume Next
Dim r, n
    If Trim(sReferTo) = "" Then Exit Sub
    r = "=" & sSheet & "!" & sReferTo
    n = sSheet & "_" & sName
    ActiveWorkbook.Names.Add Name:=n, RefersTo:=r
Err.Clear
End Sub

Function RangeByRefersTo(RefersTo, Optional sSheet = "") As String
    Dim ns As Name
    Dim s, sRefersTo
    RangeByRefersTo = ""
    If sSheet <> "" Then
        sRefersTo = "=" & sSheet & "!" & RefersTo
    Else
        sRefersTo = RefersTo
    End If
    For Each ns In ActiveWorkbook.Names
        If ns.RefersTo = sRefersTo Then RangeByRefersTo = ns.Name
    Next ns
    
End Function



Sub WorkBookName_ListKill(Optional sSheet As String = "*", Optional FindName As String = "*", Optional kill As Boolean = False)
    Dim ns As Name
    Dim sK As String
    If kill = True Then
        sK = " > Kill!"
    Else
        sK = ""
    End If
    For Each ns In ActiveWorkbook.Names
        If FindName <> "*" And sSheet <> "*" Then
            If InStr(1, ns.RefersTo, "=" & sSheet & "!") > 0 And InStr(1, ns.Name, FindName) > 0 Then
                Debug.Print ns.Name, ns.RefersTo, sK
                If kill = True Then ns.Delete
            End If
        ElseIf FindName <> "*" And sSheet = "*" Then
            If InStr(1, ns.Name, FindName) > 0 Then
                Debug.Print ns.Name, ns.RefersTo, sK
                If kill = True Then ns.Delete
            End If
        ElseIf FindName = "*" And sSheet <> "*" Then
            If InStr(1, ns.RefersTo, "=" & sSheet & "!") > 0 Then
                Debug.Print ns.Name, ns.RefersTo, sK
                If kill = True Then ns.Delete
            End If
        ElseIf FindName = "*" And sSheet = "*" Then
            Debug.Print ns.Name, ns.RefersTo, sK
            If kill = True Then ns.Delete
        End If
    Next ns
End Sub


Sub WorkBookName_ListFieldsFunction(Optional sSheet As String = "*", Optional FindName As String = "*")
    Dim ns As Name
    Dim sN
    For Each ns In ActiveWorkbook.Names
        sN = NamesGetName(ns.Name)
        If Left(sN, Len(sSheet)) = sSheet Then sN = Right(sN, Len(sN) - (Len(sSheet) + 1))
        If FindName <> "*" And sSheet <> "*" Then
            If InStr(1, ns.RefersTo, "=" & sSheet & "!") > 0 And InStr(1, ns.Name, FindName) > 0 Then
                Debug.Print "WorkBookName_Set MY_SHEET, """ & sN & """, """ & NamesGetRange(ns.RefersTo) & """"
            End If
        ElseIf FindName <> "*" And sSheet = "*" Then
            If InStr(1, ns.Name, FindName) > 0 Then
                Debug.Print "WorkBookName_Set MY_SHEET, """ & sN & """, """ & NamesGetRange(ns.RefersTo) & """"
            End If
        ElseIf FindName = "*" And sSheet <> "*" Then
            If InStr(1, ns.RefersTo, "=" & sSheet & "!") > 0 Then
                Debug.Print "WorkBookName_Set MY_SHEET, """ & sN & """, """ & NamesGetRange(ns.RefersTo) & """"
            End If
        ElseIf FindName = "*" And sSheet = "*" Then
                Debug.Print "WorkBookName_Set MY_SHEET, """ & sN & """, """ & NamesGetRange(ns.RefersTo) & """"
        End If
    Next ns
End Sub

Public Function NamesGetRange(RefersTo)
Dim i
i = InStr(1, RefersTo, "!")
NamesGetRange = Trim(Right(RefersTo, Len(RefersTo) - i))

End Function

Public Function NamesGetName(Name)
Dim i
i = InStr(1, Name, "!")
NamesGetName = Trim(Right(Name, Len(Name) - i))

End Function



Public Function RangeG(Optional SheetField = "", Optional Row = "", Optional Col = "", Optional SEP = ".")
On Error Resume Next
    Row = -1
    Col = -1
    RangeG = ""
    If SheetField = "" Then Exit Function
    Dim f
    f = Split(SheetField, SEP)
    If UBound(f) = 0 Then
        RangeG = Range(f(0)).Value
        Row = Range(f(0)).Row
        Col = Range(f(0)).Column
    Else
        RangeG = Worksheets(f(0)).Range(f(1)).Value
        Row = Worksheets(f(0)).Range(f(1)).Row
        Col = Worksheets(f(0)).Range(f(1)).Column
    End If
Err.Clear
End Function


Public Sub RangeCopy(Optional SheetFieldStart = "", Optional SheetFieldEnd = "")
On Error Resume Next
    If SheetFieldStart = "" Or SheetFieldEnd = "" Then Exit Sub
    Dim f
    f = RangeG(SheetFieldStart)
    RangeS SheetFieldEnd, f

Err.Clear
End Sub


Public Sub Sheet_HeadingsAll(sWb As String, OnOff As Boolean)
    Dim mywb As Workbook
    Dim mysh As Worksheet

    For Each mywb In Workbooks
        If InStr(1, mywb.Name, sWb, vbTextCompare) > 0 Then
            mywb.Activate
            For Each mysh In Worksheets
                Sheet_Headings mysh, OnOff
            Next mysh
        End If
    Next mywb

End Sub

Private Sub Sheet_Headings(gwks As Worksheet, OnOff As Boolean)
    gwks.Select
    If ActiveWindow.DisplayHeadings <> OnOff Then
        ActiveWindow.DisplayHeadings = OnOff
    End If
End Sub








Public Sub ApplicationUndo()
    If bCh = False Then
        bCh = True
        Application.Undo
    End If
    bCh = False
End Sub

Public Function RangeToString(sheet As Worksheet, StartRow, EndRow, DataCols, Optional IncludiVuote As Boolean = True, Optional ColonnaControlloVuota As Integer = 0) As String
On Error GoTo Gest_Err
    Dim sRows As String, sRow As String, sVuota
    Dim ir, ic, upC, lwC, iFirst
    
    lwC = LBound(DataCols)
    upC = UBound(DataCols)

    RangeToString = ""
    sVuota = ""
    For ic = lwC + 1 To upC
        sVuota = sVuota & vbTab & ""
    Next ic

    iFirst = 0
    For ir = StartRow To EndRow
        sRow = Trim(sheet.Cells(ir, DataCols(lwC)).Value)
        For ic = lwC + 1 To upC
            sRow = sRow & vbTab & Trim(sheet.Cells(ir, DataCols(ic)).Value)
        Next ic
        
        If IncludiVuote = False Then
            If ColonnaControlloVuota > 0 Then
                If Trim(sheet.Cells(ir, ColonnaControlloVuota).Value) = "" Then GoTo next_iR
            End If
            If sVuota = sRow Then GoTo next_iR
        End If

        If iFirst = 0 Then
            sRows = sRow
            iFirst = 1
        Else
            sRows = sRows & vbCrLf & sRow
        End If

next_iR:
    Next ir
    
    RangeToString = sRows
    
    Exit Function
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Function





Public Sub RangeToFile(File, sSheet, StartRow, EndRow, DataCols)
Dim sDati, myArray(), r(), c()
Dim sheet As Worksheet
    Set sheet = Worksheets(sSheet)
    
    RangeToArray sheet, StartRow, EndRow, DataCols, myArray, r, c
    Matrix_PutInString myArray, sDati
    String_ToFile File, sDati

End Sub




Public Function RangeToMatrix(sheet As Worksheet, StartRow, EndRow, DataCols)

    Dim ir, ic, upC, lwC, nRow, kR
    Dim myMatrix()
    
    lwC = LBound(DataCols)
    upC = UBound(DataCols)
    nRow = EndRow - StartRow + 1
    
    kR = 0
    ReDim myMatrix(kR To nRow - 1, lwC To upC)

        
    For ir = StartRow To EndRow
        For ic = lwC To upC
            myMatrix(kR, ic) = sheet.Cells(ir, DataCols(ic)).Value
        Next ic
        kR = kR + 1
    Next ir
    RangeToMatrix = myMatrix
End Function


Public Function ArrayToRange(sheet As Worksheet, StartRow, StartCol, myArray())

    Dim ir, ic, upR, lwR, upC, lwC, kR, kC
    
    lwR = LBound(myArray, 1)
    upR = UBound(myArray, 1)
    lwC = LBound(myArray, 2)
    upC = UBound(myArray, 2)
    
    kR = 0
    kC = 0
    For ir = StartRow To StartRow + upR
        For ic = StartCol To StartCol + upC
            sheet.Cells(ir, ic).Value = myArray(kR, kC)
            kC = kC + 1
        Next ic
        kR = kR + 1
        kC = 0
    Next ir

End Function

Public Sub ColCopy(sheet As Worksheet, StartRow, EndRow, FontCol, TargetCol)
Dim iRow
    For iRow = StartRow To EndRow
           sheet.Cells(iRow, TargetCol).Value = sheet.Cells(iRow, FontCol).Value
    Next iRow
End Sub

Public Sub CelCopy(sheet As Worksheet, TargetRow, FontCol, TargetCol)
    sheet.Cells(TargetRow, TargetCol).Value = sheet.Cells(TargetRow, FontCol).Value
End Sub

Public Sub ColCopyFormat(sheet As Worksheet, StartCol, EndCol, TargetStartCol, TargetEndCol)
    sheet.Range(Cells(1, StartCol), Cells(1, EndCol)).Select
    Selection.EntireColumn.Copy
    sheet.Range(Cells(1, TargetStartCol), Cells(1, TargetEndCol)).Select
    Selection.EntireColumn.PasteSpecial Paste:=xlFormats, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
End Sub

Public Sub ColHide(sheet As Worksheet, StartCol, EndCol, Optional Closed As Boolean, Optional Auto As Boolean = False)
    If StartCol < 1 Or EndCol < 1 Then Exit Sub
    sheet.Select
    If Auto = False Then
        sheet.Range(Cells(1, StartCol), Cells(1, EndCol)).EntireColumn.Hidden = Closed
    Else
        Closed = Not sheet.Range(Cells(1, StartCol), Cells(1, StartCol)).EntireColumn.Hidden
        sheet.Range(Cells(1, StartCol), Cells(1, EndCol)).EntireColumn.Hidden = Closed
    End If
End Sub


Public Sub RowHide(sheet As Worksheet, StartRow, EndRow, Status As Boolean)
    If StartRow < 1 Or EndRow < 1 Then Exit Sub
    sheet.Select
    sheet.Range(Cells(StartRow, 1), Cells(EndRow, 1)).EntireRow.Hidden = Status

End Sub
Public Function RowFind(sheet As Worksheet, Col, Find, Optional StartRow = 1, Optional EndRow = XLS_MAX_ROWS)
    Dim sPar, iRow
    RowFind = -1
    For iRow = StartRow To EndRow
        sPar = Trim(UCase(sheet.Cells(iRow, Col).Value))
        If Trim(UCase(Find)) = sPar Then
            RowFind = iRow
            Exit Function
        End If
    Next iRow
End Function
Public Function RowFindSubStr(sheet As Worksheet, Col, Find, Optional StartRow = 1, Optional EndRow = XLS_MAX_ROWS)
    Dim sPar, iRow
    RowFindSubStr = -1
    For iRow = StartRow To EndRow
        sPar = Trim(UCase(sheet.Cells(iRow, Col).Value))
        If InStr(sPar, Trim(UCase(Find))) > 0 Then
            RowFindSubStr = iRow
            Exit Function
        End If
    Next iRow
End Function

Public Sub ColReset(sheet As Worksheet, StartRow, EndRow, TargetCol)

    sheet.Range(sheet.Cells(StartRow, TargetCol), sheet.Cells(EndRow, TargetCol)).Value = ""

End Sub

Public Sub TargetReset(sheet As Worksheet, StartRow, EndRow, StartCol, EndCol)
On Error Resume Next
    sheet.Range(sheet.Cells(StartRow, StartCol), sheet.Cells(EndRow, EndCol)).Value = ""
Debug.Print Err.Description
End Sub

Public Function FoglioAttivo() As String

    On Error GoTo sheet
    FoglioAttivo = Trim(ActiveChart.Name)
    
    Exit Function
sheet:
    FoglioAttivo = Trim(ActiveSheet.Name)
    Err.Clear
    
End Function


Public Sub NRowsAdd(sheet As Worksheet, StartRow, nRow)
    sheet.Select
    Range("A" & StartRow).Select
    Dim i
    For i = 1 To nRow
        Selection.EntireRow.Insert
    Next i
End Sub

Public Sub NRowsDel(sheet As Worksheet, StartRow, nRow)
    Dim sRows
    sheet.Select
    sRows = StartRow & ":" & StartRow + nRow - 1
    Rows(sRows).Select
    Application.CutCopyMode = False
    Selection.Delete Shift:=xlUp
    Range("A" & StartRow).Select

''''    Sheet.Select
''''    Range("A" & StartRow).Select
''''    Dim i
''''    For i = 1 To nRow
''''        Selection.EntireRow.Delete
''''    Next i
End Sub

Public Function GetFirstRowEqual(sheet As Worksheet, StartRow, StartCol, Optional Find = "", Optional StopRow = XLS_MAX_ROWS)
    
    Dim sCell, iLastRow, iRow
    sCell = ""
    iRow = StartRow
    GetFirstRowEqual = 0
    Find = CStr(Find)
    Do
        sCell = sheet.Cells(iRow, StartCol).Value
        If CStr(sCell) = Find Then
            Exit Do
        End If
        iRow = iRow + 1
        If iRow > StopRow Then
            GetFirstRowEqual = iRow
            Exit Function
        End If
    Loop
    GetFirstRowEqual = iRow
End Function

Public Function GetFirstColEqual(sheet As Worksheet, StartRow, StartCol, Optional StepCol = 1, Optional Find = "", Optional StopCol = XLS_MAX_COLS)
    
    Dim sCell, iLastCol, iCol
    Dim niente As String
    sCell = ""
    iCol = StartCol
    GetFirstColEqual = 0
    niente = sheet.Name
    Do
        sCell = sheet.Cells(StartRow, iCol).Value
        If sCell = Find Then
            Exit Do
        End If
        iCol = iCol + StepCol
        If iCol > StopCol Then
            GetFirstColEqual = iCol
            Exit Function
        End If
    Loop
    GetFirstColEqual = iCol
End Function

Public Function GetFirstRowNotEqual(sheet As Worksheet, StartRow, StartCol, Optional Find = "", Optional StopRow = XLS_MAX_ROWS)
    
    Dim sCell, iLastRow, iRow
    sCell = ""
    iRow = StartRow
    GetFirstRowNotEqual = 0
    Do
        sCell = sheet.Cells(iRow, StartCol).Value
        If sCell <> Find Then
            Exit Do
        End If
        iRow = iRow + 1
        If iRow > StopRow Then
            GetFirstRowNotEqual = iRow
            Exit Function
        End If
    Loop
    GetFirstRowNotEqual = iRow
End Function

Public Sub Menu_Enable(Menu As String, Optional OnOff As Boolean = True)
'12-7-2004
On Error GoTo Gest_Err
Dim sMenu As String
    sMenu = Split(Menu, "|", , vbTextCompare)
    If UBound(sMenu) > 0 Then
        
    Else
        
    End If
    Application.CommandBars(Menu).Visible = OnOff
    Dim myCBAR As CommandBar
    For Each myCBAR In CommandBars
        If UCase(myCBAR.Name) = UCase(Menu) Then
            myCBAR.Enabled = OnOff
            GoTo FineIF
        End If
    Next
FineIF:
    Exit Sub
Gest_Err:
    MsgBox Err.Description
    Err.Clear
End Sub
