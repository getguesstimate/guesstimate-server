require 'roar/decorator'

class SpaceRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::JSON::HAL

  property :id
  property :name
  property :description
  property :created_at
  property :updated_at
  property :graph
  property :is_private
  property :user_id
  property :organization_id
  property :screenshot
  property :big_screenshot
  property :exported_facts_count
  property :imported_fact_ids
  property :shareable_link_token, if: ->(user_options:, **) { user_options[:current_user_can_edit] }
  property :shareable_link_enabled, if: ->(user_options:, **) { user_options[:current_user_can_edit] }

  property :user, class: User, embedded: true  do
    property :id
    property :username, as: "name"
    property :picture
  end

  property :organization, embedded: true, class: Organization do
    property :id
    property :admin_id
    property :name
    property :picture
    collection :facts,
      class: Fact,
      decorator: FactRepresenter,
      if: ->(user_options:, **) { user_options[:current_user_can_edit] }
  end

  collection :calculators, embedded: true, class: Calculator do
    property :id
    property :space_id
    property :title
    property :share_image
    property :content
    property :input_ids
    property :output_ids
  end
end
