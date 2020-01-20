Sub BreakOnSection()
   ' Das Dokument entlang der eingefügten Abschnitte (Sections) trennen.
   Application.Browser.Target = wdBrowseSection

   ' Eins abziehen, damit für die letzte Trennung keine Fehlermeldung kommt.
   For I = 1 To ((ActiveDocument.Sections.Count) - 1)
   
      'Text des Abschnitts in die Zwischenablage kopieren.
      ActiveDocument.Bookmarks("\Section").Range.Copy

      'Neues Dokument erzeugen und Zwischenablage einfügen.
      Documents.Add
      Selection.Paste

    ' Falls ein Trenner mitkopiert wurde, diesen entfernen.
    '  Selection.MoveUp Unit:=wdLine, Count:=1, Extend:=wdExtend
    '  Selection.Delete Unit:=wdCharacter, Count:=1

    ' Verzeichnis zum abspeichern wählen
    ChangeFileOpenDirectory "C:\Users\grabsch\TELOTA\MEGA\MEGAdigital2\zeugenbeschreibung_split"
    ' Auswählen der Briefummer
    ActiveDocument.Select
    ' Die erste Zeile auswählen (enthält die Briefnummer)
    Selection.GoTo What:=wdGoToSection, Which:=wdGoToFirst
    Selection.Expand wdLine
    LetterNumber = Selection.Text
    ' MsgBox (LetterNumber)

    ' Letztes Zeichen (=Zeilenumbruch) entfernen
    LetterNumber = Left(Selection.Text, Len(Selection.Text) - 1)
    

     ActiveDocument.SaveAs FileName:=LetterNumber & ".docx"
     ActiveDocument.Close
      ' Den nächsten Abschnitt bearbeiten.
     Application.Browser.Next
   Next I
   ' ActiveDocument.Close savechanges:=wdDoNotSaveChanges
End Sub

