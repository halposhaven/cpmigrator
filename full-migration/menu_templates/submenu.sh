#!/bin/bash

total_space=101

# Menu frame
echo " _______________________________________________________________________________________________________"
echo "/                                                                                                       \ "

if [ -n "$text1" ]; then
chars1=$(echo $text1|wc -m)
space1=`perl -e 'print eval('$total_space' - '$chars1');'`
add1=`perl -e 'print " " x '$space1';'`
echo "|   $text1$add1|"
fi

if [ -n "$text2" ]; then
chars2=$(echo $text2|wc -m)
space2=`perl -e 'print eval('$total_space' - '$chars2');'`
add2=`perl -e 'print " " x '$space2';'`
echo "|                                                                                                       |"
echo "|   $text2$add2|"
fi

if [ -n "$text3" ]; then
chars3=$(echo $text3|wc -m)
space3=`perl -e 'print eval('$total_space' - '$chars3');'`
add3=`perl -e 'print " " x '$space3';'`
echo "|                                                                                                       |" 
echo "|   $text3$add3|"
fi

if [ -n "$text4" ]; then
chars4=$(echo $text4|wc -m)
space4=`perl -e 'print eval('$total_space' - '$chars4');'`
add4=`perl -e 'print " " x '$space4';'`
echo "|                                                                                                       |"
echo "|   $text4$add4|"
fi

if [ -n "$text5" ]; then
chars5=$(echo $text5|wc -m)
space5=`perl -e 'print eval('$total_space' - '$chars5');'`
add5=`perl -e 'print " " x '$space5';'`
echo "|                                                                                                       |"
echo "|   $text5$add5|"
fi

if [ -n "$text6" ]; then
chars6=$(echo $text6|wc -m)
space6=`perl -e 'print eval('$total_space' - '$chars6');'`
add6=`perl -e 'print " " x '$space6';'`
echo "|                                                                                                       |"
echo "|   $text6$add6|"
fi

echo "\_______________________________________________________________________________________________________/"
echo ""
echo ""
