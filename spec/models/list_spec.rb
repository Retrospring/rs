# frozen_string_literal: true

require "rails_helper"

RSpec.describe(List, type: :model) do
  let(:user) { FactoryBot.create(:user) }

  describe "name mangling" do
    subject do
      List.new(user:, display_name:).tap(&:validate)
    end

    {
      "great list"          => "great-list",
      "followers"           => "-followers-",
      "  followers  "       => "-followers-",
      "  the game  \t\nyes" => "the-game-yes",

      # not nice, but this is just the way it is:
      "\u{1f98a} :3"        => "3",
      "\u{1f98a}"           => "",
    }.each do |display_name, expected_name|
      context "when display name is #{display_name.inspect}" do
        let(:display_name) { display_name }

        its(:name) { should eq expected_name }
      end
    end
  end

  describe "validations" do
    subject do
      List.new(user:, display_name:).validate
    end

    context "when display name is 'great list' (valid)" do
      let(:display_name) { "great list" }

      it { is_expected.to be true }
    end

    context "when display name is '1' (valid)" do
      let(:display_name) { "1" }

      it { is_expected.to be true }
    end

    context "when display name is the letter E 621 times (invalid, too long)" do
      let(:display_name) { "E" * 621 }

      it { is_expected.to be false }
    end

    context "when display name is an empty string (invalid, as `name` would be empty)" do
      let(:display_name) { "" }

      it { is_expected.to be false }
    end

    context "when display name is \u{1f98a} (invalid, as `name` would be empty)" do
      let(:display_name) { "\u{1f98a}" }

      it { is_expected.to be false }
    end
  end

  describe "#timeline" do
    let(:list) { List.create(user:, display_name: "test list") }
    let(:user1) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user) }

    let(:blocked_user) { FactoryBot.create(:user) }
    let(:muted_user) { FactoryBot.create(:user) }
    let!(:answer_to_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a true anonymous coward",
        question: FactoryBot.create(
          :question,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_to_normal_user) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a normal user",
        question: FactoryBot.create(
          :question,
          user:                user1,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_normal_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a cowardly user",
        question: FactoryBot.create(
          :question,
          user:                user1,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_from_blocked_user) do
      FactoryBot.create(
        :answer,
        user:     blocked_user,
        content:  "answer from a blocked user",
        question: FactoryBot.create(:question)
      )
    end
    let!(:answer_to_blocked_user) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a blocked user",
        question: FactoryBot.create(
          :question,
          user:                blocked_user,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_blocked_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a blocked user who's a coward",
        question: FactoryBot.create(
          :question,
          user:                blocked_user,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_from_muted_user) do
      FactoryBot.create(
        :answer,
        user:     muted_user,
        content:  "answer from a muted user",
        question: FactoryBot.create(:question)
      )
    end
    let!(:answer_to_muted_user) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a muted user",
        question: FactoryBot.create(
          :question,
          user:                muted_user,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_muted_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a muted user who's a coward",
        question: FactoryBot.create(
          :question,
          user:                muted_user,
          author_is_anonymous: true
        )
      )
    end

    before do
      list.add_member user1
      list.add_member user2
      list.add_member blocked_user
      list.add_member muted_user

      # block it here already, to test behaviour without a `current_user` passed in
      user.block blocked_user
      user.mute muted_user
    end

    subject { list.timeline }

    it "includes all answers to questions from users in the list" do
      expect(subject).to include(answer_to_anonymous)
      expect(subject).to include(answer_to_normal_user)
      expect(subject).to include(answer_to_normal_user_anonymous)
      expect(subject).to include(answer_to_blocked_user_anonymous)
      expect(subject).to include(answer_to_muted_user_anonymous)
      expect(subject).to include(answer_to_blocked_user)
      expect(subject).to include(answer_to_muted_user)
      expect(subject).to include(answer_from_blocked_user)
      expect(subject).to include(answer_from_muted_user)
    end

    context "when given a current user who blocks and mutes some users" do
      subject { list.timeline current_user: user }

      it "only includes answers to questions from users the user doesn't block or mute" do
        expect(subject).to include(answer_to_anonymous)
        expect(subject).to include(answer_to_normal_user)
        expect(subject).to include(answer_to_normal_user_anonymous)
        expect(subject).to include(answer_to_blocked_user_anonymous)
        expect(subject).to include(answer_to_muted_user_anonymous)
        expect(subject).not_to include(answer_to_blocked_user)
        expect(subject).not_to include(answer_from_blocked_user)
        expect(subject).not_to include(answer_to_muted_user)
        expect(subject).not_to include(answer_from_muted_user)
      end
    end
  end
end
