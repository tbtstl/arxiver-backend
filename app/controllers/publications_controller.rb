class PublicationsController < ApplicationController
  before_action :set_publication, only: [:show]

  # GET /publications
  def index
    @publications = Publication.joins(:authors, :subjects)

    unless params[:search].nil?
      @author_ids = Author.get_ids_from_name params[:search]
      @subject_ids = Subject.get_ids_from_search params[:search]
      @publications = @publications.search params[:search]
      @publications = @publications.or(Publication.joins(:authors, :subjects).where(subjects: {:id => @subject_ids}))
      @publications = @publications.or(Publication.joins(:authors, :subjects).where(authors: {:id => @author_ids}))
    end

    unless params[:author].nil?
      @author_ids = Author.get_ids_from_name params[:author]
      @publications = @publications.where(authors: {id: @author_ids})
    end

    unless params[:subject].nil?
      @subject_ids = Subject.get_ids_from_search params[:subject]
      @publications = @publications.where(subjects: {id: @subject_ids})
    end
    render json: @publications.page(params[:page]).distinct
    # render json: @publications.page(params[:page]).order('title').distinct
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
      params.fetch(:publication).permit(:search, :exclude_authors, :exclude_subjects, :author, :subject)
    end
end
