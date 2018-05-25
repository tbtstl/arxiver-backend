require 'elasticsearch/model'

class Publication < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  has_and_belongs_to_many :authors
  has_and_belongs_to_many :subjects

  settings index: {number_of_shards: 1} do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english', index_options: 'offsets'
      indexes :abstract, analyzer: 'english'
    end
  end

  def self.search(query)
    es_results = __elasticsearch__.search(
        {
            query: {
                multi_match: {
                    query: query,
                    fields: ['title^10', 'abstract']
                }
            }
        }
    )
    ids = es_results.map {|result| result._id}
    Publication.where(id: ids)
  end

end

# Delete the previous publications index in ElasticSearch
Publication.__elasticsearch__.client.indices.delete index:
Publication.index_name rescue nil

# Create the new index with the new mapping
Publication.__elasticsearch__.client.indices.create index: Publication.index_name, body: {settings: Publication.settings.to_hash, mappings: Publication.mappings.to_hash}

# Index all Publication records from DB to Elasticsearch
Publication.import
