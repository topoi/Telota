#!/usr/bin/env python3

import argparse
import distutils
import getpass
import glob
import logging
import os
import subprocess
import sys
import tempfile

__version__ = '0.1'


def main(loglevel, args):
    tempdir = tempfile.mkdtemp()
    # print(tempdir)
    if not args.password:
        args.password = getpass.getpass()
    process_options = [
                       'java',
                       '-jar',
                       'start.jar',
                       'backup',
                       '-p',
                       args.password,
                       '-u',
                       args.user,
                       '-b',
                       args.exist_collection,
                       '-d',
                       tempdir,
                       '-ouri={}'.format(args.url),
                       ]
    os.chdir('C:/Users/grabsch/Prog/exist-db/')
    # print(process_options)
    print("Downloading eXist-collection via eXist-db backup tool.")
    try:
        subprocess.run(process_options, check=True)
    except subprocess.CalledProcessError as err:
        print("Error retrieving eXist backup.")
        s = input("Type 'y' to see the full error: ")
        if s == 'y':
            print(err)
        return

    files_to_remove = glob.glob('{}/**/__contents__.xml'.format(tempdir), recursive=True)
    print("Found {} occurence(s) of '__contents__.xml'".format(len(files_to_remove)))
    remove_counter = 0
    for file in files_to_remove:
        os.remove(file)
        remove_counter += 1
    else:
        print("Successfully cleaned up and removed {} occurences of "
              "'__contents__.xml'".format(remove_counter))

    # Remove first char from args.exist_collection, because as a slash ('/') args.exist_collection
    # is treated as an absolute path otherwise and os.path.join() ignores the absolute path part
    # of all preceding paths (which we do not want in this case)
    src = os.path.normpath(os.path.join(tempdir, args.exist_collection[1:]))
    
    distutils.dir_util.copy_tree(src, args.path_to_git)

    print("Copied ")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                                    description="Download eXist collection and copy into"
                                    "corresponding git repository.",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        'exist_collection',
                        help="Path to eXist collection",
                        )
    parser.add_argument(
                        'path_to_git',
                        help="Path to target git repository",
                        )
    parser.add_argument(
                        '-x',
                        '--url',
                        help="URL for eXist db, in the form of "
                        "'xmldb:exist://example.org:2134/exist/xmlrpc'",
                        required=True,
                        type=str,
                       )
    parser.add_argument(
                        '-u',
                        '--user',
                        help="Username for eXist db",
                        default='admin',
                        type=str,
                       )
    parser.add_argument(
                        '-p',
                        '--password',
                        help="Password for eXist db",
                        default=None,
                        type=str
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
        print("download_exist_collection")
        print("Version: {}".format(__version__))
        sys.exit(0)

    main(loglevel, args)