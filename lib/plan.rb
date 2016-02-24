class Plan
  def self.all
    return YAML.load_file("#{Rails.root}/config/plans.yml")['plans'].map{|plan| OpenStruct.new(plan)}
  end

  def self.as_enum
    enum = {}
    all.each do |plan|
      key = plan.id.downcase.to_sym
      enum[key] = plan.enum_id
    end
    return enum
  end

  def self.find(id)
    all.find{|e| e.id == id}
  end
end
