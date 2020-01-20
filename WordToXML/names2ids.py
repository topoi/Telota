#!/usr/bin/env python3

import argparse
import csv
import datetime
import glob
import logging
import os
import sys

from lxml import etree

__version__ = "0.5"


def main(id_list_file, input_directory, output_directory):

    # Get list of XML files
    input_directory = os.path.abspath(input_directory)
    xml_files = glob.glob('{}/*.xml'.format(input_directory))

    if len(xml_files) == 0:
        logger.error('No .xml files for processing found in "{}".'.format(input_directory))
        return
    else:
        logger.info("Working with {} files in '{}'.".format(len(xml_files), input_directory))

    # Set up output directory (warn and ask for confirmation if already exists and not empty)
    output_directory = os.path.abspath(output_directory)

    # If input directory is the same as output direvtory, exit program.
    if input_directory == output_directory:
            logging.error("Input directory and output directory appear to be the same.")
            sys.exit("Exiting program.")

    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    if os.listdir(output_directory):
        logger.warning("Output directory '{}' is not empty.".format(output_directory))
        user_choice = input("Type 'yes' if you want to continue. (Directory content will be "
                            "overwritten without further confirmation.)\n")
        if not user_choice == 'yes':
            sys.exit("Exiting program.")
        else:
            logger.info("Proceeding anyway by user choice.")

    # Opening and reading CSV file
    # The csv file MUST be UTF-8 encoded, use ";" as a delimiter between columns and have two
    # columns in the order "namestring foo;someID" with no additional header row.
    id_list_file = os.path.abspath(id_list_file)
    with open(id_list_file, encoding="utf-8") as file:
        line_count = sum(1 for line in file)
    with open(id_list_file, newline='', encoding="utf-8") as csv_file:
        id_reader = csv.reader(csv_file, delimiter=';', quotechar='"')

        # Only read IDs where there is exactly one ID provided and skip keys that not have an ID
        # (Sometimes - e. g. for "Familie Marx" - two ore more person IDs might be provided)
        id_list = {}
        for row in id_reader:
            if row[1] and ' ' not in row[1] and '/' not in row[1]:
                id_list[row[0]] = row[1]
            else:
                logger.debug('Skipped row {} while reading {}'.format(row, id_list_file))
        logger.info("Read {} well-defined name-ID-pairs from '{}', which contained {} entries in "
                    "total.".format(len(id_list), id_list_file, line_count))

    # Process XML files in input_directory one anfter another
    for input_file in xml_files:

        filename = os.path.split(input_file)[1]

        # Open and parse input file
        xml_root = etree.parse(input_file).getroot()

        # Get all <persName>s in <correspAction>
        pers_names_corresp = xml_root.xpath('//tei:correspAction/tei:persName',
                                            namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})

        # Read <persName>.text and add @key attribute
        for el in pers_names_corresp:
            if not el.attrib.get('key'):
                try:
                    el.attrib['key'] = id_list[el.text]
                except KeyError:
                    logger.warning("Could not add ID in file '{}'. Did not find ID for "
                                   "<correspAction><persName> '{}'.".format(input_file, el.text))
            else:
                try:
                    logger.info("<correspAction><persName> '{}' in file '{}' already has a key, "
                                "skipping.".format(el.text.replace('\n', '\\n')[0:20] + "[...]",
                                                   input_file))
                except AttributeError:
                    logger.info("<correspAction><persName> '{}' in file '{}' already has a key, "
                                "skipping.".format(el.text[0:20] + "[...]", input_file))

        # Get all <persName>s in <body>
        pers_names_body = xml_root.xpath('//tei:body//tei:persName',
                                         namespaces={'tei': 'http://www.tei-c.org/ns/1.0'})

        # Read <persName>.key and add @key attribute
        for el in pers_names_body:
            if el.attrib.get('key') in id_list:
                el.attrib['key'] = id_list[el.attrib.get('key')]
            else:
                try:
                    logger.debug("No key found for <body><persName> '{}' with key '{}' in file '{}', "
                                "skipping.".format(el.text[0:20] + "[...]", el.attrib.get('key'),
                                                   input_file))
                except TypeError:
                    logger.debug("No key found for <body><persName> '{}' with key '{}' in file '{}', "
                                "skipping.".format(etree.tostring(el), el.attrib.get('key'),
                                                   input_file))

        # Save xml
        output_file = os.path.join(output_directory, filename)
        etree.ElementTree(xml_root).write(output_file, encoding='utf-8')

    logger.info("Successfully replaced IDs and saved files in '{}'".format(output_directory))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                                    description="Adds authority control data/IDs to names of "
                                    "XML-TEI encoded letters, using a csv list of name-ID pairs "
                                    "provided.",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        'input_directory',
                        help="Path to input directory. This directory SHOULD contain only the "
                        "letters to be processed as TEI-XML files.",
                       )
    parser.add_argument(
                        'output_directory',
                        help="Path to output directory. Processed xml files will be stored here. "
                        "Should be empty if it already exists.",
                       )
    parser.add_argument(
                        'id_list_file',
                        help="Path to csv file with name and ID pairs.",
                       )
    parser.add_argument(
                        '-V',
                        '--version',
                        help="Show version information",
                        action='store_true',
                       )
    args = parser.parse_args()

    # Set up logging for whole process.
    # (log only results, particularly errors)

    loglevel = logging.INFO

    log_file_name = datetime.datetime.now().strftime('names2ids_%Y-%m-%d-%H-%M-%S.log')
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        handlers=[logging.FileHandler(log_file_name, 'w', 'utf-8')],)
    console = logging.StreamHandler()
    console.setLevel(loglevel)
    formatter = logging.Formatter('%(levelname)s: %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('names2ids').addHandler(console)

    logger = logging.getLogger('names2ids')

    if args.version:
        print("Version: {}".format(__version__))

    main(args.id_list_file, args.input_directory, args.output_directory)
