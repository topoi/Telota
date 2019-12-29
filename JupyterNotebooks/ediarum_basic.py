from lxml import etree
import xml.etree.ElementTree as ET
from io import StringIO, BytesIO
import pandas as pd
import ipywidgets as widgets
from ipywidgets import interact, interact_manual
import numpy as np
import qgrid

selection={}
def GetActionTable(project="", item="id", SearchString=""):
    tree = ET.parse('db/projects/'+project+'/data/ediarum.'+project+'.edit/ediarum.'+project+'.edit.framework')
    root = tree.getroot()
    xmlstr = ET.tostring(root, encoding='utf8', method='xml')
    root= etree.XML(xmlstr)

    regexpNS = "http://exslt.org/regular-expressions"

    items=[['id', 'String'],['name','String'],['description', 'String'],['largeIconPath','String'],['smallIconPath','String'],['accessKey','String'],['enabledInReadOnlyContext','Boolean']]

   
    for element in items:

        find = etree.XPath("*/*/*/*/*/*/*/*/action/field[@name=\'"+element[0]+"\']/"+element[1], namespaces={'re':regexpNS})
        temp=[]
        for el in find(root):
            temp.append(str(el.text))
        selection[element[0]]=temp

    ############
    #pandas df #
    ############

    df_cols = [item[0] for item in items]
    rows = {}
    for element in df_cols:
            rows[element]=selection[element]
    df = pd.DataFrame(data=rows)
    df=df[df[item].str.contains(SearchString)==True]
    return df

def GUI():
    @interact
    def shows(field=["name","id","description"]):
        @interact
        def show_articles_more_than1(column=selection[field]):
            return GetActionTable(project="project1", item=field,SearchString=column)