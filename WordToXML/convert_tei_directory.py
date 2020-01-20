#!/usr/bin/env python3

import argparse
import datetime
import glob
import logging
import os
import re
import sys

from convert_tei_file import convert_tei_file
__version__ = "0.5"


def main(input_directory, output_directory, start_id):

    # Process TEI-XML documents in a directory.
    # (File names should match letter numbers.)

    # Get list of xml files (check for TEI files?)
    # TODO Check if only .xml files in directory (ask for confirmation if not).
    input_directory = os.path.abspath(input_directory)
    xml_files = glob.glob('{}/*.xml'.format(input_directory))
    logger.debug(input_directory)

    # Check filenames for pattern "^\d{1,3}[a-z]?.xml$"
    file_pattern = re.compile('^\d{1,3}[a-z]?.xml$')
    letters = [xml_file for xml_file in xml_files if file_pattern.match(os.path.basename(xml_file))]
    logger.debug("Processing {} letters.".format(len(letters)))

    if len(letters) == 0:
        logger.error('No .xml files for processing found in "{}".'.format(input_directory))
        return
    else:
        logger.info("Found {} .xml file(s) for processing.".format(str(len(letters))))

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
        user_choice = input("\nType 'yes' if you want to continue. (Directory content will be "
                            "overwritten without further confirmation.)\n")
        if not user_choice == 'yes':
            print("Aborting program.")
            return

    # Process files in 'letters' one anfter another
    processing_errors = []
    for i, input_file in enumerate(letters):
        letter_number = os.path.splitext(os.path.basename(input_file))[0]
        log_file = os.path.join(output_directory, '{}.log'.format(letter_number))
        output_file = os.path.join(output_directory, '{}.xml'.format(letter_number))
        zb_file_directory = input_directory
        letter_id = str(start_id + i).zfill(5)
        try:
            # This function must use it's own logging file for each call!
            convert_tei_file(input_file, output_file, log_file, zb_file_directory, letter_id)
        except IOError:  # XXX which error?
            logging.error("Could not process {}. See specific log file in output"
                          " directory for details.".format(input_file))
            processing_errors.append(input_file)

    # logging.info("Finished processing all files in {}".format(input_directory))
    # if len(processing_errors) > 0:
    #     logging.error("Some errors occured while processing the files in {}. "
    #                   "Check the log for more information.".format(diretory))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
                                    description="Transforms letters in TEI-XML format in given "
                                    "directory to final target format (for use with Ediarum).",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        'input_directory',
                        help="Path to input directory. This directory SHOULD contain only the "
                        "letters to be processed as TEI-XML files and the associated "
                        "\"Zeugenbeschreibungen\". File names should correspond to letter "
                        "numbers and to the pattern \"^\d{3}[a-z]?.xml$\", with "
                        "\"Zeugenbeschreibungen\" having a \"zb_\" prefix.",
                       )
    parser.add_argument(
                        'output_directory',
                        help="Path to output directory. Processed xml files and log files will be "
                        "stored here. Should be empty if it already exists.",
                       )
    parser.add_argument(
                        'starting_letter_id',
                        help="Starting id for the first letter in this collection. Should be a "
                        "number following the last id already existing (in ediarum). This id is "
                        "used to generate the sequential numbering of xml:id.",
                        default='1',
                        type=int,
                        )
    parser.add_argument(
                        '-V',
                        '--version',
                        help="Show version information",
                        action='store_true',
                       )
    parser.add_argument(
                        '-v',
                        '--verbose',
                        help="Increase verbosity",
                        action='store_true',
                       )
    args = parser.parse_args()

    # Set up logging for whole process.
    # (log only results, particularly errors)

    if args.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.INFO

    log_file_name = datetime.datetime.now().strftime('convert_tei_directory_%Y-%m-%d-%H-%M-%S.log')
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        filename=log_file_name,
                        filemode='w')
    console = logging.StreamHandler()
    console.setLevel(loglevel)
    formatter = logging.Formatter('%(levelname)s: %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

    logger = logging.getLogger('convert_tei_directory')

    if args.version:
        print(__version__)

    main(args.input_directory, args.output_directory, args.starting_letter_id)
