ant retrieveCode
outputFile='results.doc'
rm -f $outputFile
printf "filename:linenumber:error" >> $outputFile
printf "\n" >> $outputFile
for i in src/*.page src/*.cmp
do
	printf "~~~~" >> $outputFile
	printf "\n" >> $outputFile
	grep -o -i -n --with-filename '<apex:iframe\|<apex:canvasapp\|<iframe\|showheader=\"false\"\|showheader=\"false\"|<apex:relatedlist\|sforce.one\|\$api.session_id\|getsessionid()\|window.\|href\|<apex:includescript\|<script\|<analytics:reportchart\|<apex:detail\|<apex:emailpublisher\|<apex:enhancedlist\|<apex:flash\|apex:inputfield\|<apex:listviews\|<apex:localcallpublisher\|<apex:scontrol\|<apex:sectionheader\|<apex:selectlist\|<apex:tabpanel\|<apex:tab\|<apex:vote' -s $i >> $outputFile
	printf "\n" >> $outputFile
done
