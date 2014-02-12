class AddStoreAndCategoriesToSku < ActiveRecord::Migration
  def change
    add_column :skus, :store, :string
    add_column :skus, :categories, :string
  end
end
