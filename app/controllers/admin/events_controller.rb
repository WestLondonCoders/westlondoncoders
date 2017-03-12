class Admin::EventsController < Admin::BaseController
  before_action :get_event, only: [:show, :edit, :update, :destroy]

  layout 'admin'

  def index
    authorize! :manage, @events
    @search = Event.ransack(params[:q])
    @search.sorts = 'date asc' if @search.sorts.empty?
    @upcoming_events = @search.result.upcoming
    @past_events = @search.result.past
    @events = @search.result
  end

  def search
    index
    render :index
  end

  def your_events
    authorize! :manage, current_user.managed_events.first
    @sponsor = current_user.sponsors.first
    @upcoming_events = current_user.managed_events.upcoming
    @past_events = current_user.managed_events.past
  end

  def new
    authorize! :manage, Event
    @event = Event.new
  end

  def create
    authorize! :create, @events
    @event = Event.new(event_params)
    @event.slug = create_slug(@event)

    if @event.save
      redirect_to admin_events_path, notice: 'Event successfully created.'
    else
      flash[:alert] = "Error"
      render :new
    end
  end

  def edit
    authorize! :manage, @event
  end

  def update
    authorize! :manage, @event
    if @event.update(event_params)
      if current_user.has_role?(:admin)
        redirect_to admin_events_path
      else
        redirect_to admin_your_events_path
      end
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @event
    @event.destroy
    respond_to do |format|
      format.html { redirect_to admin_events_path }
    end
  end

  private

  def get_event
    @event = Event.friendly.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :address, :date, :sponsor_id, :slug)
  end

  def create_slug(event)
    slug_date = event.date.to_date.to_s.strip.downcase.tr(" ", "-").tr(",", "")
    slug_name = event.name.strip.downcase.tr(" ", "-").tr(",", "")
    "#{slug_date}-#{slug_name}"
  end
end
