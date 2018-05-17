class CreateJoinTableSubjectPublication < ActiveRecord::Migration[5.2]
  def change
    create_join_table :subjects, :publications do |t|
      t.index [:subject_id, :publication_id]
    end
  end
end
