from lxml import etree
import xml.etree.ElementTree as ET
from io import StringIO, BytesIO
import pandas as pd
import ipywidgets as widgets
from ipywidgets import interact, interact_manual
import numpy as np
import qgrid
import pandas, io
from pivottablejs import pivot_ui

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
        
def LoadBaseFramework(data=""):
    item="id"
    project="goedel"
    SearchString=""
    tree = ET.parse(data) 
    root = tree.getroot()
    xmlstr = ET.tostring(root, encoding='utf8', method='xml')
    root= etree.XML(xmlstr)

    regexpNS = "http://exslt.org/regular-expressions"
    basic="*/*/*/*/*/*/"
    find_actionArray = etree.XPath(basic+"field[@name='actionDescriptors']/action-array", namespaces={'re':regexpNS})

    df_cols=[]
    finallist=[]
    for el in find_actionArray(root):

        for j in range(6):
            df_cols.append(el[0][j].attrib["name"])
        for i in range(len(el)):

            selection={}
            actionmode=[]

            for k in range(len(el[i][7][0])):

                try:

                    #actiondict={}
                    #actiondict[el[i][7][0][k][0].attrib["name"]]=el[i][7][0][k][0][0].text


                    argvalues=[]
                    for m in range(len(el[i][7][0][k][1][0])):
                        argvaldict={}
                        argvaldict["arg type"]=str(el[i][7][0][k][1][0][m][0].text)
                        argvaldict["arg values"]=str(el[i][7][0][k][1][0][m][1].text)
                        argvaldict[el[i][7][0][k][0].attrib["name"]]=el[i][7][0][k][0][0].text
                        argvaldict[el[i][7][0][k][2].attrib["name"]]=el[i][7][0][k][2][0].text

                        for j in range(6):
                            
                            argvaldict[el[i][j].attrib["name"]]=el[i][j][0].text

                        argvalues.append(argvaldict)

                except:
                    pass

                actionmode.append(argvalues)
            finallist.append(actionmode)
    df=pd.DataFrame.from_dict(finallist[0][0])
    for i in range(len(finallist)):
        for j in range(len(finallist[i])):
            df=df.append(pd.DataFrame.from_dict(finallist[i][j]), ignore_index=True)

    df = df.drop(['largeIconPath', 'smallIconPath','accessKey'], axis=1)
    df=df.set_index(['id', 'description','name', 'xpathCondition', 'operationID'])
    
    qgrid.widget = qgrid.show_grid(df, show_toolbar=True)
    return qgrid.widget, df

def LoadExtendedFramework(data):
    tree = ET.parse(data) 
    root = tree.getroot()
    xmlstr = ET.tostring(root, encoding='utf8', method='xml')
    root= etree.XML(xmlstr)

    regexpNS = "http://exslt.org/regular-expressions"
    basic="*/*/*/*/*/*/"
    find_actionArray = etree.XPath(basic+"field[@name='patchList']/list/poPatch/field[@name='value']/action", namespaces={'re':regexpNS})
    df_cols=[]
    finallist=[]
    for el in find_actionArray(root):

        for j in range(6):
            df_cols.append(el[j].attrib["name"])

        for i in range(len(el)):

            selection={}
            actionmode=[]

            for k in range(len(el[i])):
                #try:

                argvalues=[]
                #for m in range(len(el[i][7][0][k][1][0])):
                for m in range(len(el[i][k])):

                    argvaldict={}
                    argvaldict["arg type"]=el[i][k][m][1][0][0][0].text
                    argvaldict["arg values"]=str(el[i][k][m][1][0][0][1].text)

                    argvaldict[el[i][k][m][0].attrib["name"]]=el[i][k][m][0][0].text
                    argvaldict[el[i][k][m][2].attrib["name"]]=el[i][k][m][2][0].text

                    for j in range(6):
                        argvaldict[el[j].attrib["name"]]=el[j][0].text

                    argvalues.append(argvaldict)
                #except:
                 #   pass

                actionmode.append(argvalues)
            finallist.append(actionmode)
    df=pd.DataFrame.from_dict(finallist[0][0])
    for i in range(len(finallist)):
        for j in range(len(finallist[i])):
            df=df.append(pd.DataFrame.from_dict(finallist[i][j]), ignore_index=True)

    df = df.drop(['largeIconPath', 'smallIconPath','accessKey'], axis=1)
    df=df.set_index(['id', 'description','name', 'xpathCondition', 'operationID'])

    qgrid.widget = qgrid.show_grid(df, show_toolbar=True)
    return qgrid.widget