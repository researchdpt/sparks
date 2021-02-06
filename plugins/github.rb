require 'github_api'

module URL
    class GitHubAPI
        include Cinch::Plugin

        def self.required_config
            ["settings:GitHub:key", "settings:GitHub:secret"]
        end

        def self.regex
            Regexp.union(%r{http(?:s)?:\/\/(?:www\.)?github.com\/([^ /?]+)(?:\/)?([^ /?]+)?(?:\/)?(?:(issues|pulls|commit)\/([^ ?\#\/]+))?}, %r{https?:\/\/gist.github.com\/([^ ?&/]+)\/([^ ?&/]+)})
        end

        set :help, <<-EOF
[\x0307Help\x03] GitHub - This module supports URL parsing for repositories, users, issues, commits and pulls.
        EOF

        match %r{http(?:s)?:\/\/(?:www\.)?github.com\/([^ /?]+)(?:\/)?([^ /?]+)?(?:\/)?(?:(issues|pulls|commit)\/([^ ?\#\/]+))?}, use_prefix: false, method: :github_select
        match %r{https?:\/\/gist.github.com\/([^ ?&/]+)\/([^ ?&/]+)}, use_prefix: false, method: :github_gist
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.api_dict.get "github"
                Helpers.api_dict.add "github", Github.new do |c|
                    c.client_id = Helpers.config.get("settings:GitHub:key")
                    c.client_secret = Helpers.config.get("settings:GitHub:key")
                end
            end
        end

        def github_select(m, user_name, repo_name, subquery, id)
            if repo_name.nil?
                github_user(m, user_name)
            else
                if subquery.nil?
                    github_repo(m, user_name, repo_name)    
                else
                    if subquery == "issues"
                        github_issue(m, user_name, repo_name, id)
                    elsif subquery == "pull"
                        github_pull(m, user_name, repo_name, id)
                    elsif subquery == "commit"
                        github_commit(m, user_name, repo_name, id)
                    end
                end
            end
        end

        def github_user(m, user_name)
            user = Github.users.get user: user_name
            
            if user.location != ""
                location = " - Location: #{user.location}"
            else
                location = ""
            end
            if user.bio != ""
                bio = " - \"#{user.bio}\""
            else
                bio = ""
            end
            
            m.reply "[GitHub/User] #{user.name} (#{user.login})#{location} #{bio} - Repos: #{user.public_repos} - Gists: #{user.public_gists}"
        end

        def github_repo(m, user_name, repo_name)
            repo = Github.repos.get user: user_name, repo: repo_name
            m.reply "[GitHub/Repo] #{repo.full_name} - \"#{repo.description}\" - Last Commit: #{Time.parse(repo.pushed_at).strftime("%F %R")} - ↻#{repo.forks_count} ⭐#{repo.stargazers_count} - ⚠️#{repo.open_issues_count}"
        end

        def github_issue(m, user_name, repo_name, id)
            issue = Github.issues.get user_name, repo_name, id

            if issue.assignees.count > 1
                assignees = " - Assignees: #{issue.assignees.map {|assignee| assignee.login}.join(", ")}"
            elsif issue.assignees.count == 1
                assignees = " - Assignee: #{issue.assignees.map {|assignee| assignee.login}.join(", ")}"
            end

            if Time.parse(issue.updated_at) != Time.parse(issue.created_at)
                time = "Created at: #{Time.parse(issue.created_at).strftime("%F %R")} - Updated at: #{Time.parse(issue.updated_at).strftime("%F %R")}"
            else
                time = "Created at: #{Time.parse(issue.created_at).strftime("%F %R")}"
            end

            m.reply "[GitHub/Issue] #{user_name}/#{repo_name} - \"#{issue.title}\" by #{issue.user.login} - #{time} - State: #{issue.state == "open" ? "\x0303Open\x03" : "\x0304Closed\x03"} & #{issue.locked ? "\x0304Locked\x03" : "\x0303Unlocked\x03"}#{assignees}"
        end

        def github_pull(m, user_name, repo_name, id)
            pull = Github.pull_requests.get user_name, repo_name, id

            if Time.parse(pull.updated_at) != Time.parse(pull.created_at)
                time = "Created at: #{Time.parse(pull.created_at).strftime("%F %R")} - Updated at: #{Time.parse(pull.updated_at).strftime("%F %R")}"
            else
                time = "Created at: #{Time.parse(pull.created_at).strftime("%F %R")}"
            end
            
            m.reply "[GitHub/Pull] #{user_name}/#{repo_name} - \"#{pull.title}\" by #{pull.user.login} - #{time} - State: #{pull.state == "open" ? "\x0303Open\x03" : "\x0304Closed\x03"} & #{pull.locked ? "\x0304Locked\x03" : "\x0303Unlocked\x03"}#{assignees}"                            
        end

        def github_commit(m, user_name, repo_name, id)
            commit = Github.repos.commits.get user: user_name, repo: repo_name, sha: id
            m.reply "[GitHub/Commit] \"#{commit.commit.message}\" by #{commit.commit.committer.name} (#{commit.committer.login}) - Committed: #{Time.parse(commit.commit.committer.date).strftime("%F %R")} - #{commit.stats.total} (\x0303+#{commit.stats.additions}\x03/\x0304-#{commit.stats.deletions}\x03) - #{commit.commit.verification.verified ? "\x0303Signed\x03" : "\x0304Unsigned\x03"}"
        end

        def github_gist(m, user_name, gist_id)
            gist = Github::Client.get id: gist_id

            if gist.description != ""
                description = " - \"#{gist.description}\""
            end

            m.reply "[GitHub/Gist] #{gist.owner.login}/#{gist.files.to_hash.values[0]["filename"]}#{description} - Last Update: #{Time.parse(gist.updated_at).strftime("%F %R")} - \"#{gist.files.to_hash.values[0]["content"]}\""
        end
    end
end