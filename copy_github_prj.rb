require 'octokit'

client = Octokit::Client.new(access_token: 'githubのアクセストークン')

base_project_name = 'コピー元のプロジェクト名'
new_project_name = 'コピー先のプロジェクト名'
base_project = nil

10.times do |i|
  # 'y-mitsuyoshi/copy_github_project'は移したいprojectのあるリポジトリ
  projects = client.projects('y-mitsuyoshi/copy_github_project', per_page: 100, page: i + 1)
  break if projects == []

  projects.each do |project|
    if project.name == base_project_name
      base_project = project
      break
    end
  end
  break unless base_project.nil?
end

project_id = base_project.id

new_project = client.create_project('y-mitsuyoshi/copy_github_project', new_project_name)

base_project_columns = client.project_columns(project_id)
base_project_columns.each_with_index do |project_column, i|
  new_project_column = client.create_project_column(new_project.id, project_column.name)
  break if i == (base_project_columns.size - 1)

  client.column_cards(project_column.id).reverse.each do |card|
    content_id = card.content_url.sub('https://api.github.com/repos/y-mitsuyoshi/copy_github_project/issues/', '').to_i
    client.create_project_card(new_project_column.id, content_id: content_id, content_type: 'Issue')
    client.delete_project_card(card.id)
  end
end
