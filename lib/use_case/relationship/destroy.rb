# frozen_string_literal: true

require "use_case/base"
require "errors"

module UseCase
  module Relationship
    class Destroy < UseCase::Base
      option :source_user, type: Types::Strict::String | Types.Instance(::User)
      option :target_user, type: Types::Strict::String | Types.Instance(::User)
      option :type, type: Types::RelationshipTypes

      def call
        source_user = find_source_user
        target_user = find_target_user

        source_user.public_send("un#{type}", target_user)

        {
          status:   204,
          resource: nil,
          extra:    {
            target_user: target_user
          }
        }
      end

      private

      def find_source_user
        return source_user if source_user.is_a?(::User)

        ::User.find_by!(screen_name: source_user)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end

      def find_target_user
        return target_user if target_user.is_a?(::User)

        ::User.find_by!(screen_name: target_user)
      rescue ActiveRecord::RecordNotFound
        raise Errors::UserNotFound
      end
    end
  end
end
