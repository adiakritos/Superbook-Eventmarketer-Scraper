require 'csv'
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'


doc = Nokogiri.XML('<foo><bar /><foo>', nil, 'UTF-8') 

url = "http://superbook.eventmarketer.com/category/agencies/"
 
puts "Opening URL"
data = Nokogiri::HTML(open(url))

puts "Grabbing info in .padding"
listings = data.css('.padding')

listing_row = Array.new()

puts "Collecting Listings Information. This might take a few minutes..."

listing_pb = ProgressBar.create(title: "Listings", starting_at: 1, total: listings.count)
csv_pb     = ProgressBar.create(title: "CSV File", starting_at: 1, total: listings.count)

listings.each do |listing|
  url = listing.at_css('.title')[:href]
  data = Nokogiri::HTML(open(url))

  sections = data.xpath("//section")
  
  if !sections[0].nil?
    first_section  = sections[0]
    if !first_section.element_children().nil?
      first_section_children  = first_section.element_children()
      agency_name = first_section_children[0].text.to_s
      if !first_section_children[1].nil?
        logo_src = first_section_children[1][:src].to_s
        logo_file_name = logo_src.match(/(?<=thumbs\/).+/).to_s
        logo_image_type = logo_file_name.match(/\..+/).to_s
        open(logo_src) {|f|
          File.open("logos/" + agency_name + logo_image_type,"wb") do |file|
            file.puts f.read
          end
        } 
      end
    else
      agency_name = "  "
    end
  end

# if !sections[1].nil?
#   second_section = sections[1]
#   if !second_section.element_children().nil?
#     second_section_children = second_section.element_children()
#     address = second_section_children[1].text.to_s
#     if !second_section_children[2].to_s.nil?
#       phone_email = second_section_children[2].to_s
#       phone = phone_email.match(/(?<=<p>Phone: ).+(?=<br>)/).to_s
#       email = phone_email.match(/(?<=<br>Email: ).+(?=<\/p>)/).to_s
#     else
#       phone = "  "
#       email = "  "
#     end
#     agency_url  = second_section_children[3].text.to_s
#   else
#     address    = "  "
#     agency_url = "  "
#   end
# end
# profile = data.at_css('.article').to_s
#  listing_row << [ agency_name, address, phone, email, agency_url, profile ]
  listing_pb.increment
end

# puts "Storing Listings into CSV..."
#   CSV.open("listings.csv", "wb") do |csv|
#     listing_row.each do |row|
#         csv << row
#         csv_pb.increment
#     end
#   end
 puts "Finished!"



