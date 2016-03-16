class AddCategoryCodeToSpreeTaxons < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :category_code, :integer
  end
end
