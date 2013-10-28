require 'mechanize'
require 'fileutils'

class LabLifeParser
  attr_accessor :account_id, :account_pw
  attr_accessor :index_url

  def initialize
    @account_id = 'daniel.jurczak@imba.oeaw.ac.at'
    @account_pw = '_RxYRAKN'
    @index_url = 'https://www.lablife.org/inv?a=inventory_materials_list&category_id=1&group_id=2772'
  end

  def parse
    agent = Mechanize.new
    page = agent.get(@index_url)

    index = page.form_with(:name => "loginform") do |f|
      f.acct = @account_id
      f.passwd = @account_pw
    end.click_button

    while index do
      # links to each individual inventory_materials view
      links = index.links.select { |l| l.uri.to_s.match(/inventory_materials_view/) }

      ## TODO: parse index for PDF/attachments
      links.each do |link|
        page = link.click;
        doc = page.parser;
        name_field = doc.css('.IVY_FIELD_is_alt_name_id');
        name = name_field.children.last.text;

        puts name
        FileUtils.mkdir_p("resources/#{name}/plasmid/");
        FileUtils.mkdir_p("resources/#{name}/attachments/")

        ## find and download images
        plasmid_field = doc.css('.IVY_FIELD_is_plasmid_map');

        plasmid_field.children.search("img").each_with_index do |img, i|
          agent.get(img.attributes["src"]).save("resources/#{name}/plasmid/#{i}.jpg");
        end

        ## find and download attachments
        attachment_field = doc.css('.IVY_FIELD_is_attachments');

        attachment_field.children.search("img").each do |img|
          attachment = img.parent()
          attachment_name = attachment.search("a").text
          attachment_url = attachment.search("a").first.attr("href")

          agent.get(attachment_url).save("resources/#{name}/attachments/#{attachment_name}")
        end
      end

      ## get the next page link
      next_page = index.link_with(:text => "Next")

      ## stop iterating if we are on the last page
      break if next_page == nil

      puts "\ngetting next 50 entries\n"
      ## otherwise go to next page
      index = next_page.click
    end
  end
end

