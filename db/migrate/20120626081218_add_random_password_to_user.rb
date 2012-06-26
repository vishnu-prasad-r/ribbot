class AddRandomPasswordToUser < Mongoid::Migration
  def self.up
    User.where(:random_password => nil).update_all(:random_password => false)
  end

  def self.down
  end
end
