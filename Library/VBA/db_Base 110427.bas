Attribute VB_Name = "db_Base"
'<DATA>: 110427
Option Compare Database
'CreateStructureTable "T_Cmp|T_Map",True,,False

'.....110427..dpe
Public Function Tabella_NumRec(NomeTabella)
    Dim Cnn As New ADODB.Connection
    Dim rS As New ADODB.Recordset
    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "Select * FROM [" & NomeTabella & "]"
    Tabella_NumRec = -1
    On Error GoTo errore

    rS.CursorLocation = adUseClient
    rS.LockType = adLockOptimistic
    rS.Open sQuery, Cnn, 1    ' 1 = adOpenKeyset

    If rS.RecordCount > 0 Then
        Tabella_NumRec = rS.RecordCount
    Else
        Tabella_NumRec = 0
    End If
         
    rS.Close
    Set Cnn = Nothing
    Exit Function
    
errore:
    Err.Clear
    Set Cnn = Nothing
    
End Function
'.....110427..dpe
Public Sub Tabelle_CleanAll()
On Error Resume Next
    Dim sSQL, sTabs, i, j, nLoop, bAllVuote As Boolean
    Dim Cnn As New ADODB.Connection

    Set Cnn = Application.CurrentProject.Connection
    
    sTabs = Split(Obj_List(acTable), "|")
    bAllVuote = False
    For j = 1 To 100
        If bAllVuote = True Then GoTo FineLoop
        bAllVuote = True
        For i = LBound(sTabs) To UBound(sTabs)
            
            If Tabella_NumRec(sTabs(i)) > 0 Then
                sSQL = "DELETE * FROM " & Trim(sTabs(i))
                Cnn.Execute sSQL
                Err.Clear
                bAllVuote = False
            End If

        Next i
    Next j
FineLoop:
    nLoop = j - 1
    
    Debug.Print nLoop, bAllVuote
    Set Cnn = Nothing


End Sub


'---------101010
Public Sub Matrix_GetFromStringLoc(sDati, myArray(), Optional Sep = vbTab)
    On Error Resume Next

    Dim sRows() As String
    Dim sValori() As String
    Dim iR, iC, upR, lwR, upC, lwC, upC1, lwC1


    sRows = Split(sDati, vbCrLf)
    lwR = LBound(sRows)
    upR = UBound(sRows)
    lwC = 0
    upC = 0
    

    For iR = lwR To upR
        sValori = Split(sRows(iR), Sep)
        If UBound(sValori) > upC Then upC = UBound(sValori)
    Next iR
    
    ReDim myArray(lwR To upR, lwC To upC)
    
    For iR = lwR To upR
        sValori = Split(sRows(iR), Sep)
        For iC = lwC To upC
            myArray(iR, iC) = sValori(iC)
            Err.Clear
        Next iC
    Next iR


End Sub


Public Sub CreateStructureTable(Optional sPerfisso = "MSys", Optional bConPrefisso As Boolean = False, Optional sFind = "", Optional bParentesi As Boolean = True)
On Error Resume Next
    
    Dim Cnn As New ADODB.Connection
    Dim rstMDB As ADODB.Recordset
    Dim rstTable As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String
    Dim sTable As String
    Dim myMatrix(), Dati

    Set Cnn = Application.CurrentProject.Connection
    Set rstMDB = New ADODB.Recordset
    strSQL = "DELETE * FROM Tab_StrutturaDb;"
    Cnn.Execute strSQL
    Err.Clear
    
    strSQL = "SELECT * FROM Tab_StrutturaDb;"
    rstMDB.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

    
    Dati = GetStructureDb(sPerfisso, bConPrefisso, sFind)
    If bParentesi = False Then
        Dati = Replace(Dati, "[", "")
        Dati = Replace(Dati, "]", "")
    End If
    
    Matrix_GetFromStringLoc Dati, myMatrix
    
    
    Dim iR, iC, upR, lwR, upC, lwC

    lwR = LBound(myMatrix, 1)
    upR = UBound(myMatrix, 1)
    lwC = LBound(myMatrix, 2)
    upC = UBound(myMatrix, 2)

    
    For iR = lwR To upR
        rstMDB.AddNew
        For iC = lwC To upC
            rstMDB.Fields(iC).Value = myMatrix(iR, iC)
        Next iC
        rstMDB.Update
    Next iR
    
    rstMDB.Close
    Set rstMDB = Nothing
    Cnn.Close
    Set Cnn = Nothing
    

End Sub











Public Function GetStructureDb(Optional sPerfisso = "MSys", Optional bConPrefisso As Boolean = False, Optional sFind = "")
Dim i, j, k
Dim sTbl, Tbl() As String
Dim sFieldsFromTbl, FieldsFromTbl() As String, sFieldsFromTblType, FieldsFromTblType() As String

sTbl = Obj_List(acTable, sPerfisso, bConPrefisso, , sFind)
'Debug.Print sTbl
    GetStructureDb = ""
    Tbl = Split(sTbl, "|")
    For i = LBound(Tbl) To UBound(Tbl)
'        Debug.Print Tbl(i)
        GetFieldsFromTab Tbl(i), sFieldsFromTbl, sFieldsFromTblType
        FieldsFromTbl = Split(sFieldsFromTbl, "|")
        FieldsFromTblType = Split(sFieldsFromTblType, "|")
        For j = LBound(FieldsFromTbl) To UBound(FieldsFromTbl)
            If i = 0 And j = 0 Then
                GetStructureDb = Tbl(i) & vbTab & FieldsFromTbl(j) & vbTab & FieldsFromTblType(j)
            Else
                GetStructureDb = GetStructureDb & vbCrLf & Tbl(i) & vbTab & FieldsFromTbl(j) & vbTab & FieldsFromTblType(j)
            End If
        Next j
    Next i

End Function




Public Sub GetFieldsFromTab(sTab, FieldsFromTab, Optional FieldsFromTabType, Optional FindField = "", Optional bEqual As Boolean = False)
On Error Resume Next
    Dim Cnn As New ADODB.Connection
    Dim rS As New ADODB.Recordset
    Dim sQuery, i, nR, bAdd As Boolean
    
    
    Set Cnn = Application.CurrentProject.Connection
    rS.CursorLocation = adUseClient
    sQuery = "select top 1 * from [" & sTab & "]"
    FieldsFromTab = ""
    FieldsFromTabType = ""
    
    rS.LockType = adLockOptimistic
    rS.Open sQuery, Cnn, 1    ' 1 = adOpenKeyset
    nR = rS.RecordCount
    bAdd = False
    If nR = 0 Then
        rS.AddNew
        bAdd = True
    End If

    For i = 0 To rS.Fields.Count - 1
        If bEqual = False Then
            If InStr(1, Trim(rS(i).Name), FindField) > 0 Then
                FieldsFromTabType = FieldsFromTabType & Trim(rS(i).Type) & "|"
                FieldsFromTab = FieldsFromTab & "[" & Trim(rS(i).Name) & "]|"
            End If
        Else
            If UCase(Trim(rS(i).Name)) = UCase(FindField) Then
                FieldsFromTabType = FieldsFromTabType & Trim(rS(i).Type) & "|"
                FieldsFromTab = FieldsFromTab & "[" & Trim(rS(i).Name) & "]|"
            End If
        End If
    Next i
    
    FieldsFromTab = Trim(FieldsFromTab)
    FieldsFromTabType = Trim(FieldsFromTabType)
    If FieldsFromTab <> "" Then
        FieldsFromTabType = Left(FieldsFromTabType, Len(FieldsFromTabType) - 1)
        FieldsFromTab = Left(FieldsFromTab, Len(FieldsFromTab) - 1)
    End If
    
    If bAdd = True Then
        rS.Cancel
    End If
Err.Clear
End Sub





Public Function Obj_List(TipoObj As AcObjectType, Optional Prefisso = "MSys", Optional bConPrefisso As Boolean = False, Optional Sep = "|", Optional FindString = "") As String
On Error Resume Next

    Dim obj As AccessObject, dbs As Object, ObjGroup As Object
    Dim sPrefisso() As String
    Dim sFindString() As String
    Dim sObj As String
    Dim bPresente As Boolean
    Dim i
    Dim Obj_List_ConPrefisso As String, Obj_List_SnzPrefisso As String
    
    sPrefisso = Split(Prefisso, "|")
    sFindString = Split(FindString, "|")
    Obj_List = ""
    Obj_List_ConPrefisso = ""
    Obj_List_SnzPrefisso = ""
    
    Select Case TipoObj
    Case acTable
        Set dbs = Application.CurrentData
        Set ObjGroup = dbs.AllTables
    Case acForm
        Set dbs = Application.CurrentProject
        Set ObjGroup = dbs.AllForms
    Case acModule
        Set dbs = Application.CurrentProject
        Set ObjGroup = dbs.AllModules
    Case acReport
        Set dbs = Application.CurrentProject
        Set ObjGroup = dbs.AllReports
    Case acQuery
        Set dbs = Application.CurrentData
        Set ObjGroup = dbs.AllQueries
    Case Else
        Exit Function
    End Select


    For Each obj In ObjGroup
        sObj = obj.Name
        If FindString = "" Then
            If Prefisso <> "" Then
                bPresente = False
                For i = LBound(sPrefisso) To UBound(sPrefisso)
                        If Trim(sPrefisso(i)) = Left(sObj, Len(Trim(sPrefisso(i)))) Then bPresente = True
                Next i
                If bPresente = True Then
                    Obj_List_ConPrefisso = Obj_List_ConPrefisso & Sep & sObj
                Else
                    Obj_List_SnzPrefisso = Obj_List_SnzPrefisso & Sep & sObj
                End If
            Else
                Obj_List_ConPrefisso = Obj_List_ConPrefisso & Sep & sObj
                Obj_List_SnzPrefisso = Obj_List_SnzPrefisso & Sep & sObj
            End If
        ElseIf FindString <> "" Then
                bPresente = False
                For i = LBound(sFindString) To UBound(sFindString)
                        If InStr(1, sObj, Trim(sFindString(i))) > 0 Then bPresente = True
                Next i
                If bPresente = True Then
                    Obj_List_ConPrefisso = Obj_List_ConPrefisso & Sep & sObj
                Else
                    Obj_List_SnzPrefisso = Obj_List_SnzPrefisso & Sep & sObj
                End If
        End If
        
  
        
        
    Next obj
    
    If Obj_List_ConPrefisso <> "" Then Obj_List_ConPrefisso = Right(Trim(Obj_List_ConPrefisso), Len(Obj_List_ConPrefisso) - 1)
    If Obj_List_SnzPrefisso <> "" Then Obj_List_SnzPrefisso = Right(Trim(Obj_List_SnzPrefisso), Len(Obj_List_SnzPrefisso) - 1)
'    Debug.Print "con:", Obj_List_ConPrefisso
'    Debug.Print "snz:", Obj_List_SnzPrefisso

    If bConPrefisso = True Then
        Obj_List = Obj_List_ConPrefisso
    Else
        Obj_List = Obj_List_SnzPrefisso
    End If
'    Debug.Print "fin:", Obj_List

Err.Clear
End Function
