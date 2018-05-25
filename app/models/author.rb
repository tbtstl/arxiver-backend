require 'elasticsearch/model'

class Author < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  has_and_belongs_to_many :publications

  settings index: {number_of_shards: 1} do
    mappings dynamic: 'false' do
      indexes :name, index_options: 'offsets'
    end
  end

  def self.get_ids_from_name(query)
    es_results = __elasticsearch__.search(
        {
            query: {
                multi_match: {
                    query: query,
                    fields: ['name']
                }
            }
        }
    )
    es_results.map {|result| result._id}
  end
end

# Delete the previous Authors index in ElasticSearch
Author.__elasticsearch__.client.indices.delete index:
                                                   Author.index_name rescue nil

# Create the new index with the new mapping
Author.__elasticsearch__.client.indices.create index: Author.index_name, body: {settings: Author.settings.to_hash, mappings: Author.mappings.to_hash}

# Index all Author records from DB to Elasticsearch
Author.import