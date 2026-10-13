# frozen_string_literal: true

module Sw
  # The supertype of every domain object. Data classes can't share a superclass that holds members, so this is a
  # module, and each class lists :url among its own.
  module DomainObject
    # The API's URL tells a reload which object is which, since a reload builds every object anew. Only another
    # object of the same kind may read it: objects link to each other directly, never by an ID.
    def self.included(domain_class) = domain_class.class_eval { protected :url }

    def same_as?(other) = other.is_a?(self.class) && url == other.url

    # Data's own inspect follows every link through a cyclic graph, so a failing test would print the whole galaxy.
    # Every kind's first member names it.
    def inspect = "#<#{self.class} #{public_send(self.class.members.first)}>"
  end
end
