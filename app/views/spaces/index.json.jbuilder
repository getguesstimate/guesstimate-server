json.array!(@spaces) do |space|
  json.extract! space, :id, :name, :description, :graph
  json.url space_url(space, format: :json)
end
