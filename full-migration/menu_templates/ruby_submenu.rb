require 'text'

puts $text1

blank="-"
total_space="94"
chars1=(puts text1.length)
space1=(total_space.to_i - chars1.to_i)
add1=(space1.to_s * blank.to_i)

puts add1

puts " _______________________________________________________________________________________________________"
puts "/                                                                                                       \ "

if [ text1.to_s == '' ]; then
puts "|    text1.to_s|"
puts "|                                                                                                       |"
end

if [ text2.to_s == '' ]; then
puts "|    text2|"
puts "|                                                                                                       |"
end

if [ text3.to_s == '' ]; then
puts "|    text3|"
puts "|                                                                                                       |" 
end

if [ text4.to_s == '' ]; then
puts "|    text4|"
puts "|                                                                                                       |"
end

if [ text5.to_s == '' ]; then
puts "|    text5|"
puts "|                                                                                                       |"
end

if [ text6.to_s == '' ]; then
puts "|    text6|"
puts "|                                                                                                       |"
end

puts "\_______________________________________________________________________________________________________/"
puts ""
puts ""
