class PublicationSerializer < ActiveModel::Serializer
  attributes :arxiv_url, :pdf, :title, :abstract
end
