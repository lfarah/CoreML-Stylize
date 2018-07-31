# Descrição para PR
warn "Insira uma descrição completa da sua PR" if bitbucket_cloud.pr_body.length < 30

# Reviewer para a PR
warn "Adicione no mínimo 2 revisores" if bitbucket_cloud.pr_json[:reviewers].length < 2

# Link para Podfile se este foi editado
warn "#{bitbucket_cloud.html_link("Podfile")} foi editado." if git.modified_files.include? "Podfile"

fail "MEH" if not bitbucket_cloud.pr_body.include? "asana.com"

# Swiftlint
# swiftlint.lint_files

