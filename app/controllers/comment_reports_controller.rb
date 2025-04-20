class CommentReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:new, :create]
  
  def new
    @report = CommentReport.new
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def create
    @report = @comment.reports.new(report_params)
    @report.user = current_user
    
    respond_to do |format|
      if @report.save
        format.html { redirect_to post_path(@comment.post), notice: "Comment was reported successfully." }
        format.turbo_stream { flash.now[:notice] = "Comment was reported successfully." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("report_form", partial: "comment_reports/form", locals: { comment: @comment, report: @report }) }
      end
    end
  end
  
  private
  
  def set_comment
    @comment = Comment.find(params[:comment_id])
  end
  
  def report_params
    params.require(:comment_report).permit(:reason, :details)
  end
end
