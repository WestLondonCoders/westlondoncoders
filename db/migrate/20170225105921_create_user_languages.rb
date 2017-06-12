class CreateUserLanguages < ActiveRecord::Migration[4.2]
  def change
    create_table :user_languages do |t|
      t.references :user, null: false
      t.references :language, null: false
      t.timestamps null: false
    end
  end
end
