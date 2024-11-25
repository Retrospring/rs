# frozen_string_literal: true

class UserController < ApplicationController
  include ThemeHelper
  include PaginatesAnswers

  before_action :set_user, except: :show_theme
  before_action :hidden_social_graph_redirect, only: %i[followers followings]
  after_action :mark_notification_as_read, only: %i[show]

  def show
    return show_theme if params[:format] == "css"

    @pinned_answers = @user.answers.for_user(current_user).pinned.includes([{ user: :profile }, :question]).order(pinned_at: :desc).limit(10).load_async
    paginate_answers { |args| @user.cursored_answers(current_user_id: current_user, **args) }

    respond_to do |format|
      format.html
      format.turbo_stream { render layout: false }
    end
  end

  def show_theme
    theme = Theme.where(user: User.where("LOWER(screen_name) = ?", params[:username].downcase).select(:id)).first
    return head :no_content unless theme

    expires_in 3.months
    return if fresh_when theme, public: true

    render plain: get_theme_css(theme), content_type: "text/css"
  end

  def followers
    paginate_relationships(:cursored_follower_relationships)
    @users = @relationships.map(&:source)
    own_relationships = find_own_relationships
    locals = {
      type:           :follower,
      own_followings: own_relationships[Relationships::Follow],
      own_blocks:     own_relationships[Relationships::Block],
      own_mutes:      own_relationships[Relationships::Mute]
    }

    respond_to do |format|
      format.html { render "show_follow", locals: }
      format.turbo_stream { render "show_follow", locals: }
    end
  end

  def followings
    paginate_relationships(:cursored_following_relationships)
    @users = @relationships.map(&:target)
    own_relationships = find_own_relationships
    locals = {
      type:           :friend,
      own_followings: own_relationships[Relationships::Follow],
      own_blocks:     own_relationships[Relationships::Block],
      own_mutes:      own_relationships[Relationships::Mute]
    }

    respond_to do |format|
      format.html { render "show_follow", locals: }
      format.turbo_stream { render "show_follow", locals: }
    end
  end

  def questions
    @questions = @user.cursored_questions(author_is_anonymous: false, direct: direct_param, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, direct: direct_param, last_id: @questions_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def mark_notification_as_read
    return unless user_signed_in?

    Notification
      .where(
        target_type:  "Relationship",
        target_id:    @user.active_follow_relationships.where(target_id: current_user.id).pluck(:id),
        recipient_id: current_user.id,
        new:          true
      ).update(new: false)
  end

  def set_user
    @user = User.where("LOWER(screen_name) = ?", params[:username].downcase).includes(:profile).first!
  end

  def find_own_relationships
    return {} unless user_signed_in?

    Relationship.where(source: current_user, target_id: @users.map(&:id))
      &.select(:target_id, :type)
      &.group_by(&:type)
  end

  def paginate_relationships(method)
    @relationships = @user.public_send(method, last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.public_send(method, last_id: @relationships_last_id, size: 1).count.zero?
  end

  def hidden_social_graph_redirect
    return if belongs_to_current_user? || !@user.privacy_hide_social_graph

    redirect_to user_path(@user)
  end

  def direct_param
    # return `nil` instead of `false` so we retrieve all questions for the user, direct or not.
    # `cursored_questions` will then remove the `direct` field from the WHERE query.  otherwise the query filters
    # for `WHERE direct = false` ...
    return if belongs_to_current_user? || moderation_view?

    # page is not being viewed by the current user, and we're not in the moderation view -> only show public questions
    false
  end

  def belongs_to_current_user? = @user == current_user
end
