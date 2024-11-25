# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) do
    FactoryBot.create :user,
                      otp_module:     :disabled,
                      otp_secret_key: "EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3"
  end

  shared_examples_for "social graph hidden" do
    context "user has social graph hidden" do
      before(:each) do
        user.update(privacy_hide_social_graph: true)
      end

      it "shows the followers template to the current user" do
        sign_in user
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end

      it "redirects to the user profile page if not logged in" do
        subject
        expect(response).to redirect_to(user_path(user))
      end

      it "redirects to the user profile page if logged in as a different user" do
        sign_in FactoryBot.create(:user)
        subject
        expect(response).to redirect_to(user_path(user))
      end
    end
  end

  describe "#show" do
    subject { get :show, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show")
      end
    end

    context "user opts out of search indexing" do
      render_views

      before(:each) do
        sign_in user
        user.privacy_noindex = true
        user.save
      end

      it "renders the answer/show template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response.body).to include("<meta content='noindex' name='robots'>")
      end
    end
  end

  describe "#show_theme" do
    subject { get :show, params: { username: user.screen_name }, format: :css }

    context "user does not have a theme set" do
      it "returns no content" do
        expect(subject).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context "user has theme" do
      let!(:theme) { FactoryBot.create(:theme, user:) }

      it "returns theme CSS" do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(<<~CSS.chomp)
:root {
	--primary: #8e8cd8;
	--primary-rgb: 142, 140, 216;
	--primary-text: 255, 255, 255;
	--danger: #d98b8b;
	--danger-text: 255, 255, 255;
	--success: #bfd98b;
	--success-text: 255, 255, 255;
	--warning: #d99e8b;
	--warning-text: 255, 255, 255;
	--info: #8bd9d9;
	--info-text: 255, 255, 255;
	--dark: #666666;
	--dark-text: 238, 238, 238;
	--raised-bg: #ffffff;
	--raised-bg-rgb: 255, 255, 255;
	--background: #c6c5eb;
	--body-text: 51, 51, 51;
	--muted-text: 51, 51, 51;
	--input-bg: #f0edf4;
	--input-text: 102, 102, 102;
	--raised-accent: #f7f7f7;
	--raised-accent-rgb: 247, 247, 247;
	--light: #f8f9fa;
	--light-text: 0, 0, 0;
	--input-placeholder: 108, 117, 125;
	--raised-text: 51, 51, 51;
	--raised-accent-text: 51, 51, 51;
	--turbolinks-progress-color: #ceccff
}
        CSS
      end
    end
  end

  describe "#followers" do
    subject { get :followers, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end

    include_examples "social graph hidden"
  end

  describe "#followings" do
    subject { get :followings, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end

    include_examples "social graph hidden"
  end

  describe "#questions" do
    let!(:question_anyone) { FactoryBot.create(:question, user:, direct: false, author_is_anonymous: false) }
    let!(:question_direct) { FactoryBot.create(:question, user:, direct: true, author_is_anonymous: false) }
    let!(:question_direct_anon) { FactoryBot.create(:question, user:, direct: true, author_is_anonymous: true) }

    subject { get :questions, params: { username: user.screen_name } }

    it "renders the user/questions template" do
      subject
      expect(assigns(:user)).to eq(user)
      expect(response).to render_template("user/questions")
    end

    context "when the current user is the question author" do
      before do
        sign_in user
      end

      it "contains all non-anon questions" do
        subject
        expect(assigns(:questions)).to include(question_anyone, question_direct)
        expect(assigns(:questions)).not_to include(question_direct_anon)
        expect(assigns(:questions).size).to eq(2)
      end
    end

    context "when the current user is someone else" do
      let(:another_user) { FactoryBot.create :user }

      before do
        sign_in another_user
      end

      it "contains all non-direct non-anon questions" do
        subject
        expect(assigns(:questions)).to include(question_anyone)
        expect(assigns(:questions)).not_to include(question_direct, question_direct_anon)
        expect(assigns(:questions).size).to eq(1)
      end
    end

    context "when a moderator uses unmask" do
      let(:another_user) { FactoryBot.create :user, roles: ["moderator"] }

      before do
        sign_in another_user
        allow_any_instance_of(UserHelper).to receive(:moderation_view?) { true }
      end

      it "contains all non-anon questions" do
        subject
        expect(assigns(:questions)).to include(question_anyone, question_direct)
        expect(assigns(:questions)).not_to include(question_direct_anon)
        expect(assigns(:questions).size).to eq(2)
      end
    end

    context "when user is not signed in" do
      it "contains all non-direct non-anon questions" do
        subject
        expect(assigns(:questions)).to include(question_anyone)
        expect(assigns(:questions)).not_to include(question_direct, question_direct_anon)
        expect(assigns(:questions).size).to eq(1)
      end
    end
  end
end
