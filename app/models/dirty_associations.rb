# app/models/dirty_associations.rb
module DirtyAssociations

  attr_accessor :dirty
  attr_accessor :_record_changes

  def make_dirty(record)
    self.dirty = true
    self._record_changes = record
  end
  
  # saved_changes? ---> DEPRECATION WARNING
  # This is tigerring all kinds of other deprectation warnings too, not sure yet what to do
  def changed?
    dirty || super
  end
end
