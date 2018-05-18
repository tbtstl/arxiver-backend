class Subject < ApplicationRecord
  has_and_belongs_to_many :publications
  PATH_TO_CATEGORY_MAPPING_DATA = Rails.root.join('data', 'category_key_to_label_mapping.xml')

  def self.key_to_friendly_name_map
    @category_mapping = {}
    file = File.read(PATH_TO_CATEGORY_MAPPING_DATA)
    xml = ::Nokogiri::XML(file).remove_namespaces!

    categories = xml.xpath("/service/workspace/collection/categories/category")
    categories.each do |category|
      abbreviation = category.attributes["term"].value.match(/[^\/]+$/)[0]
      description = category.attributes["label"].value
      @category_mapping.merge!(abbreviation => description)
    end
    @category_mapping
  end

end
