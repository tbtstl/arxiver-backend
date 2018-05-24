class PublicationsController < ApplicationController
  before_action :set_publication, only: [:show]

  # GET /publications
  def index
    @publications = Publication.joins(:subjects, :authors)
    unless params[:search].nil?
      search = "%#{params[:search]}%"
      @publications = @publications.where('LOWER(title) LIKE LOWER(:search) OR LOWER(abstract) LIKE LOWER(:search)', search: search)

      if params[:exclude_authors].nil? or params[:exclude_authors] == "false"
        @publications = @publications.or(Publication.joins(:subjects, :authors).where('LOWER(authors.name) LIKE LOWER(:search)', search: search))
      end

      if params[:exclude_subjects].nil? or params[:exclude_subjects] == "false"
        @publications = @publications.or(Publication.joins(:subjects, :authors).where('LOWER(subjects.key) LIKE LOWER(:search) OR LOWER(subjects.name) LIKE LOWER(:search)', search: search))
      end
    end
    render json: @publications.page(params[:page]).order('title').distinct
  end

  # GET /publications/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_publication
      @publication = Publication.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def publication_params
      params.fetch(:publication).permit(:search, :exclude_authors, :exclude_subjects)
    end
end
