#!/usr/bin/env python3

import argparse
import datetime
import glob
import logging
import os
# import pprint
import sys

__version__ = '0.3'


def main(loglevel, backup_directory):
    # Set up logging to a log file in script directory
    path = os.path.dirname(os.path.realpath(__file__))
    log_file_name = datetime.datetime.now().strftime('clean_exist_backup_%Y-%m-%d.log')
    log_file_name = os.path.join(path, log_file_name)
    logging.basicConfig(level=loglevel,
                        format='%(asctime)s - %(levelname)s - %(message)s',
                        filename=log_file_name,
                        filemode='a')
    logger = logging.getLogger('names2ids')
    backup_directory = os.path.abspath(backup_directory)
    logger.info('backup_directory: "{}"'.format(backup_directory))

    if not os.path.exists(backup_directory):
        logger.error('"{}" does not exist'.format(backup_directory))
        print('"{}" does not exist. Exiting script'.format(backup_directory))
        sys.exit(1)

    files = glob.glob('{}/**/__contents__.xml'.format(backup_directory), recursive=True)
    logger.info('Found {} occurence(s) of "__contents__.xml"'.format(len(files)))

    if len(files) == 0:
        print('Nothing found to cleanup. Exiting script')
        sys.exit(0)
    else:
        print('Found {} files to delete.'.format(len(files)))

    for file in files:
        logger.info('Removing "{}"'.format(file))
        print('Removing "{}"'.format(file))
        os.remove(file)

    logger.info('Succesfully cleaned up "{}"'.format(backup_directory))
    print('Succesfully cleaned up "{}". Exiting script'.format(backup_directory))
    sys.exit(0)

    # pp = pprint.PrettyPrinter()
    # pp.pprint(files)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                                    description="Clean unneccessary files in a given directory of "
                                    "an eXist backup (just '__contents__.xml' for now).",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        'backup_directory',
                        help="Path to directory which is to be cleaned up.",
                        nargs='?',
                        default=None,
                        )
    parser.add_argument(
                        '-V',
                        '--version',
                        help="Print version information and exit",
                        action='store_true',
                       )
    args = parser.parse_args()

    loglevel = logging.INFO

    if args.version:
        print("clean_exist_backup.py")
        print("Version: {}".format(__version__))
        sys.exit(0)

    if not args.backup_directory:
        parser.error("the following arguments are required: backup_directory")
        sys.exit(1)

    main(loglevel, args.backup_directory)
