# app/models/dirty_associations.rb
module DirtyAssociations

  attr_accessor :dirty
  attr_accessor :_record_changes

  def make_dirty(record)
    self.dirty = true
    self._record_changes = record
  end

  def changed?
    dirty || super
  end
end
