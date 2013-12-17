module PlasmidHelper
  def key_to_name(key)
    return key.capitalize if ["backbone", "species", "promoter", "reference", "source", "notes"].include?(key)
    return key.gsub("_", " ").titleize
  end
end
