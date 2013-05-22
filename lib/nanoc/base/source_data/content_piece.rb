# encoding: utf-8

module Nanoc

  # Has content, attributes and an identifier.
  class ContentPiece

    # @return [String]
    attr_accessor :identifier

    # @return [Nanoc::Content] This content piece's raw content
    attr_reader :content

    # @return [Hash]
    attr_accessor :attributes

    # @return [Nanoc::Site] The site this content piece belongs to
    attr_accessor :site

    # Creates a new content piece with the given content, attributes and
    # identifier.
    #
    # @param [Nanoc::Content] content The uncompiled content
    #
    # @param [Hash] attributes
    #
    # @param [String] identifier This content piece's identifier.
    def initialize(content, attributes, identifier)
      # Content
      if content.nil?
        raise ArgumentError, "attempted to create a #{self.class} with no content/filename (identifier #{@identifier})"
      elsif content.is_a?(Nanoc::TextualContent)
        @content = content
      else
        @content = Nanoc::TextualContent.new(content.to_s, nil)
      end

      # Attributes
      @attributes = attributes.symbolize_keys_recursively

      # Identifier
      if identifier.is_a?(Nanoc::Identifier)
        @identifier = identifier
      else
        @identifier = Nanoc::Identifier.from_string(identifier.to_s)
      end
    end

    def binary?
      self.content.binary?
    end

    # Requests the attribute with the given key.
    #
    # @param [Symbol] key The name of the attribute to fetch
    #
    # @return [Object] The value of the requested attribute
    def [](key)
      Nanoc::NotificationCenter.post(:visit_started, self)
      Nanoc::NotificationCenter.post(:visit_ended,   self)

      @attributes[key]
    end

    # Sets the attribute with the given key to the given value.
    #
    # @param [Symbol] key The name of the attribute to set
    #
    # @param [Object] value The value of the attribute to set
    def []=(key, value)
      @attributes[key] = value
    end

    # @return [Symbol] the type of this object as a symbol (`:item`, `:layout`, ...)
    #
    # @api private
    #
    # @abstract
    def type
      raise NotImplementedError
    end

    # Returns an object that can be used for uniquely identifying objects.
    #
    # @api private
    #
    # @return [Object] An unique reference to this object
    def reference
      [ type, self.identifier ]
    end

    # @see Object#freeze
    def freeze
      attributes.freeze_recursively
      identifier.freeze
      content.freeze
    end

    # @see Object#inspect
    def inspect
      "<#{self.class} identifier=#{self.identifier.inspect}>"
    end

    # @see Object#hash
    def hash
      self.class.hash ^ self.identifier.hash
    end

    # @see Object#eql?
    def eql?(other)
      self.class == other.class && self.identifier == other.identifier
    end

    # @see Object#==
    def ==(other)
      self.eql?(other)
    end

  end

end
