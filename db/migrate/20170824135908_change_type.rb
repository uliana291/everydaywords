class ChangeType < ActiveRecord::Migration
  change_table :frequencies do |t|
    t.change :language, :string
  end
end
