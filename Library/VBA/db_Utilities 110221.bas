Attribute VB_Name = "db_Utilities"
'<DATA>: 110221
Option Compare Database
Option Explicit


'-----110221
Public Sub DB_CreaBackUp(Optional sTipo = "DATI", Optional SubFolder = "")
On Error GoTo Gest_Err
Dim s, s1, t, sBckDir
Dim sPathFile As String, sList As String

    Dim cn As myCnn
    cn = GetDBPredefinito
    If cn.Type = "ODBC" Then Exit Sub




    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2
    
    
    sBckDir = GetApplicationSubPath("BCK") & "\" & GetNewID("MDB-") & "-" & sTipo
    
    sBckDir = InputBox("Percorso di salvataggio", "BCK", sBckDir)
    
    If sBckDir = "" Then
        MsgBox "Operazione annullata", vbCritical
        GoTo FineBCK
    End If
    
    
    MkDir sBckDir
    
    If sTipo = "FONT" Then
        sPathFile = sBckDir & "\db_forms_font.mdb"
        FileCopy GetApplicationSubPath("Fonts") & "\Vuoto.mdb", sPathFile
        
        sList = Obj_List(acForm, "main|z_main", True)
        Debug.Print sList
        Obj_Load acExport, acForm, sPathFile, sList, sList, , "Microsoft Access", False
        
        sList = Obj_List(acModule, "db_|mdl|cls", True)
        Debug.Print sList
        Obj_Load acExport, acModule, sPathFile, sList, sList, , "Microsoft Access", False
        
        sList = Obj_List(acTable, "main", True)
        Debug.Print sList
        Obj_Load acExport, acTable, sPathFile, sList, sList, , "Microsoft Access", False
        
        GoTo FineBCK
    End If
    
    If sTipo = "PROGETTO" Then DB_CreaReplica sBckDir
    
    s1 = sBckDir & "\" & GetFileName(cn.Source)
    
    t = GetDBTabStart
    Obj_UnLoad acTable, t
    PauseTime 2
    
    
    File_Copy cn.Source, s1
    If SubFolder <> "" Then Folder_Copy cn.Path & "\" & SubFolder, sBckDir & "\" & SubFolder
    
    
    PauseTime 2
    
    Obj_Load acLink, acTable, cn.Source, t, t, "", cn.Type, True

FineBCK:
    DoCmd.Close acForm, "main_Attendi"
    
    
    Exit Sub
Gest_Err: 'On Error GoTo gest_err
    MsgBox Err.Description
    Err.Clear
End Sub

'---------110209
Public Sub List_SetElencoConAsterisco(ctl As Control, Optional sTable = "", Optional sField = "", Optional Asterisco = "*", Optional sSQL = "")
Dim s, s1

    ctl.RowSourceType = "Elenco valori"
    
    ctl.RowSource = ""
    ctl.Selected(0) = True
    
    s = Asterisco & ";" & GetFromTableColonna(sTable, sField, ";", True, sSQL)
    
    ctl.RowSource = s
    ctl.Selected(0) = True
    ctl.Value = Asterisco
    
End Sub

'---------101019
Public Function GetFromTableColonna(Optional sTable = "", Optional sField = "", Optional Sep = "|", Optional Distinct As Boolean = False, Optional sSQL = "")
On Error Resume Next
    
    Dim Cnn As New ADODB.Connection
    Dim rstMDB As ADODB.Recordset

    Dim strCnn As String
    Dim strSQL As String
    Dim iR

    GetFromTableColonna = ""

    If Trim(sTable & sField & sSQL) = "" Then Exit Function
    

    Set Cnn = Application.CurrentProject.Connection
    Set rstMDB = New ADODB.Recordset
    
    If Distinct = False Then
        strSQL = "SELECT [" & sField & "] FROM [" & sTable & "] ORDER BY [" & sField & "] DESC"
    Else
        strSQL = "SELECT DISTINCT [" & sField & "] FROM [" & sTable & "]  ORDER BY [" & sField & "] DESC"
    End If
    If sSQL <> "" Then strSQL = sSQL
    
    
    rstMDB.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

    rstMDB.MoveFirst
    For iR = 1 To rstMDB.RecordCount
        GetFromTableColonna = rstMDB(0).Value & Sep & GetFromTableColonna
        rstMDB.MoveNext
    Next iR
    If GetFromTableColonna = "" Then
    
    Else
        GetFromTableColonna = Left(GetFromTableColonna, Len(GetFromTableColonna) - 1)
    End If
    
    rstMDB.Close
    Set rstMDB = Nothing
    Cnn.Close
    Set Cnn = Nothing
    Err.Clear

End Function




'---------101018


'---------101010
Public Sub DB_Delete(Optional TableList = "")
On Error Resume Next
Dim s, s1, t, t1

    Dim cn As myCnn
    cn = GetDBPredefinito

    If TableList = "" Then
        TableList = InputBox("Dammi l'elenco delle tabelle da svuotare separato da | ", "Svuota tabelle", "")
    End If

    If TableList = "" Then Exit Sub

    Dim Resp
    Resp = MsgBox("SVUOTAMENTO DELLE TABELLE " & vbCrLf & TableList & vbCrLf & vbCrLf & "VUOI FARE UN BACK-UP?", vbYesNoCancel, "Cancella Tabelle")
    If Resp = vbCancel Then Exit Sub
    If Resp = vbYes Then
        If cn.Type = "ODBC" Then
            MsgBox "La connessione di tipo " & cn.Type & " e non si può fare il backup"
            Exit Sub
        End If
        DB_CreaBackUp "DATI"
    End If


    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2

    Tabelle_Delete TableList
    Tabelle_Delete TableList
    Tabelle_Delete TableList
    Tabelle_Delete TableList

    DoCmd.Close acForm, "main_Attendi"

Err.Clear
End Sub

Public Sub Tabelle_Delete(Optional sMyTabelle = "")
On Error GoTo Gest_Err
    Dim sSQL, sTabs, i
    Dim Cnn As New ADODB.Connection

    If sMyTabelle = "" Then
        sMyTabelle = InputBox("Dammi l'elenco delle tabelle da svuotare separato da | ", "Svuota tabelle", "")
    End If

    If sMyTabelle = "" Then Exit Sub
    
    Const SQL = "DELETE sMyTabelle.* FROM sMyTabelle;"
    Set Cnn = Application.CurrentProject.Connection
    
    sTabs = Split(sMyTabelle, "|")
    
    For i = LBound(sTabs) To UBound(sTabs)
        On Error Resume Next
        sSQL = Replace(SQL, "sMyTabelle", Trim(Trim(sTabs(i))))
        Cnn.Execute sSQL
        Err.Clear
    Next i

    Set Cnn = Nothing
    Exit Sub
    
    Exit Sub
Gest_Err:
    Debug.Print Err.Description
    Err.Clear
    Resume Next
    
End Sub
'----------------100918

Public Sub DB_CreaFontDati()
On Error Resume Next
Dim s, s1, t, t1, sBckDir

    Dim cn As myCnn
    cn = GetDBPredefinito
    If cn.Type = "ODBC" Then Exit Sub
    
    DoCmd.OpenForm "main_Attendi", acNormal
    PauseTime 2
    
    
    s1 = GetApplicationSubPath("Fonts") & "\db_Dati_font.mdb"
    
    t = GetDBTabStart
    Obj_UnLoad acTable, t
    
    PauseTime 2
    FileCopy cn.Source, s1
    
    
    Obj_Load acLink, acTable, s1, t, t, "", cn.Type, True
    
    t1 = Obj_List(acTable, "MSys|Main", False)
    Tabelle_Delete t1
    Tabelle_Delete t1
    Tabelle_Delete t1
    Tabelle_Delete t1
    
    Obj_UnLoad acTable, t
    Obj_Load acLink, acTable, cn.Source, t, t, "", cn.Type, True
    
    DoCmd.Close acForm, "main_Attendi"

Err.Clear
End Sub


Public Sub DB_CreaBackUpDati_XML()
Dim sList, sTable, i, sBckDir

    sList = Obj_List(acTable)
    sTable = Split(sList, "|")
    
    sBckDir = GetApplicationSubPath("BCK") & "\XML-" & GetNewID

    MkDir sBckDir
    
    For i = LBound(sTable) To UBound(sTable)
        RstTable_SaveXML sBckDir, sTable(i)
    Next i

    MsgBox "BCK " & "OK"
    Exit Sub
Gest_Err: 'On Error GoTo gest_err
    MsgBox "BCK " & Err.Description
    Err.Clear
End Sub



'-----------------------100527
Public Function Rec_GetNum(sTable, sField, sFind)
    Dim Cnn As New ADODB.Connection
    Dim rstMDB As ADODB.Recordset
    Dim strCnn As String
    Dim strSQL As String
    Rec_GetNum = 0
    
    Set Cnn = Application.CurrentProject.Connection
    Set rstMDB = New ADODB.Recordset

    strSQL = "SELECT [" & sField & "] FROM " & sTable & " WHERE ((([" & sField & "])='" & sFind & "'));"
    rstMDB.Open strSQL, Cnn, adOpenKeyset, adLockOptimistic

    If rstMDB.RecordCount >= 0 Then Rec_GetNum = rstMDB.RecordCount
    
    Set rstMDB = Nothing
    Set Cnn = Nothing
    
End Function

Public Sub Rec_Kill(FormEdt As myFormEdt, Optional bMsg As Boolean = True)
'==========================================
'
'==========================================


    If bMsg = True Then
        If MsgBox("Vuoi davvero eliminare il record?" & vbCrLf & FormEdt.IDValue, vbYesNo, "Elimina") = vbNo Then Exit Sub
    End If
    
    Dim Cnn As ADODB.Connection
    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    Select Case gMyFormEdt.IDFieldType
    Case "stringa"
        sQuery = "DELETE [" & FormEdt.Tabella & "].* FROM [" & FormEdt.Tabella & "] WHERE ((([" & FormEdt.IDField & "])='" & FormEdt.IDValue & "'));"
    Case "numerico"
        sQuery = "DELETE [" & FormEdt.Tabella & "].* FROM [" & FormEdt.Tabella & "] WHERE ((([" & FormEdt.IDField & "])=" & FormEdt.IDValue & "));"
    Case "guid"
        MsgBox "fare guid"
    End Select
    
    Cnn.Execute sQuery
    
    Set Cnn = Nothing
    
End Sub

Public Sub Rec_Add(FormEdt As myFormEdt)
'==========================================
'
'==========================================

    Dim Cnn As ADODB.Connection
    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "INSERT INTO " & FormEdt.Tabella & " (" & FormEdt.NewField & ") VALUES ('" & FormEdt.NewValue & "')"
'    Debug.Print sQuery
    Cnn.Execute sQuery
    Set Cnn = Nothing
    
End Sub



'-----------------------------------------100512
Public Function SetField(rst As ADODB.Recordset, field, Value) As String

    SetField = ""
    
    If NullToString(field) = "" Then
        Debug.Print vbTab & "update" & vbTab & "Errore" & vbTab & "Nome Campo vuoto!"
        Exit Function
    End If

Dim i, j, k
    For i = 0 To rst.Fields.Count - 1
        If rst.Fields(i).Name = field Then
            rst.Fields(i).Value = Value
            GoTo Update
        End If
    Next i
Update:
    On Error GoTo NoUpdate
    rst.Update

    SetField = vbTab & "update" & vbTab & "Ok" & vbTab & field & vbTab & Left(Value, 10) & " ....."
    
    Exit Function
NoUpdate:
    SetField = vbTab & "update" & vbTab & "Errore" & vbTab & field & vbTab & Left(Value, 10) & " ....." & vbTab & Err.Description
    Err.Clear
    rst.CancelUpdate
    
End Function

'---------------------------------------------


Sub db_EraseTab(Optional Prefisso = "MSys|Main")
On Error Resume Next
Dim t

    t = Obj_List(acTable, Prefisso)
    Obj_UnLoad acTable, t, ""
    
Err.Clear
End Sub



'---------------------------------------------



'----------------- 100222 --------------------




Public Sub RstTable_SaveXML(Path, Table)
    On Error Resume Next

    Dim strSQL As String
    strSQL = "SELECT * FROM " & Table
    
    RstSQL_SaveXML Path, strSQL, Table
    
    Err.Clear
End Sub

Public Sub RstSQL_SaveXML(Path, SQL, SqlName)

    On Error GoTo ErrorHandler

    'recordset and connection variables
    Dim rstTable As ADODB.Recordset
    Dim Cnxn As ADODB.Connection
    Dim strCnxn As String
    Dim sPath As String
     
    
    Set Cnxn = Application.CurrentProject.Connection

    Set rstTable = New ADODB.Recordset
    rstTable.Open SQL, Cnxn, adOpenDynamic, adLockOptimistic, adCmdText
    
    'For sake of illustration, save the Recordset to a diskette in XML format
    rstTable.Save Path & "\" & SqlName & ".xml", adPersistXML

    ' clean up
    rstTable.Close
    Cnxn.Close
    Set rstTable = Nothing
    Set Cnxn = Nothing
    Exit Sub
    
ErrorHandler:
    'clean up
    If Not rstTable Is Nothing Then
        If rstTable.State = adStateOpen Then rstTable.Close
    End If
    Set rstTable = Nothing
    
    If Not Cnxn Is Nothing Then
        If Cnxn.State = adStateOpen Then Cnxn.Close
    End If
    Set Cnxn = Nothing
    
    If Err <> 0 Then
        MsgBox Err.Source & "-->" & Err.Description, , "Error"
    End If
End Sub



Public Sub RstTable_LoadXML(Optional sPathXMLFile = "")
' mettere adox per ricerca key
    On Error GoTo ErrorHandler
    
    'To integrate this code
    'replace the data source and initial catalog values
    'in the connection string
    
    Dim Cnxn As New ADODB.Connection
    Dim rstXML As ADODB.Recordset
    Dim rstMDB As ADODB.Recordset
    Dim strCnxn As String
    Dim strSQL As String
    Dim sTable As String
    Dim sPathFileStart As String
    Dim sFileXML As String
        
    If sPathXMLFile = "" Then
        Dim commonDialog1 As New clsDialog
        commonDialog1.InitDir = GetApplicationSubPath("Sinc")
        commonDialog1.Filter = "Files xml|*.xml"
        'show the open window
        commonDialog1.ShowOpen
        sPathXMLFile = commonDialog1.FileName
        sFileXML = GetFileName(sPathXMLFile)
        If sFileXML = "" Then Exit Sub
    End If

    sTable = GetFileNameNoExt(sFileXML)

    strSQL = "SELECT * FROM " & sTable
    sPathXMLFile = sTable & ".xml"
    
    Set rstXML = New ADODB.Recordset
    ' The lock mode is batch optimistic because we are going to
    ' use the UpdateBatch method.
    rstXML.Open sPathXMLFile, "Provider=MSPersist;", adOpenForwardOnly, adLockBatchOptimistic, adCmdFile
    
    Set Cnxn = Application.CurrentProject.Connection
    Set rstMDB = New ADODB.Recordset
    rstMDB.Open strSQL, Cnxn, adOpenKeyset, adLockOptimistic


''''    Dim i, j
''''    rstXML.MoveFirst
''''    rstMDB.MoveFirst
''''    For i = 1 To rstXML.RecordCount
''''        rstMDB.AddNew
''''        On Error Resume Next
''''        For j = 0 To rstXML.Fields.Count - 1
''''            rstMDB(rstXML(j).Name).Value = rstXML(j).Value
''''            Err.Clear
''''        Next j
''''        rstMDB.Update
''''        rstXML.MoveNext
''''        Err.Clear
''''    Next i

''''    Dim i, j
''''    rstXML.MoveFirst
''''    rstMDB.MoveFirst
''''    For i = 1 To rstMDB.RecordCount
''''        rstXML.AddNew
''''        On Error Resume Next
''''        For j = 0 To rstMDB.Fields.Count - 1
''''            rstXML(rstMDB(j).Name).Value = rstMDB(j).Value
''''            Err.Clear
''''        Next j
''''        rstXML.Update
''''        rstMDB.MoveNext
''''        Err.Clear
''''    Next i

    Dim adoField As ADODB.field
    Dim adoProp As ADODB.Property
    ' Display the property attributes of the Employee Table
'    Debug.Print "Property attributes:"
'    For Each adoProp In rstMDB.PropertiesADOX.Table
'        Debug.Print "   " & adoProp.Name & " = " & adoProp.Attributes
'    Next adoProp
    
    ' Display the field attributes of the Employee Table
    Debug.Print "Field attributes:"
    For Each adoField In rstMDB.Fields
       Debug.Print "   " & adoField.Name & " = " & adoField.Attributes
    Next adoField




'    Dim i, j
'    rstXML.MoveFirst
'    rstMDB.MoveFirst
'    For i = 1 To rstMDB.RecordCount
'        On Error Resume Next
'        For j = 0 To rstMDB.Fields.Count - 1
'            Debug.Print rstMDB(j).Name, rstMDB(j).Type
'            Err.Clear
'        Next j
'        rstMDB.MoveNext
'        Err.Clear
'    Next i


    ' clean up
    rstXML.Close
    rstMDB.Close
    Cnxn.Close
    Set rstXML = Nothing
    Set Cnxn = Nothing
    Exit Sub
    
ErrorHandler:
    'clean up
    If Not rstXML Is Nothing Then
        If rstXML.State = adStateOpen Then rstXML.Close
    End If
    Set rstXML = Nothing
    
    If Not Cnxn Is Nothing Then
        If Cnxn.State = adStateOpen Then Cnxn.Close
    End If
    Set Cnxn = Nothing
    
    If Err <> 0 Then
        MsgBox Err.Source & "-->" & Err.Description, , "Error"
    End If
End Sub


'--------------090419----------------------------------
Public Sub Obj_Load(TipoTransfer As AcDataTransferType, TipoObj As AcObjectType, DBOrigine, NomeObjSource, NomeObjDestination, Optional Estensione = "", Optional TipoOrigine = "Microsoft Access", Optional bUnload As Boolean = True)
On Error GoTo Gest_Err
    'controlla esistenza file
    If DBOrigine = "" Then
        MsgBox "La stringa DBOrigine è vuota.", vbCritical, "Caricamento oggetti " & TipoObj
        Exit Sub
    End If

    Dim sObjS() As String
    Dim sObjD() As String
    
    Dim iObj As Integer
    sObjS = Split(NomeObjSource, "|")
    sObjD = Split(NomeObjDestination, "|")
    
    If (bUnload = True) And (TipoTransfer <> acExport) Then
    'lo scaricamento deve valere solo nel db in cui viene eseguita la sub: non può farlo nel db attivo!!!
        Obj_UnLoad TipoObj, NomeObjDestination, Estensione
    End If
    
    For iObj = LBound(sObjS) To UBound(sObjS)
        On Error Resume Next
            DoCmd.TransferDatabase TipoTransfer, TipoOrigine, DBOrigine, TipoObj, Trim(sObjS(iObj)), Trim(sObjD(iObj) & Estensione), False
            If Trim(Err.Description) <> "" Then
                Debug.Print "Obj_Load", "EER", sObjS(iObj), Err.Description
            Else
                Debug.Print "Obj_Load", "OK", sObjS(iObj)
            End If
        Err.Clear
    Next iObj
   
    Exit Sub
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub





'--------------090331-------------------------------------
Public Function PurgeParentesi(TabName)
    PurgeParentesi = Replace(TabName, "[", "")
    PurgeParentesi = Replace(PurgeParentesi, "]", "")
    PurgeParentesi = Trim(PurgeParentesi)

End Function

Public Sub Tabelle_SetIfNull(TabName, field, sReplace)
On Error GoTo Gest_Err
Dim Cnn As New ADODB.Connection
Dim sQuery As String
Dim rS As New ADODB.Recordset
    Set Cnn = Application.CurrentProject.Connection
    TabName = PurgeParentesi(TabName)
    field = PurgeParentesi(field)
    sQuery = " UPDATE [" & TabName & "] SET [" & TabName & "].[" & field & "] = '" & sReplace & "' WHERE ((([" & TabName & "].[" & field & "]) Is Null)) OR ((([" & TabName & "].[" & field & "])=''));"
    Cnn.Execute sQuery
    Set Cnn = Nothing
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub
Public Sub Tabelle_Set(TabName, field, Find, sReplace)
On Error GoTo Gest_Err
Dim Cnn As New ADODB.Connection
Dim sQuery As String
Dim rS As New ADODB.Recordset
    Set Cnn = Application.CurrentProject.Connection
    
    TabName = PurgeParentesi(TabName)
    field = PurgeParentesi(field)
    Find = Replace(Find, "*", "%")
    sQuery = " UPDATE [" & TabName & "] SET [" & TabName & "].[" & field & "] = '" & sReplace & "' WHERE ((([" & TabName & "].[" & field & "]) like '%" & Find & "%'));"
    Debug.Print sQuery
    Cnn.Execute sQuery
    Set Cnn = Nothing
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub








'------------------090328--------------------
Public Sub Tabelle_ListDipendenze(Optional FindTab = "", Optional FindFields = "")

    Dim obj As AccessObject, dbs As Object
    Dim sTabs, sFields, sField, i, sFieldTabs, sFieldsType

    If FindTab <> "" Then
        Debug.Print "Tabella Origine : ", FindTab
        GetFieldsFromTab FindTab, sFields
    Else
        Debug.Print "Campo Origine : ", FindFields
        sFields = FindFields
    End If

    Set dbs = Application.CurrentData
    ' Search for open AccessObject objects in AllTables collection.
    sFields = Replace(sFields, "[", "")
    sFields = Replace(sFields, "]", "")
    sField = Split(sFields, "|")

    For i = LBound(sField) To UBound(sField)
        On Error Resume Next
            Debug.Print "Campo : ", Trim(sField(i))
            
            For Each obj In dbs.AllTables
                sTabs = Trim(obj.Name)
        
                If Left(sTabs, 2) <> "MS" And sTabs <> FindTab Then
                    GetFieldsFromTab sTabs, sFieldTabs, sFieldsType, sField(i), True
                    If sFieldTabs <> "" Then
                        Debug.Print "", sTabs, sFieldTabs
                    End If
        
                End If
            Next obj
            
        Err.Clear
    Next i
    


End Sub

Public Sub Tabelle_ListFields(Optional FindTab = "", Optional FindField = "")

    Dim obj As AccessObject, dbs As Object
    Dim sTabs, sFields, sFieldsType, nField, s1, nTab, nFields
    Set dbs = Application.CurrentData
    ' Search for open AccessObject objects in AllTables collection.
    nFields = 0
    nTab = 0
    For Each obj In dbs.AllTables
        sTabs = Trim(obj.Name)
        nField = 0
        If Left(sTabs, 2) <> "MS" And InStr(1, sTabs, FindTab) > 0 Then
            nTab = nTab + 1
            GetFieldsFromTab sTabs, sFields, sFieldsType, FindField
            s1 = Split(sFields, "|")
            Debug.Print "Tabella:", sTabs, " N°Campi", UBound(s1) + 1, sFields
'            Debug.Print sFields
            nFields = nFields + UBound(s1) + 1
        End If
    Next obj
    Debug.Print "Tabelle:", nTab, "N°Campi:", nFields
End Sub





'---------------090324--------------------------------------
Public Sub Tabelle_AccodaAll(Tabs, IDField, Optional Estensione_Dati = "", Optional Estensione_DaAccodare = "")
    
    Dim sObj() As String
    Dim sID() As String
    Dim iObj As Integer
    sObj = Split(Tabs, "|")
    If IDField = "" Or IDField = "-" Then
        For iObj = LBound(sObj) To UBound(sObj)
            On Error Resume Next
                Tabelle_Accoda Trim(sObj(iObj) & Estensione_Dati), Trim(sObj(iObj) & Estensione_DaAccodare), "-"
            Err.Clear
        Next iObj
    Else
        sID = Split(IDField & "", "|")
        For iObj = LBound(sObj) To UBound(sObj)
            On Error Resume Next
                Tabelle_Accoda Trim(sObj(iObj) & Estensione_Dati), Trim(sObj(iObj) & Estensione_DaAccodare), sID(iObj)
            Err.Clear
        Next iObj
    End If

End Sub






'--------------------090310------------------------------





Public Sub Obj_UnLoad(TipoObj As AcObjectType, NomeObj, Optional Estensione = "")
On Error GoTo Gest_Err

    Dim sObj() As String
    Dim iObj As Integer
    sObj = Split(NomeObj, "|")
    For iObj = LBound(sObj) To UBound(sObj)
        On Error Resume Next
            DoCmd.DeleteObject TipoObj, Trim(sObj(iObj) & Estensione)
            If Trim(Err.Description) <> "" Then
                Debug.Print "Obj_UnLoad", "EER", sObj(iObj), Err.Description
            Else
                Debug.Print "Obj_UnLoad", "OK", sObj(iObj)
            End If
        Err.Clear
    Next iObj
   
    Exit Sub
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub




'--------------------090307------------------------------
Public Sub Tabelle_AggiornaCampoNullo(myTabella, myField, Optional Valore = "-", Optional num As Boolean = False)
On Error GoTo Gest_Err
    Dim sSQL
    Dim Cnn As New ADODB.Connection
    Dim sQuery As String
    Dim rS As New ADODB.Recordset


    If myField = "" Or myField = "-" Or myTabella = "" Then Exit Sub
    If num = False Then
        sSQL = "UPDATE myTabella SET myTabella.[myField] = '" & Valore & "' WHERE ( ((myTabella.[myField] ) Is Null) or ((myTabella.[myField] ) = '' )   );"
    Else
        sSQL = "UPDATE myTabella SET myTabella.[myField] = " & Valore & " WHERE ( ((myTabella.[myField] ) Is Null)    );"
    End If
    sSQL = Replace(sSQL, "myTabella", myTabella)
    sSQL = Replace(sSQL, "myField", myField)

    Set Cnn = Application.CurrentProject.Connection
    Cnn.Execute sSQL
    Set Cnn = Nothing
    Exit Sub
    
    Exit Sub
Gest_Err:
    Debug.Print Err.Description
    Err.Clear
    Resume Next
    
End Sub

Public Sub Tabelle_AggiornaCampo(myTabella, myField, Find, Replace, Optional num As Boolean = False)
On Error GoTo Gest_Err
Dim Cnn As New ADODB.Connection
Dim sSQL As String
Dim rS As New ADODB.Recordset
    If myField = "" Or myField = "-" Or myTabella = "" Then Exit Sub
    If num = False Then
        sSQL = " UPDATE [" & myTabella & "] SET [" & myTabella & "].[" & myField & "] = '" & Replace & "' WHERE ((([" & myTabella & "].[" & myField & "]) like '%" & Find & "%'));"
    Else
        MsgBox "todo: Tabelle_AggiornaCampo completare"
    '    sSQL = " UPDATE [" & myTabella & "] SET [" & myTabella & "].[" & myField & "] = " & Replace & " WHERE ((([" & myTabella & "].[" & myField & "]) like '%" & find & "%'));"
    End If
    
    Set Cnn = Application.CurrentProject.Connection
    Cnn.Execute sSQL
    Set Cnn = Nothing
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    Debug.Print Err.Description
    Err.Clear
    Resume Next
End Sub

Public Function Tabelle_List(Optional bParentesi As Boolean = False)

    Dim obj As AccessObject, dbs As Object
    Dim sTabs
    Set dbs = Application.CurrentData
    ' Search for open AccessObject objects in AllTables collection.
    For Each obj In dbs.AllTables
        If Left(obj.Name, 2) <> "MS" Then
            If bParentesi = False Then
                sTabs = sTabs & "|" & Trim(obj.Name)
            Else
                sTabs = sTabs & "|[" & Trim(obj.Name) & "]"
            End If
        End If
    Next obj
    sTabs = Trim(sTabs)
    sTabs = Right(sTabs, Len(sTabs) - 1)
    Debug.Print sTabs
    Tabelle_List = sTabs
End Function

Public Function Tabelle_ListLike(Optional FindTab = "", Optional bParentesi As Boolean = False)
    Tabelle_ListLike = ""
    Dim obj As AccessObject, dbs As Object
    Dim sTabs
    Set dbs = Application.CurrentData
    ' Search for open AccessObject objects in AllTables collection.
    For Each obj In dbs.AllTables
        If Left(obj.Name, 2) <> "MS" And InStr(1, Trim(obj.Name), FindTab) > 0 Then
            If bParentesi = False Then
                sTabs = sTabs & "|" & Trim(obj.Name)
            Else
                sTabs = sTabs & "|[" & Trim(obj.Name) & "]"
            End If
        End If
    Next obj
    sTabs = Trim(sTabs)
    sTabs = Right(sTabs, Len(sTabs) - 1)
    Debug.Print sTabs
    Tabelle_ListLike = sTabs
End Function



Public Sub Tabelle_Accoda(sTab_Dati, sTab_DaAccodare, sIDField)
Dim sFieldsFromTab, sFieldsFromTabType
Dim sFieldsFromTab1, sFieldsFromTabType1
Dim sSQL, sQuery

    GetFieldsFromTab sTab_Dati, sFieldsFromTab, sFieldsFromTabType
    GetFieldsFromTab sTab_DaAccodare, sFieldsFromTab1, sFieldsFromTabType1

    If sFieldsFromTab = "" Then
        sFieldsFromTab = sFieldsFromTab1
        sFieldsFromTabType = sFieldsFromTabType1
    End If
    If sFieldsFromTab1 = "" Then
        sFieldsFromTab1 = sFieldsFromTab
        sFieldsFromTabType1 = sFieldsFromTabType
    End If

    If sFieldsFromTab <> sFieldsFromTab1 Then
        Debug.Print "Campi diversi : impossibile accodamento", sTab_Dati, sTab_DaAccodare
        Exit Sub
    End If
    
    sFieldsFromTab = Replace(sFieldsFromTab, "|", ", ")

    sQuery = "SELECT  [" & sTab_DaAccodare & "].* " & _
        " FROM [" & sTab_DaAccodare & "] " & _
        " LEFT JOIN [" & sTab_Dati & "] ON [" & sTab_DaAccodare & "].[" & sIDField & "] = [" & sTab_Dati & "].[" & sIDField & "] " & _
        " WHERE ((([" & sTab_Dati & "].[" & sIDField & "]) Is Null))"
    Debug.Print sQuery
    
    If sIDField = "" Or sIDField = "-" Then
        sQuery = sTab_DaAccodare
        sSQL = "INSERT INTO [" & sTab_Dati & "] (" & sFieldsFromTab & " ) " & _
            " SELECT " & sFieldsFromTab & _
            " FROM " & sTab_DaAccodare & " "
    Else
        sSQL = "INSERT INTO [" & sTab_Dati & "] (" & sFieldsFromTab & " ) " & _
            " SELECT " & sFieldsFromTab & _
            " FROM ( " & sQuery & " ) AS QueryDati"
    End If
    Debug.Print sSQL
'
    
    DoCmd.RunSQL sSQL, -1


End Sub




'------------------------20090301------------------------------------------
Public Sub Set_UCASE_Tabella(Optional Tabella = "", Optional Risultato)
On Error GoTo Gest_Err

    Dim i, sSQL, sTab, vFields, sFields, sTypes, sRisultato
    Risultato = "Nullo"
    If Tabella = "" Then
        sTab = InputBox("SET", "Tabella", Tabella)
    End If

    If sTab = "" Or sTab = "-" Then Exit Sub
    
    GetFieldsFromTab sTab, sFields, sTypes

    vFields = Split(sFields, "|")
    Risultato = "-----START----- " & sTab & " ------------"
    For i = LBound(vFields) To UBound(vFields)
        Set_UCASE_TabellaCampo sTab, vFields(i), sRisultato
        Risultato = Risultato & vbCrLf & sRisultato
    Next i
    
    Risultato = Risultato & vbCrLf & "-----START----- " & sTab & " ------------"
    
    Debug.Print Risultato
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    Risultato = "ERRORE IN " & sTab & ": " & Err.Description
End Sub


Public Sub Set_UCASE_TabellaCampo(Optional Tabella = "", Optional Campo = "", Optional Risultato)
On Error GoTo Gest_Err

    Dim sSQL, sTab, sField, sInput, vInput
    Risultato = "Nullo"
    If Tabella & Campo = "" Then
        sInput = InputBox("SET", "Tabella|Campo", Tabella & "|" & Campo)
    Else
        sInput = Tabella & "|" & Campo
    End If
    vInput = Split(sInput, "|")
    sTab = vInput(0)
    sField = vInput(1)
    
    If sField = "" Or sField = "-" Then Exit Sub
    If sTab = "" Or sTab = "-" Then Exit Sub
    
    sSQL = "UPDATE [" & sTab & "] SET [" & sField & "]  = UCase([" & sField & "] );"
    DoCmd.RunSQL sSQL, -1
    Risultato = Tabella & "|" & Campo & ": " & "ok"
    
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    Risultato = Risultato = "ERRORE IN " & Tabella & "|" & Campo & ": " & Err.Description
''''    MsgBox Err.Description
''''    Err.Clear
''''    Resume Next
End Sub

'caricare la tabella da 1 file xls
Public Sub xls_ImportToTable(Optional FileXls = "")
On Error GoTo Gest_Err
Dim bDBOkay As Boolean

    If FileXls = "" Then
        Dim commonDialog1 As New clsDialog
        Dim sPathFileStart As String
        Dim sFileStart As String
        commonDialog1.InitDir = GetApplicationSubPath("Sinc")
        commonDialog1.Filter = "Files xls|*.xls"
        'show the open window
        commonDialog1.ShowOpen
        sPathFileStart = commonDialog1.FileName
        sFileStart = GetFileName(sPathFileStart)
        If sFileStart = "" Then Exit Sub
        FileXls = sPathFileStart
    End If
    
    Debug.Print "caricamento dati", sPathFileStart

    Tabelle_UnLoad "Xls_Import"
    DoCmd.TransferSpreadsheet acImport, , "Xls_Import", FileXls, True


    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next









End Sub




Public Sub obj_LockByName(fForm As Form, sPrefisso, bLock As Boolean)
    Dim obj As Object
    Dim sPr() As String, sPr1 As String
    Dim i
    On Error Resume Next
    sPr = Split(sPrefisso, "|")
    For i = LBound(sPr) To UBound(sPr)
        For Each obj In fForm
            If InStr(1, Trim(obj.Name), Trim(sPr(i)), 1) > 0 Then
                obj.Locked = bLock
            End If
        Next
    Next i
    
    Err.Clear
End Sub




Public Function GetType(intType As Integer) As String
    Select Case intType
        Case 2
            GetType = "Integer"
        Case 3
            GetType = "Long Integer"
        Case 4
            GetType = "Single"
        Case 5
            GetType = "Double"
        Case 6
            GetType = "Currency"
        Case 7
            GetType = "Date/Time"
        Case 11
            GetType = "Yes/No"
        Case 17
            GetType = "Byte"
        Case 72
            GetType = "Replication ID"
        Case 202
            GetType = "Text"
        Case 203
            GetType = "Memo"
        Case 205
            GetType = "OLE Object"
        Case Else
            GetType = "Unknown"
    End Select
    
End Function





Public Sub DB_CreaReplica(Optional sDir = "")
On Error Resume Next
Dim sPathFile As String, sList As String
    
    If GetApplicationSubPath("Fonts") = "" Then Exit Sub
    Dim s
    s = CurrentProject.Name
    If sDir = "" Then
        sPathFile = GetApplicationSubPath("Fonts") & "\" & s
    Else
        sPathFile = sDir & "\" & s
    End If
    FileCopy GetApplicationSubPath("Fonts") & "\Vuoto.mdb", sPathFile

    sList = Obj_List(acTable)
    Debug.Print sList
    Obj_Load acExport, acTable, sPathFile, sList, sList, , "Microsoft Access", False

    sList = Obj_List(acForm)
    Debug.Print sList
    Obj_Load acExport, acForm, sPathFile, sList, sList, , "Microsoft Access", False

    sList = Obj_List(acModule)
    Debug.Print sList
    Obj_Load acExport, acModule, sPathFile, sList, sList, , "Microsoft Access", False
    
    sList = Obj_List(acQuery)
    Debug.Print sList
    Obj_Load acExport, acQuery, sPathFile, sList, sList, , "Microsoft Access", False

    sList = Obj_List(acReport)
'    Debug.Print sList
    Obj_Load acExport, acReport, sPathFile, sList, sList, , "Microsoft Access", False

    sList = Obj_List(acMacro)
'    Debug.Print sList
    Obj_Load acExport, acMacro, sPathFile, sList, sList, , "Microsoft Access", False
    
    

    
Err.Clear
End Sub

Public Sub OutputQuery_SuXLS(Query, Xls, SH, Optional FirstLine = 1, Optional FirstCol = 1, Optional Intestazione = True, Optional Save As Boolean = True)
On Error Resume Next

    Dim oXLS As Excel.Application
    Dim oWbk As Excel.Workbook
    Dim oWsh As Excel.Worksheet
    Dim nR As Long, iR As Integer, nFld As Integer, iFld As Integer
    Dim openSh As Boolean
    Dim sheetExist As Boolean, nsheets As Integer
    Dim ss, xRange
    
    openSh = True
    DoEvents
    On Error Resume Next
    Set oXLS = GetObject(, "Excel.Application")
    'If Excel is not launched start it
    If Err.Number = 429 Then
        Err = 0
        Set oXLS = CreateObject("Excel.Application")
        'Can't create object
        If Err = 429 Then
            MsgBox Err.Description & ": " & Error, vbExclamation + vbOKOnly
            Exit Sub
        End If
    End If

    oXLS.Visible = True
    Dim sXLS
    sXLS = GetFileName(Xls)
    
    If sXLS = "" Then
        ss = Split(Xls, ".")
        Xls = Application.CurrentProject.Path & "\" & ss(0) & ".XLS"
        sXLS = GetFileName(Xls)
    End If
    
    For Each oWbk In oXLS.Workbooks
        If oWbk.Name = sXLS Then
            openSh = False
        End If
    Next oWbk
    
    If openSh = False Then
        oXLS.Workbooks(sXLS).Activate
    Else

        If Dir(Xls, vbNormal) <> "" Then
            oXLS.Workbooks.Open Xls
            openSh = False
        Else
            oXLS.Workbooks.Add
            oXLS.ActiveSheet.Name = SH
        End If
        '......................................................................
    End If
    
    sheetExist = False
    nsheets = oXLS.ActiveWorkbook.Worksheets.Count
    For iR = 1 To nsheets
        If oXLS.ActiveWorkbook.Sheets(iR).Name = SH Then
            sheetExist = True
            Exit For
        End If
    Next iR
    nsheets = iR
    If sheetExist Then
        Set oWsh = oXLS.ActiveWorkbook.Sheets(nsheets)
    Else
        Set oWsh = oXLS.ActiveWorkbook.Worksheets.Add
        oWsh.Name = SH
    End If
    oWsh.Activate

    Dim Cnn As New ADODB.Connection
    Dim rS As New ADODB.Recordset
    If Query = "" Then
        MsgBox "Query Vuota", vbCritical, "Query"
        Exit Sub
    End If
'........dpe 71119.................
    Query = Replace(Query, "SELECT *", "SELECT XXXX")
    Query = Replace(Query, "*.*", ".XXXX")
    Query = Replace(Query, ".*", ".XXXX")
    Query = Replace(Query, "*", "%")
    Query = Replace(Query, "XXXX", "*")
    
    Set Cnn = Application.CurrentProject.Connection
    rS.CursorLocation = adUseClient
    rS.LockType = adLockOptimistic
    rS.Open Query, Cnn, 1    ' 1 = adOpenKeyset
    nR = rS.RecordCount
    If nR = 0 Then
        MsgBox "Non ci sono dati", vbCritical, "Query"
        Exit Sub
    End If
    
    If FirstLine = 1 And FirstCol = 1 Then
        oWsh.Select
        oWsh.Cells.ClearContents
        oWsh.Range("a1").Select
    End If
    
    'intestazioni campi
    iR = 0
    If Intestazione Then
        iR = FirstLine
        For iFld = 0 To rS.Fields.Count - 1
            oWsh.Cells(iR, iFld + FirstCol).Value = rS.Fields(iFld).Name
        Next iFld
        iR = iR + 1
    Else
        iR = FirstLine
    End If

'    todo: controllare, ma  mi sembra inutile
    xRange = CellToRange(iR, FirstCol)
    oWsh.Range(xRange).CopyFromRecordset rS
    If Save = True Then
        If openSh = False Then
            oXLS.ActiveWorkbook.Save
        Else
            oXLS.ActiveWorkbook.SaveAs Xls
        End If
    End If
    
    Set Cnn = Nothing
    Set rS = Nothing
    Err.Clear
    
    

    Exit Sub

Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub

Private Function CellToRange(Row, Optional Col = 1)
    Dim base, Resto, Lettera, ris
    
    CellToRange = ""
    If Col = 0 Then Exit Function
    base = 64
    ris = Int(Col / 26)
    Resto = Col Mod 26
    If Col <= 26 Then
        Lettera = Chr(base + Col)
    Else
        If Resto = 0 Then
            Lettera = Chr(ris - 1 + base)
            Lettera = Lettera & "Z"
        Else
            Lettera = Chr(ris + base)
            Lettera = Lettera & Chr(Resto + base)
        End If
    End If
    CellToRange = Lettera & CStr(Row)

End Function


Private Function Property_Change(strPropName, varPropType As Variant, varPropValue As Variant) As Integer
On Error Resume Next
'==========================================
'v01 - 16-8-2004
'==========================================
    Dim dbs As Object, prp As Variant
    Const conPropNotFoundError = 3270

    Set dbs = CurrentDb
    On Error GoTo Change_Err
    dbs.Properties(strPropName) = varPropValue
    Property_Change = True

Change_Bye:
    Exit Function

Change_Err:
    If Err = conPropNotFoundError Then    ' Property not found.
        Set prp = dbs.CreateProperty(strPropName, _
            varPropType, varPropValue)
        dbs.Properties.Append prp
        Resume Next
    Else
        ' Unknown error.
        Property_Change = False
        Resume Change_Bye
    End If
End Function
Public Sub Property_StartupSet()
'==========================================
'
'==========================================
    Const DB_Boolean As Long = 1
    Property_Change "StartupShowDBWindow", DB_Boolean, False
    Property_Change "StartupShowStatusBar", DB_Boolean, False
    Property_Change "AllowBuiltinToolbars", DB_Boolean, False
    Property_Change "AllowFullMenus", DB_Boolean, False
    Property_Change "AllowBreakIntoCode", DB_Boolean, False
    Property_Change "AllowSpecialKeys", DB_Boolean, False
    Property_Change "AllowBypassKey", DB_Boolean, True
End Sub
Public Sub Property_StartupReset()
'==========================================
'
'==========================================
    Const DB_Boolean As Long = 1
    Property_Change "StartupShowDBWindow", DB_Boolean, True
    Property_Change "StartupShowStatusBar", DB_Boolean, True
    Property_Change "AllowBuiltinToolbars", DB_Boolean, True
    Property_Change "AllowFullMenus", DB_Boolean, True
    Property_Change "AllowBreakIntoCode", DB_Boolean, True
    Property_Change "AllowSpecialKeys", DB_Boolean, True
    Property_Change "AllowBypassKey", DB_Boolean, True
End Sub


Public Sub Rec_Duplica(NomeTabella, IDField, IDValue, IDNew)
On Error GoTo Gest_Err
    Dim Cnn As New ADODB.Connection
    Dim rS As New ADODB.Recordset
    Dim rs1 As New ADODB.Recordset
    Dim iFl
    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "Select [" & NomeTabella & "].* FROM [" & NomeTabella & "]"
    sQuery = sQuery & " WHERE((([" & NomeTabella & "].[" & IDField & "]) = '" & IDValue & "'))"
    
    rS.CursorLocation = adUseClient
    rS.LockType = adLockOptimistic
    rS.Open sQuery, Cnn, 1    ' 1 = adOpenKeyset

    Set rs1 = rS.Clone

    rS.AddNew
    
'    rs.Update
    For iFl = 0 To rS.Fields.Count - 1
        If rS.Fields(iFl).Name = IDField Then
            If IDNew = "" Then
'                id-generato automaticamente
            Else
                rS(IDField) = IDNew
            End If
        Else
            rS(iFl) = rs1(iFl)
        End If
    Next iFl
    
        ' inserito per forzare il campo DB_Centrale a False sul dB_Locale quando duplico un record
    On Error Resume Next
    '.....................................................
    rS.Update
    rS.Resync
    rS.Requery

    rs1.Close
    Set Cnn = Nothing
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub



Public Sub Rec_UPDate(NomeTabella, IDField, IDValue, myField, myValue)
    Dim Cnn As New ADODB.Connection

    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "UPDATE [" & NomeTabella & "] SET [" & NomeTabella & "].[" & myField & "] = '" & myValue & "' "
    sQuery = sQuery & " WHERE((([" & NomeTabella & "].[" & IDField & "]) = '" & IDValue & "'))"
    
    Cnn.Execute sQuery
        
    Set Cnn = Nothing
    
End Sub



Public Sub Tabelle_LoadFile(Tabelle, Optional InitDir = "c:\", Optional EstensioneSinc = "_SINC")
On Error GoTo Gest_Err
Dim bDBOkay As Boolean

    Dim commonDialog1 As New clsDialog
    Dim sPathFileStart As String
    Dim sFileStart As String
    commonDialog1.InitDir = InitDir
    commonDialog1.Filter = "Files MDB|*.mdb"
    'show the open window
    commonDialog1.ShowOpen
    sPathFileStart = commonDialog1.FileName
    sFileStart = GetFileName(sPathFileStart)
    If sFileStart = "" Then Exit Sub
    'caricamento dati

    Tabelle_Load sFileStart, Tabelle, EstensioneSinc, bDBOkay, False, True


    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub





Public Sub Tabelle_Load(FileDB, Tabelle, Optional Estensione = "", Optional DBOkay, Optional ShowErr As Boolean = True, Optional UnloadTab As Boolean = True)
'==========================================
'070102 fatta lib
'==========================================
On Error GoTo Gest_Err
    DBOkay = False
    If FileDB = "" Then
        MsgBox "La stringa FileDB è vuota.", vbCritical, "Tabelle Load"
        Exit Sub
    End If
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")
    If fs.FileExists(FileDB) = False Then
        MsgBox "Manca il file del DB " & FileDB & " : contatta il sistemista"
        Exit Sub
    End If
    If Trim(Tabelle) = "" Then
        MsgBox "L'elenco tabelle è vuoto : contatta il sistemista"
        Exit Sub
    End If
    DBOkay = True

    If UnloadTab = True Then Tabelle_UnLoad Tabelle, Estensione
    
''''    Dim sOp As String
''''    Dim obj As AccessObject, dbs As Object
''''    Set dbs = Application.CurrentData

    Dim sTab() As String
    Dim iTab As Integer

    ' caricamento
    sTab = Split(Tabelle, "|")
    If ShowErr = True Then
        On Error GoTo Load_err
    Else
        On Error Resume Next
    End If
    
    For iTab = LBound(sTab) To UBound(sTab)
        DoCmd.TransferDatabase acLink, "Microsoft Access", FileDB, acTable, sTab(iTab), Trim(sTab(iTab) & Estensione), False
    Next iTab

    
    Exit Sub
Load_err:
    MsgBox "LOAD TABELLE errore : " & Err.Description, vbCritical, "Errore di LOAD TABELLA"
    Err.Clear
    DBOkay = False
    Resume Next
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    DBOkay = False
    Resume Next
End Sub

Public Function Tabella_Exist(NomeTabella) As Boolean
    Dim Cnn As New ADODB.Connection
    Dim rS As New ADODB.Recordset
    Dim sQuery As String
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "Select TOP 1 [" & NomeTabella & "].* FROM [" & NomeTabella & "]"
    Tabella_Exist = True
    On Error GoTo errore

    rS.CursorLocation = adUseClient
    rS.LockType = adLockOptimistic
    rS.Open sQuery, Cnn, 1    ' 1 = adOpenKeyset
         
         
    rS.Close
    Set Cnn = Nothing
    Exit Function
    
errore:
'    MsgBox "Il dB non è stato caricato correttamente", vbCritical
    Tabella_Exist = False
    Err.Clear
    Set Cnn = Nothing
    
End Function


Public Sub Tabelle_UnLoad(Tabelle, Optional Estensione = "")
On Error GoTo Gest_Err

    Dim sTab() As String
    Dim iTab As Integer
    sTab = Split(Tabelle, "|")
    For iTab = LBound(sTab) To UBound(sTab)
        On Error Resume Next
        DoCmd.DeleteObject acTable, Trim(sTab(iTab) & Estensione)
        Err.Clear
    Next iTab
   
    Exit Sub
Gest_Err:
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub

Public Sub Tabelle_UCase(TabName)
On Error GoTo Gest_Err
Dim Cnn As New ADODB.Connection
Dim sQuery As String
Dim rS As New ADODB.Recordset
    Set Cnn = Application.CurrentProject.Connection
    sQuery = "SELECT TOP 1 * FROM [" & TabName & "]"
    rS.Open sQuery, Cnn, 1    ' 1 = adOpenKeyset
    

    If rS.RecordCount > 0 Then
        Dim iFld As Integer
        rS.MoveFirst
        For iFld = 0 To rS.Fields.Count - 1
            sQuery = "UPDATE [" & TabName & "] SET [" & TabName & "].[" & rS.Fields(iFld).Name & "] = UCase([" & rS.Fields(iFld).Name & "]);"
            Cnn.Execute sQuery
        Next iFld
    End If
    
    
    Set Cnn = Nothing
    Exit Sub
Gest_Err: 'On Error GoTo Gest_Err
    MsgBox Err.Description
    Err.Clear
    Resume Next
End Sub


Public Sub DB_AggiungiVuoto()
    On Error Resume Next

    Dim sSource, sDestination
    Dim sName As String
    sName = InputBox("Immmetti il nome Db", "Nuovo DB", "db_Dati_")
    If sName = "" Or sName = "db_Dati_" Then Exit Sub
        
    sSource = GetApplicationSubPath("Fonts") & "\db_Dati_font.mdb"
    sDestination = GetApplicationSubPath("DB") & "\" & sName & ".mdb"
    FileCopy sSource, sDestination

    Err.Clear

End Sub

