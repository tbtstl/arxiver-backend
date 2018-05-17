class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :abstract
      t.string :pdf
      t.string :arxiv_url

      t.timestamps
    end
  end
end
