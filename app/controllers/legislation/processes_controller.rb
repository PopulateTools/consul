class Legislation::ProcessesController < Legislation::BaseController
  has_filters %w{open next past}, only: :index
  load_and_authorize_resource

  def index
    @current_filter ||= 'open'
    @processes = ::Legislation::Process.send(@current_filter).page(params[:page])
  end

  def show
    if @process.allegations_phase.enabled? && @process.allegations_phase.started? && draft_version = @process.draft_versions.published.last
      redirect_to legislation_process_draft_version_path(@process, draft_version)
    elsif @process.debate_phase.enabled?
      redirect_to legislation_process_debate_path(@process)
    else
      redirect_to legislation_process_allegations_path(@process)
    end
  end

  def debate
    set_process
    @phase = :debate_phase

    if @process.debate_phase.started?
      render :debate
    else
      render :phase_not_open
    end
  end

  def draft_publication
    set_process
    @phase = :draft_publication

    if @process.draft_publication.started?
      if draft_version = @process.draft_versions.published.last
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def allegations
    set_process
    @phase = :allegations_phase

    if @process.allegations_phase.started?
      if draft_version = @process.draft_versions.published.last
        redirect_to legislation_process_draft_version_path(@process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def result_publication
    set_process
    @phase = :result_publication

    if @process.result_publication.started?
      if final_version = @process.final_draft_version
        redirect_to legislation_process_draft_version_path(@process, final_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  private

    def set_process
      @process = ::Legislation::Process.find(params[:process_id])
    end
end
