class PublicationsController < ApplicationController
  before_action :set_publication, only: [:show]

  # GET /publications
  def index
    @publications = Publication.order('title').page params[:page]
    render json: @publications
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
      params.fetch(:publication, {})
    end
end
