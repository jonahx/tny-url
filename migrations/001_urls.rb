require 'sequel'

Sequel.migration do

  up do
    create_table(:urls, :engine => :InnoDB) do
      primary_key :id
      String :full_url, :null=>false 
      String :short_name, :null=>false, unique: true
      String :owners_secret, :null=>false 
      DateTime :created_on, :null=>false, :default=>Sequel::CURRENT_TIMESTAMP
      DateTime :deleted_on
    end
  end

  down do
    drop_table(:urls)
  end
end
