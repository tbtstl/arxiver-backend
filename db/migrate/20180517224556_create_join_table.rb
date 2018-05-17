class CreateJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :publications, :authors do |t|
      t.index [:publication_id, :author_id]
    end
  end
end
