class PagesController < ApplicationController
  before_action :require_sign_in, only: :chart

  def home
    @posts = Post.all.where(featured: true).order("created_at desc")
    @comments = Comment.top_level.published.most_recent_first.take(6)
    @sponsors = [Sponsor.first, Sponsor.find_by(name: 'Treehouse')]
    @next_meetup = Meetup.in_upcoming_order.first
  end

  def chart
    hackroom_stats
    language_stats
    score_stats
    chatty_kathy_stats
  end

  private

  def hackroom_stats
    @hackrooms = []
    @hackroom_colours = []
    @hackroom_members = []
    Hackroom.all.in_popularity_order.each do |hackroom|
      @hackrooms << hackroom.name
      @hackroom_colours << hackroom.colour
      @hackroom_members << hackroom.users.size
    end
    gon.hackroom_names = @hackrooms
    gon.hackroom_colours = @hackroom_colours
    gon.hackroom_members = @hackroom_members
  end

  def language_stats
    @languages = []
    @language_colours = []
    @language_fans = []
    Language.all.in_popularity_order.each do |language|
      @languages << language.name
      @language_colours << language.colour
      @language_fans << language.all_users.size
    end
    gon.language_names = @languages
    gon.language_colours = @language_colours
    gon.language_fans = @language_fans
  end

  def score_stats
    @high_scorers = []
    @user_colours = []
    @user_points = []
    User.all.in_popularity_order.take(10).each do |user|
      @high_scorers << user.name
      @user_colours << user.colour
      @user_points << user.score
    end
    gon.high_scorers = @high_scorers
    gon.user_colours = @user_colours
    gon.user_points = @user_points
  end

  def chatty_kathy_stats
    @most_chatty = []
    @chatty_user_colours = []
    @user_comments = []
    User.all.in_popularity_order.take(10).each do |user|
      @most_chatty << user.name
      @chatty_user_colours << user.colour
      @user_comments << user.comments.published.size
    end
    gon.most_chatty = @most_chatty
    gon.chatty_user_colours = @chatty_user_colours
    gon.user_comments = @user_comments
  end
end
