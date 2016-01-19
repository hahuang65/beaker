Bureaucrat.start(default_path: 'lib/web/controllers/API_doc.md')
ExUnit.start(formatters: [ExUnit.CLIFormatter, Bureaucrat.Formatter])
TestApp.start_link()
