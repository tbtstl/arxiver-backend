class SearchController < ApplicationController
  def index
    search = "%#{params[:query]}%"
    @authors = Author.where('LOWER(name) LIKE LOWER(:search)', search: search).order('name')
    @publications = Publication.where('LOWER(title) LIKE LOWER(:search) OR LOWER(abstract) LIKE LOWER(:search)', search: search).order('title').order('title')
    @subjects = Subject.where('LOWER(name) LIKE LOWER(:search) OR LOWER(key) LIKE LOWER(:search)', search: search).order('name').order('name')
    render json: {:authors => @authors, :publications => @publications, :subjects => @subjects}
  end

  private
  def search_params
    params.permit(:query)
  end
end
