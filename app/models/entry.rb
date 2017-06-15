class Entry < ActiveRecord::Base

    belongs_to :author, class_name:"User", foreign_key: "user_id"
    STATUS_VALUES = %w(draft user_only public)
    
    validates :title, presence: true, length: {maximum: 200}
    # validates :body, posted_at, presence: true
    validates :status, inclusion: { in:STATUS_VALUES }
    
    scope :common, -> { where(status:"public") }
    scope :published, -> { where("status <> ?","draft")}
    scope :full, -> (user) {
        where("status <> ? OR user_id = ?", "draft", user.id) }
    scope :readable_for, ->(user) { user ? full(user) : common }
    
    
   
    
    class << self
        def status_text(status)
            I18n.t("activerecord.attributes.entry.status_#{status}")
        end
        def status_options
            STATUS_VALUES.map { |status| [status_text(status), status] }
        end
        
        def sidebar_entries(user, num = 5)
            
            readable_for(user).order(posted_at::desc).limit(num)
        end
    end
    
     mount_uploader :image, ImageUploader
end
