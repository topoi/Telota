# Zu verarbeitende Briefe sperren

Für den Zeitraum in dem die ID-Ersetzung/Normdatenanreicherung erfolgt,
sollten an den zu bearbeitenden Dokumenten/Briefen keine Änderungen und
Bearbeitungen durchgeführt werden. Es sollte also mit den BearbeiterInnen beim
Vorhaben ein konkreter Zeitraum abgesprochen werden.

**TODO** Wie kann (z. B. über den `Query Dialog`) ein Ordner/eine Gruppe von
Dateien gelockt und dann nach durchgeführter Bearbeitung wieder entsperrt
werden?

# Zu bearbeitende XML-Dateien/Briefe lokal speicher

 1. Über den `eXist Admin Client` die XML-Dateien als ZIP lokal speichern.
 2. Ist-Stand der XML-Daten ggf./idealerweise in git einchecken.

# ID-Daten als einfache csv abspeichern

Die .csv-Datei mit den Zuordnungen von Personennamen/-strings erstellen. Die
Datei:

  * **MUSS** UTF-8 enkodiert sein, 
  * **MUSS** `;` als Trenner nutzen, 
  * **MUSS** zwei Spalten in der Reihenfolge `namestring foo;someID` enthalten
    und
  * **DARF KEINE** Kopfzeilen o. ä. enthalten.

Die .csv-Datei sollte auch ins git eingecheckt werden.

# Skript für die Ersetzung der Personennamen ausführen

Es wird das Paket `lxlml` benötigt, das Skript muss also im
entsprechenden/richtigen Virtual Environment ausgeführt werden. Der Aufruf
erfolgt mit `python names2ids.py input_directory output_directory
id_list_file`.

# Neue XML-Dateien überprüfen und einchecken

Das Skript für die ID-Anreicherung gibt Informationen über den Verlauf, ggf.
sind dort Hinweise zu nicht gefundenen Personen-IDs, Namen die nicht
zugeordnet werden konnten o. ä. Wenn hier keine Fehler gefunden werden, sollte
der neue XML-Datenbestand ins git eingecheckt werden.

# Neue XML-Dateien wieder in eXist abspeichern

Über oXygen XML Author/Ediarum alle XML-Dateien in das entsprechende
Verzeichnis schieben und die bestehenden Dateien überschreiben.