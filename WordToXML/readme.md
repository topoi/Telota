---
title: 'Dokumentation MEGA/Ediarum: Transformation .docx zu TEI-XML'
author: Sascha Grabsch
date: 2016-10-12
version: 0.3
---

# Dokumentation MEGA/Ediarum: Transformation .docx zu TEI-XML # {-}
Für die Transformation der Briefe aus MEGA/III in das TEI-XML-Format sind
mehrere Arbseitsschritte notwendig. Im Folgenden wird dieser Ablauf kurz
dokumentiert. Die *genaue Abfolge* der Arbeitsschritte ist unbedingt
einzuhalten, insbesondere vorm Aufsplitten der Briefe sind mehrere
Arbeitsschritte mit dem Gesamtdokument aller Briefe notwendig.

Alle Python-Skripte für diesen Workflow nutzen *Python 3* und einige zusätzliche
externe Module (z. B. `requests`). XXX TODO: Virtual-Environment klar definieren
(`pip freeze`)!

# Ausgangspunkt #
- `.doc`-Datei mit allen Briefen eines Bandes/Jahrgangs
- `.doc`-Datei mit den dazugehörigen Zeugenbeschreibungen (zu jedem Brief
  enthält diese Datei eine Beschreibung zur Überlieferung, Zustand des
  Manuskripts, usw.)

# Bereinigung und Aufbereitung der Briefe (`.doc`/Word-Dokument) #

# Änderungen/Kommentare/Löschungen #
Möglicherweise gibt es Änderungen/Kommentare/Löschungen die über die "Änderungen
nachverfolgen"-Funktion eingefügt wurden. In Rücksprache mit den BearbeiterInnen
der MEGA werden diese alle angenommen, so dass im Ergebnis keine
Änderungen/Kommentare/Löschungen mehr enthalten sind.

# Klartextcodes für ausgewählte Formatierungen #
Bestimmte in der Word-Datei enthaltene Formatierungen müssen über die Funktion
Suche-und-Ersetzen/bedingte Formatierung mit Klartextcodes ausgezeichnet werden,
da diese Formatierungen bei der Umwandlung über OxGarage nicht korrekt in XML
übertragen werden und somit entfallen würden. Zum jetzigen Zeitpunkt sind davon
drei Formatierungen betroffen:

 #. *Kursivierung*

    Dies entspricht einer Hervorhebung erster Stufe im Autortext.

 #. G e s p e r r t e &nbsp;Z e i c h e n
    
    Dies entspricht einer Hervorhebung zweiter Stufe im Autortext.

 #. Unterpunktung

    Dies entspricht redaktionellen Ergänzungen. Da in den Briefwechseln oft
    Wörter abgekürzt werden, werden diese teilweise zur Verbesserung der
    Lesbarkeit ergänzt. So wird z. B. "d" zu "dem" - "em" ist dann dabei
    unterpunktet. Auch kleinere Rechtschreibfehler werden so korrigiert.

 #. Gedruckter Text/Vordrucke

    Einige Dokumente sind Telegramme oder enthalten anderweitig vorgedruckte
    Abschnitte und sind also nur teilweise handschriftlich. Die Textabschnitte
    die vorgedruckt sind sind in Word durch Kapitälchen markiert.

 Alle diese Formatierungen werden durch Klartextcodes ergänzt, die im folgenden
 genauer aufgeführt werden.

## Kursivierung ##

Kursivierungen müssen mit dem Klartextcode `{emph1}`*Kursivierter
Text*`{/emph1}` ausgezeichnet werden.

## Gesperrte Zeichen ##

Gesperrter Text muss mit dem Klartextcode `{emph2}`G e s p e r r t e r &nbsp;T e
x t`{/emph2}` ausgezeichnet werden.

## Unterpunktung ##

Unterpunkteter Text muss mit dem Klartextcode `{add}`unterpunktet`{/add}`
ausgezeichnet werden.

## GEDRUCKTER TEXT/VORDRUCKE ##

Vorgedruckter Text muss mit dem Klartextcode `{ged}`VORDRUCKTEXT`{/ged}`
ausgezeichnet werden.

# Abspeichern des Dokuments als `.docx`-Datei #

Für die weitere Verarbeitung wird das `.docx`-Format erwartet. Die Word-Datei
wird dafür entsprechend mit "Speichern unter..." abgespeichert werden.

# Aufsplitten der Briefe in einzelne Dateien #

Um die weitere Verarbeitung zu vereinfachen, wird die Word-Datei so
aufgesplittet, dass jeder Brief in einer einzelnen Datei enthalten ist. Dafür
gibt es ein Visual-Basic-Makro. Die Datei `split_document.vb` enthält den dafür
benötigten Code. Für das Aufsplitten selber wird ein Makro in Microsoft Word
ausgeführt (die folgenden Schritte beziehen sich auf die Version Microsoft
Office Word 2010):

 #. Mit <kbd>ALT</kbd> + <kbd>F&nbsp;11</kbd> den Visual-Basic-Editor aufrufen
 #. Über <kbd><samp>Einfügen</samp></kbd> → <kbd><samp>Modul</samp></kbd> ein
    neues Modul anlegen
 #. Den Quellcode aus der `split_document.vb` in das neu angelegte VB-Modul
    kopieren
 #. Zielverzeichnis für die Ausgabe der aufgesplitteten Briefe anpassen
    
    In dem entsprechenden Skript muss das Zielverzeichnis für die
    aufgesplitteten Briefe angegeben werden. Dies erfolgt in der Zeile mit dem
    Aufruf `ChangeFileOpenDirectory`. Das entsprechende Verzeichnis muss im
    angegebenen Pfad bereits existieren.

 #. Das VB-Skript über den Befehl <kbd><samp>Ausführen</samp></kbd> →
    <kbd><samp>Sub/UserForm ausführen</samp></kbd> starten

    **Wichtig:** Im aufzusplittenden Dokument (mit allen Briefen) muss sich der
    Cursor auf der ersten Seite ganz am Anfang des Dokuments befinden. 

**Troubleshooting:** Das Visual-Basic-Makro bezieht sich für das Aufsplitten der
Briefe auf <samp>Abschnittswechsel</samp>, die korrekt nach jedem Brief
eingefügt sein müssen. Für die Benennung der einzelnen Brief-Dateien mit der
entsprechenden Briefnummer muss die erste Zeile jedes Briefes
(<samp>MBKolumTitel</samp>) korrekt aufgebaut sein: Die Briefnummer erscheint
als erstes Element der Zeile, abgetrennt von einem '<samp>.</samp>'.
Möglicherweise auftretende Fehler haben meist inkorrekt markierte
<samp>Abschnittswechsel</samp> oder fehlerhaft aufgebaute Briefnummern als
Ursache.

Je nach Geschwindigkeit des Computers dauert die Ausführung des Makros ca. 2 - 3
Minuten. Während das Makro ausgeführt wird, öffnen und schließen sich
Microsoft-Word-Fenster (in diesen wird jeweils ein neues Dokument mit einzelnem
Brief angelegt und abgespeichert). Während das Skript läuft dürfen keine
anderen Arbeiten am Computer durchgeführt werden; da das Skript mit der
Zwischenablage arbeitet, dürfen insbesondere keine anderen Texte, Dateien etc.
in die Zwischenablage kopiert werden.

# Aufsplitten der Zeugenbeschreibungen in einzelne Dateien #

Das entsprechende Skript ist in der Datei `split_document-zeugenbeschreibung.vb`
enthalten. Die Arbeitsschritte erfolgen analog zum Aufsplitten der Briefe:

 #. Mit <kbd>ALT</kbd> + <kbd>F&nbsp;11</kbd> den Visual-Basic-Editor aufrufen
 #. Über <kbd><samp>Einfügen</samp></kbd> → <kbd><samp>Modul</samp></kbd> ein
    neues Modul anlegen
 #. Den Quellcode aus der `split_document-zeugenbeschreibung.vb` in das neu
    angelegte VB-Modul kopieren
 #. Zielverzeichnis für die Ausgabe der aufgesplitteten Briefe anpassen
    
    In dem entsprechenden Skript muss das Zielverzeichnis für die
    aufgesplitteten Briefe angegeben werden. Dies erfolgt in der Zeile mit dem
    Aufruf `ChangeFileOpenDirectory`.

 #. Das VB-Skript über den Befehl <kbd><samp>Ausführen</samp></kbd> →
    <kbd><samp>Sub/UserForm ausführen</samp></kbd> starten

    **Wichtig:** Im aufzusplittenden Dokument mit allen Briefen muss sich der
    Cursor auf der ersten Seite ganz am Anfang des Dokuments befinden.

**Troubleshooting:** Das Visual-Basic-Makro bezieht sich für das Aufsplitten der
Briefe auf <samp>Abschnittswechsel</samp>, die korrekt nach jedem Brief
eingefügt sein müssen. Für die Benennung der einzelnen Brief-Dateien mit der
entsprechenden Briefnummer muss die erste Zeile jedes Briefes
(<samp>MBKolumTitel</samp>) korrekt aufgebaut sein: Die Briefnummer erscheint
als erstes Element der Zeile, abgetrennt von einem '<samp>.</samp>'.
Möglicherweise auftretende Fehler haben meist inkorrekt markierte
<samp>Abschnittswechsel</samp> oder fehlerhaft aufgebaute Briefnummern als
Ursache.

Je nach Geschwindigkeit des Computers dauert die Ausführung des Makros ca. 2 - 3
Minuten. Während das Makro ausgeführt wird, öffnen und schließen sich
Microsoft-Word-Fenster (in diesen wird jeweils ein neues Dokument mit einzelner
Zeugenbeschreibung angelegt und abgespeichert). Während das Skript läuft dürfen
keine anderen Arbeiten am Computer durchgeführt werden; da das Skript mit der
Zwischenablage arbeitet, dürfen insbesondere keine anderen Texte, Dateien etc.
in die Zwischenablage kopiert werden.

# Umbenennen der aufgesplitteten Dateien (leading '0's) #

Mit einem Batch-Tool für das Umbennen von Dateien (z. B. <samp>[Bulk Rename
Utility](http://www.bulkrenameutility.co.uk/)</samp>) sollten die
aufgesplitteten Einzeldateien so umbenannt werden, dass die Dateinamen folgenden
Schemata entsprechen (Reguläre Ausdrücke):

* für die Briefe: `\d{3}[a-z]?.xml` (z. B. <samp>002.xml</samp> oder
  <samp>015a.xml</samp>)
* für die Zeugenbeschreibungen: `zb_\d{3}[a-z]?.xml` (z. B.
  <samp>zb_002.xml</samp> oder <samp>zb_015ba.xml</samp>)

# Batchtransformation mit OxGarage #

Mit dem Python-Skript `oxgarage_rest_call.py` werden **alle** `.docx`-Dateien
in dem Verzeichnis in dem das Skript liegt über den OxGarage-Web-Service
(http://oxgarage.oucs.ox.ac.uk:8080) nach TEI konvertiert. Die Datei
`oxgarage_rest_call.py` muss also im gleichen Verzeichnis liegen, wie die zu
transformierenden Briefe oder Zeugenbeschreibungen. Das Verzeichnis sollte
außer den zu transformierenden Briefen/Zeugenbeschreibungen und dem
Python-Skript `oxgarage_rest_call.py` keine weiteren Dateien enthalten.

**Achtung:** Eventuell vorhandene XML-Dateien werden ohne Nachfrage
überschrieben!

 #. Das Python-Skript `oxgarage_rest_call.py` in den entsprechenden Ordner mit
    aufgesplitteten Briefen/Zeugenbeschreibungen kopieren
 #. Im passenden *Virtual Environment* (= Python-Umgebung) auf der Kommandozeile
    im entsprechenden Ordner das Python-Skript aufrufen mit: `python
    oxgarage_rest_call.py`.
 #. Nach der Verarbeitung gibt das Skript Informationen über eventuelle Fehler.
    Die Dateien `error.log` und `unicode_error.log` enthalten die Namen der
    betroffenen Dateien. (XXX TODO Fehlerbehandlung dokumentieren)

Nach der Transformation nach TEI über den Webservice OxGarage ersetzt das Skript
`oxgarage_rest_call.py` die mit Klartextcodes ausgezeichneten Textstellen mit
passenden TEI-XML-Elementen (vgl. [Klartextcodes für ausgewählte
Formatierungen](#klartextcodes-für-ausgewählte-formatierungen)). Die erzeugten
XML-Dateien erhalten für den Dateinamen das Präfix <samp>final_</samp>. Die
finalen XML-Dateien sollten dann in ein neues Verzeichnis kopiert werden und
dort dann der entsprechende Präfix wieder entfernt werden. Ab diesem Schritt
werden die Briefe und die zugehörigen Zeugenbschreibungen dann zusammen
verarbeitet (mit XSLT und Python).

# Unicode-Korrekturen für alte kyrillische Schriftart #

Da in den Word-Dokumenten für Textabschnitt mit kyrillischen Schriftzeichen eine
Schriftart verwendet wird, in der die alle Zeichen der Unicode Privat Use Area
zugeordnet sind (und also nicht die korrekten Standard Unicode Points verwendet
werden), müssen diese Unicode-Zeichen aus der Privat Use Area korrigiert werden.
Dafür gibt es das XSLT-Skript `Unicode-RU-Zeichen-ersetzen.xsl`. Es wird über
die Kommandozeile aufgerufen:

<kbd><samp>`λ java -jar "/Pfad/zu/saxon9he.jar"
-xsl:"Pfad/zum/Ordner/mit/Unicode-RU-Zeichen-ersetzen.xsl"
-s:"Pfad/zum/Ordner/mit/input-xml-dateien"
-o:"Pfad/zum/Ordner/für/output-xml-dateien"`</samp></kbd>

Dabei ist zu beachten, dass der Output-Ordner bereits existieren muss (und leer
sein sollte).

# XSLT für rudimentäre TEI-XML-Anpassung #

Um nach der Konvertierung über OxGarage die grundlegende TEI-XML-Struktur für
Ediarum herzustellen, werden *2* XSLT-Skripte verwendet:

* `oxgarage2tei.xsl` (für Umstruktierung zum TEI-Zielformat) und
* `tei-tidy-up.xsl` (zur Entfernung überflüssiger Elemente)

Ähnlich wie die Korrektur der Unicode-Zeichen verläuft auch hier Transformation
über die Kommandozeile mit dem Aufruf des XSLT-Processors Saxon jeweils für
einen ganzen Ordner: 

<kbd><samp>`java  -jar /path-to-saxon/saxon9he.jar -s:"input-folder" "-o:output-folder"
-xsl:stylesheet.xsl`</samp></kbd>

Dieser Aufruf muss für jedes der beiden XSLT-Skripte (als 1. `oxgarage2tei.xsl`,
als 2. `tei-tidy-up.xsl`) ausgeführt werden. **Wichtig**: Mit den Pfaden nicht
durcheinanderkommen - der Output-Pfad des ersten Aufrufs muss der Input-Pfad des
zweiten Durchlaufs sein!

# Python-Skript `convert_tei_directory.py` #

Komplexere Änderungen im Aufbau des TEI-XML erfolgen mit dem Python-Skript
`convert_tei_directory.py`. In diesem Schritt werden auch die Informationen aus
den Zeugenbeschreibungen (<samp>zb_XXX</samp>) zur Vervollständigung in die
Briefdateien übernommen. Aus diesem Grund muss zu jedem Brief eine entsprechende
Zeugenbschreibung vorhanden sein, der Dateiname muss dem Muster
<samp>zb_Briefnummer</samp> entsprechen (wobei die Briefnummer immer dreistellig
ist und ggf. mit '0' oder '00' aufgefüllt wird).

 #. Im passenden *Virtual Environment* (= Python-Umgebung) auf der Kommandozeile
    im entsprechenden Ordner das Python-Skript aufrufen mit: <kbd><samp>`python
    convert_tei_directory.py Pfad-zum-Input-Ordner
    Pfad-zum-Output-Ordner`</samp></kbd>. Weitere Informationen zum Skript gibt
    es mit dem Befehl <kbd><samp>`python convert_tei_directory.py
    -h`</samp></samp>.
 #. Nach der Verarbeitung gibt das Skript Informationen über eventuelle Fehler.
    Es gibt eine allgemeine Logdatei im gleichen Ordner wie das Python-Skript
    (<samp>convert_tei_directory_YYYY-MM-DD-HH-MM-SS.log</samp>). Außerdem
    enthält der angegebene Output-Ordner zu jedem verarbeiteten Brief eine
    Log-Datei mit Details zum Brief (im Format <samp>briefnummer.log</samp>).

Die Logdatein zu jedem Brief müssen dann kontrolliert werden. Umwandlungen oder
Anpassungen die nicht erfolgreich waren, sind dort als <samp>ERROR</samp>
gekennzeichnet. Gegebenenfalls/wahrscheinlich müssen einige Änderungen dann noch
per Hand durchgeführt werden.

# Notwendige manuelle Ergänzungen/Korrekturen

  * verbliebene Elemente mit `@rend="italic"` müssen zu `@ana="emph1"`
    umgewandelt werden (wird für `@rend` mit mehr als einem Wert - z. B.
    `superscript` - nicht korrekt umgewandelt, vgl.
    <https://telotadev.bbaw.de/redmine/issues/7073>)
  * verbliebene Elemente mit `@rend="bold"` müssen in oXygen Processing
    Instructions umgewandelt werden (vgl.
    <https://telotadev.bbaw.de/redmine/issues/7074>)
  * verbliebene Elemente mit `@rend="superscript"` müssen nach
    `@rendition="#sup"` geändert werden

Abschließend können alle XML-Dateien über oXygen Author in Ediarum hochgeladen
werden.
