json.array!(@users) do |user|
  json.extract! user, :id, :name, :picture, :auth0_id
end
