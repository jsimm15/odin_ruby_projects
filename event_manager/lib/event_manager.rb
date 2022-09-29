require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time' 
require 'date'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    legislators = legislators.officials
    #legislator_names = legislators.map(&:name)
    #legislator_names.join(", ")
  rescue
    "You can find your representatives on the internet."
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def save_day_table(day_table)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/day_table.html"

  File.open(filename, 'w') do |file|
    file.puts day_table
  end
end

def save_hour_table(hour_table)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/hour_table.html"

  File.open(filename, 'w') do |file|
    file.puts hour_table
  end
end

#Strip number any non-number characters and validate a length of 10 digits
def clean_phone_number(number)
  phone = number.gsub(/[-()\. ]/, '')
  if phone.length == 10 
    phone
  #Accept 11 digit numbers beginning with 1, but strip the leading 1
  elsif phone.length == 11 && phone[0] == 1
    phone[1..-1]
  #Invalid number return string
  else 
    "N/A"  
  end
end

def extract_reg_hour(reg_date)
  time = reg_date.split(" ")[1]
end

def extract_weekday(reg_date)
  date = reg_date.split(" ")[0]
  fdate = Date.strptime(date, '%m/%d/%Y')
  day = fdate.strftime('%A')  
  
  #fdate = Date.new(year, month, day)
  # DAYNAMES[fdate.wday]
end


#Begin main program

puts "Event manager initialized!"

filename = 'event_attendees.csv'

contents = CSV.open(
  filename,
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

template_day_table = File.read('day_distribution.erb')
template_hour_table = File.read('hour_distribution.erb')
erb_day = ERB.new template_day_table
erb_hour = ERB.new template_hour_table

times = {}
days = {}

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  
  zipcode = clean_zipcode(row[:zipcode])
  
  legislators = legislators_by_zipcode(zipcode)
  
  # personal_letter = template_letter.gsub('FIRST_NAME', name)
  # personal_letter.gsub!('LEGISLATORS', legislators)
  
  form_letter = erb_template.result(binding)
  #puts form_letter
  
  save_thank_you_letter(id, form_letter)
  
  #puts "#{name} : #{zipcode} : #{legislators}" 
  #puts personal_letter
  
  phone = row[:homephone]
  cleaned_phone = clean_phone_number(phone)
  
  registration_time = extract_reg_hour(row[:regdate])
  hour = Time.parse(registration_time).hour
  if times[hour] == nil 
    times[hour] = 1
  else
    times[hour] += 1
  end 
  
  day = extract_weekday(row[:regdate])
  
  if days[day] == nil
    days[day] = 1
  else
    days[day] += 1
  end

  puts "id:#{id} name:#{name} zipcode:#{zipcode} phone:#{cleaned_phone} reg_time: #{registration_time}"
  
end

form_days_table = erb_day.result(binding)
save_day_table(form_days_table)

form_hours_table = erb_hour.result(binding)
save_hour_table(form_hours_table)

p times.sort_by {|k,v| v}.reverse.to_h
p days