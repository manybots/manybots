class Target < ActivityObject
  validates_presence_of :url_id

  def self.to_select
    [
      ['ARTICLE', 'http://activitystrea.ms/schema/1.0/article'],
      ['AUDIO', 'http://activitystrea.ms/schema/1.0/audio'],
      ['BOOKMARK', 'http://activitystrea.ms/schema/1.0/bookmark'],
      ['COMMENT', 'http://activitystrea.ms/schema/1.0/comment'],
      ['FILE', 'http://activitystrea.ms/schema/1.0/file'],
      ['FOLDER', 'http://activitystrea.ms/schema/1.0/folder'],
      ['GROUP', 'http://activitystrea.ms/schema/1.0/group'],
      ['LIST', 'http://activitystrea.ms/schema/1.0/list'],
      ['NOTE', 'http://activitystrea.ms/schema/1.0/note'],
      ['PERSON', 'http://activitystrea.ms/schema/1.0/person'],
      ['PHOTO', "http://activitystrea.ms/schema/1.0/photo"],
      ['PHOTO ALBUM', 'http://activitystrea.ms/schema/1.0/photo-album'],
      ['PLACE', 'http://activitystrea.ms/schema/1.0/place'],
      ['PLAYLIST', 'http://activitystrea.ms/schema/1.0/playlist'],
      ['PRODUCT', 'http://activitystrea.ms/schema/1.0/product'],
      ['REVIEW', 'http://activitystrea.ms/schema/1.0/review'],
      ['SERVICE', 'http://activitystrea.ms/schema/1.0/service'],
      ['STATUS', 'http://activitystrea.ms/schema/1.0/status'],
      ['VIDEO', 'http://activitystrea.ms/schema/1.0/video']
    ]
  end  
  
end
