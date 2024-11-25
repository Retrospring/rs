# frozen_string_literal: true

require "rails_helper"

describe ThemeHelper, type: :helper do

  describe "#get_hex_color_from_theme_value" do
    it "returns the proper hex value from the decimal value for white" do
      expect(helper.get_hex_color_from_theme_value(16777215)).to eq("ffffff")
    end

    it "returns the proper hex value from the decimal value for purple" do
      expect(helper.get_hex_color_from_theme_value(6174129)).to eq("5e35b1")
    end

    it "returns the proper hex value from the decimal value for blue" do
      expect(helper.get_hex_color_from_theme_value(255)).to eq("0000ff")
    end
  end

  describe "#get_decimal_triplet_from_hex" do
    it "returns the proper decimal triplet from a hex value" do
      expect(helper.get_decimal_triplet_from_hex("5e35b1")).to eq("94, 53, 177")
    end
  end

  describe "#active_theme_user" do
    context "when user is a guest" do
      context "when target page doesn't have a theme" do
        it "returns no user" do
          expect(helper.active_theme_user).to be_nil
        end
      end

      context "when target page has a theme" do
        before(:each) do
          @user = FactoryBot.create(:user)
          @user.theme = Theme.new
          @user.save!
        end

        it "returns a theme" do
          expect(helper.active_theme_user).to be_a(User)
        end
      end

      context "when target answer's user has a theme" do
        before(:each) do
          @answer = FactoryBot.create(:answer, user: FactoryBot.create(:user))
          @answer.user.theme = Theme.new
          @answer.user.save!
        end

        it "returns a user" do
          expect(helper.active_theme_user).to be_a(User)
        end
      end
    end

    context "when user is signed in" do
      let(:user) { FactoryBot.create(:user) }

      before(:each) { sign_in(user) }

      context "when user has no theme" do
        context "when target page has a corresponding user" do
          let(:theme) { Theme.new }

          before(:each) do
            @user = FactoryBot.create(:user)
            @user.theme = theme
            @user.save!
          end

          it "returns a theme" do
            expect(helper.active_theme_user).to be(@user)
          end
        end

        context "when target page has contains an answer" do
          let(:theme) { Theme.new }

          before(:each) do
            @answer = FactoryBot.create(:answer, user: FactoryBot.create(:user))
            @answer.user.theme = theme
            @answer.user.save!
          end

          it "returns a theme" do
            expect(helper.active_theme_user).to be(@answer.user)
          end
        end
      end

      context "when user has a theme" do
        let(:theme) { Theme.new }

        before(:each) do
          user.theme = theme
          user.show_foreign_themes = true
          user.save!
        end

        context "when target page has no theme" do
          it "returns the theme of the current user" do
            expect(helper.active_theme_user).to eq(user)
          end
        end

        context "when target page has a theme" do
          let(:user_theme) { Theme.new }

          before(:each) do
            @user = FactoryBot.create(:user)
            @user.theme = user_theme
            @user.save!
          end

          it "returns the theme of the current page" do
            expect(helper.active_theme_user).to eq(@user)
          end

          context "when user doesn't allow foreign themes" do
            before(:each) do
              user.show_foreign_themes = false
              user.save!
            end

            it "should return the users theme" do
              expect(helper.active_theme_user).to eq(user)
            end
          end
        end

        context "when target answer's user has a theme" do
          let(:answer_theme) { Theme.new }

          before(:each) do
            @answer = FactoryBot.create(:answer, user: FactoryBot.create(:user))
            @answer.user.theme = answer_theme
            @answer.user.save!
          end

          it "returns the theme of the current page" do
            expect(helper.active_theme_user).to eq(@answer.user)
          end

          context "when user doesn't allow foreign themes" do
            before(:each) do
              user.show_foreign_themes = false
              user.save!
            end

            it "should return the users theme" do
              expect(helper.active_theme_user).to eq(user)
            end
          end
        end
      end
    end
  end

  describe "#theme_color" do
    subject { helper.theme_color }

    context "when user is signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:theme) { FactoryBot.create(:theme, user:) }

      before(:each) do
        user.theme = theme
        user.save!
        sign_in(user)
      end

      it "should return the user theme's primary color" do
        expect(subject).to eq("#8e8cd8")
      end
    end

    context "user is not signed in" do
      it "should return the default primary color" do
        expect(subject).to eq("#5e35b1")
      end
    end
  end

  describe "#mobile_theme_color" do
    subject { helper.mobile_theme_color }

    context "when user is signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:theme) { FactoryBot.create(:theme, user:) }

      before(:each) do
        user.theme = theme
        user.save!
        sign_in(user)
      end

      it "should return the user theme's background color" do
        expect(subject).to eq("#c6c5eb")
      end
    end

    context "user is not signed in" do
      it "should return the default background color" do
        expect(subject).to eq("#f0edf4")
      end
    end
  end

  describe "#get_color_for_key" do
    context "any key and value are supplied" do
      subject { helper.get_color_for_key("primary", 6174129) }

      it "returns a hex color code" do
        expect(subject).to eq("#5e35b1")
      end
    end

    context "a text key is supplied" do
      subject { helper.get_color_for_key("primary-text", 6174129) }

      it "returns RGB triplets" do
        expect(subject).to eq("94, 53, 177")
      end
    end
  end
end
