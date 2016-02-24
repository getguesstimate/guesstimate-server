class Plan
  def self.all
    return YAML.load_file("#{Rails.root}/config/plans.yml")['plans']
  end

  def self.as_enum
    enum = {}
    all.each do |plan|
      key = plan['name'].downcase.to_sym
      enum[key] = plan['enum_id']
    end
    return enum
  end
end
