Attribute VB_Name = "Esempio_Sincronia"
Option Compare Database
Option Explicit

Const DATI_CENTRALE = "db_Dati.mdb"
Const DATI_LOCALE = "db_Locale.mdb"

Global Const FIELD_VERSIONEDATI = "VersioneDati"
Global Const FIELD_VERSIONESTRUTTURA = "VersioneStruttura"
Global Const FIELD_DBCENTRALE = "DB_Centrale"
Global Const FIELD_DBUFFICIALE = "DB_Ufficiale"

Global gstrPathFile_DBLocale As String
Global gstrPathFile_DBCentrale As String
Global gstrPathFile_DBTemp As String

Global gstrVersioneMain As String

Public Type MyVersion
    ID As Long
    Struttura As String
    Dati As String
    Note As String
End Type
Dim tMyVersionCen As MyVersion
Dim tMyVersionLoc As MyVersion

Private Sub SincroniaVersioni_LocaleToCentrale()
On Error Resume Next
    Dim sTab() As String
    Dim INUMTAB As Integer
    Dim i, j, iRecNum
    Dim sQuery As String
    
    Dim cnn As New ADODB.Connection
    Dim rs As New ADODB.Recordset
    Dim sQ_Cen As String
    Dim sQ_Loc As String
    Set cnn = Application.CurrentProject.Connection
   
    'scarica tabelle attualmente caricate del locale
    Tabelle_UnLoad gstrDboTabStart
    'carica le tabelle
    Tabelle_Load gstrPathFile_DBTemp, gstrDboTabStart, "_Cen"
    Tabelle_Load gstrPathFile_DBLocale, gstrDboTabStart, "_Loc"
    
    DoEvents
    
    sTab = Split(gstrDboTabStart, "|")
    INUMTAB = UBound(sTab)
    
    'Controllo preventivo dell'esistenza di eventuali variazioni di struttura
    sQuery = "Select * From [Main Strutture]"
    rs.CursorLocation = adUseClient
    rs.LockType = adLockOptimistic
    rs.Open sQuery, cnn, 1    ' 1 = adOpenKeyset
    If rs.RecordCount = 0 Then
        rs.Close
        Exit Sub
    End If
    rs.Close
    'loop sui nomi di tutte le tabelle
    For i = 0 To INUMTAB
        'Query per individuare la tabella con la struttura modificata
        sQuery = "Select * From [Main Strutture] Where [Tabella]" & "='" & sTab(i) & "'"
        rs.CursorLocation = adUseClient
        rs.LockType = adLockOptimistic
        rs.Open sQuery, cnn, 1    ' 1 = adOpenKeyset
        iRecNum = rs.RecordCount
        If iRecNum > 0 Then
            rs.MoveFirst
            sQ_Cen = "" 'campi centrale
            sQ_Loc = ""
            'creazione query di accodamento
            For j = 1 To iRecNum
            
                If rs.Fields(1).Value <> "-" And rs.Fields(2).Value <> "-" Then
                    If j = 1 Then
                        sQ_Cen = "[" & sTab(i) & "_Cen] ( [" & rs.Fields(2).Value & "]"
                        sQ_Loc = "[" & sTab(i) & "_Loc].[" & rs.Fields(1).Value & "]"
                    Else
                        sQ_Cen = sQ_Cen & ", [" & rs.Fields(2).Value & "]"
                        sQ_Loc = sQ_Loc & ", [" & sTab(i) & "_Loc].[" & rs.Fields(1).Value & "]"
                    End If
                End If
                rs.MoveNext
            Next j
            sQ_Cen = sQ_Cen & " ) "
            sQ_Loc = sQ_Loc & " "
            sQuery = "INSERT INTO " & sQ_Cen & "SELECT " & sQ_Loc & _
            "FROM [" & sTab(i) & "_Loc] " & _
            "WHERE ((([" & sTab(i) & "_Loc]." & FIELD_DBCENTRALE & ")=False))"
        Else 'per eventuale accodamento dei soli dati
            sQuery = "INSERT INTO [" & sTab(i) & "_Cen" & _
            "] SELECT [" & sTab(i) & "_Loc].* FROM [" & sTab(i) & "_Loc] LEFT JOIN [" & sTab(i) & "_Cen]" & _
            " ON [" & sTab(i) & "_Loc]." & FIELD_DBCENTRALE & " = [" & sTab(i) & "_Cen]." & FIELD_DBCENTRALE & _
            " WHERE ((([" & sTab(i) & "_Loc]." & FIELD_DBCENTRALE & ")=False))"
        End If
        DoCmd.RunSQL sQuery, -1
        rs.Close
    Next i
        
    Tabelle_UnLoad gstrDboTabStart, "_Cen"
    Tabelle_UnLoad gstrDboTabStart, "_Loc"
    

End Sub


Private Sub SincroniaDati_LocaleToCentrale()
On Error Resume Next
   Dim sTabCen() As String
   Dim sTabLoc() As String
   Dim INUMTAB As Integer
   Dim i
   Dim sQuery As String

    'scarica tabelle attualmente caricate del locale
    Tabelle_UnLoad gstrDboTabStart
    ' carica le tabelle
    Tabelle_Load gstrPathFile_DBTemp, gstrDboTabStart, "_Cen"
    Tabelle_Load gstrPathFile_DBLocale, gstrDboTabStart, "_Loc"
    
    DoEvents
    
    sTabCen = Split(gstrDboTabStart, "|")
    sTabLoc = Split(gstrDboTabStart, "|")
    INUMTAB = UBound(sTabCen)
    For i = 0 To INUMTAB
        sTabCen(i) = sTabCen(i) & "_Cen"
        sTabLoc(i) = sTabLoc(i) & "_Loc"
    Next i
    
    For i = 0 To INUMTAB
        sQuery = "INSERT INTO [" & sTabCen(i) & _
            "] SELECT [" & sTabLoc(i) & "].* FROM [" & sTabLoc(i) & "] LEFT JOIN [" & sTabCen(i) & _
            "] ON [" & sTabLoc(i) & "]." & FIELD_DBCENTRALE & " = [" & sTabCen(i) & "]." & FIELD_DBCENTRALE & _
            " WHERE ((([" & sTabLoc(i) & "]." & FIELD_DBCENTRALE & ")=False))"
        DoCmd.RunSQL sQuery, -1
    Next i
        


    'query di accodamento

    Tabelle_UnLoad gstrDboTabStart, "_Cen"
    Tabelle_UnLoad gstrDboTabStart, "_Loc"
    
    
End Sub
    


Public Function GetInfoVersione() As String
    Versioni_Read tMyVersionCen.Struttura, tMyVersionCen.Dati, gstrFileDBPredefinito, "T_Versioni", "_Predefinito"
    gstrVersioneMain = "Struttura: " & tMyVersionCen.Struttura & vbCrLf & "Dati: " & tMyVersionCen.Dati & vbCrLf & "Forms: " & FORM_VERSIONE
End Function



Public Sub AggiornamentoDB()
On Error Resume Next
    Dim fs As Object
    Dim bDBOkay As Boolean
    
    gstrPathFile_DBLocale = gstrPathDirDB & "\" & DATI_LOCALE
    gstrPathFile_DBCentrale = gstrPathDirDB & "\" & DATI_CENTRALE
    gstrFileDBPredefinito = gstrPathFile_DBLocale
    gstrPathFile_DBTemp = gstrPathDirDB & "\db_dati_temp.mdb"

    'il controllo lo facciamo sul file db perchè si potrebbe essere cancellato il file ini 1
    'Versioni_Read sVersioneStruttura, sVersioneMain
    
    'legge la versione del db_dati
    Versioni_Read tMyVersionCen.Struttura, tMyVersionCen.Dati, gstrPathFile_DBCentrale, "T_Versioni", "_Cen"
''''    todo: rimettere gstrVersioneMain = "Struttura: " & tMyVersionCen.Struttura & vbCrLf & "Dati: " & tMyVersionCen.Dati & vbCrLf & "Forms: " & FORM_VERSIONE


    Set fs = CreateObject("Scripting.FileSystemObject")
    
    ' se non c' è il db_locale lo crea copiandolo dal centrale
    If fs.FileExists(gstrPathFile_DBLocale) = False Then
        fs.copyFile gstrPathFile_DBCentrale, gstrPathFile_DBLocale
        Tabelle_Load gstrFileDBPredefinito, gstrDboTabStart, , bDBOkay
    Else
        Versioni_Read tMyVersionLoc.Struttura, tMyVersionLoc.Dati, gstrPathFile_DBLocale, "T_Versioni", "_Loc"
          'se la versione di struttura è differente effettua l'allineamento passando da un file temporaneo
          'Il mio locale vecchio è salvato nella cartella BCK con il nome della data di allineamento
        If tMyVersionLoc.Struttura <> tMyVersionCen.Struttura Then
''''            Versioni_Write tMyVersionCen.Struttura, tMyVersionCen.Dati, gstrPathFile_DBLocale, "T_Versioni", "_Loc"
            fs.copyFile gstrPathFile_DBCentrale, gstrPathFile_DBTemp
            SincroniaVersioni_LocaleToCentrale
            BackupDB
            Tabelle_Load gstrFileDBPredefinito, gstrDboTabStart, , bDBOkay
        Else
          'se la versione di dati è differente effettua l'allineamento passando da un file temporaneo
          'Il mio locale vecchio è salvato nella cartella BCK con il nome della data di allineamento
            If tMyVersionLoc.Dati <> tMyVersionCen.Dati Then
''''                Versioni_Write tMyVersionCen.Struttura, tMyVersionCen.Dati, gstrPathFile_DBLocale, "T_Versioni", "_Loc"
                fs.copyFile gstrPathFile_DBCentrale, gstrPathFile_DBTemp
                SincroniaDati_LocaleToCentrale
                BackupDB
                Tabelle_Load gstrFileDBPredefinito, gstrDboTabStart, , bDBOkay
            End If
        End If

    End If
    
    Set fs = Nothing
End Sub
     
Private Sub BackupDB()
On Error Resume Next
    Dim sLocaleBck As String
    Dim fs As Object
    Set fs = CreateObject("Scripting.FileSystemObject")

    'dà il nome al file di BCK che è la copia del mio db_locale vecchio
    sLocaleBck = GetNewID & ".mdb"
    fs.copyFile gstrPathFile_DBLocale, gstrPathDirBCK & "\" & sLocaleBck
    fs.copyFile gstrPathFile_DBTemp, gstrPathFile_DBLocale
    Kill gstrPathFile_DBTemp
        
End Sub
 
 
Private Sub Versioni_Write(sVersioneStruttura As String, sVersioneMain As String, DB As String, Tabella As String, Estensione As String)
On Error Resume Next
'scrive nella tabella T_Versioni il nome della nuova versione di dati/struttura
    Dim strVersStru As String, strVersMain As String
    Dim nRec
    Dim sQuery As String
    Dim cnn As New ADODB.Connection
    Dim rs As New ADODB.Recordset
    Set cnn = Application.CurrentProject.Connection

    Tabelle_Load DB, Tabella, Estensione
    
    sQuery = "Select * From [" & Tabella & Estensione & "]"
    
    On Error GoTo esci
    rs.CursorLocation = adUseClient
    rs.LockType = adLockOptimistic
    rs.Open sQuery, cnn, 1    ' 1 = adOpenKeyset
    nRec = rs.RecordCount
    If nRec > 0 Then
        rs.MoveLast
        If rs(FIELD_VERSIONESTRUTTURA) <> sVersioneStruttura Or rs(FIELD_VERSIONEDATI) <> sVersioneMain Then
            rs.AddNew
            rs(FIELD_VERSIONESTRUTTURA) = sVersioneStruttura
            rs(FIELD_VERSIONEDATI) = sVersioneMain
            rs.Update
        End If
    Else
        rs.AddNew
        rs("Note") = "Prima Versione"
            rs(FIELD_VERSIONESTRUTTURA) = sVersioneStruttura
            rs(FIELD_VERSIONEDATI) = sVersioneMain
        rs.Update
    End If
    
    rs.Close
    Set rs = Nothing
    GoTo Fine

esci:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Err.Clear
Fine:
    Tabelle_UnLoad Tabella, Estensione
    
    
End Sub


Private Sub Versioni_Read(sVersioneStruttura As String, sVersioneMain As String, DB As String, Tabella As String, Estensione As String)
On Error Resume Next
'legge dalla tabella T_versioni la versione dei dati/struttura posizionandosi all'ultimo record di essa
    Dim sQuery As String
    Dim cnn As New ADODB.Connection
    Dim rs As New ADODB.Recordset
    Set cnn = Application.CurrentProject.Connection

    Tabelle_Load DB, Tabella, Estensione
    
    sQuery = "Select * From [" & Tabella & Estensione & "]"
    
    On Error GoTo esci
    rs.CursorLocation = adUseClient
    rs.LockType = adLockOptimistic
    rs.Open sQuery, cnn, 1    ' 1 = adOpenKeyset
    
    If rs.RecordCount = 0 Then
        'La prima volta nel DB centrale non trova nessun record con la versione
        sVersioneStruttura = GetNewVersion() 'crea la versione di partenza
        sVersioneMain = sVersioneStruttura
        rs.AddNew
        rs(FIELD_VERSIONESTRUTTURA) = sVersioneStruttura
        rs(FIELD_VERSIONEDATI) = sVersioneMain
        rs.Update
        rs.Close
        Set rs = Nothing
        GoTo Fine
    End If
    rs.MoveLast
    sVersioneStruttura = rs(FIELD_VERSIONESTRUTTURA)
    sVersioneMain = rs(FIELD_VERSIONEDATI)
    rs.Close
    GoTo Fine
esci:
    On Error Resume Next
    rs.Close
    Set rs = Nothing
    Err.Clear
Fine:
    Tabelle_UnLoad Tabella, Estensione
End Sub
 


Public Sub UpDate_DBCentrale()
On Error Resume Next
    Dim sTab() As String
    Dim INUMTAB As Integer
    Dim i
    Dim sQuery As String

    sTab = Split(gstrDboTabStart, "|")
    INUMTAB = UBound(sTab)
    
    For i = 0 To INUMTAB
        sQuery = "UPDATE [" & sTab(i) & "] SET [" & sTab(i) & "]." & FIELD_DBCENTRALE & " = True  ,  [" & sTab(i) & "]." & FIELD_DBUFFICIALE & " = ""Ufficiale"""
        DoCmd.RunSQL sQuery, -1
    Next i
    
    Versioni_Read tMyVersionCen.Struttura, tMyVersionCen.Dati, gstrPathFile_DBCentrale, "T_Versioni", "_Cen"
    Versioni_Write tMyVersionCen.Struttura, GetNewVersion(), gstrPathFile_DBCentrale, "T_Versioni", "_Cen"
   
 
End Sub

Public Sub Update_Installazione()
On Error Resume Next
Dim sQuery

    sQuery = "UPDATE T_Misure SET T_Misure.SelezioneMisura = False;"
    DoCmd.RunSQL sQuery, -1
    ' desetto il campo selezione misura prima di fare il nuovo pacchetto
        
    sQuery = "Delete T_Misure.Alias From T_Misure WHERE (((T_Misure.Alias) Like ""*xxx*""));"
    DoCmd.RunSQL sQuery, -1
    ' elimino i rs del tipo xxx in quanto prove

    Kill gstrPathDirDocumenti & "\*.jpg"
    ' elimino i jpg nella cartella documenti del form aperto in questo istante
    
    Kill gstrPathDirDocumenti & "\*.ppt"   ' elimino i ppt eventualmente presenti nella cartella documenti del form aperto in questo istante
 
 'todo : valutare se serve o se fare il tutto da innosetup
    Folder_DeleteTree ("D:\Documenti\Pwt-Tools\Grafica\Programma\FormGrafica_mcr")
    'elimina la cartella formGrafica_mcr in modo che il programma dopo aver eseguito il pacchetto autoinstallante funzioni
    
    Kill "D:\Documenti\Pwt-Tools\DB-Powertrain\Programma\DB\db_locale.mdb"
    'elimino il db_Locale perchè non serve
    
End Sub

Private Function GetNewVersion() As String
On Error Resume Next
    Dim D, T
    D = Split(CDate(Date), "/")
    T = Split(Time, ":")
   
    GetNewVersion = D(2) & D(1) & D(0) & "." & T(0) & T(1) & T(2)
End Function






