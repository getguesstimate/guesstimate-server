DISALLOWED_WORDS = [
  "my", "to", "in", "at", "or", "of", "is", "be", "as", "at", "so", "we", "he", "by", "on", "do", "if", "me", "up",
  "an", "go", "no", "us", "am", "foo", "foobar", "bar", "and", "one", "two", "three", "four", "five", "six", "seven",
  "eight", "nine", "ten", "ha"
]

module FakeNames
  def self.is_fake(name)
    return true if name.nil? or name.empty?

    name.downcase!
    name.strip!

    allowed_words = []

    words = name.scan(/[a-zA-Z]+/) { |word|
      allowed_words.push word unless
        word.include? 'test' or
        word.include? 'bla' or
        word.include? 'sdf' or
        word.bytes.uniq.length == 1 or
        DISALLOWED_WORDS.include? word
    }

    allowed_words.empty?
  end

  def self.is_real(name)
    !FakeNames.is_fake(name)
  end

  def has_real_name?
    !FakeNames.is_fake(name)
  end

  def has_fake_name?
    FakeNames.is_fake(name)
  end
end
