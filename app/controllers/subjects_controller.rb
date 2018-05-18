class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show]

  # GET /subjects
  def index
    @subjects = Subject.order('name')
    render json: @subjects
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subject_params
      params.fetch(:subject, {})
    end
end
