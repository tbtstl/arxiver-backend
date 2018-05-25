require 'elasticsearch/model'

class Subject < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  has_and_belongs_to_many :publications
  PATH_TO_CATEGORY_MAPPING_DATA = Rails.root.join('data', 'category_key_to_label_mapping.xml')

  settings index: {number_of_shards: 1} do
    mappings dynamic: 'false' do
      indexes :name, analyzer: 'english', index_options: 'offsets'
      indexes :key
    end
  end

  def self.get_ids_from_search(query)
    es_results = __elasticsearch__.search(
        {
            query: {
                multi_match: {
                    query: query,
                    fields: ['name', 'key']
                }
            }
        }
    )
    es_results.map {|result| result._id}
  end

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

Subject.__elasticsearch__.client.indices.delete index:
    Subject.index_name rescue nil

Subject.__elasticsearch__.client.indices.create index: Subject.index_name, body: {settings: Subject.settings.to_hash, mappings: Subject.mappings.to_hash}

Subject.import