

library(XML)
data <- xmlTreeParse("stimLogs/stimulus-log.xml")
rootNode <- xmlRoot(data)
xml_data <- xmlToList(data)
dataDictionary <- xmlToDataFrame(getNodeSet(doc,"//StimuliInfo/StimulusInformation"))  


xmlToDataFrame(nodes=getNodeSet(data,"//StimulusInformation"))