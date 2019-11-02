class Task < ApplicationRecord
    has_one_attached :image
    
    def self.ransack_attributes(auth_object = nil)
      %w[name created_at]
    end
    
    def self.ransack_associations(path_object = nil)
      []
    end
    before_validation :set_nameless_name
    validates :name, presence: true
    validates :name, length: { maximum: 30 }
    validate :validate_name_not_including_comma
    
    belongs_to :user
    
    scope :recent, -> { order(created_at: :desc)}
    
    def self.csv_attibutes
      ["name", "description", "created_at", "updated_at"]
    end
    
    def self.generate_csv
      CSV.generate(headers: true) do |csv|
        csv << csv_attibutes
        all.each do |task|
          csv << csv_attibutes.map{|attr| task.send(attr)}
        end
      end
    end
    
    def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
        task = new
        task.attributes = rows.to_hash.slice(*csv_attibutes)
        task.save!
      end
    end  
  

    private
    
    def set_nameless_name
      self.name = '名前なし' if name.blank?
    end
    
end
