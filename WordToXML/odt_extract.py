#!/usr/bin/env python3

############################################################################
#                                                                          #
# Small command line tool to extract 'content.xml' from Open Document Text #
# files.                                                                   #
#                                                                          #
############################################################################

import argparse
import os
import sys
import zipfile


def main():
    """Extracts content.xml from given Open Document Text file into current
        working directory."""
    parser = argparse.ArgumentParser(description='Extracts content.xml from '
                                                 'given .odt file into '
                                                 'current directory.')
    parser.add_argument('input_file', help='Path to the .odt file')

    # parser.add_argument('output_file', help='Name of the emitted .xml file '
    #                     '(default: "content.xml" in current directory)',
    #                     default='content.xml', nargs="?")

    args = parser.parse_args()

    # If input_file does not end in '.odt' assume it's not an .odt file and
    # exit program.
    if args.input_file[-4:] != '.odt':
        sys.exit('The given input file \'{}\' does not seem to be an .odt '
                 'file (no \'.odt\' ending).'.format(args.input_file))

    # Check if 'content.xml' already exists in working directory - we don't
    # want to overwrite existing files.
    if os.path.isfile('content.xml'):
        sys.exit('\'content.xml\' already exists in working directory')

    try:
        with zipfile.ZipFile(args.input_file, 'r') as odt_file:
            odt_file.extract('content.xml')
            print('\'content.xml\' successfully extracted to current working '
                  'directory.')
    except (zipfile.BadZipFile, os.error):
        print('Could not extract "content.xml" The given input file \'{}\' '
              'seems to be corrupted.'.format(args.input_file))


if __name__ == '__main__':
    main()
