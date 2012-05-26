require 'rubygems'
require 'nokogiri'
require 'sequel'
require 'fileutils'

if File.exist?('drugs.db')
  FileUtils.rm('drugs.db')
end

DB = Sequel.sqlite('drugs.db')

# create an items table
DB.create_table :drug_pages do
  primary_key :id
  String :name
  String :dose
  String :file_name
end

contents_path = File.expand_path(File.join(File.dirname(__FILE__), 'html', 'www.medicinescomplete.com', 'mc', 'bnf', 'current'))

drugs_table = DB[:drug_pages]

Dir.chdir(contents_path) do
  Dir.glob("*.htm*").each do |file|
    html_path = File.join(contents_path, file)

    html_string = File.read(html_path)
    html = Nokogiri::HTML.parse(html_string)

    if dose_element = html.xpath("//h2[contains(text(), \"Dose\")]").first
      name = html.xpath("//h1").first.inner_text
      next if name.upcase != name # Drugs seem to mostly be uppercase

      dose_info = dose_element.parent.inner_html

      drugs_table.insert(:name => name, :dose => dose_info, :file_name => file)
    end
  end
end

drugs_table.each do |drug|
  puts drug[:name]
end

puts drugs_table.count