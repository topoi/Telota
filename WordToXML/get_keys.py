#!/usr/bin/env python3

import argparse
import glob
import os

import xlsxwriter

from collections import Counter
from lxml import etree


def main(input_directory, output_file):
    # Process TEI-XML documents in a directory.
    # Get list of xml files (check for TEI files?)
    input_directory = os.path.abspath(input_directory)
    xml_files = glob.glob('{}/*.xml'.format(input_directory))

    if len(xml_files) == 0:
        print("No .xml files for processing found in '{}'.".format(input_directory))
        return

    if not output_file.endswith('.xlsx'):
        print("Output file must be of type '.xlsx'.")
        return

    # Set up counter object for <persName> @keys
    cnt_persName_keys = Counter()

    # Set up counter object for correspondence <persName>s
    cnt_correspondence_names = Counter()

    # Set up counter object for correspondence <placeName>s
    cnt_correspondence_places = Counter()

    # Open all xml files in given directory
    for file in xml_files:
        xml_tree = etree.parse(file)
        xml_root = xml_tree.getroot()

        # XPath for <persName>s in letter text
        persNames = xml_root.xpath('//tei:body//tei:persName',
                                   namespaces={
                                               'tei': 'http://www.tei-c.org/ns/1.0'
                                              })
        # Add all found keys to counter
        for persName in persNames:
            cnt_persName_keys[persName.get('key').encode('utf-8')] += 1

        # XPath for <persName>s in <correspAction>
        persNames = xml_root.xpath('//tei:correspAction/tei:persName',
                                   namespaces={
                                               'tei': 'http://www.tei-c.org/ns/1.0'
                                              })
        # Add all found keys to counter
        for persName in persNames:
            if persName.text:
                cnt_correspondence_names[persName.text.encode('utf-8')] += 1

        # XPath for <placeName>s in <correspAction>
        placeNames = xml_root.xpath('//tei:correspAction/tei:placeName',
                                    namespaces={
                                               'tei': 'http://www.tei-c.org/ns/1.0'
                                              })
        # Add all found keys to counter
        for placeName in placeNames:
            if placeName.text:
                cnt_correspondence_places[placeName.text.encode('utf-8')] += 1

    print("INFO: Found {} <persName> keys, {} names of correspondents and {} place names in {} "
          "xml files.".format(len(cnt_persName_keys), len(cnt_correspondence_names),
                              len(cnt_correspondence_places), len(xml_files)))

    # Output results to .xlsx file
    workbook = xlsxwriter.Workbook(output_file)
    worksheet_persName_keys = workbook.add_worksheet('keys zu <persName>')
    bold = workbook.add_format()
    bold.set_bold()
    worksheet_persName_keys.set_column('A:A', 28)
    worksheet_persName_keys.set_column('C:C', 28)
    worksheet_persName_keys.write('A1', 'key', bold)
    worksheet_persName_keys.write('B1', 'Anzahl', bold)
    worksheet_persName_keys.write('C1', 'PDR-ID aus Personenregister', bold)
    row = 1
    col = 0

    for key, count in sorted(cnt_persName_keys.items()):
        worksheet_persName_keys.write(row, col, key.decode('utf-8'))
        worksheet_persName_keys.write(row, col + 1, count)
        row += 1

    worksheet_persName_correspondence = workbook.add_worksheet('Namen von Korrespondenzpartnern')
    bold = workbook.add_format()
    bold.set_bold()
    worksheet_persName_correspondence.set_column('A:A', 28)
    worksheet_persName_correspondence.set_column('C:C', 28)
    worksheet_persName_correspondence.write('A1', 'Name', bold)
    worksheet_persName_correspondence.write('B1', 'Anzahl', bold)
    worksheet_persName_correspondence.write('C1', 'PDR-ID aus Personenregister', bold)
    row = 1
    col = 0

    for key, count in sorted(cnt_correspondence_names.items()):
        worksheet_persName_correspondence.write(row, col, key.decode('utf-8'))
        worksheet_persName_correspondence.write(row, col + 1, count)
        row += 1

    worksheet_placeName_correspondence = workbook.add_worksheet('Ortsnamen zur Korrespondenz')
    bold = workbook.add_format()
    bold.set_bold()
    worksheet_placeName_correspondence.set_column('A:A', 28)
    worksheet_placeName_correspondence.set_column('C:C', 28)
    worksheet_placeName_correspondence.write('A1', 'Ort', bold)
    worksheet_placeName_correspondence.write('B1', 'Anzahl', bold)
    worksheet_placeName_correspondence.write('C1', 'Orts-ID aus Ortsregister', bold)
    row = 1
    col = 0

    for key, count in sorted(cnt_correspondence_places.items()):
        worksheet_placeName_correspondence.write(row, col, key.decode('utf-8'))
        worksheet_placeName_correspondence.write(row, col + 1, count)
        row += 1

    try:
        workbook.close()
    except PermissionError:
        print("ERROR: Can't write to '{}'. (Maybe it is already opened?)".format(output_file))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Lists and counts occurences of keys for "
                                                 "<persName> and <placeName> in TEI-XML "
                                                 "documents.")
    parser.add_argument('input_directory',
                        help="Path to input directory. This directory SHOULD contain only the "
                        "TEI-XML files to be processed.")
    parser.add_argument('output_file',
                        help="Name/Path for output file. This shoud be a '.xslx' file.")
    args = parser.parse_args()

    main(args.input_directory, args.output_file)
