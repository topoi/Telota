#!/usr/bin/env python3

import argparse
import datetime
import logging
import os
import sys

import requests

from tqdm import tqdm

__version__ = '0.1'


def main(pdr_ids_file, output_directory):

    # Query PDR-IDI for files

    # Get list PDR IDs
    input_file = os.path.abspath(pdr_ids_file)

    logger.info("Reading PDR-IDs from {}".format(input_file))

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except IOError:
        logger.error("Could not read {}".format(input_file))
        print("Exiting program")
        sys.exit(1)

    # Set up output directory (warn and ask for confirmation if already exists and not empty)
    output_directory = os.path.abspath(output_directory)

    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    if os.listdir(output_directory):
        logger.warning("Output directory '{}' is not empty.".format(output_directory))
        user_choice = input("\nType 'yes' if you want to continue. (Directory content will be "
                            "overwritten without further confirmation.)\n")
        if not user_choice == 'yes':
            print("Aborting program.")
            return

    pdr_ids = [line.rstrip() for line in lines if not line.isspace() and line.startswith('pdr')]
    logger.debug("Found {} PDR-IDs".format(str(len(pdr_ids))))

    with requests.Session() as s:
        for pdr_id in tqdm(pdr_ids):
            logger.debug("Requesting PDR data for PDR-ID {}".format(pdr_id))
            url = 'https://pdrprod.bbaw.de/idi/pdrnc/{}'.format(pdr_id)
            try:
                pdr_response = s.get(url)
                pdr_response.raise_for_status()
            except requests.exceptions.HTTPError:
                logger.error("Error requesting {}. Server responded with status "
                             "code {}".format(url, pdr_response.status_code))
                continue
            except requests.exceptions.ConnectionError:
                logger.error("Could not connect to server")
                continue

            output_filename = os.path.join(output_directory, '{}.xml'.format(pdr_id))
            try:
                with open(output_filename, 'wb') as output_file:
                    output_file.write(pdr_response.content)
            except IOError:
                logger.error("Could not write to {}".format(output_filename))

            logger.debug("Successfully saved PDR data for "
                         "PDR-ID {} to {}".format(pdr_id, output_filename))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
                                    description="Queries PDR-IDI for person data (as xml)",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        'pdr_ids_file',
                        help="Text file (MUST be UTF-8) with a single pdr-person-ID on each line",
                       )
    parser.add_argument(
                        'output_directory',
                        help="Path to output directory. Downloader xml files and log files will be "
                        "stored here. Should be empty if it already exists.",
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

    log_file_name = datetime.datetime.now().strftime('get_pdr_data_%Y-%m-%d-%H-%M-%S.log')
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        filename=log_file_name,
                        filemode='w')
    console = logging.StreamHandler()
    console.setLevel(loglevel)
    formatter = logging.Formatter('%(levelname)s: %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

    logger = logging.getLogger('get_pdr_data')

    if args.version:
        print(__version__)

    main(args.pdr_ids_file, args.output_directory)
