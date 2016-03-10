DISALLOWED_SUB_WORDS = [
  "test", # For any deviation of "test".
  "bla", # For any deviation of "blah", "blabla", "blahblah", etc.
  "sdf" # For any deviation of "asdf", "sdf", etc.
]
DISALLOWED_WORDS = [
  "my", "to", "in", "at", "or", "of", "is", "be", "as", "at", "so", "we", "he", "by", "on", "do", "if", "me", "up",
  "an", "go", "no", "us", "am", "foo", "foobar", "bar", "and", "one", "two", "three", "four", "five", "six", "seven",
  "eight", "nine", "ten", "ha", "fake"
]

module FakeNameDetector
  def self.seems_fake(name)
    return true if name.blank?

    name.downcase!
    name.strip!

    allowed_words = []

    words = name.scan(/[a-zA-Z]+/) { |word|
      allowed_words.push word unless
        word.bytes.uniq.length == 1 ||
        DISALLOWED_SUB_WORDS.any? { |disallowed_word| word.include? disallowed_word }
        DISALLOWED_WORDS.include? word
    }

    allowed_words.empty?
  end

  def self.seems_real(name)
    !FakeNameDetector.seems_fake(name)
  end

  def has_real_name?
    FakeNameDetector.seems_real(name)
  end

  def has_fake_name?
    FakeNameDetector.seems_fake(name)
  end
end
