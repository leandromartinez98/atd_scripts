#!/bin/bash
####################################################################################################

# Software name:

package=atd_scripts

# HTML file containing download list:

downloads=~/public_html/atd-scripts/download.shtml

# GIT URL:

giturl=https://github.com/leandromartinez98/atd_scripts

# Name of file containing version number

versionfile=./VERSION

####################################################################################################


year=`date +%y`
day=`date +%j`
version="${year:0:1}${year:1:1}.$day"

file="$package-$version.tar.gz" 
version_file=$version

i=2
while grep -q $file $downloads ; do
  file=$package-$version.$i.tar.gz
  version_file=$version.$i
  i=`expr $i + 1`
done
version=$version_file
file=$package-$version.tar.gz
echo "Will create file: $file"

echo $version > $versionfile

git add -A .
git commit -m "Changed version file to $version"
git tag -a $version -m "Release $version"
git push origin master tag $version

changelog="https://github.com/leandromartinez98/$package/releases/tag/$version"
newline="<tr><td width=190px valign=top><a href=$giturl/archive/$version.tar.gz> $file </a></td><td><a target=_blank_ href=$changelog> Change log </a></td></tr>"
htmlfile=$downloads

writeline=yes
while IFS= read -r line ; do
 
  if [ "$writeline" = "yes" ] ; then
    echo $line >> ./htmlfile_new_temp
  fi
  if [ $writeline = "no" ] ; then
    writeline="yes"
  fi

  if [[ $line == *NEW_VERSION_HERE* ]] ; then
    echo $newline >> ./htmlfile_new_temp
  fi

done < "$htmlfile"
rm $htmlfile
mv htmlfile_new_temp $htmlfile   

echo "----------------------"
echo "CHANGE LOG:"
echo "----------------------"
range=`git tag | tail -n 2 | xargs | sed 's! !...!'`
git log --pretty=oneline $range | awk '{$1=""; print "-"$0}'
echo "----------------------"

echo " Done. " 

