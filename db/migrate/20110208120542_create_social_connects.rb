class CreateSocialConnects < ActiveRecord::Migration
  def self.up
    create_table "social_accounts" do |t|
      t.string   "provider"
      t.string   "uid"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table 'social_accounts' 
  end
end
