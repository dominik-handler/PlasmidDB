class LabLifeCSVParser
  attr_accessor :valid_fields

  def initialize
    @valid_fields = ["entered_by", "name", "alt_name_id", "backbone", "gene_insert", "species", "promoter", "mutations_deletions", "tag_1", "location_of_tag_1", "tag_2", "location_of_tag_2", "bacterial_resistance", "bacterial_resistance_other", "selectable_marker", "selectable_marker_other", "special_growth_conditions", "reference", "source", "source_specify", "notes", "dna_concentration"]
  end


  def perform(csv_file)
    contents = SmarterCSV.process(csv_file)

    contents.each_with_index do |data, i|
      if i > 0
        tmp = {};
        data.each do |k,v|
          adjusted_name = k.to_s.split(".").last;
          tmp[adjusted_name] = v if valid_fields.include?(adjusted_name);
        end

        p = Plasmid.create(:name => tmp["name"], :internal_id => tmp["alt_name_id"]);
        p.author = Author.find_by_username(tmp["entered_by"].split.last.downcase)
        p.info = tmp.select { |k,v| ["name", "alt_name_id", "entered_by"].include?(k) == false}

        ## attach the plasmid map file to the plasmid_map field
        ## by definition we can only have one plasmid_map per entry, thus if there are multiple we just overwrite the previous one
        Dir["resources/#{tmp["alt_name_id"]}/plasmid/*"].each do |f|
          plasmid_image_data = File.open(f)
          p.plasmid_map = plasmid_image_data
          plasmid_image_data.close
        end if File.exists?("resources/#{tmp["alt_name_id"]}/plasmid/")

        ## and now attach everything else..
        Dir["resources/#{tmp["alt_name_id"]}/attachments/*"].each do |f|
          name = File.basename(f, ".*")

          attachment = Attachment.create(:name => name)

          attachment_data = File.open(f)
          attachment.file = attachment_data
          attachment_data.close
          p.attachments.push(attachment)
          p.save
        end if File.exists?("resources/#{tmp["alt_name_id"]}/attachments/")
      end
    end
  end
end
