---
title: 'MEGA-Transformation/-Ediarum: Offene Fragen, Arbeitspakete, Timeline'
author: Sascha Grabsch
date: 2016-10-11
version: 0.3
---

# Transformation nach TEI-Zielformat für Ediarum #
Verantwortlich: Sascha

Beteiligte: Sascha, Stefan

 - `<pb>`-Elemente ([#6927](https://telotadev.bbaw.de/redmine/issues/6927))
 - `<encodingDesc>` entfernen
   ([#6779](https://telotadev.bbaw.de/redmine/issues/6779))
 - `@rend` vs. `@rendition` (betrifft u. a. `="superscript"`) ([#7072](https://telotadev.bbaw.de/redmine/issues/7072))
 - Was ist mit `@rendition="italic"`? ([#7073](https://telotadev.bbaw.de/redmine/issues/7073))
 - Anpassung/Verbesserung der Signaturen und Zeugenbeschreibung ([#7077](https://telotadev.bbaw.de/redmine/issues/7077))
     - "Marx-Engels-Nachlass" fehlt (Signaturüberprüfung zu spezifisch) in
       manchen Briefen ([#7075](https://telotadev.bbaw.de/redmine/issues/7075))
     - ersten Absatz der Zeugenbeschreibung mit "Originalhandschrift: ..."
       beibehalten (zur Überprüfung bei der Bearbeitung, wird manuell gelöscht)
     - Doppelpunkt nach "Standort Orig. nicht bekannt; Kopie" einfügen ([#7076](https://telotadev.bbaw.de/redmine/issues/7076))
 - Verzeichnung "Erstveröffentlichung" in TEI
   ([#6803](https://telotadev.bbaw.de/redmine/issues/6803))
 - Hervorhebung `<hi rend="bold">` im Author Mode ([#7074](https://telotadev.bbaw.de/redmine/issues/7074))
 - **nicht-transformierte Einträge kritischer Apparat** (und auch `{ktb}`, vgl.
   Brief 3) ([#7078](https://telotadev.bbaw.de/redmine/issues/7078))
 - vorgedruckte Formulartexte → händische (?) Auszeichnung mit `p|hi@rendition="#mPrint"`
 - Randanstreichungen (→ Abbildung in XML, Auszeichnung in Word möglich mit
   `{mr_Tinte}...{/mr}` und `{mr_Bleistift}...{/mr}`) → `@rendition="#mMM"` für `<p>` oder `<hi>`
 - Umgang mit Beilagen → Schulung
 - fehlerhafte Unicode-Zeichen (altkyrillisch)
 - (Unicode-Logging-Fehler)
 - evtl. Build-Skript? ordentliche Dokumentation sollte aber auch ausreichen
 - Überprüfung des XML durch Stefan

# Features Ediarum #

## oXygen Author-Mode ##

### Personenregister ###
Verantwortlich: Sascha

Beteiligte: Stefan, MEGA, Sascha

 #. Transformation der PDR-Daten (Stefan, schon abgeschlossen?)
 #. Firmendaten aus dem PDR laden (Sascha, [#7074](https://telotadev.bbaw.de/redmine/issues/7074))
 #. Zuordnung der vergebenen `@key` zu erzeugtem Personenregister (MEGA)
 #. Ersetzung der vergebenen `@key` mit Personen-IDs aus Register (Sascha oder
    Stefan)

### Zotero-Anbindung ###
Verantwortlich: ?

Beteiligte: Stefan, Sascha, Markus, Martin, ?

- Details zu MEGA-Zotero-Account
- Einrichtung in eXist/Datenbank und Ediarum-App in Absprache mit Martin Fechner
- Einweisung für Fr. Roth/BearbeiterInnen

### Zeitungs-/Zeitschriftenregister ###
Verantwortlich: ?

Beteiligte: Stefan, Sascha, ?

- Einrichtung eines Zeitungs-/Zeitschriftenregisters
- Offen: Wie ist das Verhältnis dieses Registers zur Angabe von Werktiteln
  (`<bibl>`) und der Referenzierung über Zotero-Datenbank?
- Ersetzung der `<index>`-Einträge für Zeitungen/Zeitschriften entsprechend der
  erarbeiteten Lösung (das sind Indexeinträge die mit <samp>"zz"</samp>
  beginnen)

## Redaktionsansicht ##
Verantwortlich: ?
Beteiligte: Stefan, Sascha, MEGA

- Web-Ansicht zu Einzelbrief mit Briefmetadaten, Zeugenbeschreibung, kritischem
  Apparat und Sacherläuterungen
- Aufruf aus oXygen
- Volltext-Suchfunktion (kann evtl. auch 1-2 Wochen nach Redaktionsansicht
  folgen)

# Timeline #

Aufgabe                                             Termin      Verantwortlich
------------------------------------------------    ------      --------------
[Transformation nach TEI-Zielformat für Ediarum]    11.10.2016  Sascha
[Personenregister]                                  ?           Sascha
[Zeitungs-/Zeitschriftenregister]                   ?           ?
[Zotero-Anbindung]                                  14.10.2016  ?
[Redaktionsansicht]                                 17.10.2016  ?