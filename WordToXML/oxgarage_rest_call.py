#!/usr/bin/env python3
# coding: utf-8

import argparse
import glob
import logging
import os
import re

import requests

from tqdm import tqdm

__version__ = "0.6"

REQUEST_URL = 'http://oxgarage.oucs.ox.ac.uk:8080/ege-webservice/Conversions/docx%3Aapplication%3Avnd.openxmlformats-officedocument.wordprocessingml.document/TEI%3Atext%3Axml'


def main(args, loglevel):

    # Set requests logging level to WARNING
    logging.getLogger("requests").setLevel(logging.WARNING)

    logging.basicConfig(format="%(levelname)s: %(message)s", level=loglevel)

    docx_files = glob.glob('*.docx')
    errors = []
    unicode_errors = []
    xml_files = []

    #################################################################
    # Transform *.docx files to basic TEI via OxGarage REST Service #
    #################################################################

    logging.info("Transforming *.docx files in current directory.")
    for docx_file in tqdm(docx_files):
        # logging.info("Processing file '{}'".format(docx_file))
        with open(docx_file, 'rb') as upload_file:
            try:
                r = requests.post(REQUEST_URL, files={'file': upload_file})
                r.raise_for_status()
            except requests.exceptions.HTTPError:
                # logging.error("Could not transform '{}'".format(docx_file))
                errors.append(docx_file)
                continue

            filename = '{}.xml'.format(os.path.splitext(docx_file)[0])
            with open(filename, 'wb') as output_file:
                output_file.write(r.content)
                xml_files.append(filename)
            # logging.info("Succesfully saved '{}'".format(filename))

    if errors:
        logging.error("Some errors ({}) while processing *.docx files. "
                      "See 'error.log' for details".format(str(len(errors))))
        with open('error.log', 'w', encoding='utf-8') as error_log:
            error_log.write("The following files could not be transformed:\n\n")
            for error in errors:
                error_log.write("{}\n".format(error))
    else:
        logging.info("All files successfully transformed.")

    ########################################################################
    # Replace various inline markup (e. g. {e/}, {add}, etc.) with TEI-XML #
    ########################################################################

    logging.info("Continuing with file processing. Replacing pseudo-xml with TEI-XML (via regex).")

    for xml_file in tqdm(xml_files):
        try:
            with open(xml_file, 'r', encoding='utf-8') as content_file:
                content = content_file.read()
        except UnicodeDecodeError:
            print("ERROR")
            unicode_errors.append(xml_file)
            continue

        # Replace {add}text{/add}, and also (optionally) match the end of the expanded word
        expr = re.compile(r'(\w{1,}){add}(.*?){\/add}(\w*)', re.DOTALL)
        subst = r'<expan resp="editor" sameAs="dottet_underline">\1<ex>\2</ex>\3</expan>'
        replaced_text = re.sub(expr, subst, content)

        # Replace {add_red}[text]{/add_red}
        expr = re.compile(r'{add_red}\[(.*?)\]{\/add_red}', re.DOTALL)
        subst = r'<supplied cert="high">\1</supplied>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Remove <hi rend="color(0000FF)">{e}</hi> in endnotes
        expr = re.compile(r'(\s<hi rend="color\(0000FF\)">\{e\}<\/hi>\d{1,3}\s*)')
        subst = r''
        replaced_text = re.sub(expr, subst, replaced_text)

        # Remove {autor}...{/autor} in endnotes (only for letters, not for Zeugenbeschreibungen!)
        if not xml_file.startswith('zb_'):
            expr = re.compile(r'{autor}(.*?){\/autor}]?\xa0?')
            subst = r''
            replaced_text = re.sub(expr, subst, replaced_text)

        # Replace <hi rend="color(0000FF)">{e/}</hi>
        expr = re.compile(r'(<hi rend="color\(0000FF\)">\{e\/\}<\/hi>)')
        subst = r'<anchor/>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {e/}
        expr = re.compile(r'(\{e\/\})')
        subst = r'<anchor/>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {Pfund-Währung}
        expr = re.compile(r'(\{Pfund-Währung})')
        subst = r'£'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {Pfund-Gewicht}
        expr = re.compile(r'(\{Pfund-Gewicht})')
        subst = r'℔'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {Pfennig-denarius}
        expr = re.compile(r'(\{Pfennig-denarius})')
        subst = r'₰'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {emph2}text{/emph2}
        expr = re.compile(r'({emph2})(.*?)({(\\|\/)emph2})', re.DOTALL)
        subst = r'<hi rendition="#uu">\2</hi>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {beilage}
        expr = re.compile(r'({beilage})')
        subst = r'<?oxy_custom_start type="oxy_content_highlight" color="207,241,255"?>\1'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {/beilage}
        expr = re.compile(r'({\/beilage})')
        subst = r'\1<?oxy_custom_end?>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {GED t="f"} and {GED}
        # expr = re.compile(r'(<hi rend=\"color\(00B050\)\">{GED( T=\"F\")?}</hi>)', re.DOTALL |
        #                   re.IGNORECASE)
        # subst = r'<hi rendition="#mprint">'
        # replaced_text = re.sub(expr, subst, replaced_text)

        # Replace {/GED}
        # expr = re.compile(r'(<hi rend=\"color\(00B050\)\">{\/GED}</hi>)', re.DOTALL | re.IGNORECASE)
        # subst = r'</hi>'
        # replaced_text = re.sub(expr, subst, replaced_text)

        # Replace page break indicators (|/, \|)
        expr = re.compile(r'(\|/|/\|)')
        subst = '<pb ana="xxx_special"/>'
        replaced_text = re.sub(expr, subst, replaced_text)

        # Replace other (standard) page break indicators (| and ||)
        expr = re.compile(r'(?<!:)((\|(?!\|)|\|\|))(?!:)')
        subst = '<pb/>'
        replaced_text = re.sub(expr, subst, replaced_text)

        with open('final_{}'.format(xml_file), 'w', encoding='utf-8') as final_file:
            final_file.write(replaced_text)

    if unicode_errors:
            logging.error("Some errors ({}) while processing generated xml files. "
                          "See 'unicode_error.log' for details".format(str(len(unicode_errors))))
            with open('unicode_error.log', 'w', encoding='utf-8') as unicode_error_log:
                unicode_error_log.write("The following files could not be processed:\n\n")
                for unicode_error in unicode_errors:
                    unicode_error_log.write("{}\n".format(unicode_error))

    logging.info("Finished processing.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                                    description="Transforms all *.docx files"
                                    "in current directory to TEI-XML. It uses"
                                    " curl to call the OxGarage Conversion "
                                    " REST API at "
                                    "http://oxgarage.oucs.ox.ac.uk:8080/ege-webclient/. "
                                    "The directory SHOULD only contain this "
                                    "python script and the *.docx files that "
                                    "are to be processed.",
                                    )
    # Setup command line arguments
    parser.add_argument(
                        '-v',
                        '--verbose',
                        help="Increase verbosity",
                        action='store_true',
                       )
    args = parser.parse_args()

    # Setup logging, for now always use DEBUG
    # loglevel = logging.DEBUG

    if args.verbose:
        loglevel = logging.DEBUG
    else:
        loglevel = logging.INFO

    main(args, loglevel)