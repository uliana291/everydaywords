class AddPublicToContextText < ActiveRecord::Migration
  def change
    add_column :context_texts, :is_public, :bool
  end
end
