class AddInitialCluster < ActiveRecord::Migration
  def up
    id = insert("INSERT INTO clusters(name, created_at, updated_at) VALUES ('Main Cluster', NOW(), NOW())")
    execute("UPDATE communities SET cluster_id = #{id}")
  end
end
