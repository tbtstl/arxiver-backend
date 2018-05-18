class PublicationSerializer < ActiveModel::Serializer
  attributes :arxiv_url, :pdf, :title, :abstract

  has_many :authors
  has_many :subjects
end
