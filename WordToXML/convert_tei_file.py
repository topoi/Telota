#!/usr/bin/env python3

############################################################################
#                                                                          #
# Smalltool to transform letters in TEI-XML format to final  target format #
# (for use with Ediarum)                                                   #
#                                                                          #
############################################################################

import logging
import os
import re
import uuid


# import os

from lxml import etree
from datetime import datetime, timezone

__version__ = "0.85"


def convert_tei_file(input_file, output_file, log_file, zb_file_directory, letter_id):
    # Set up logging
    log = logging.getLogger(__name__)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s: %(message)s')
    file_handler = logging.FileHandler(log_file, mode='w')
    file_handler.setFormatter(formatter)
    log.setLevel(logging.DEBUG)
    log.addHandler(file_handler)

    log.info("Processing '{}'".format(input_file))
    # Check if output_file already exists - we don't want to overwrite
    # existing files.
    # if os.path.isfile(args.output_file):
    #    logging.error("Output file '{}' already exists.".format(
    #                                                     args.output_file
    #                                                     )
    #                  )
    #    sys.exit("Exiting program.")

    # Parse input_file with lxml/etree
    xml_tree = etree.parse(input_file)
    log.debug("Successfully parsed '{}'".format(input_file))
    xml_root = xml_tree.getroot()

    # Get/extract Metadata
    idno, title, ms_identifier_iisg_idno, ms_identifier_rc_idno, sender, \
        date_sent, place_sent, receipients, place_received = \
        extract_meta_data(xml_root)

    # Set xml:id, xml:lang and telota:doctype on root element
    etree.register_namespace('telota', 'http://www.telota.de')
    xml_root.attrib['{http://www.telota.de}doctype'] = 'letter mega'
    xml_root.attrib['{http://www.w3.org/XML/1998/namespace}id'] = 'B{}'.format(letter_id)
    xml_root.attrib['{http://www.w3.org/XML/1998/namespace}lang'] = 'de'

    # Remove <author> in <titleStmt>
    author_element = xml_root.xpath('//tei:fileDesc/tei:titleStmt/tei:author',
                                    namespaces={'tei': 'http://www.tei-c.org/ns/1.0'
                                                })[0]
    author_element.getparent().remove(author_element)

    # Remove unnecessary <p>Converted from a Word document</p>

    p_word = xml_root.xpath('//tei:p[text()="Converted from a Word document"]',
                            namespaces={'tei': 'http://www.tei-c.org/ns/1.0'
                                        })
    for el in p_word:
        el.getparent().remove(el)

    ###############################
    #                             #
    # Fill in extracted meta data #
    #                             #
    ###############################

    # Fill in title
    title_element = xml_root.xpath('//tei:titleStmt/tei:title',
                                   namespaces={
                                        'tei': 'http://www.tei-c.org/ns/1.0'
                                        })[0]
    title_idno_element = etree.SubElement(title_element, 'idno')

    title_idno_element.text = idno
    title_idno_element.tail = title

    # Fill in msIdentifier
    sourcedesc_element = xml_root.xpath('//tei:sourceDesc',
                                        namespaces={
                                         'tei': 'http://www.tei-c.org/ns/1.0'
                                         })[0]
    msdesc_element = etree.SubElement(sourcedesc_element, 'msDesc')

    if ms_identifier_iisg_idno:
        ms_identifier_iisg_element = etree.SubElement(msdesc_element,
                                                      'msIdentifier')
        institution_element = etree.SubElement(ms_identifier_iisg_element,
                                               'institution')
        institution_element.text = 'IISG'
        collection_element = etree.SubElement(ms_identifier_iisg_element,
                                              'collection')
        if ms_identifier_iisg_idno[0] in 'CDFKL':  # e. g. from archive folder "C" or "K" ...
            collection_element.text = 'Marx-Engels-Nachlass'
        else:
            collection_element.text = 'SAMMLUNG_FEHLT'
        idno_element = etree.SubElement(ms_identifier_iisg_element, 'idno')
        idno_idno_element = etree.SubElement(idno_element, 'idno')
        idno_idno_element.set('type', 'shelfmark')
        idno_idno_element.text = ms_identifier_iisg_idno

    if ms_identifier_rc_idno and ms_identifier_iisg_idno:
        additional_element = etree.SubElement(msdesc_element, 'additional')
        listbibl_element = etree.SubElement(additional_element, 'listBibl')
        bibl_element = etree.SubElement(listbibl_element, 'bibl')
        bibl_element.text = 'RGASPI ' + ms_identifier_rc_idno
    elif ms_identifier_rc_idno:
        ms_identifier_rc_element = etree.SubElement(msdesc_element,
                                                    'msIdentifier')
        institution_element = etree.SubElement(ms_identifier_rc_element,
                                               'institution')
        institution_element.text = 'RGASPI'
        idno_element = etree.SubElement(ms_identifier_rc_element, 'idno')
        idno_idno_element = etree.SubElement(idno_element, 'idno')
        idno_idno_element.set('type', 'shelfmark')
        if 'K: ' in ms_identifier_rc_idno:
            idno_idno_element.text = ("Standort Orig. nicht bekannt; Kopie: {}"
                                      .format(ms_identifier_rc_idno[3:]))
        else:
            idno_idno_element.text = ms_identifier_rc_idno

    # Fill in profileDesc
    teiheader_element = xml_root.xpath('//tei:teiHeader',
                                       namespaces={
                                        'tei': 'http://www.tei-c.org/ns/1.0'
                                        })[0]
    profiledesc_element = etree.SubElement(teiheader_element, 'profileDesc')
    correspdesc_element = etree.SubElement(profiledesc_element, 'correspDesc')
    if sender:
        # log.debug(sender)
        correspaction_sent_element = etree.SubElement(correspdesc_element,
                                                      'correspAction')
        correspaction_sent_element.attrib['type'] = 'sent'
        for name in sender:
            persname_element = etree.SubElement(correspaction_sent_element,
                                                'persName')
            persname_element.text = name
        placename_element = etree.SubElement(correspaction_sent_element,
                                             'placeName')
        placename_element.text = place_sent
        date_element = etree.SubElement(correspaction_sent_element, 'date')
        date_element.attrib['when'] = date_sent or 'MISSING'
    if receipients:
        correspaction_received_element = etree.SubElement(correspdesc_element,
                                                          'correspAction')
        correspaction_received_element.attrib['type'] = 'received'
        for name in receipients:
            persname_element = etree.SubElement(correspaction_received_element,
                                                'persName')
            persname_element.text = name
        placename_element = etree.SubElement(correspaction_received_element,
                                             'placeName')
        placename_element.text = place_received

    # Consolidate information about OxGarage transformation into <change>-entry in <revisionDesc>

    change_element = xml_root.xpath('//tei:revisionDesc/tei:listChange/tei:change', namespaces={
                                    'tei': 'http://www.tei-c.org/ns/1.0'})[0]
    application_element = xml_root.xpath('//tei:appInfo/tei:application', namespaces={
                                         'tei': 'http://www.tei-c.org/ns/1.0'})[0]
    change_element[0].tail = " | "
    change_element[1].tail = " | "
    orgName_element = etree.SubElement(change_element, 'orgName')
    orgName_element.text = "Telota"
    orgName_element.tail = " | OxGarage {} | {}".format(application_element[0].text,
                                                        application_element.get('version'))

    del application_element, change_element, orgName_element

    # Add information about this transformation step to <revisionDesc>

    listChange_element = xml_root.xpath('//tei:revisionDesc/tei:listChange', namespaces={
                                        'tei': 'http://www.tei-c.org/ns/1.0'
                                        })[0]
    change_element = etree.SubElement(listChange_element, 'change')
    time_now = datetime.now(timezone.utc).replace(microsecond=0).astimezone().isoformat()
    date_element = etree.SubElement(change_element, 'date')
    date_element.text = time_now
    date_element.tail = " | "
    name_element = etree.SubElement(change_element, 'name')
    name_element.text = "Sascha Grabsch"
    name_element.tail = " | "
    orgName_element = etree.SubElement(change_element, 'orgName')
    orgName_element.text = "Telota"
    orgName_element.tail = " | convert_tei_file.py | {}".format(__version__)

    del listChange_element, change_element, date_element, name_element, orgName_element

    # Move <revisionDesc> to last position

    revisionDesc_element = xml_root.xpath('//tei:revisionDesc', namespaces={
                                        'tei': 'http://www.tei-c.org/ns/1.0'
                                        })[0]
    revisionDesc_parent = revisionDesc_element.getparent()
    revisionDesc_parent.append(revisionDesc_element)

    # Remove <encodingDesc>-Element

    for el in xml_root.xpath('//tei:encodingDesc',
                             namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        el.getparent().remove(el)

    # Remove now unnecessary p[@rend="MBKolumTitel"] and p[@rend="MBRedKopf"]

    for el in xml_root.xpath('//tei:p[@rend="MBKolumTitel"]',
                             namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        el.getparent().remove(el)

    for el in xml_root.xpath('//tei:p[@rend="MBRedKopf"]',
                             namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        el.getparent().remove(el)

    ##########################################
    #                                        #
    # Read 'Zeugenbeschreibung' and add info #
    #                                        #
    ##########################################

    # XXX <correspContext> not processed

    correspContext_element, physDesc_element, listWit_element, first_published, \
        iisg_foto_shelfmark = get_zeugenbeschreibung(idno, zb_file_directory)

    try:
        if additional_element is not None:
            msdesc_element.insert(1, physDesc_element)
        else:
            msdesc_element.append(physDesc_element)
    except TypeError:
        log.error("Could not add <physDesc>.")
    except UnboundLocalError:
        msdesc_element.append(physDesc_element)

    try:
        sourcedesc_element.append(listWit_element)
    except TypeError:
        log.warning("Did not add a <listWit_element>.")

    # Add information about "Erstveröffentlichung" to <teiHeader><fileDesc><editionStmt>
    if first_published:
        edition_element = xml_root.xpath('//tei:editionStmt/tei:edition', namespaces={
                                         'tei': 'http://www.tei-c.org/ns/1.0'
                                         })[0]
        edition_element.set('ana', '#firstEdition')
        edition_element.text = 'Dieser Brief wird hier erstmals veröffentlicht.'
    else:
        editionStmt_element = xml_root.xpath('//tei:editionStmt', namespaces={
                                             'tei': 'http://www.tei-c.org/ns/1.0'})[0]
        editionStmt_element.getparent().remove(editionStmt_element)

    # Add information about "Fotosignatur" (for some IISG letters) to <idno>
    if iisg_foto_shelfmark:
        # idno_element = xml_root.xpath('//tei:idno/tei:idno', namespaces={
        #                               'tei': 'http://www.tei-c.org/ns/1.0'
        #                               })[0]
        text_temp = idno_idno_element.text
        idno_idno_element.text = "{} {}".format(text_temp, iisg_foto_shelfmark)

    log.info("Successfully completed metadata in <teiHeader>")

    ##############################################
    #                                            #
    # Move <dateline> and <salute> into <opener> #
    #                                            #
    ##############################################

    # Create <opener>-Element and find <dateline> and <salute> elements
    opener = etree.Element('opener')
    dateline_element = xml_root.xpath('//tei:dateline',
                                      namespaces={'tei':
                                                  'http://www.tei-c.org/ns/1.0'
                                                  })
    salute_element = xml_root.xpath('//tei:salute',
                                    namespaces={'tei':
                                                'http://www.tei-c.org/ns/1.0'
                                                })

    # Add opener before first occurence of <dateline> or <salute>
    # TODO make this robust - <dateline> and <salute> are not copied in
    # document order right now. Need to traverse the tree and maybe copy
    # sibblings or something?

    try:
        dateline_element[0].addprevious(opener)
        log.info("Successfully created <opener>")
    except (IndexError, KeyError):
        log.debug("No <dateline> element found for <opener>! Trying with "
                  "<salute> now.")
        try:
            opener_element = salute_element[0].addprevious(opener)
            log.info("Successfully created <opener>")
        except (IndexError, KeyError):
            log.warning("No <salute> element found, <opener> not inserted.")

    try:
        opener_element = xml_root.xpath('//tei:div',
                                        namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})[0].find(
                                                                                          "opener")
        for element in dateline_element:
            opener_element.append(element)
        for element in salute_element:
            opener_element.append(element)
        log.debug("Successfully moved <dateline> and <salute> into opener")
    except NameError:
        log.warning("Could not create <opener>")

    #####################
    #                   #
    # Process Footnotes #
    #                   #
    #####################

    for footnote in xml_root.xpath('//tei:note[@place="foot"]',
                                   namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):

        type_of_change, text_affected, new_element = process_footnote(footnote)

        if type_of_change in ('variant_deletion', 'variant_deletion_break_off'):
            footnote.getparent().replace(footnote, new_element)
        if type_of_change in ('variant_addition', 'variant_replacement', 'korrektur_replacement'):
            # Check if text at the end of parent text or as tail of preceding element and remove
            # affected text
            # logging.info(footnote.getparent().text)
            logging.debug(text_affected)
            # Escape text_affected, as it might contain brackets or other regex special characters
            try:
                expr = re.compile(r'{}$'.format(re.escape(text_affected)))
            except TypeError:  # Catch text_affected is None
                pass
            if (text_affected and footnote.getparent().text and
                    len(footnote.getparent().text) >= len(text_affected) and
                    text_affected in footnote.getparent().text[-len(text_affected)]):
                footnote.getparent().text = re.sub(expr, '', footnote.getparent().text)
            elif (text_affected and footnote.getprevious() is not None and
                    footnote.getprevious().tail is not None and
                    text_affected in footnote.getprevious().tail):
                footnote.getprevious().tail = re.sub(expr, '', footnote.getprevious().tail)
            elif (footnote.getparent().text is not None and text_affected and
                    text_affected in footnote.getparent().text):
                footnote.getparent().text = re.sub(expr, '', footnote.getparent().text)
            else:
                log.error("Footnote not replaced!")
                # input("Press any key to continue.")
                continue

            # Replace footnote with new element
            footnote.getparent().replace(footnote, new_element)

    log.info("Successfully processed footnotes")

    ##################################################
    #                                                #
    # Process and transform endnotes/editorial notes #
    #                                                #
    ##################################################

    for endnote_container in xml_root.xpath('//tei:hi[@rend="endnote_reference"]',
                                            namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        seg_element = etree.Element('seg')
        seg_element.attrib['type'] = 'comment'
        orig_element = etree.Element('orig')

        # If the preceding sibling is of type <anchor>, we can easily copy the text into <orig> and
        # delete the <anchor> element
        try:
            if endnote_container.getprevious().tag == '{http://www.tei-c.org/ns/1.0}anchor':
                orig_element.text = endnote_container.getprevious().tail
                endnote_container.getparent().remove(endnote_container.getprevious())
        except AttributeError:
            pass

        seg_element.append(orig_element)
        seg_element.tail = endnote_container.tail
        note_element = etree.Element('note')
        note_element.attrib['{http://www.w3.org/XML/1998/namespace}id'] = get_nonnumerical_uuid()

        # Remove <p> if only one <p> in <note>, copy <p> content (text and elements) to
        # <note> element
        if len(endnote_container[0]) == 1:  # This means only one <p> as child
            # log.debug(etree.tostring(endnote_container[0][0], encoding='unicode'))
            note_element.text = endnote_container[0][0].text
            for child_element in endnote_container[0][0].iterchildren():
                note_element.append(child_element)
            del(endnote_container[0][0])
        else:  # Copy/preserve all <p> elements
            try:
                for child_element in endnote_container[0].iterchildren():
                    note_element.append(child_element)
            except IndexError:  # Fails on some endnotes with weird XML structure.
                log.error("Error processing endnote: {}".format(etree.tostring(endnote_container,
                                                                               encoding='unicode')))

        seg_element.append(note_element)
        endnote_container.getparent().replace(endnote_container, seg_element)

    log.info("Successfully processed endnotes")

    ###########################
    #                         #
    # Process editor comments #
    #                         #
    ###########################

    for comment in xml_root.xpath('//tei:hi[@rend="annotation_reference"]',
                                  namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        comment_author = comment[0].get('resp')
        comment_text = comment[0][0].tail
        comment_timestamp = comment[0][0].get('when')

        processing_instruction_start = etree.ProcessingInstruction('oxy_comment_start',
                                                                   'author="{}" timestamp="{}" '
                                                                   'comment="{}"'.format(
                                                                    comment_author,
                                                                    comment_timestamp,
                                                                    comment_text))
        processing_instruction_start.tail = '\uFFFD'  # Add distinctive character as comment place

        processing_instruction_end = etree.ProcessingInstruction('oxy_comment_end')
        processing_instruction_end.tail = comment.tail  # Preserve text after comment element

        comment.getparent().replace(comment, processing_instruction_end)
        processing_instruction_end.addprevious(processing_instruction_start)

    log.info("Successfully processed comments")

    ##############################################
    #                                            #
    # Transform <index> elements into <persName> #
    #                                            #
    ##############################################

    for index_element in xml_root.xpath('//tei:index[@indexName="XE"]',
                                        namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        index_key = index_element[0].text
        if index_key.startswith('zz'):  # If index entry starts with 'zz', it is a newspaper index
            continue

        try:
            previous_text = index_element.getprevious().tail
            parent = False  # Remember if text belongs to parent element or previous sibling

            # Special case, if previous sibling is a highlighted/emphasized part
            # (i.e. a <hi>-element)
            if not previous_text:
                try:
                    if (index_element.getprevious().tag == '{http://www.tei-c.org/ns/1.0}hi' and
                            index_element.getprevious().attrib['ana'] in ['emph1', 'emph2']):
                        previous_text = index_element.getprevious().text
                # If previous element is <hi> but has no @ana we add a place holder character
                except KeyError:
                    previous_text = '\uFFFD'

        # If there is no previous element (because this index_element is a direct descendant of <p>)
        # get the text of the parent <p>.
        except AttributeError:
            previous_text = index_element.getparent().text
            parent = True

        # Find last word in previous text
        expr = re.compile(r'(\w*(’)?\w*)(\S?| \S?|\S ?)$', re.DOTALL)
        try:
            persName_text = re.search(expr, previous_text).group(0)
        except AttributeError:
            persName_text = None
        except TypeError:
            if not previous_text:
                continue

        # Remove last word in previous text (because it will be placed in the <persName> element)
        if parent:
            index_element.getparent().text = re.sub(expr, '', index_element.getparent().text)
        else:
            try:
                index_element.getprevious().tail = re.sub(expr, '',
                                                          index_element.getprevious().tail)
            except TypeError:  # Happens, if previous text is in a preceding element such as <hi>
                index_element.getprevious().text = re.sub(expr, '',
                                                          index_element.getprevious().text)

        persName_element = etree.Element('persName')
        persName_element.attrib['key'] = index_key
        persName_element.text = persName_text
        persName_element.tail = index_element.tail
        index_element.getparent().replace(index_element, persName_element)

    log.info("Successfully processed index entries for persons")

    ##########################################
    #                                        #
    # Transform <index> elements into <bibl> #
    #                                        #
    ##########################################

    for index_element in xml_root.xpath('//tei:index[@indexName="XE"]',
                                        namespaces={'tei': 'http://www.tei-c.org/ns/1.0'}):
        index_key = index_element[0].text
        if not index_key.startswith('zz'):  # If index entry does not start with 'zz', skip it
            continue

        try:
            previous_text = index_element.getprevious().tail
            parent = False  # Remember if text belongs to parent element or previous sibling

            # Special case, if previous sibling is a highlighted/emphasized part
            # (i.e. a <hi>-element)
            if not previous_text:
                try:
                    if (index_element.getprevious().tag == '{http://www.tei-c.org/ns/1.0}hi' and
                            index_element.getprevious().attrib['ana'] in ['emph1', 'emph2']):
                        previous_text = index_element.getprevious().text
                # If previous element is <hi> but has no @ana we add a place holder character
                except KeyError:
                    previous_text = '\uFFFD'

        # If there is no previous element (because this index_element is a direct descendant of <p>)
        # get the text of the parent <p>.
        except AttributeError:
            previous_text = index_element.getparent().text
            parent = True

        # Find last word in previous text
        expr = re.compile(r'(\w*(’)?\w*)(\S?| \S?|\S ?)$', re.DOTALL)
        try:
            newspaper_name_text = re.search(expr, previous_text).group(0)
        except AttributeError:
            newspaper_name_text = None
        except TypeError:
            if not previous_text:
                continue

        # Remove last word in previous text (because it will be placed in the <persName> element)
        if parent:
            index_element.getparent().text = re.sub(expr, '', index_element.getparent().text)
        else:
            try:
                index_element.getprevious().tail = re.sub(expr, '',
                                                          index_element.getprevious().tail)
            except TypeError:  # Happens, if previous text is in a preceding element such as <hi>
                index_element.getprevious().text = re.sub(expr, '',
                                                          index_element.getprevious().text)

        bibl_element = etree.Element('bibl')
        bibl_element.attrib['sameAs'] = index_key
        bibl_element.text = newspaper_name_text
        bibl_element.tail = index_element.tail
        index_element.getparent().replace(index_element, bibl_element)

    log.info("Successfully processed index entries for newspapers")

    ##################################
    #                                #
    # Remove redundant <pb> elements #
    #                                #
    ##################################

    # Find <pb> elements
    pb_elements = xml_root.xpath('//tei:pb', namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})

    # If <pb> element is last child of <p>, remove it.
    for pb in pb_elements:
        # If this <pb> has a tail text it stays.
        if pb.tail:
            continue

        # If this <pb> has a following sibling element it stays.
        elif pb.getnext():
            continue

        # If this <pb> is the last child of <closer, remove it.
        elif pb.getparent().tag == '{http://www.tei-c.org/ns/1.0}closer':
            pb.getparent().remove(pb)

        # If this <pb> is not a direct descendant of a <p>, check if its parent has a next sibling.
        elif pb.getparent().tag != '{http://www.tei-c.org/ns/1.0}p':
            if pb.getparent().getparent().getnext():
                tag_name = pb.getparent().getparent().getnext().tag
                if tag_name == '{http://www.tei-c.org/ns/1.0}p':
                    pb.getparent().remove(pb)

        # Otherwise remove this <pb>
        else:
            pb.getparent().remove(pb)

    log.info("Successfully processed redundant <pb> elments")

    ##################################
    #                                #
    # Process <closer> element       #
    #                                #
    ##################################

    # Find <closer> element
    try:
        closer_element = xml_root.xpath('//tei:closer',
                                        namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})[0]
    except IndexError:  # If no closer element found...
        log.debug("No <closer> element found for processing")

    try:  # If no closer_element found
        # Assume a structure of <closer>Name</closer>
        if len(closer_element) == 0:
            signed_text = closer_element.text
            closer_element.text = ''
            signed_element = etree.SubElement(closer_element, 'signed')
            signed_element.text = signed_text
            log.debug("Replaced elements in <closer>")

        # Assume a structure of <closer><hi>{u1}</hi>Gruß<lb/>Name</closer>
        elif (closer_element[0].tag == '{http://www.tei-c.org/ns/1.0}hi' and
                closer_element[0].text == '{u1}' and
                len(closer_element) == 2):
            salute_text = closer_element[0].tail
            signed_text = closer_element[1].tail
            for child_element in closer_element:
                child_element.getparent().remove(child_element)
            salute_element = etree.SubElement(closer_element, 'salute')
            salute_element.text = salute_text
            signed_element = etree.SubElement(closer_element, 'signed')
            signed_element.text = signed_text
            log.debug("Replaced elements in <closer>")
    except UnboundLocalError:
        pass

    if not output_file:
        try:
            output_file = 'output/{}.xml'.format(str(int(idno)).zfill(3))
        except ValueError:
            output_file = 'output/{}.xml'.format(str(int(idno[:-1])).zfill(3))
    etree.ElementTree(xml_root).write(output_file)
    log.info("Successfully saved '{}' to disk.".format(output_file))
    log.removeHandler(file_handler)


def extract_meta_data(xml_root):
    """Gets a letter as an (TEI) xml tree and extracts metadata for the
    <teiHeader> part. Return values are 'None' if not data could be
    determined.

    Args:
        xml_root (lxml.etree._Element): letter as an xml tree

    Returns:
        idno (str): Identifier of the letter
        title (str): Title of letter
        ms_identifier_iisg_idno (str): Identifier for manuscript signature in
            IISG
        ms_identifier_rc_idno (str): Identifier for signature of the manuscript
            copy in RC
        sender (list): List with names of sender
        date_sent (str): Date when letter was sent (in ISO 8601, YYYY-MM-DD)
        place_sent (str): Place name of senders place
        receipients (list): List with receipient names
        place_received (str): Place name of receiver
    """

    # Set up dictionary for string versions of months.
    months_lookup = {
              'Januar': '01',
              'Februar': '02',
              'März': '03',
              'April': '04',
              'Mai': '05',
              'Juni': '06',
              'Juli': '07',
              'August': '08',
              'September': '09',
              'Oktober': '10',
              'November': '11',
              'Dezember': '12'
    }

    log = logging.getLogger(__name__)

    # Get contents of <p rend="MBKolumTitel"> & <p rend="MBRedKopf"> via XPath
    # If the XPath matches, kolum_titel_node & red_kopf are nested lists
    # containing the matched element.
    kolum_titel_node = xml_root.xpath("//tei:p[@rend='MBKolumTitel']",
                                      namespaces={'tei':
                                                  'http://www.tei-c.org/ns/1.0'
                                                  })
    red_kopf = xml_root.xpath("//tei:p[@rend='MBRedKopf']",
                              namespaces={'tei':
                                          'http://www.tei-c.org/ns/1.0'})

    # Make the 4 lines of MBRedKopf available on their own and remove potential
    # line breaks and superflous white space.
    try:
        red_kopf_line_1 = clean_whitespace(red_kopf[0].text)
        red_kopf_line_2 = clean_whitespace(red_kopf[0][0].tail)
        red_kopf_line_3 = clean_whitespace(red_kopf[0][1].tail)
        red_kopf_line_4 = clean_whitespace(red_kopf[0][2].tail)
    except KeyError:
        log.error("Could not read MBRedKopf")
        pass

    # Remove potential line breaks and whitespace from kolum_titel_node and
    # extract text (whitout superflous white space!) into kolum_titel.
    try:
        kolum_titel = clean_whitespace(kolum_titel_node[0].text)
    except IndexError:
        log.error("Could not extract text from 'kolum_titel'.")

    # Read idno and title from p[@rend="MBRedKopf"]
    try:
        idno = red_kopf_line_1
        log.debug("idno: '{}'".format(str(idno)))
    except NameError:
        idno = None
        log.error("Could not generate 'idno'.")

    # Create title from p[@rend="MBRedKopf"]
    # The title is set apart by <lb>-Elements, which are assembled together
    # in a one line string. White space for the last element get's replaced.

    try:
        title = '{} {}. {}'.format(
                                   red_kopf_line_2, red_kopf_line_3,
                                   red_kopf_line_4
                                  )
        log.debug("title: '{}'".format(str(title)))
    except NameError:
        title = None
        log.error("Could not generate 'title'.")

    # Read ms_identifier_* from p[@rend="MBKolumTitel"]
    try:
        if 'IISG' in kolum_titel:
            # XXX regex if no "K:" in MBKolumTitel
            regex = re.compile(r'\/\/ ?IISG ((?:(?! K:).)*)')
            # log.debug(kolum_titel)
            ms_identifier_iisg_idno = re.findall(regex, kolum_titel)[0]
        else:
            ms_identifier_iisg_idno = None

        log.debug("ms_identifier_iisg_idno: '{}'"
                  .format(str(ms_identifier_iisg_idno)))

        if 'RC' in kolum_titel or 'RGA' in kolum_titel:
            regex = re.compile(r'(RC.*|RGA.*)')
            ms_identifier_rc = re.findall(regex, kolum_titel)[0].split('.')

            # Slightly modify ms_identifier for RC (=RGASPI)
            ms_identifier_rc_idno = "f. {} op. {} d. {}".format(ms_identifier_rc[0][3:],
                                                                ms_identifier_rc[1],
                                                                ms_identifier_rc[2])
        else:
            ms_identifier_rc_idno = None

        if not ms_identifier_iisg_idno and 'K:' in kolum_titel:
            ms_identifier_rc_idno = 'K: ' + str(ms_identifier_rc_idno)

        log.debug(kolum_titel)
        log.debug("ms_identifier_rc_idno: '{}'".format(str(ms_identifier_rc_idno)))

    except NameError:
        ms_identifier_iisg_idno = None
        ms_identifier_rc_idno = None
        log.error("Could not generate 'ms_identifier_iisg_idno'.")

    # Read sender (can be one or more) from p[@rend="MBRedKopf"]

    # Take text of second line of MBRedKopf, split on ' an ' and take first
    # part as sender string. Since there can be more than one sender, this
    # string is split on ', ' and ' und '. This works because re.split returns
    # the original string if the pattern does not match.
    try:
        sender_string = red_kopf_line_2.split(' an ')[0]

        sender = re.split(', | und ', sender_string)
        log.debug("sender: '{}'".format(str(sender)))
    except (NameError, AttributeError):
        sender = []
        log.error("Could not generate 'sender'.")

    # Read receipients (can be one or more) from p[@rend="MBRedKopf"]

    # Take text of second line of MBRedKopf, split on ' an ' and take second
    # part as receipient string. Since there can be more than one receipient,
    # this string is split on ', ' and ' und '. This works because re.split
    # returns the original string if the pattern does not match.
    try:
        log.debug(red_kopf_line_2)
        receipients_string = red_kopf_line_2.split(' an ')[1]

        receipients = re.split(', | und ', receipients_string)
        log.debug("receipients: '{}'".format(str(receipients)))
    except (NameError, AttributeError):
        receipients = []
        log.error("Could not generate 'receipients'.")

    # Read date_sent from p[@rend="MBRedKopf"]
    try:
        # Remove potential line break from this line of MBRedKopf
        date_sent_line = red_kopf_line_4

        expr = re.compile('(\d{1,2}). (Januar|Februar|März|April|Mai|Juni|'
                          'Juli|August|September|Oktober|November|Dezember)'
                          ' (\d{4})')
        date_sent_elements = re.findall(expr, date_sent_line)

        # Put the regex results into ISO 8601 format
        date_sent = '{}-{}-{}'.format(date_sent_elements[0][2],
                                      months_lookup[date_sent_elements[0][1]],
                                      date_sent_elements[0][0].zfill(2))
        log.debug("date_sent: '{}'".format(str(date_sent)))
    except NameError:
        date_sent = None
        log.error("Could not generate 'date_sent'.")
    except IndexError:  # XXX If there is a person index entry, everything breaks :-/
        date_sent = None
        log.error("Could not generate 'date_sent'.")
    except TypeError:  # FIXME prevent breakage
        date_sent = None
        log.error("Could note generate 'date_sent'.")
        log.debug(date_sent_line)

    # Read place_sent from p[@rend="MBRedKopf"]
    try:
        expr = re.compile('^(?:(?!, ).)*')
        place_sent = re.findall(expr, red_kopf_line_4)[0]
        log.debug("place_sent: '{}'".format(str(place_sent)))
    except NameError:
        place_sent = None
        log.error("Could not generate 'place_sent'.")
    except TypeError:  # FIXME prevent breakage
        place_sent = None
        log.error("Could note generate 'place_sent'.")
        log.debug(date_sent_line)

    # Read place_received from p[@rend="MBRedKopf"]
    try:
        expr = re.compile('^in (.*)')
        place_received = re.findall(expr, red_kopf_line_3)[0]
        log.debug("place_received: '{}'".format(str(place_received)))
    except NameError:
        place_received = None
        log.error("Could not generate 'place_received'.")
    except IndexError:  # XXX If there is a person index entry, everything breaks :-/
        place_received = None
        log.error("Could not generate 'place_received'.")
    except TypeError:  # FIXME prevent breakage
        place_received = None
        log.error("Could note generate 'place_received'.")
        log.debug(red_kopf_line_3)

    return idno, title, ms_identifier_iisg_idno, ms_identifier_rc_idno, \
        sender, date_sent, place_sent, receipients, place_received


def get_zeugenbeschreibung(idno, zb_file_directory):
    """Read metadata ("Zeugenbeschreibung") for a single letter from a
    TEI-XML file. This depends on the file naming scheme
    "zb_briefnummer.xml".

    Args:
        idno (str): Letter number
        zb_file_directory: Path to directory with zb_* files

    Returns:
        correspContext_element
        physDesc_element
        listWit_element
        first_published
        iisg_foto_shelfmark
    """

    log = logging.getLogger(__name__)

    correspContext_element, physDesc_element, listWit_element, publication_history, \
        iisg_foto_shelfmark = (None,)*5

    # Generate file name for Zeugenbeschreibung
    try:
        zb_filename = 'zb_{}.xml'.format(str(int(idno)).zfill(3))
        # if idno contains a character we remove it before padding it with zeros
        # and than readd it
    except ValueError:
        zb_filename = 'zb_{}{}.xml'.format(str(int(idno[:-1])).zfill(3), idno[-1:])
    file_zeugenbeschreibung = os.path.join(zb_file_directory, zb_filename)

    # Open 'Zeugenbeschreibung'
    try:
        xml_tree = etree.parse(file_zeugenbeschreibung)
    except OSError:
        log.error("Could not read 'Zeugenbeschreibung' for letter no.: {}. '{}'"
                  " not found.".format(idno, file_zeugenbeschreibung))
        raise
        # return correspContext_element, physDesc_element, listWit_element, None

    xml_root = xml_tree.getroot()
    log.debug("Successfully parsed Zeugenbeschreibung ('{}')".format(file_zeugenbeschreibung))

    p_elements = xml_root.xpath('//tei:body/tei:div/tei:p[not(@*)]',
                                namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})

    first_published = False
    physDesc_p_elements = []
    for p in p_elements:
        # log.info(p.text)
        p_text = etree.tostring(p, method='text', encoding='unicode')

        # Does the letter have a "Fotosignatur" (as some IISG letters do)

        try:
            expr = re.compile(r'Fotosign\.\s(.*)\. ?$', re.UNICODE)
            iisg_foto_shelfmark = re.search(expr, clean_whitespace(p_text)).group(0)
            log.debug("Found iisg_foto_shelfmark: {}".format(iisg_foto_shelfmark))
        except AttributeError:
            pass

        # Is the letter first published?
        try:
            expr = re.compile(r'^ ?(Der Brief wird hier erstmals veröffentlicht\.)$')
            first_published = re.search(expr, clean_whitespace(p_text)).group(0)
            log.debug("first_published: {}".format(first_published))
        except AttributeError:
            pass

        # Publication history
        try:
            expr = re.compile(r'^ *(Erstveröffentlichung:.*)', re.DOTALL)
            publication_history = re.search(expr, p_text).group(0)
            publication_history = publication_history.split('; ')
        except AttributeError:
            if not publication_history:
                publication_history = None

        # Other paragraphs
        try:
            expr = re.compile(r'^ *(Erstveröffentlichung:.*)', re.DOTALL)
            if 'Der Brief wird hier erstmals veröffentlicht.' not in \
                    clean_whitespace(p_text) and not re.search(expr, p_text) and \
                    'Originalhandschrift: ' not in clean_whitespace(p_text):
                physDesc_p_elements.append(p)
        except:  # FIXME Specify error type!
            pass

    physDesc_element = etree.Element('physDesc')
    for i, el in enumerate(physDesc_p_elements):
        physDesc_element.insert(i, el)

    if publication_history:
        listWit_element = etree.Element('listWit')

    if not first_published:
        log.debug("first_published: not published for first time")

    try:
        for entry in publication_history:
            witness_element = etree.Element('witness')
            bibl_element = etree.SubElement(witness_element, 'bibl')
            # Provide superscript markup for 'MEGA1'
            if 'MEGA1' in entry:
                expr = re.compile(r'MEGA1')
                position = re.search(expr, entry).start()
                bibl_element.text = entry[:position] + 'MEGA'
                hi_sup_element = etree.SubElement(bibl_element, 'hi')
                hi_sup_element.set('rendition', '#sup')
                hi_sup_element.text = '1'
                hi_sup_element.tail = entry[position+5:]
            else:
                bibl_element.text = entry
            listWit_element.append(witness_element)
    except TypeError:
        pass

    return correspContext_element, physDesc_element, listWit_element, first_published, \
        iisg_foto_shelfmark


def process_footnote(footnote):
    """Processes a footnote and returns type of indicated variant or emendation

    Args:
        footnote (lxml.etree._Element): The footnote to be processed

    Returns:
        type_of_change (str): The type of variant, emendation or correction
        text(str): The text affected
        new_element(lxml.etree._Element): The newly created TEI-XML element which replaces
            the footnote.
    """

    # log.debug((footnote[0][0].tail))
    # log.debug(etree.tostring(footnote))

    text = None
    new_element = None

    log = logging.getLogger(__name__)
    log.debug("Footnote no.: {}".format(footnote.get('n')))
    log.debug("text: {}".format(etree.tostring(footnote)))

    try:
        if footnote[0][0].text == '{v}':
            type_of_change = 'variant'
        elif footnote[0][0].text == '{k}':
            type_of_change = 'korrektur'
        else:
            type_of_change = None
    except KeyError:
        log.error("Could not determine type of footnote no.:\n {}"
                  .format(str(footnote.get('n'))))
        log.debug("Footnote source:\n{}".format(format(etree.tostring(footnote))))
        type_of_change = None

    # Check for editor statement in footnote
    expr = re.compile(r'^\[?(.*)] +{H} *(.*?)(?= ) (.*)$')
    try:
        footnote_text = clean_whitespace(footnote[0][0].tail.strip() or footnote[0][1].text.strip())
        # log.info(etree.tostring(footnote[0][1]))
        # log.info(clean_whitespace(footnote[0][1].text.strip()))
        # log.debug(etree.tostring(footnote))
        add_text = re.search(expr, footnote_text).group(1)
        if re.search(expr, footnote_text).group(2):
            del_text = re.search(expr, footnote_text).group(2)
            editor_text = re.search(expr, footnote_text).group(3)
        else:
            del_text = re.search(expr, footnote_text).group(3)
            editor_text = None
        type_of_change += '_replacement'
        text = add_text
        new_element = etree.Element('choice')
        # new_element.attrib['resp'] = 'editor'
        sic_element = etree.Element('sic')
        sic_element.text = del_text
        corr_element = etree.Element('corr')
        corr_element.text = add_text
        corr_element.attrib['cert'] = 'high'
        # corr_element.attrib['type'] = 'editorial' --> not needed/expected for ediarum
        new_element.insert(0, sic_element)
        new_element.insert(1, corr_element)
        if editor_text is not None:
            note_element = etree.Element('note')
            note_element.attrib['resp'] = 'editor'
            note_element.text = editor_text
            new_element.insert(0, note_element)

        # new_element.insert(1, corr_element)
        # log.info(etree.tostring(new_element))

    except (IndexError, AttributeError):
        pass

    # Check for addition ("Textergänzung"), contained in "|: text :|"
    expr = re.compile(r'^\|: ((?:(?!:\|).)*)(?!:\|)')
    try:
        text = re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(1)
        type_of_change += '_addition'
        new_element = etree.Element('add')
        new_element.text = text
    except (IndexError, AttributeError):
        pass

    # Check for normal deletion, contained in "<text>"
    expr = re.compile(r'<(.*)>(?=$)')
    try:
        text = re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(1)
        type_of_change += '_deletion'
        new_element = etree.Element('del')
        new_element.text = text
    except (IndexError, AttributeError):
        pass

    # Check for deletion with break-off ("Textreduzierung mit Abbruch"),
    # contained in "<text>/"
    expr = re.compile(r'<(.*)>/(?=$)')
    try:
        text = re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(1)
        type_of_change += '_deletion_break_off'
        new_element = etree.Element('del')
        sic_element = etree.Element('sic')
        sic_element.attrib['ana'] = '#break-off'
        new_element.text = text
        new_element.insert(0, sic_element)
    except (IndexError, AttributeError):
        pass

    # Check for text replacement ("Umstellung"),
    # marked by "text_old>>text_new" (with possible whitespace before/after ">>")
    expr = re.compile(r'((?:(?!( )?>>).)*) ?>> ?((?:(?!$).)*)')
    try:
        # text = [re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(1),
        #         re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(3)]
        del_text = re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(1)
        add_text = re.search(expr, clean_whitespace(footnote[0][0].tail.strip())).group(3)
        text = add_text
        type_of_change += '_replacement'
        new_element = etree.Element('subst')
        del_element = etree.Element('del')
        del_element.text = del_text
        add_element = etree.Element('add')
        add_element.text = add_text
        new_element.insert(0, del_element)
        new_element.insert(1, add_element)
        # log.info(etree.tostring(new_element))
    except (IndexError, AttributeError):
        pass

    log.debug("Working on: {}".format(clean_whitespace(footnote[0][0].tail.strip() or
                                      footnote[0][0].text.strip())))
    log.debug("type_of_change: '{}'".format(type_of_change))
    log.debug("found_text: '{}'".format(text))

    try:
        new_element.tail = footnote.tail
        log.debug("new_element: {}".format(etree.tostring(new_element)))
    except (AttributeError, TypeError):
        pass

    if not text:
        log.warning("Editor intervention could not be determined for footnote no.: {}".
                    format(footnote.get('n')))
        # input("Press any key to continue.")

    return type_of_change, text, new_element


def clean_whitespace(string):
    """ Cleanes the supplied string from linebreaks and superflous whitespace.
    This is intended to simplify working with the strings from pretty-printed
    XML.

    Args:
        string (str): The string to be cleaned

    Returns:
        cleaned_string (str): The cleaned up string

    """
    try:
        cleaned_string = re.sub('( *\n\s*)', ' ', string)
    except TypeError:
        return None
    return cleaned_string


def get_nonnumerical_uuid():
    """Returns a uuid (Version 4), that is guaranteed to start with a letter ([a-z]). This makes it
    usable as a XML-ID.

    Returns:
        nonnumerical_uuid (str): A String containinig a uuid (Version 4), guaranteed to start with
                                 a letter

    """

    id = uuid.uuid4()
    while str(id)[0] not in 'abcdef':
        id = uuid.uuid4()
    return str(id)
