#!/usr/bin/env bash

page=$1
echo $1
cat head.html > $page.html
markdown $page.md >> $page.html
sed -i 's|=&gt;|=>|g' $page.html
sed -i 's|&amp;|\&|g' $page.html
cat $page.html | perl -pe 's|(<h.>.*?)<code>(.*?)</code>|\1\2|' > $page.html.bk1
cat $page.html.bk1 | perl -pe 's|<code>(.*?)</code>|<span style='\''font-family:"Courier New","DejaVu Sans Mono", monospace'\''>\1</span>|g' > $page.html.bk2
cat $page.html.bk2 | sed 's|code>|code>\n|g' > $page.html
rm $page.html.bk1
rm $page.html.bk2
