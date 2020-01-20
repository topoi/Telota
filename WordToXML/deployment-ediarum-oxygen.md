---
title: 'Einrichtung der Arbeitsumgebung Ediarum in oXygen Author'
author: Sascha Grabsch
date: 2016-10-20
version: 0.1
---

# Konfiguration der Add-On-Quellen

 #. _oXygen XML Author_ öffnen
 #. <kbd><samp>Optionen</samp></kbd> → <kbd><samp>Einstellungen</samp></kbd> → <kbd><samp>Add-Ons</samp></kbd>
 #. Bestehende Einträge zu <samp>http://www.oxygenxml.com</samp> in URL-Liste entfernen
 #. Einträge für Ediarum-Basis-Version und projektspetifische Arbeitsumgebung hinzufügen:
    - <kbd>http://telotadev.bbaw.de/oxygen/ediarum_basis/update.xml</kbd>
    - <kbd>http://telotadev.bbaw.de/oxygen/\$PROJECT/update.xml</kbd> (<samp>\$PROJECT</samp> entspricht z. B. '<kbd>mega</kbd>')

# Installation der Add-Ons
 #. <kbd><samp>Hilfe</samp></kbd> → <kbd><samp>Neue Add-Ons installieren</samp></kbd>
 #. Auswahl: <samp>Add-Ons zeigen von: </samp><kbd><samp>-- ALLE VERFÜGBAREN SEITEN --</samp></kbd>
 #. Aus der angezeigten Liste <samp>ediarum - Basisversion</samp> und <samp>ediarum - \$PROJECT</samp> per Checkbox auswählen
 #. Checkbox <samp>Ich akzeptiere alle Bestimmungen der Lizenzerklärung für Endbenutzer</samp> auswählen
 #. <kbd><samp>Beenden</samp></kbd> auswählen
 #. Die erscheinende Warnmeldung zur fehlerhaften/ungültigen Signatur der ausgewählten Add-Ons mit <kbd><samp>Trotzdem fortsetzen</samp></kbd> bestätigen
 #. _oXygen XML Author_ schließen und dann neu starten

# Öffnen des oXygen-Projekts
 #. <kbd><samp>Projekt</samp></kbd> → <kbd><samp>Projekt öffnen</samp></kbd>
 #. Eingabe <kbd>%APPDATA%</kbd> in Verzeichnispfad
 #. Auswahl des Unterverzeichnises <kbd><samp>com.oxygenxml</samp></kbd>/<kbd><samp>extensions</samp></kbd><kbd><samp>v17.1</samp></kbd> (oder entsprechend andere oXygen-Version)/<kbd><samp>frameworks</samp></kbd>/<kbd><samp>http___telotadev.bbaw.de_oxygen_\$PROJECT_update.xml</samp></kbd> (<samp>\$PROJECT</samp> entspricht z. B. '<kbd>mega</kbd>')/<kbd><samp>ediarum_\$PROJECT</samp></kbd>/
 #. Aus diesem Verzeichnis die Datei <kbd><samp>$PROJECT.xpr</samp></kbd> auswählen und öffnen
 #. Warnung zu Einstellungen, die durch dieses Projekt verändert/überschrieben werden bestätigen und fortfahren

# Einrichtung der Datenbankverbindung
 #. Die Sidebar <kbd><samp>Datenquellen Explorer</samp></kbd> öffnen
 #. Über das Icon <kbd><samp>Datenbankquellen konfigurieren...</samp></kbd> die Einstellungen für die Datenquellen/Datenbankverbindungen öffnen
 #. Eine neue Verbindung hinzufügen, Typ <kbd><samp>WebDAV (S)FTP</samp></kbd>
 	- Die URL ist <kbd>http://telotadev.bbaw.de:8028/exist/webdav/db/projects/\$PROJECT/data</kbd> (<samp>\$PROJECT</samp> entspricht z. B. '<kbd>mega</kbd>')
 	- Username und Password werden über die Ediarum-App im Browser erstellt und hier entsprechend eingetragen

Mit der erfolgreichen Einstellung der Datenbankverbindung ist die Einrichtung der Arbeitsumgebung in _oXygen XML Author_ abgeschlossen. 