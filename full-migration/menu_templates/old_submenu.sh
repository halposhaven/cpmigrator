#!/bin/bash

total_space=101
# Determine spacing for slots
# Slot 1
chars1=$(echo $text1|wc -m)
space1=`perl -e 'print eval('$total_space' - '$chars1');'`
add1=`perl -e 'print " " x '$space1';'`
# Slot 2
chars2=$(echo $text2|wc -m)
space2=`perl -e 'print eval('$total_space' - '$chars2');'`
add2=`perl -e 'print " " x '$space2';'`
# Slot 3
chars3=$(echo $text3|wc -m)
space3=`perl -e 'print eval('$total_space' - '$chars3');'`
add3=`perl -e 'print " " x '$space3';'`
# Slot 4
chars4=$(echo $text4|wc -m)
space4=`perl -e 'print eval('$total_space' - '$chars4');'`
add4=`perl -e 'print " " x '$space4';'`
# Slot 5
chars5=$(echo $text5|wc -m)
space5=`perl -e 'print eval('$total_space' - '$chars5');'`
add5=`perl -e 'print " " x '$space5';'`
# Slot 6
chars6=$(echo $text6|wc -m)
space6=`perl -e 'print eval('$total_space' - '$chars6');'`
add6=`perl -e 'print " " x '$space6';'`

# Menu frame
echo " _______________________________________________________________________________________________________"
echo "/                                                                                                       \ "

if [ -n "$text1" ]; then
echo "|   $text1$add1|"
echo "|                                                                                                       |"
fi

if [ -n "$text2" ]; then
echo "|   $text2$add2|"
echo "|                                                                                                       |"
fi

if [ -n "$text3" ]; then
echo "|   $text3$add3|"
echo "|                                                                                                       |" 
fi

if [ -n "$text4" ]; then
echo "|   $text4$add4|"
echo "|                                                                                                       |"

fi
if [ -n "$text5" ]; then
echo "|   $text5$add5|"
echo "|                                                                                                       |"
fi

if [ -n "$text6" ]; then
echo "|   $text6$add6|"
echo "|                                                                                                       |"
fi

echo "\_______________________________________________________________________________________________________/"
echo ""
echo ""
