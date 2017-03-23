class RouteInstance < ActiveRecord::Base

  belongs_to :route, :class_name => :Route
  belongs_to :instance, :class_name => :Route

  scope :is_modified, -> {where(:modified => true)}
  scope :is_complete, -> {where(:complete => true)}
  scope :is_cancelled, -> {where(:cancelled => true)}
  scope :is_late, -> {where(:late => true)}

end
